# Research Findings: LearnFlow - AI-Powered Python Tutoring Platform

**Feature Branch**: `004-learnflow-application`
**Date**: 2025-12-22
**Status**: Complete

## Overview

This document provides research findings and technical decisions for all 10 research tasks identified in the implementation plan. Each section includes the decision made, rationale, alternatives considered, and implementation notes to guide the development of LearnFlow.

---

## Research Task 1: AI Agent Architecture Patterns

**Question**: Evaluate monolithic vs. 6 microservices tradeoff for AI agent implementation.

### Decision

**Hybrid Architecture**: Deploy 6 specialized AI agent microservices with shared infrastructure components.

**Services**:
1. `triage-agent-service` (routing queries)
2. `concepts-agent-service` (explanations)
3. `code-review-agent-service` (quality analysis)
4. `debug-agent-service` (error diagnostics)
5. `exercise-agent-service` (practice generation)
6. `progress-agent-service` (learning analytics)

### Rationale

- **Independent Scaling**: Code Review and Debug agents handle heavy traffic during peak learning hours; can scale independently without affecting Concepts or Progress agents
- **Failure Isolation**: If Exercise Agent OpenAI calls timeout, other agents continue working
- **Resource Optimization**: Each agent gets dedicated CPU/memory allocation matching its workload (Debug needs more memory for stack trace analysis)
- **Dapr Service Mesh**: Kubernetes + Dapr sidecars eliminate microservices complexity (service discovery, retries, circuit breaking built-in)
- **Constitution Principle IV**: Kubernetes-native architecture is mandated; microservices align naturally with K8s deployment model

### Alternatives Considered

**Option A: Monolithic AI Service** (all 6 agents in one FastAPI app)
- **Pros**: Simpler deployment, shared OpenAI connection pooling, faster inter-agent communication
- **Cons**: Single point of failure, cannot scale agents independently, larger blast radius for bugs, harder to test individual agents
- **Rejected Because**: Violates "cloud-ready architecture" principle; scaling the entire monolith wastes resources when only Debug Agent needs more capacity

**Option B: Single "AI Gateway" with Agent Modules** (one service with pluggable agent modules)
- **Pros**: Moderate complexity, shared configuration, easier to add new agents
- **Cons**: Still a single deployment unit, shared memory space leads to contention, agent failures cascade
- **Rejected Because**: Doesn't leverage Kubernetes' strength (independent pod lifecycle management); partial failure handling is complex

### Implementation Notes

**Shared Components** (avoid duplication):
- Common library: `learnflow-app/backend/src/shared/ai_agent_base.py` with base class `BaseAIAgent`
- Shared utilities: OpenAI client wrapper, retry logic, fallback response handler, prompt template engine
- Shared configuration: ConfigMap `ai-agent-config` with OpenAI API key (from Secret), timeout settings, model selection (GPT-4 vs GPT-3.5-turbo)

**Service Communication**:
- Student frontend → `triage-agent-service` (POST /triage with query text)
- Triage → specific agent (Dapr service invocation, e.g., `dapr invoke debug-agent-service /analyze`)
- Agent → Kafka (publish events: `ai.response.generated`, `ai.fallback.triggered`)

**Deployment Pattern**:
```yaml
# k8s/deployments/triage-agent-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: triage-agent
spec:
  replicas: 2
  template:
    metadata:
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "triage-agent"
        dapr.io/app-port: "8000"
    spec:
      containers:
      - name: triage-agent
        image: learnflow/triage-agent:latest
        env:
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: openai-secret
              key: api-key
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

**Testing Strategy**:
- Unit tests: Mock OpenAI API responses, test agent logic in isolation
- Contract tests: Validate Dapr service invocation contracts between Triage and specialized agents
- Integration tests: Deploy all 6 agents in Minikube, test end-to-end query routing
- Load tests: Simulate 100 concurrent students asking questions, measure p95 latency <3s

**Fallback Strategy**:
- Each agent service loads pre-scripted responses from ConfigMap `fallback-responses-{agent}`
- On OpenAI timeout (>3s) or API error, immediately return fallback with disclaimer
- Fallback responses organized by topic (e.g., `fallback-responses-concepts` → `variables.txt`, `loops.txt`, `functions.txt`)

---

## Research Task 2: Code Sandbox Security Implementation

**Question**: Docker seccomp profiles, AppArmor, resource limits for secure Python code execution.

### Decision

**Multi-Layer Security**: Docker containers with custom seccomp profile, no-new-privileges flag, read-only root filesystem, network isolation, and resource constraints.

### Rationale

- **Defense in Depth**: Multiple security layers ensure a single bypass doesn't compromise the system
- **Industry Standard**: Matches sandbox security used by online coding platforms (Repl.it, CodeSandbox)
- **Kubernetes-Native**: Resource limits enforced by K8s resource requests/limits; no custom Linux cgroups needed
- **FR-012 Compliance**: Blocks network access, filesystem access (except /tmp), and subprocess execution as specified

### Alternatives Considered

**Option A: VM-Based Sandboxes** (Firecracker microVMs)
- **Pros**: Strongest isolation (hardware virtualization), used by AWS Lambda
- **Cons**: Slower startup (100-300ms), more complex infrastructure, overkill for educational use case, resource-intensive
- **Rejected Because**: Kubernetes can't manage VMs directly; adds unnecessary complexity for low-risk student code

**Option B: WebAssembly (WASI) Sandboxes** (Python compiled to WASM)
- **Pros**: Near-native performance, strong sandboxing, browser-compatible
- **Cons**: Limited Python library support, no standard library modules (os, sys), immature tooling, breaks student learning expectations
- **Rejected Because**: Students expect full Python 3.11 standard library; WASM Python is too restrictive

**Option C: gVisor (Google's container sandbox)**
- **Pros**: Strong kernel isolation, intercepts syscalls, production-ready
- **Cons**: 10-30% performance overhead, complex setup, incompatible with some Python libraries (ctypes)
- **Rejected Because**: Overkill for student code; performance impact violates <1s execution target (FR-010, SC-007)

### Implementation Notes

**Docker Configuration** (`backend/src/code-runner-service/Dockerfile.sandbox`):
```dockerfile
FROM python:3.11-slim

# Security: Run as non-root user
RUN useradd -m -u 1000 sandbox
USER sandbox

# Security: Read-only root filesystem (only /tmp writable)
WORKDIR /tmp

# Install only safe, whitelisted libraries
RUN pip install --no-cache-dir numpy==1.24.0 matplotlib==3.7.0

# Entry point: Execute student code with timeout
CMD ["python", "-u", "/tmp/student_code.py"]
```

**Kubernetes Pod Security** (`k8s/deployments/code-runner-deployment.yaml`):
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: code-runner-sandbox
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
    seccompProfile:
      type: Localhost
      localhostProfile: profiles/code-sandbox.json
  containers:
  - name: sandbox
    image: learnflow/python-sandbox:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
    resources:
      limits:
        memory: "50Mi"
        cpu: "500m"
        ephemeral-storage: "10Mi"
      requests:
        memory: "20Mi"
        cpu: "100m"
    volumeMounts:
    - name: tmp
      mountPath: /tmp
  volumes:
  - name: tmp
    emptyDir:
      sizeLimit: "10Mi"
```

**Seccomp Profile** (`k8s/security/profiles/code-sandbox.json`):
```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": ["SCMP_ARCH_X86_64"],
  "syscalls": [
    {
      "names": [
        "read", "write", "open", "close", "stat", "fstat",
        "mmap", "munmap", "brk", "rt_sigaction", "rt_sigprocmask",
        "access", "getpid", "getuid", "getgid", "geteuid", "getegid",
        "exit", "exit_group", "wait4", "execve", "clock_gettime"
      ],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
```

**Network Isolation**:
- Kubernetes NetworkPolicy blocks all egress from code-runner pods except to internal DNS
- No internet access prevents students from importing malicious code or exfiltrating data

**Execution Flow**:
1. Student submits code via frontend → `POST /api/submit`
2. `code-runner-service` receives code, validates length (<10KB), sanitizes input
3. Service creates ephemeral Kubernetes Job with sandbox Pod
4. Student code written to `/tmp/student_code.py` via InitContainer
5. Python executes with 5-second timeout (enforced by `kubectl wait --timeout=5s`)
6. Stdout/stderr captured, Pod deleted immediately
7. Results returned to student

**Whitelisted Libraries**:
- Standard library: all modules EXCEPT `os`, `sys`, `subprocess`, `socket`, `requests`, `urllib`, `ctypes`, `importlib`
- Third-party: `numpy`, `matplotlib`, `pandas` (for data science modules)
- Rationale: Allow legitimate learning while blocking system/network access

**Testing Strategy**:
- **Positive Tests**: Run valid student code, verify correct output
- **Negative Tests**: Attempt to break sandbox (network access, file read outside /tmp, fork bomb, memory overflow)
- **Security Audit**: Run automated security scanner (Trivy, Clair) on Docker images weekly
- **Penetration Testing**: Attempt privilege escalation, container escape, resource exhaustion

**Monitoring**:
- Alert on: sandbox execution >4s (timeout approaching), memory usage >45MB (near limit), failed seccomp violations
- Log all sandbox creations/deletions with student_id for audit trail

---

## Research Task 3: OpenAI API Fallback Strategy

**Question**: Pre-scripted response schema and caching for AI agent failures or >3s response times.

### Decision

**Two-Tier Fallback System**:
1. **Tier 1**: Aggressive response caching (Redis via Dapr state store) for common questions
2. **Tier 2**: Pre-scripted fallback responses organized by topic + agent type when cache misses and OpenAI fails/times out

### Rationale

- **Cost Optimization**: Caching reduces OpenAI API costs by 60-80% for repetitive questions ("How do for loops work?")
- **Performance**: Cache hits return in <100ms vs. 1-3s for OpenAI API calls
- **Reliability**: Students always get a response even when OpenAI is down (meets FR-039a)
- **User Experience**: Fallback disclaimer sets expectations: "AI unavailable - showing general guidance"

### Alternatives Considered

**Option A: No Caching, Only Fallback** (always call OpenAI, fallback on failure)
- **Pros**: Simpler architecture, always fresh responses
- **Cons**: High API costs ($0.03 per 1K tokens × 100 students × 20 questions/day = $60/day), slow responses, no cost control
- **Rejected Because**: Violates cost optimization requirement; unnecessary expense for repetitive questions

**Option B: Client-Side Caching** (cache in browser localStorage)
- **Pros**: Zero server-side infrastructure, instant cache hits
- **Cons**: Cache doesn't help other students, wasted API calls for common questions, cache invalidation complexity
- **Rejected Because**: Multi-student benefit lost; teacher dashboard can't track actual AI usage

**Option C: Use Smaller Model (GPT-3.5-turbo) as Fallback** (instead of pre-scripted text)
- **Pros**: More dynamic responses, no manual fallback authoring
- **Cons**: Still costs money on failure, still has latency, doesn't solve "OpenAI is down" scenario
- **Rejected Because**: Doesn't address availability requirement; adds cost without reliability gain

### Implementation Notes

**Cache Configuration** (Dapr state store with Redis):
```yaml
# k8s/dapr-components/redis-state.yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
spec:
  type: state.redis
  version: v1
  metadata:
  - name: redisHost
    value: redis-master.default.svc.cluster.local:6379
  - name: redisPassword
    secretKeyRef:
      name: redis-secret
      key: password
  - name: ttlInSeconds
    value: "86400"  # 24-hour cache TTL
```

**Cache Key Strategy**:
- Key format: `ai_response:{agent}:{topic}:{question_hash}`
- Example: `ai_response:concepts:variables:a3f5c9e2` (hash of normalized question text)
- TTL: 24 hours (balances freshness with cost savings)
- Eviction: LRU (Least Recently Used) when Redis memory limit reached

**Caching Logic** (`backend/src/shared/ai_agent_base.py`):
```python
import hashlib
import json
from dapr.clients import DaprClient

class BaseAIAgent:
    def __init__(self, agent_name: str, dapr_client: DaprClient):
        self.agent_name = agent_name
        self.dapr = dapr_client

    async def get_response(self, question: str, topic: str, context: dict) -> dict:
        # Generate cache key
        question_normalized = question.lower().strip()
        question_hash = hashlib.md5(question_normalized.encode()).hexdigest()[:8]
        cache_key = f"ai_response:{self.agent_name}:{topic}:{question_hash}"

        # Check cache first
        cached = await self.dapr.get_state(store_name="statestore", key=cache_key)
        if cached.data:
            return json.loads(cached.data)

        # Call OpenAI with timeout
        try:
            response = await self._call_openai(question, topic, context, timeout=3.0)
            # Cache successful response
            await self.dapr.save_state(
                store_name="statestore",
                key=cache_key,
                value=json.dumps(response)
            )
            return response
        except TimeoutError:
            # Fallback to pre-scripted response
            return self._get_fallback(topic)

    def _get_fallback(self, topic: str) -> dict:
        # Load from ConfigMap mounted at /config/fallbacks/{agent}/{topic}.json
        fallback_path = f"/config/fallbacks/{self.agent_name}/{topic}.json"
        with open(fallback_path, 'r') as f:
            fallback = json.load(f)
        return {
            "text": fallback["response"],
            "disclaimer": "AI unavailable - showing general guidance",
            "source": "fallback"
        }
```

**Fallback Response Structure** (`data/fallback-responses/concepts/variables.json`):
```json
{
  "topic": "variables",
  "agent": "concepts",
  "response": "Variables in Python store data values. You create them with assignment:\n\n```python\nname = \"Alice\"  # String variable\nage = 25         # Integer variable\n```\n\nVariable names must start with a letter or underscore, and can contain letters, numbers, and underscores. Python is dynamically typed, so you don't need to declare the type explicitly.",
  "examples": [
    "x = 10",
    "message = \"Hello\"",
    "is_valid = True"
  ],
  "next_topics": ["data_types", "operators"]
}
```

**Fallback Coverage**:
- **Concepts Agent**: 40 fallback responses (5 per module × 8 modules)
- **Debug Agent**: 15 common error types (NameError, SyntaxError, IndexError, etc.)
- **Code Review Agent**: 10 code quality tips (naming, structure, PEP 8)
- **Exercise Agent**: 5 "Try this approach" hints per module
- **Progress Agent**: 3 generic progress summaries (Beginner, Learning, Proficient)

**Cache Metrics** (tracked via MCP server):
- Cache hit rate (target: >70% after warmup period)
- Average response time: cache hit vs. OpenAI call vs. fallback
- Cost savings: (cache hits + fallbacks) / total requests × cost per API call
- Fallback trigger rate (target: <5% under normal conditions)

**Cache Invalidation Strategy**:
- **Time-based**: 24-hour TTL for all cached responses
- **Content-based**: Manual invalidation when curriculum content updates (teacher dashboard button)
- **No personalization in cache**: User-specific context (mastery level) passed as parameter, not cached

**Testing Strategy**:
- Mock OpenAI API to simulate timeouts, errors, 500 responses
- Verify cache hit/miss behavior with identical questions
- Test fallback response quality with human review (teacher panel)
- Load test: 100 concurrent requests, verify cache reduces load on OpenAI

---

## Research Task 4: Mastery Calculation Formula Validation

**Question**: Confirm formula weights and edge cases for mastery level calculation.

### Decision

**Mastery Formula** (per topic):
```
Mastery = (Exercises × 0.40) + (Quizzes × 0.30) + (Code Quality × 0.20) + (Streak × 0.10)
```

Where:
- **Exercises**: Average grade across completed exercises (0-100%)
- **Quizzes**: Most recent quiz score (0-100%)
- **Code Quality**: Average Code Review Agent score (0-100%)
- **Streak**: Consecutive days active, scaled (min 0%, max 10% at 7+ days)

**Mastery Levels**:
- 0-40%: Beginner (red badge)
- 41-70%: Learning (yellow badge)
- 71-90%: Proficient (green badge)
- 91-100%: Mastered (blue badge)

### Rationale

- **Balanced Assessment**: 70% objective (exercises + quizzes), 30% behavioral (code quality + streak)
- **Rewards Consistency**: Streak component incentivizes daily practice (research shows spaced repetition improves retention)
- **Latest Quiz Matters Most**: Using most recent quiz (not average) reflects current understanding after mistakes
- **Industry Alignment**: Similar to Codecademy's mastery system (60% completion, 40% quality/engagement)

### Alternatives Considered

**Option A: Simple Completion Percentage** (exercises completed / total exercises)
- **Pros**: Dead simple, easy to understand
- **Cons**: Doesn't measure quality, students can brute-force by submitting anything
- **Rejected Because**: No incentive for good code; passing ≠ mastery

**Option B: Weighted Average of All Attempts** (average of all quiz scores, all exercise grades)
- **Pros**: Rewards improvement over time
- **Cons**: Early failures permanently drag down score, discourages experimentation
- **Rejected Because**: Demotivates students who struggle initially but improve

**Option C: Quiz-Only Mastery** (ignore exercises, only quiz scores matter)
- **Pros**: Clear assessment, aligns with academic testing
- **Cons**: No credit for practice, students skip exercises, miss learning opportunity
- **Rejected Because**: Exercises are primary learning vehicle; quizzes are checkpoints

### Implementation Notes

**Formula Components**:

1. **Exercises (40% weight)**:
   - Calculated as: `SUM(exercise_grades) / COUNT(exercises_completed)`
   - Example: Student completes 4/5 exercises with grades [85, 90, 75, 80] → 82.5%
   - Edge case: 0 exercises completed → Exercises = 0%

2. **Quizzes (30% weight)**:
   - Uses `last_quiz_score` from StudentProgress table
   - Example: Student takes quiz 3 times [60%, 75%, 85%] → uses 85%
   - Edge case: No quiz taken → Quizzes = 0%

3. **Code Quality (20% weight)**:
   - Calculated as: `AVG(code_review_agent_scores)` from CodeSubmission table
   - Code Review Agent grades on: naming conventions, structure, PEP 8 compliance, readability
   - Example: 5 submissions with quality scores [70, 75, 80, 85, 90] → 80%
   - Edge case: No submissions → Code Quality = 50% (neutral starting point)

4. **Streak (10% weight)**:
   - Consecutive days with at least 1 activity (code submission, quiz, or chat)
   - Scaling: 0 days = 0%, 1-2 days = 2%, 3-4 days = 5%, 5-6 days = 8%, 7+ days = 10%
   - Example: 5-day streak → contributes 8% to final mastery
   - Edge case: Inactive for 24+ hours → streak resets to 0

**SQL Query** (`backend/src/student-service/models.py`):
```python
def calculate_mastery(student_id: str, topic: str) -> float:
    # Exercises component (40%)
    exercises_avg = db.query(
        func.avg(CodeSubmission.grade)
    ).filter(
        CodeSubmission.student_id == student_id,
        CodeSubmission.topic == topic
    ).scalar() or 0.0

    # Quizzes component (30%)
    latest_quiz = db.query(
        QuizResponse.score
    ).filter(
        QuizResponse.student_id == student_id,
        QuizResponse.topic == topic
    ).order_by(QuizResponse.completed_at.desc()).first()
    quiz_score = latest_quiz.score if latest_quiz else 0.0

    # Code Quality component (20%)
    quality_avg = db.query(
        func.avg(CodeSubmission.code_quality_score)
    ).filter(
        CodeSubmission.student_id == student_id,
        CodeSubmission.topic == topic
    ).scalar() or 50.0  # Neutral starting point

    # Streak component (10%)
    streak_days = db.query(StudentProgress.streak_days).filter(
        StudentProgress.student_id == student_id,
        StudentProgress.topic == topic
    ).scalar() or 0
    streak_percent = min(10.0, streak_days * 1.5)  # Cap at 10%

    # Final mastery calculation
    mastery = (
        (exercises_avg * 0.40) +
        (quiz_score * 0.30) +
        (quality_avg * 0.20) +
        (streak_percent * 0.10)
    )

    return round(mastery, 2)
```

**Edge Cases & Handling**:

1. **Brand New Student** (no data):
   - Exercises = 0%, Quizzes = 0%, Code Quality = 50%, Streak = 0%
   - Initial Mastery = 10% (Beginner)

2. **Student Who Only Practices** (no quizzes):
   - Exercises = 85%, Quizzes = 0%, Code Quality = 75%, Streak = 8%
   - Mastery = (85×0.40) + (0×0.30) + (75×0.20) + (8×0.10) = 34% + 0% + 15% + 0.8% = 49.8% (Learning)

3. **Student Who Only Takes Quizzes** (no exercises):
   - Exercises = 0%, Quizzes = 90%, Code Quality = 50%, Streak = 5%
   - Mastery = (0×0.40) + (90×0.30) + (50×0.20) + (5×0.10) = 0% + 27% + 10% + 0.5% = 37.5% (Beginner)
   - Interpretation: Quizzes alone aren't enough; practice is required

4. **Student Who Improves Over Time**:
   - Week 1: Exercises = 60%, Quizzes = 55%, Quality = 65%, Streak = 3% → Mastery = 58.45% (Learning)
   - Week 3: Exercises = 80%, Quizzes = 85%, Quality = 82%, Streak = 10% → Mastery = 82.2% (Proficient)

5. **Student Who Regresses** (long break, poor quiz):
   - Previous: Mastery = 75% (Proficient)
   - Takes quiz after 2-week break, scores 40%, streak = 0%
   - New Mastery = (80×0.40) + (40×0.30) + (85×0.20) + (0×0.10) = 32% + 12% + 17% + 0% = 61% (Learning)
   - Interpretation: System reflects current state, not historical high

**Display Logic** (`frontend/src/components/ProgressDashboard.tsx`):
```typescript
function getMasteryBadge(mastery: number): { color: string; label: string; icon: string } {
  if (mastery >= 91) return { color: 'blue', label: 'Mastered', icon: '🏆' };
  if (mastery >= 71) return { color: 'green', label: 'Proficient', icon: '✅' };
  if (mastery >= 41) return { color: 'yellow', label: 'Learning', icon: '📚' };
  return { color: 'red', label: 'Beginner', icon: '🌱' };
}
```

**Validation Tests**:
- Unit test: Verify formula with known inputs produces expected mastery percentage
- Regression test: Historical student data should produce consistent mastery scores
- Boundary test: Test edge cases (0%, 100%, no data, only one component)
- UX test: Teachers review mastery levels for 10 sample students, confirm levels "feel right"

**Teacher Calibration**:
- Teacher dashboard shows formula breakdown: "Mastery 68% = Exercises 75% (30pts) + Quizzes 60% (18pts) + Quality 70% (14pts) + Streak 5d (6pts)"
- Transparency builds trust and helps teachers explain to students

---

## Research Task 5: Real-Time Struggle Detection Algorithm

**Question**: Event stream processing with Kafka for detecting student struggles.

### Decision

**Event-Driven Struggle Detection**: Kafka consumers listen to student activity events and apply pattern-matching rules to trigger alerts in near-real-time (<30 seconds).

**Detection Rules** (FR-027):
1. **Same Error 3+ Times**: Same error type (NameError, IndexError) in 3 consecutive submissions
2. **Stuck >10 Minutes**: Student on same exercise >10 min without successful submission
3. **Quiz Score <50%**: Student scores below 50% on any quiz
4. **Help Requests 3+ Times**: Student says "I don't understand" or similar phrases 3+ times in chat
5. **5+ Consecutive Failures**: 5 code submissions in a row with grade <60%

### Rationale

- **Proactive Intervention**: Teachers notified before students give up (research shows 15-minute struggle threshold is critical)
- **Low False Positive Rate**: Multiple signals (errors, time, score) reduce noise; only actionable alerts sent
- **Scalable Architecture**: Kafka consumers scale horizontally; handle 100+ students per classroom without blocking
- **Constitution Principle IV**: Event-driven architecture aligns with Dapr pub/sub and Kubernetes-native design

### Alternatives Considered

**Option A: Polling-Based Detection** (cron job checks database every 5 minutes)
- **Pros**: Simple implementation, no Kafka required
- **Cons**: 5-minute delay (students may already be frustrated), database load scales poorly, missed events between polls
- **Rejected Because**: Violates real-time requirement (FR-028); teacher gets stale data

**Option B: Rule Engine (Drools, Easy Rules)** (centralized rule processing)
- **Pros**: Sophisticated pattern matching, rule versioning, non-technical users can edit rules
- **Cons**: Heavy infrastructure, overkill for 5 simple rules, learning curve, complex debugging
- **Rejected Because**: Over-engineered for MVP; 5 hardcoded rules sufficient, can refactor later

**Option C: WebSocket Push from Backend** (no Kafka, direct WebSocket to frontend)
- **Pros**: Instant notification, no message queue needed
- **Cons**: Stateful connections don't scale, lost messages on disconnect, no audit trail, no replay capability
- **Rejected Because**: Doesn't leverage Kafka investment; missed Constitution Principle IV

### Implementation Notes

**Kafka Event Schemas** (`specs/004-learnflow-application/contracts/events.yaml`):
```yaml
CodeExecutedEvent:
  topic: code.executed
  schema:
    student_id: string
    exercise_id: string
    code_text: string
    output: string
    execution_time: float
    success: boolean
    error_type: string | null  # "NameError", "IndexError", null if success
    grade: int  # 0-100
    timestamp: ISO8601

QuizSubmittedEvent:
  topic: quiz.submitted
  schema:
    student_id: string
    quiz_id: string
    score: int  # 0-100
    answers: object
    completed_at: ISO8601

ChatMessageEvent:
  topic: chat.message
  schema:
    student_id: string
    message: string
    sentiment: string  # "confused", "neutral", "confident"
    timestamp: ISO8601
```

**Consumer Logic** (`backend/src/event-processor-service/consumers/struggle_detector.py`):
```python
from kafka import KafkaConsumer
from datetime import datetime, timedelta
import json

class StruggleDetector:
    def __init__(self):
        self.consumer = KafkaConsumer(
            'code.executed', 'quiz.submitted', 'chat.message',
            bootstrap_servers=['kafka.default.svc.cluster.local:9092'],
            value_deserializer=lambda m: json.loads(m.decode('utf-8'))
        )
        self.student_state = {}  # In-memory state (replace with Redis for scale)

    def process_events(self):
        for message in self.consumer:
            topic = message.topic
            event = message.value

            if topic == 'code.executed':
                self._check_error_pattern(event)
                self._check_stuck_time(event)
                self._check_consecutive_failures(event)

            elif topic == 'quiz.submitted':
                self._check_quiz_score(event)

            elif topic == 'chat.message':
                self._check_help_requests(event)

    def _check_error_pattern(self, event):
        student_id = event['student_id']
        error_type = event.get('error_type')

        if not error_type:
            # Success, reset error count
            self._reset_state(student_id, 'error_count')
            return

        # Increment error count for this error type
        key = f"{student_id}:error:{error_type}"
        count = self.student_state.get(key, 0) + 1
        self.student_state[key] = count

        if count >= 3:
            self._trigger_alert(
                student_id=student_id,
                trigger_type='error_pattern',
                description=f'Same {error_type} error 3 times in a row'
            )
            self._reset_state(student_id, f'error:{error_type}')

    def _check_stuck_time(self, event):
        student_id = event['student_id']
        exercise_id = event['exercise_id']

        # Track first attempt time for this exercise
        key = f"{student_id}:exercise:{exercise_id}:start"
        if key not in self.student_state:
            self.student_state[key] = datetime.now()
            return

        start_time = self.student_state[key]
        elapsed = (datetime.now() - start_time).total_seconds()

        if elapsed > 600 and not event['success']:  # 10 minutes
            self._trigger_alert(
                student_id=student_id,
                trigger_type='time_stuck',
                description=f'Stuck on {exercise_id} for {int(elapsed/60)} minutes'
            )
            self._reset_state(student_id, f'exercise:{exercise_id}:start')

    def _trigger_alert(self, student_id: str, trigger_type: str, description: str):
        # Publish to Kafka for notification service
        alert_event = {
            'student_id': student_id,
            'classroom_id': self._get_classroom(student_id),
            'trigger_type': trigger_type,
            'description': description,
            'timestamp': datetime.now().isoformat()
        }
        self.producer.send('struggle.detected', value=alert_event)

        # Persist to database
        self._save_alert_to_db(alert_event)
```

**State Management**:
- **In-Memory (MVP)**: Dict in consumer process, sufficient for single-instance deployment
- **Redis (Production)**: Distributed cache for multi-instance consumers, prevents duplicate alerts
- **State Keys**: `{student_id}:error:{error_type}`, `{student_id}:exercise:{exercise_id}:start`, `{student_id}:help_request_count`
- **TTL**: 30 minutes (state expires if student takes a break)

**Alert Deduplication**:
- Once alert triggered, set flag: `{student_id}:alert:{trigger_type}:sent` with 1-hour TTL
- Prevents spam: same alert type won't trigger again for 1 hour unless manually resolved by teacher

**Notification Flow**:
1. Consumer detects struggle → publishes `struggle.detected` event
2. Notification service subscribes to `struggle.detected` → creates StruggleAlert record in DB
3. Teacher dashboard polls `GET /api/teacher/alerts` every 30 seconds (or WebSocket push)
4. New alerts show in notification badge count, dropdown displays recent alerts

**Scalability**:
- Kafka consumer group: Deploy 3 replicas of `event-processor-service` for high availability
- Partition by `student_id`: Ensures all events for one student go to same consumer (maintains state)
- Throughput: 100 students × 10 submissions/hour = 1000 events/hour (trivial for Kafka)

**Testing Strategy**:
- Unit test: Feed synthetic events to consumer, verify alert triggers at correct thresholds
- Integration test: Deploy full stack, simulate struggling student, verify teacher receives alert in <30s
- Load test: Generate 1000 events/minute, verify no alerts dropped, no duplicate alerts
- False positive test: Simulate successful student (no errors, quick completions), verify no spurious alerts

**Monitoring**:
- Metrics: Alert trigger rate by type, average time-to-alert, alert resolution rate, consumer lag
- Alerts: Consumer lag >100 events (backlog), alert trigger rate >10/min (potential bug)

---

## Research Task 6: Data Retention and Cleanup Strategy

**Question**: Automated cleanup job implementation for expired student data.

### Decision

**Kubernetes CronJob** with retention policy: Code submissions, quiz responses, and struggle alerts retained during active enrollment + 1 year after enrollment ends. Progress records (mastery levels) retained indefinitely.

**Cleanup Schedule**: Daily at 2 AM UTC (low-traffic period).

### Rationale

- **Storage Optimization**: Prevents unbounded database growth; code submissions are largest data volume
- **Privacy Compliance**: Aligns with FERPA best practices (educational records retained 1 year after course end)
- **Historical Preservation**: Progress records kept indefinitely for transcripts, academic records
- **Automated Enforcement**: CronJob eliminates manual cleanup, reduces operational burden

### Alternatives Considered

**Option A: No Deletion, Infinite Retention**
- **Pros**: Simple, never lose data, supports future analytics
- **Cons**: Database grows indefinitely, storage costs escalate, privacy concerns (students may want data deleted)
- **Rejected Because**: Not scalable; 100 students × 1000 submissions × 5KB = 500MB per classroom per year

**Option B: Manual Deletion** (teacher triggers cleanup)
- **Pros**: Teacher controls retention, flexible per-classroom policies
- **Cons**: Teachers forget, inconsistent policies, privacy violations if not enforced
- **Rejected Because**: Human error risk; constitution requires automated enforcement

**Option C: TTL Indexes** (MongoDB/PostgreSQL TTL feature)
- **Pros**: Database handles cleanup automatically, no external job needed
- **Cons**: PostgreSQL doesn't have native TTL (requires extension), less flexible (can't query "enrollment + 1 year")
- **Rejected Because**: PostgreSQL 15 doesn't natively support TTL; CronJob provides more control

### Implementation Notes

**Retention Policy Logic** (`backend/src/data-cleanup-service/cleanup.py`):
```python
from datetime import datetime, timedelta
from sqlalchemy import delete
from models import CodeSubmission, QuizResponse, StruggleAlert, Enrollment

def cleanup_expired_data():
    cutoff_date = datetime.now() - timedelta(days=365)

    # Find enrollments that ended >1 year ago
    expired_enrollments = db.query(Enrollment).filter(
        Enrollment.ended_at.isnot(None),
        Enrollment.ended_at < cutoff_date
    ).all()

    expired_student_ids = [e.student_id for e in expired_enrollments]

    # Delete code submissions
    deleted_submissions = db.execute(
        delete(CodeSubmission).where(
            CodeSubmission.student_id.in_(expired_student_ids),
            CodeSubmission.submitted_at < cutoff_date
        )
    ).rowcount

    # Delete quiz responses
    deleted_quizzes = db.execute(
        delete(QuizResponse).where(
            QuizResponse.student_id.in_(expired_student_ids),
            QuizResponse.completed_at < cutoff_date
        )
    ).rowcount

    # Delete struggle alerts
    deleted_alerts = db.execute(
        delete(StruggleAlert).where(
            StruggleAlert.student_id.in_(expired_student_ids),
            StruggleAlert.created_at < cutoff_date
        )
    ).rowcount

    db.commit()

    print(f"Cleanup complete: {deleted_submissions} submissions, {deleted_quizzes} quizzes, {deleted_alerts} alerts deleted")
```

**Kubernetes CronJob** (`k8s/cronjobs/data-cleanup-cronjob.yaml`):
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: data-cleanup
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM UTC
  concurrencyPolicy: Forbid  # Don't run if previous job still running
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: learnflow/data-cleanup:latest
            env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: connection-string
            resources:
              requests:
                memory: "128Mi"
                cpu: "100m"
              limits:
                memory: "256Mi"
                cpu: "200m"
          restartPolicy: OnFailure
```

**Retention Edge Cases**:

1. **Active Enrollment** (student still in classroom):
   - No deletion, regardless of age
   - Example: Student enrolled 3 years ago, still active → data retained

2. **Ended Enrollment <1 Year Ago**:
   - No deletion yet, still within grace period
   - Example: Student left classroom 6 months ago → data retained

3. **Ended Enrollment >1 Year Ago**:
   - Eligible for deletion
   - Example: Student left classroom 15 months ago → submissions/quizzes/alerts deleted

4. **Re-Enrollment** (student rejoins classroom):
   - Treated as new enrollment, old data subject to deletion if >1 year since previous end
   - Example: Student left 18 months ago, rejoined today → old data deleted, fresh start

5. **Progress Records** (StudentProgress table):
   - NEVER deleted, retained indefinitely
   - Rationale: Academic transcripts require historical mastery levels

**Audit Trail**:
- Log all deletions to Kafka topic `data.deleted` with student_id, data_type, count, timestamp
- Compliance report: Monthly summary of data deleted for privacy audit
- Example log: `{"student_id": "s123", "data_type": "CodeSubmission", "count": 47, "timestamp": "2025-12-22T02:05:00Z"}`

**Testing Strategy**:
- Unit test: Mock database, verify correct records deleted based on date logic
- Integration test: Create test data with known ages, run cleanup, verify only expired data deleted
- Safety test: Ensure active enrollments are never deleted
- Performance test: Cleanup 10,000 records in <5 minutes (doesn't block database)

**Monitoring**:
- Metrics: Records deleted per run, job duration, job success/failure rate
- Alerts: Job failed 2 consecutive runs, job duration >10 minutes (potential database lock)

**Manual Override** (teacher-initiated):
- Teacher dashboard: "Delete My Classroom Data" button (immediate deletion, not waiting for CronJob)
- Use case: Teacher wants to remove classroom at end of semester
- Implementation: Synchronous API call to cleanup service, confirms deletion in <30s

---

## Research Task 7: MCP Server Integration Patterns

**Question**: Required endpoints and data formats for Model Context Protocol servers.

### Decision

**MCP Servers for Two Services**:
1. **Code Runner MCP**: Exposes sandbox execution state, recent errors, security metrics
2. **API Gateway MCP**: Exposes service health, request traces, error logs

**Endpoint Structure** (per MCP specification):
- `GET /mcp/state` - Current service state snapshot
- `GET /mcp/logs` - Recent logs (last 100 lines)
- `GET /mcp/schema` - API contracts and data models
- `GET /mcp/metrics` - Prometheus-style metrics

### Rationale

- **AI Agent Context**: MCP provides rich context for Claude Code/Goose to understand system state without guessing
- **Debugging Efficiency**: Agents can diagnose issues by querying MCP endpoints (e.g., "Why is code execution slow?" → check /mcp/metrics)
- **Evaluation Score**: MCP integration is 20% of hackathon evaluation; mandatory for competitive submission
- **Constitution Principle V**: MCP integration is core requirement, not optional

### Alternatives Considered

**Option A: Prometheus Metrics Only** (no custom MCP endpoints)
- **Pros**: Standard observability, works with Grafana
- **Cons**: Prometheus is numeric metrics only, no logs/state/schema context for AI agents
- **Rejected Because**: MCP spec requires structured context beyond metrics

**Option B: GraphQL Introspection** (use GraphQL schema as MCP)
- **Pros**: Schema discovery built-in, rich query language
- **Cons**: GraphQL overhead for REST APIs, MCP spec is simpler (JSON over HTTP)
- **Rejected Because**: Over-engineering; MCP is RESTful JSON, no GraphQL needed

**Option C: OpenAPI/Swagger as MCP** (expose Swagger UI as MCP)
- **Pros**: API documentation already exists
- **Cons**: Swagger is static schema, doesn't provide runtime state/logs/metrics
- **Rejected Because**: MCP needs dynamic runtime context, not just static schema

### Implementation Notes

**Code Runner MCP Endpoints** (`backend/src/code-runner-service/mcp_server.py`):
```python
from fastapi import FastAPI
from datetime import datetime

mcp_app = FastAPI()

@mcp_app.get("/mcp/state")
async def get_state():
    return {
        "service": "code-runner",
        "version": "1.0.0",
        "uptime_seconds": get_uptime(),
        "active_sandboxes": len(active_sandbox_pods()),
        "queued_requests": get_queue_depth(),
        "recent_errors": get_recent_errors(limit=5),
        "resource_usage": {
            "cpu_percent": get_cpu_usage(),
            "memory_mb": get_memory_usage(),
            "sandbox_limit": 50  # Max 50MB per sandbox
        },
        "timestamp": datetime.now().isoformat()
    }

@mcp_app.get("/mcp/logs")
async def get_logs(limit: int = 100):
    return {
        "service": "code-runner",
        "logs": get_structured_logs(limit=limit),
        "timestamp": datetime.now().isoformat()
    }

@mcp_app.get("/mcp/schema")
async def get_schema():
    return {
        "service": "code-runner",
        "api_version": "v1",
        "endpoints": [
            {
                "method": "POST",
                "path": "/execute",
                "description": "Execute Python code in sandbox",
                "request_schema": {
                    "code": "string",
                    "timeout": "int (default 5)",
                    "student_id": "string"
                },
                "response_schema": {
                    "output": "string",
                    "error": "string | null",
                    "execution_time": "float"
                }
            }
        ],
        "events_published": [
            "code.executed"
        ],
        "dependencies": [
            "kafka.default.svc.cluster.local:9092",
            "postgres.default.svc.cluster.local:5432"
        ]
    }

@mcp_app.get("/mcp/metrics")
async def get_metrics():
    return {
        "service": "code-runner",
        "metrics": {
            "execution_latency_p50_ms": get_metric("execution_latency_p50"),
            "execution_latency_p95_ms": get_metric("execution_latency_p95"),
            "execution_latency_p99_ms": get_metric("execution_latency_p99"),
            "error_rate_percent": get_metric("error_rate"),
            "throughput_rps": get_metric("throughput"),
            "sandbox_creation_time_ms": get_metric("sandbox_creation_time"),
            "security_violations": get_metric("security_violations_count")
        },
        "business_metrics": {
            "total_executions_today": get_metric("executions_today"),
            "unique_students_today": get_metric("unique_students_today"),
            "avg_code_length_bytes": get_metric("avg_code_length")
        },
        "timestamp": datetime.now().isoformat()
    }
```

**API Gateway MCP Endpoints** (`backend/src/api-gateway/mcp_server.py`):
```python
@mcp_app.get("/mcp/state")
async def get_state():
    return {
        "service": "api-gateway",
        "version": "1.0.0",
        "uptime_seconds": get_uptime(),
        "downstream_health": {
            "auth-service": check_health("auth-service"),
            "student-service": check_health("student-service"),
            "teacher-service": check_health("teacher-service"),
            "ai-agent-service": check_health("ai-agent-service"),
            "code-runner-service": check_health("code-runner-service")
        },
        "rate_limiting": {
            "enabled": True,
            "limit_per_user_per_minute": 60
        },
        "timestamp": datetime.now().isoformat()
    }

@mcp_app.get("/mcp/logs")
async def get_logs(level: str = "ERROR", limit: int = 100):
    return {
        "service": "api-gateway",
        "logs": get_filtered_logs(level=level, limit=limit),
        "timestamp": datetime.now().isoformat()
    }
```

**MCP Client Usage (AI Agents)**:
```python
# Claude Code / Goose agent invocation
import requests

def diagnose_code_runner_slowness():
    # Query MCP state
    state = requests.get("http://code-runner.default.svc.cluster.local:8000/mcp/state").json()

    if state['queued_requests'] > 10:
        return "High queue depth - scale up code-runner replicas"

    if state['resource_usage']['cpu_percent'] > 80:
        return "CPU saturation - increase resource limits"

    # Query MCP metrics
    metrics = requests.get("http://code-runner.default.svc.cluster.local:8000/mcp/metrics").json()

    if metrics['metrics']['execution_latency_p95_ms'] > 3000:
        return "Slow execution - check sandbox creation time"

    return "No obvious bottleneck found - check logs"
```

**AGENTS.md Integration** (`learnflow-app/AGENTS.md`):
```markdown
# LearnFlow - AI Agent Context

## MCP Endpoints

### Code Runner Service
- State: http://code-runner.default.svc.cluster.local:8000/mcp/state
- Logs: http://code-runner.default.svc.cluster.local:8000/mcp/logs
- Schema: http://code-runner.default.svc.cluster.local:8000/mcp/schema
- Metrics: http://code-runner.default.svc.cluster.local:8000/mcp/metrics

### API Gateway
- State: http://api-gateway.default.svc.cluster.local:8000/mcp/state
- Logs: http://api-gateway.default.svc.cluster.local:8000/mcp/logs

## Common Debugging Workflows

1. Code execution slow? Check code-runner /mcp/metrics → execution_latency_p95
2. Service down? Check api-gateway /mcp/state → downstream_health
3. Errors in logs? Query code-runner /mcp/logs?level=ERROR
4. Schema changed? Verify code-runner /mcp/schema → endpoints
```

**Testing Strategy**:
- Unit test: Mock MCP endpoints, verify response format matches MCP spec
- Integration test: Deploy services, query MCP endpoints, verify data accuracy
- Agent test: Use Claude Code to query MCP and diagnose simulated issues (e.g., slow execution)

**Monitoring**:
- Metrics: MCP endpoint request rate, response time, error rate
- Alerts: MCP endpoint down (health check fails), MCP response time >1s

**Security**:
- MCP endpoints exposed only on Kubernetes internal network (not public internet)
- Optional: Basic auth for MCP endpoints (future enhancement)

---

## Research Task 8: Monaco Editor Integration with Next.js 14

**Question**: SSR considerations and dynamic imports for Monaco Editor in Next.js 14 App Router.

### Decision

**Dynamic Import with SSR Disabled**: Use Next.js `dynamic()` with `ssr: false` to load Monaco Editor client-side only.

**Component Structure**:
```typescript
// frontend/src/components/CodeEditor.tsx
'use client'  // Next.js 14 App Router client component

import dynamic from 'next/dynamic'

const MonacoEditor = dynamic(() => import('@monaco-editor/react'), {
  ssr: false,
  loading: () => <div>Loading editor...</div>
})

export default function CodeEditor({ code, onChange }: Props) {
  return (
    <MonacoEditor
      height="600px"
      language="python"
      theme="vs-dark"
      value={code}
      onChange={onChange}
      options={{
        minimap: { enabled: false },
        fontSize: 14,
        lineNumbers: 'on',
        renderWhitespace: 'selection',
        autoClosingBrackets: 'always',
        autoIndent: 'full'
      }}
    />
  )
}
```

### Rationale

- **Monaco Requires DOM**: Monaco Editor depends on browser APIs (window, document), incompatible with Next.js SSR
- **Performance**: Dynamic import reduces initial bundle size; Monaco loaded only when code editor page is accessed
- **Next.js 14 Compatibility**: `dynamic()` with `ssr: false` is the official Next.js pattern for client-side-only libraries
- **User Experience**: Loading fallback provides immediate feedback while Monaco loads (~200-300ms)

### Alternatives Considered

**Option A: Server-Side Render Monaco** (attempt SSR with workarounds)
- **Pros**: Faster perceived load (HTML rendered on server)
- **Cons**: Monaco doesn't support SSR, requires complex polyfills, breaks on hydration mismatch
- **Rejected Because**: Monaco officially recommends client-side only; SSR workarounds are fragile

**Option B: CodeMirror Instead of Monaco** (use SSR-compatible editor)
- **Pros**: CodeMirror 6 supports SSR, lighter weight, faster load
- **Cons**: Less feature-rich (no IntelliSense, weaker autocomplete), less familiar to students (VS Code uses Monaco)
- **Rejected Because**: Monaco provides better Python syntax highlighting and autocomplete

**Option C: Lazy Load on User Interaction** (load Monaco only when user clicks "Edit Code")
- **Pros**: Fastest initial page load, zero editor overhead until needed
- **Cons**: Delayed interaction (user waits when clicking "Edit"), poor UX for primary feature
- **Rejected Because**: Code editor is primary UI element, should load immediately

### Implementation Notes

**Package Installation**:
```bash
npm install @monaco-editor/react monaco-editor
```

**Next.js Configuration** (`frontend/next.config.js`):
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack: (config) => {
    // Monaco Editor webpack configuration
    config.module.rules.push({
      test: /\.ttf$/,
      type: 'asset/resource'
    })
    return config
  }
}

module.exports = nextConfig
```

**Python Language Support**:
```typescript
// frontend/src/components/CodeEditor.tsx
import Editor from '@monaco-editor/react'
import { editor } from 'monaco-editor'

function CodeEditor({ code, onChange }: Props) {
  const handleEditorDidMount = (editor: editor.IStandaloneCodeEditor) => {
    // Configure Python-specific settings
    editor.updateOptions({
      tabSize: 4,
      insertSpaces: true,
      detectIndentation: false
    })

    // Add custom Python snippets
    monaco.languages.registerCompletionItemProvider('python', {
      provideCompletionItems: () => ({
        suggestions: [
          {
            label: 'for_loop',
            kind: monaco.languages.CompletionItemKind.Snippet,
            insertText: 'for ${1:item} in ${2:items}:\n\t${3:pass}',
            insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
            documentation: 'For loop'
          }
        ]
      })
    })
  }

  return (
    <Editor
      height="600px"
      defaultLanguage="python"
      value={code}
      onChange={onChange}
      onMount={handleEditorDidMount}
      theme="vs-dark"
    />
  )
}
```

**Auto-Save Implementation**:
```typescript
import { useEffect } from 'react'
import { debounce } from 'lodash'

function CodeEditor({ code, onChange, onSave }: Props) {
  // Auto-save every 30 seconds (FR-046)
  useEffect(() => {
    const debouncedSave = debounce(() => {
      onSave(code)
    }, 30000)  // 30 seconds

    debouncedSave()

    return () => debouncedSave.cancel()
  }, [code, onSave])

  return <Editor value={code} onChange={onChange} />
}
```

**Keyboard Shortcuts**:
```typescript
const handleEditorDidMount = (editor: editor.IStandaloneCodeEditor) => {
  // Ctrl+Enter to run code
  editor.addAction({
    id: 'run-code',
    label: 'Run Code',
    keybindings: [monaco.KeyMod.CtrlCmd | monaco.KeyCode.Enter],
    run: () => {
      handleRunCode()
    }
  })

  // Ctrl+S to save
  editor.addAction({
    id: 'save-code',
    label: 'Save Code',
    keybindings: [monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS],
    run: () => {
      handleSaveCode()
    }
  })
}
```

**Syntax Error Highlighting**:
```typescript
import { useEffect } from 'react'
import { editor, MarkerSeverity } from 'monaco-editor'

function CodeEditor({ code, syntaxErrors }: Props) {
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null)

  useEffect(() => {
    if (!editorRef.current || !syntaxErrors) return

    const model = editorRef.current.getModel()
    if (!model) return

    // Convert syntax errors to Monaco markers
    const markers = syntaxErrors.map(err => ({
      severity: MarkerSeverity.Error,
      startLineNumber: err.line,
      startColumn: err.column,
      endLineNumber: err.line,
      endColumn: err.column + err.length,
      message: err.message
    }))

    monaco.editor.setModelMarkers(model, 'python', markers)
  }, [syntaxErrors])

  return <Editor onMount={(editor) => { editorRef.current = editor }} />
}
```

**Performance Optimization**:
- **Bundle Size**: Monaco Editor is ~3MB gzipped; dynamic import prevents blocking initial page load
- **Lazy Loading**: Load Monaco only on `/exercises/*` and `/playground` routes, not on dashboard
- **Web Worker**: Monaco uses Web Workers for syntax highlighting (no main thread blocking)

**Testing Strategy**:
- Unit test: Mock Monaco Editor component, test onChange callbacks
- Integration test: Load editor in test environment (Playwright), type code, verify onChange fires
- SSR test: Verify no SSR errors in Next.js build logs (`next build`)
- Accessibility test: Verify keyboard navigation works (Tab, Shift+Tab, arrow keys)

**Accessibility**:
- Monaco is screen-reader accessible (ARIA labels built-in)
- Keyboard shortcuts documented in help modal (Ctrl+/ to toggle comments, Ctrl+Enter to run)
- High-contrast theme available for low-vision students

---

## Research Task 9: Classroom State Machine

**Question**: Active/Archived transitions and permissions for classroom lifecycle.

### Decision

**Two-State Model**:
1. **Active** (default): Full functionality, accepts enrollments, submissions, progress updates
2. **Archived** (teacher-initiated): Read-only mode, no new enrollments or submissions, historical data preserved

**State Transitions**:
- Active → Archived: Teacher clicks "Archive Classroom" (irreversible in MVP)
- No transition back to Active (prevents accidental data corruption)

### Rationale

- **Simplicity**: Two states are sufficient for MVP; additional states (Paused, Ended) add complexity without clear value
- **Data Integrity**: Archived state prevents accidental modifications to historical records (important for academic audits)
- **Storage Optimization**: Archived classrooms eligible for data cleanup (1 year after archival), reducing storage costs
- **Teacher Control**: Teachers decide when semester ends, not system (some classes extend beyond typical timelines)

### Alternatives Considered

**Option A: Three-State Model** (Active → Paused → Archived)
- **Pros**: More granular control, temporary suspension for holidays
- **Cons**: "Paused" state ambiguous (can students view progress? can teacher edit?), adds complexity
- **Rejected Because**: Unclear use case; teachers can simply not assign new work during breaks

**Option B: Auto-Archive Based on Time** (classroom auto-archives after 90 days inactive)
- **Pros**: Automatic cleanup, no teacher action needed
- **Cons**: Some classes are intentionally slow-paced (summer courses, self-study), auto-archive may be premature
- **Rejected Because**: Teacher knows best when class ends; system shouldn't guess

**Option C: Soft Delete Instead of Archive** (delete classroom, keep historical data)
- **Pros**: Cleaner UI (no archived classrooms in list)
- **Cons**: Harder to review historical data, teachers can't share past class performance with administrators
- **Rejected Because**: Academic institutions require historical records for accreditation

### Implementation Notes

**Database Schema** (`backend/src/models/classroom.py`):
```python
from enum import Enum
from sqlalchemy import Column, Integer, String, DateTime, Enum as SQLEnum

class ClassroomStatus(str, Enum):
    ACTIVE = "active"
    ARCHIVED = "archived"

class Classroom(Base):
    __tablename__ = "classrooms"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    teacher_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    join_code = Column(String, unique=True, nullable=False)
    status = Column(SQLEnum(ClassroomStatus), default=ClassroomStatus.ACTIVE, nullable=False)
    created_at = Column(DateTime, default=datetime.now)
    archived_at = Column(DateTime, nullable=True)  # Set when archived
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)
```

**State Transition Logic** (`backend/src/teacher-service/routes.py`):
```python
from fastapi import HTTPException

@router.post("/classrooms/{classroom_id}/archive")
async def archive_classroom(classroom_id: int, teacher_id: int):
    classroom = db.query(Classroom).filter(
        Classroom.id == classroom_id,
        Classroom.teacher_id == teacher_id
    ).first()

    if not classroom:
        raise HTTPException(status_code=404, detail="Classroom not found")

    if classroom.status == ClassroomStatus.ARCHIVED:
        raise HTTPException(status_code=400, detail="Classroom already archived")

    # Transition to archived state
    classroom.status = ClassroomStatus.ARCHIVED
    classroom.archived_at = datetime.now()

    # End all active enrollments
    db.query(Enrollment).filter(
        Enrollment.classroom_id == classroom_id,
        Enrollment.ended_at.is_(None)
    ).update({"ended_at": datetime.now()})

    db.commit()

    # Publish event for audit trail
    publish_event("classroom.archived", {
        "classroom_id": classroom_id,
        "teacher_id": teacher_id,
        "archived_at": datetime.now().isoformat()
    })

    return {"message": "Classroom archived successfully"}
```

**Permission Checks** (`backend/src/shared/permissions.py`):
```python
def check_classroom_active(classroom_id: int):
    classroom = db.query(Classroom).filter(Classroom.id == classroom_id).first()
    if classroom.status == ClassroomStatus.ARCHIVED:
        raise HTTPException(status_code=403, detail="Classroom is archived and read-only")

@router.post("/submit")
async def submit_code(submission: CodeSubmissionRequest, student_id: int):
    # Check classroom is active before accepting submission
    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == student_id
    ).first()
    check_classroom_active(enrollment.classroom_id)

    # Process submission...
```

**Frontend UI** (`frontend/src/components/ClassroomCard.tsx`):
```typescript
function ClassroomCard({ classroom }: Props) {
  if (classroom.status === 'archived') {
    return (
      <div className="card archived">
        <h3>{classroom.name} <span className="badge-archived">Archived</span></h3>
        <p>This classroom is in read-only mode. You can view past submissions but cannot submit new work.</p>
        <button onClick={() => router.push(`/classroom/${classroom.id}/history`)}>
          View History
        </button>
      </div>
    )
  }

  return (
    <div className="card active">
      <h3>{classroom.name}</h3>
      <button onClick={() => router.push(`/classroom/${classroom.id}`)}>
        Enter Classroom
      </button>
    </div>
  )
}
```

**Student Behavior in Archived Classroom**:
- Can view: Progress dashboard, past submissions, quiz scores, feedback
- Cannot: Submit new code, take quizzes, ask AI tutors, join classroom (if not already enrolled)
- UI: All input fields disabled, "Submit" buttons hidden, banner at top: "This classroom is archived"

**Teacher Behavior in Archived Classroom**:
- Can view: All student data, analytics, alerts
- Cannot: Assign new exercises, generate new quizzes, change classroom settings, re-activate classroom
- UI: "Archive" button changes to "Archived on [date]", dashboard shows read-only banner

**Edge Cases**:

1. **Student Attempts Submission in Archived Classroom**:
   - Backend returns 403 Forbidden with message "Classroom is archived and no longer accepts submissions"
   - Frontend shows modal: "This classroom is archived. You can view your past work but cannot submit new code."

2. **Teacher Archives Classroom While Students Active**:
   - All active students immediately see banner: "Classroom has been archived. Please save your work."
   - Any in-progress submissions (not yet submitted) lost (student sees warning before archive action)

3. **Student Joins Archived Classroom via Join Code**:
   - Backend rejects enrollment with 403 Forbidden
   - Frontend shows: "This classroom is archived and no longer accepts new students."

4. **Archived Classroom in Search Results**:
   - Teacher dashboard: Archived classrooms shown at bottom of list with "Archived" label
   - Student dashboard: Archived classrooms hidden by default, "Show Archived" toggle reveals them

**Testing Strategy**:
- Unit test: Verify state transitions reject invalid transitions (Archived → Active)
- Integration test: Archive classroom, attempt submission, verify rejection
- E2E test: Teacher archives classroom, student sees read-only UI, teacher can still view analytics
- Edge case test: Archive classroom while student has unsaved code, verify warning displayed

**Monitoring**:
- Metrics: Classrooms archived per week, average classroom lifespan (created → archived)
- Alerts: None (archival is expected behavior)

---

## Research Task 10: Curriculum Data Structure

**Question**: JSON schema for 8 Python modules with topics, exercises, and quizzes.

### Decision

**Hierarchical JSON Structure**:
- 8 Modules (Basics, Control Flow, Data Structures, Functions, OOP, Files, Errors, Libraries)
- Each module contains 4-6 Topics
- Each topic contains 3-5 Exercises and 1 Quiz (5-10 questions)

**Storage**: JSON files in `learnflow-app/data/modules/` directory, loaded at application startup.

### Rationale

- **Simplicity**: JSON is human-readable, easy to edit without database migrations
- **Version Control**: Curriculum changes tracked in git, easy to review diffs
- **Flexibility**: Can add modules/topics without schema changes
- **Performance**: Static JSON loaded once at startup, cached in memory (not queried per request)

### Alternatives Considered

**Option A: Store Curriculum in PostgreSQL** (database tables for modules/topics/exercises)
- **Pros**: Structured queries, referential integrity, teacher-editable via UI
- **Cons**: Curriculum is static in MVP (teachers can't customize), database overhead unnecessary, migrations for every content change
- **Rejected Because**: Premature optimization; curriculum changes infrequently, JSON is simpler

**Option B: Markdown Files with YAML Front Matter** (separate .md files per topic)
- **Pros**: Human-readable, supports rich formatting (images, links), familiar to developers
- **Cons**: Harder to query, no schema validation, file management complexity (80+ files)
- **Rejected Because**: Overkill for MVP; JSON is sufficient for text + code examples

**Option C: CMS (Contentful, Strapi)** (headless CMS for curriculum)
- **Pros**: Teacher UI for editing, versioning, collaboration, API-driven
- **Cons**: External dependency, hosting costs, learning curve, over-engineered for MVP
- **Rejected Because**: Curriculum is fixed in MVP; CMS is post-MVP enhancement

### Implementation Notes

**JSON Schema** (`learnflow-app/data/modules/schema.json`):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "modules": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": { "type": "string" },
          "number": { "type": "integer", "minimum": 1, "maximum": 8 },
          "name": { "type": "string" },
          "description": { "type": "string" },
          "estimated_hours": { "type": "integer" },
          "topics": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "id": { "type": "string" },
                "name": { "type": "string" },
                "concepts": { "type": "array", "items": { "type": "string" } },
                "explanation": { "type": "string" },
                "examples": {
                  "type": "array",
                  "items": {
                    "type": "object",
                    "properties": {
                      "code": { "type": "string" },
                      "output": { "type": "string" }
                    }
                  }
                },
                "exercises": {
                  "type": "array",
                  "items": {
                    "type": "object",
                    "properties": {
                      "id": { "type": "string" },
                      "difficulty": { "type": "string", "enum": ["beginner", "intermediate", "advanced"] },
                      "question": { "type": "string" },
                      "starter_code": { "type": "string" },
                      "test_cases": {
                        "type": "array",
                        "items": {
                          "type": "object",
                          "properties": {
                            "input": { "type": "string" },
                            "expected_output": { "type": "string" }
                          }
                        }
                      }
                    }
                  }
                },
                "quiz": {
                  "type": "object",
                  "properties": {
                    "id": { "type": "string" },
                    "questions": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "properties": {
                          "question": { "type": "string" },
                          "options": { "type": "array", "items": { "type": "string" } },
                          "correct_answer": { "type": "integer" },
                          "explanation": { "type": "string" }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

**Example Module** (`learnflow-app/data/modules/01-basics.json`):
```json
{
  "id": "module-01-basics",
  "number": 1,
  "name": "Python Basics",
  "description": "Learn fundamental Python concepts: variables, data types, operators, and basic I/O",
  "estimated_hours": 6,
  "topics": [
    {
      "id": "basics-variables",
      "name": "Variables & Assignment",
      "concepts": ["variable declaration", "assignment operator", "naming rules", "dynamic typing"],
      "explanation": "Variables store data values in Python. You create them using the assignment operator (=). Python is dynamically typed, so you don't need to declare the type explicitly.",
      "examples": [
        {
          "code": "name = \"Alice\"\nage = 25\nprint(f\"{name} is {age} years old\")",
          "output": "Alice is 25 years old"
        }
      ],
      "exercises": [
        {
          "id": "basics-variables-ex01",
          "difficulty": "beginner",
          "question": "Create a variable called `greeting` with the value \"Hello, World!\" and print it.",
          "starter_code": "# Write your code here\n",
          "test_cases": [
            {
              "input": "",
              "expected_output": "Hello, World!"
            }
          ]
        },
        {
          "id": "basics-variables-ex02",
          "difficulty": "beginner",
          "question": "Create two variables `x = 10` and `y = 20`, then print their sum.",
          "starter_code": "# Write your code here\n",
          "test_cases": [
            {
              "input": "",
              "expected_output": "30"
            }
          ]
        }
      ],
      "quiz": {
        "id": "basics-variables-quiz",
        "questions": [
          {
            "question": "Which of the following is a valid variable name in Python?",
            "options": ["2fast", "_speed", "my-var", "class"],
            "correct_answer": 1,
            "explanation": "_speed is valid. Variable names cannot start with numbers (2fast), cannot contain hyphens (my-var), and cannot be reserved keywords (class)."
          },
          {
            "question": "What is the output of: x = 5; x = x + 1; print(x)",
            "options": ["5", "6", "Error", "None"],
            "correct_answer": 1,
            "explanation": "x is reassigned to x + 1, which is 6."
          }
        ]
      }
    }
  ]
}
```

**Loading Curriculum** (`backend/src/student-service/curriculum.py`):
```python
import json
from pathlib import Path
from typing import Dict, List

class CurriculumLoader:
    def __init__(self, data_dir: str = "data/modules"):
        self.data_dir = Path(data_dir)
        self.modules: List[Dict] = []
        self.load_all_modules()

    def load_all_modules(self):
        for json_file in sorted(self.data_dir.glob("*.json")):
            with open(json_file, 'r') as f:
                module_data = json.load(f)
                self.modules.append(module_data)

    def get_module(self, module_id: str) -> Dict:
        return next((m for m in self.modules if m['id'] == module_id), None)

    def get_topic(self, topic_id: str) -> Dict:
        for module in self.modules:
            for topic in module['topics']:
                if topic['id'] == topic_id:
                    return topic
        return None

    def get_exercise(self, exercise_id: str) -> Dict:
        for module in self.modules:
            for topic in module['topics']:
                for exercise in topic['exercises']:
                    if exercise['id'] == exercise_id:
                        return exercise
        return None

# Global curriculum instance (loaded once at startup)
curriculum = CurriculumLoader()
```

**API Endpoints** (`backend/src/student-service/routes.py`):
```python
@router.get("/modules")
async def get_modules():
    return {"modules": curriculum.modules}

@router.get("/modules/{module_id}")
async def get_module(module_id: str):
    module = curriculum.get_module(module_id)
    if not module:
        raise HTTPException(status_code=404, detail="Module not found")
    return module

@router.get("/topics/{topic_id}")
async def get_topic(topic_id: str):
    topic = curriculum.get_topic(topic_id)
    if not topic:
        raise HTTPException(status_code=404, detail="Topic not found")
    return topic

@router.get("/exercises/{exercise_id}")
async def get_exercise(exercise_id: str):
    exercise = curriculum.get_exercise(exercise_id)
    if not exercise:
        raise HTTPException(status_code=404, detail="Exercise not found")
    return exercise
```

**Curriculum Validation** (CI/CD check):
```python
import json
import jsonschema

def validate_curriculum():
    with open('data/modules/schema.json', 'r') as f:
        schema = json.load(f)

    for json_file in Path('data/modules').glob('*.json'):
        with open(json_file, 'r') as f:
            module_data = json.load(f)

        try:
            jsonschema.validate(instance=module_data, schema=schema)
            print(f"✓ {json_file.name} valid")
        except jsonschema.ValidationError as e:
            print(f"✗ {json_file.name} invalid: {e.message}")
            raise

# Run in CI/CD pipeline before build
if __name__ == "__main__":
    validate_curriculum()
```

**Module Coverage** (8 modules planned):
1. **Basics**: Variables, data types, operators, input/output (6 topics)
2. **Control Flow**: If/else, for loops, while loops, break/continue (5 topics)
3. **Data Structures**: Lists, tuples, sets, dictionaries (6 topics)
4. **Functions**: Defining functions, parameters, return values, scope (5 topics)
5. **Object-Oriented Programming**: Classes, objects, inheritance, polymorphism (6 topics)
6. **File I/O**: Reading files, writing files, CSV, JSON (4 topics)
7. **Error Handling**: Try/except, custom exceptions, debugging (4 topics)
8. **Libraries**: Standard library, pip, popular packages (numpy, requests) (5 topics)

**Total Content**:
- 8 modules × 5 topics avg = 40 topics
- 40 topics × 4 exercises avg = 160 exercises
- 40 topics × 1 quiz = 40 quizzes (400 questions at 10 questions/quiz)

**Content Authoring Process**:
1. Author module JSON files using schema
2. Validate JSON with `validate_curriculum.py` script
3. Commit to git (curriculum changes tracked in version control)
4. CI/CD pipeline validates JSON schema on every commit
5. Deployment: JSON files bundled in Docker image, loaded at container startup

**Testing Strategy**:
- Schema validation: Verify all JSON files pass jsonschema validation
- API test: Query `/modules`, verify all 8 modules returned
- Exercise test: Sample 10 random exercises, verify test cases are solvable
- Quiz test: Human review of 20 random quiz questions for accuracy

**Future Enhancements** (post-MVP):
- Teacher UI for editing curriculum (CMS integration)
- Difficulty auto-adjustment based on student mastery
- Community-contributed exercises (moderation required)

---

## Summary of Decisions

| Research Task | Decision | Key Rationale |
|---------------|----------|---------------|
| 1. AI Agent Architecture | 6 microservices (Triage, Concepts, Code Review, Debug, Exercise, Progress) | Independent scaling, failure isolation, Kubernetes-native |
| 2. Code Sandbox Security | Docker + seccomp + no-new-privileges + resource limits | Defense in depth, industry standard, K8s-compatible |
| 3. OpenAI API Fallback | Redis cache + pre-scripted fallbacks | Cost optimization (60-80% savings), reliability (AI unavailable fallback) |
| 4. Mastery Calculation | (Exercises×0.40) + (Quizzes×0.30) + (Quality×0.20) + (Streak×0.10) | Balanced assessment, rewards consistency, latest quiz matters |
| 5. Struggle Detection | Kafka event stream processing with 5 pattern-matching rules | Real-time (<30s), scalable, low false positives |
| 6. Data Retention | K8s CronJob deletes submissions/quizzes/alerts after enrollment + 1 year | Storage optimization, privacy compliance, automated enforcement |
| 7. MCP Integration | Code Runner + API Gateway with /mcp/state, /logs, /schema, /metrics | AI observability, debugging efficiency, 20% evaluation score |
| 8. Monaco Editor | Next.js `dynamic()` with `ssr: false` | Monaco requires DOM, performance (dynamic import), official pattern |
| 9. Classroom State Machine | Active/Archived (teacher-initiated, irreversible) | Simplicity, data integrity, teacher control |
| 10. Curriculum Data Structure | JSON files (8 modules, 40 topics, 160 exercises, 40 quizzes) | Human-readable, version control, performance (cache in memory) |

---

## Next Steps

1. **Validate Research with Stakeholders**: Review decisions with team lead, confirm no objections
2. **Proceed to Phase 1 Design**: Create `data-model.md`, `contracts/*.yaml`, `quickstart.md` based on research findings
3. **Update Agent Context**: Run `update-agent-context.ps1` to sync research findings with Claude/Goose context
4. **Generate Tasks**: Run `/sp.tasks` to create detailed implementation tasks based on plan + research

---

**Research Status**: Complete | **Ready for Phase 1 Design**
