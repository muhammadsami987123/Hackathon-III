# Data Model Specification: LearnFlow Application

**Feature**: `004-learnflow-application`
**Created**: 2025-12-22
**Status**: Draft
**Version**: 1.0

## Overview

This document defines the complete data model for the LearnFlow AI-Powered Python Tutoring Platform, including PostgreSQL entity schemas, Kafka event schemas, data retention policies, and entity relationships.

---

## Table of Contents

1. [PostgreSQL Entity Schemas](#postgresql-entity-schemas)
2. [Kafka Event Schemas](#kafka-event-schemas)
3. [Data Retention Rules](#data-retention-rules)
4. [Entity Relationship Diagram](#entity-relationship-diagram)
5. [Indexes and Performance](#indexes-and-performance)
6. [Migration Strategy](#migration-strategy)

---

## PostgreSQL Entity Schemas

### 1. User

Represents a person using the platform (student or teacher).

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('student', 'teacher')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

**Relationships**:
- One-to-Many with `classroom` (as teacher)
- One-to-Many with `enrollment` (as student)
- One-to-Many with `student_progress`
- One-to-Many with `code_submission`
- One-to-Many with `quiz_response`
- One-to-Many with `struggle_alert`

**Sample Data**:
```sql
INSERT INTO users (id, email, name, password_hash, role) VALUES
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'maya.student@example.com', 'Maya Johnson', '$2b$12$KIXxJH8H3qJ7vF3YYZ9Gxe9J5Q8gR3.HJK8L9M0N1P2Q3R4S5T6U7V', 'student'),
('b2c3d4e5-f6a7-8901-bcde-f12345678901', 'james.lee@example.com', 'James Lee', '$2b$12$LJYyKI9I4rK8wG4ZZA0Hyf0K6R9hS4.IKL9M0N1O2P3Q4R5S6T7U8W', 'student'),
('c3d4e5f6-a7b8-9012-cdef-123456789012', 'rodriguez@school.edu', 'Mr. Rodriguez', '$2b$12$MKZzLJ0J5sL9xH5AAB1Izg1L7S0iT5.JLM0N1O2P3Q4R5S6T7U8V9X', 'teacher');
```

---

### 2. Classroom

Represents a teacher-managed group of students.

```sql
CREATE TABLE classroom (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    join_code VARCHAR(20) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    archived_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT valid_archived_at CHECK (
        (status = 'archived' AND archived_at IS NOT NULL) OR
        (status = 'active' AND archived_at IS NULL)
    )
);

-- Indexes
CREATE INDEX idx_classroom_teacher_id ON classroom(teacher_id);
CREATE INDEX idx_classroom_join_code ON classroom(join_code);
CREATE INDEX idx_classroom_status ON classroom(status);
CREATE INDEX idx_classroom_created_at ON classroom(created_at);

-- Trigger for updated_at
CREATE TRIGGER update_classroom_updated_at
BEFORE UPDATE ON classroom
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger to set archived_at when status changes to archived
CREATE OR REPLACE FUNCTION set_archived_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'archived' AND OLD.status = 'active' THEN
        NEW.archived_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_classroom_archived_at
BEFORE UPDATE ON classroom
FOR EACH ROW
EXECUTE FUNCTION set_archived_at();
```

**Relationships**:
- Many-to-One with `users` (teacher)
- One-to-Many with `enrollment`
- One-to-Many with `struggle_alert`

**Sample Data**:
```sql
INSERT INTO classroom (id, name, teacher_id, join_code, status) VALUES
('d4e5f6a7-b8c9-0123-def0-234567890123', 'Intro to Python - Fall 2025', 'c3d4e5f6-a7b8-9012-cdef-123456789012', 'PYTHON2025', 'active'),
('e5f6a7b8-c9d0-1234-ef01-345678901234', 'Advanced Python - Spring 2025', 'c3d4e5f6-a7b8-9012-cdef-123456789012', 'ADVPY2025', 'active'),
('f6a7b8c9-d0e1-2345-f012-456789012345', 'Python Basics - Summer 2024', 'c3d4e5f6-a7b8-9012-cdef-123456789012', 'SUMMER2024', 'archived');
```

---

### 3. Enrollment

Represents the many-to-many relationship between students and classrooms.

```sql
CREATE TABLE enrollment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    classroom_id UUID NOT NULL REFERENCES classroom(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT unique_student_classroom UNIQUE(student_id, classroom_id)
);

-- Indexes
CREATE INDEX idx_enrollment_student_id ON enrollment(student_id);
CREATE INDEX idx_enrollment_classroom_id ON enrollment(classroom_id);
CREATE INDEX idx_enrollment_enrolled_at ON enrollment(enrolled_at);
CREATE INDEX idx_enrollment_ended_at ON enrollment(ended_at);

-- Trigger to set ended_at when classroom is archived
CREATE OR REPLACE FUNCTION end_enrollments_on_archive()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'archived' AND OLD.status = 'active' THEN
        UPDATE enrollment
        SET ended_at = NOW()
        WHERE classroom_id = NEW.id AND ended_at IS NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_end_enrollments_on_archive
AFTER UPDATE ON classroom
FOR EACH ROW
EXECUTE FUNCTION end_enrollments_on_archive();
```

**Relationships**:
- Many-to-One with `users` (student)
- Many-to-One with `classroom`

**Sample Data**:
```sql
INSERT INTO enrollment (student_id, classroom_id, enrolled_at, ended_at) VALUES
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'd4e5f6a7-b8c9-0123-def0-234567890123', '2025-09-01 08:00:00+00', NULL),
('b2c3d4e5-f6a7-8901-bcde-f12345678901', 'd4e5f6a7-b8c9-0123-def0-234567890123', '2025-09-01 09:15:00+00', NULL),
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'f6a7b8c9-d0e1-2345-f012-456789012345', '2024-06-15 10:00:00+00', '2024-08-30 17:00:00+00');
```

---

### 4. StudentProgress

Tracks mastery level and learning metrics per student per topic.

```sql
CREATE TABLE student_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    module_number INT NOT NULL CHECK (module_number BETWEEN 1 AND 8),
    topic VARCHAR(100) NOT NULL,
    mastery_level DECIMAL(5, 2) NOT NULL DEFAULT 0.00 CHECK (mastery_level BETWEEN 0 AND 100),
    exercises_completed INT NOT NULL DEFAULT 0 CHECK (exercises_completed >= 0),
    quizzes_taken INT NOT NULL DEFAULT 0 CHECK (quizzes_taken >= 0),
    last_quiz_score DECIMAL(5, 2) CHECK (last_quiz_score IS NULL OR (last_quiz_score BETWEEN 0 AND 100)),
    code_quality_avg DECIMAL(5, 2) DEFAULT 0.00 CHECK (code_quality_avg BETWEEN 0 AND 100),
    streak_days INT NOT NULL DEFAULT 0 CHECK (streak_days >= 0),
    last_activity_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT unique_student_module_topic UNIQUE(student_id, module_number, topic)
);

-- Indexes
CREATE INDEX idx_student_progress_student_id ON student_progress(student_id);
CREATE INDEX idx_student_progress_module_number ON student_progress(module_number);
CREATE INDEX idx_student_progress_topic ON student_progress(topic);
CREATE INDEX idx_student_progress_mastery_level ON student_progress(mastery_level);
CREATE INDEX idx_student_progress_last_activity ON student_progress(last_activity_at);

-- Trigger for updated_at
CREATE TRIGGER update_student_progress_updated_at
BEFORE UPDATE ON student_progress
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

**Relationships**:
- Many-to-One with `users` (student)

**Mastery Formula**:
```
mastery_level = (exercises_completed_pct × 0.40) +
                (last_quiz_score × 0.30) +
                (code_quality_avg × 0.20) +
                (streak_factor × 0.10)
```

**Mastery Levels**:
- Beginner: 0-40% (red badge)
- Learning: 41-70% (yellow badge)
- Proficient: 71-90% (green badge)
- Mastered: 91-100% (blue badge)

**Sample Data**:
```sql
INSERT INTO student_progress (student_id, module_number, topic, mastery_level, exercises_completed, quizzes_taken, last_quiz_score, code_quality_avg, streak_days, last_activity_at) VALUES
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 1, 'Variables & Assignment', 85.50, 12, 2, 90.00, 82.00, 7, '2025-12-21 14:30:00+00'),
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 2, 'For Loops', 68.25, 8, 1, 80.00, 75.00, 7, '2025-12-21 16:45:00+00'),
('b2c3d4e5-f6a7-8901-bcde-f12345678901', 1, 'Variables & Assignment', 32.50, 3, 1, 45.00, 50.00, 2, '2025-12-20 11:20:00+00');
```

---

### 5. CodeSubmission

Represents student attempts at solving coding exercises.

```sql
CREATE TABLE code_submission (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    exercise_id VARCHAR(100) NOT NULL,
    classroom_id UUID REFERENCES classroom(id) ON DELETE SET NULL,
    code_text TEXT NOT NULL,
    output TEXT,
    error_message TEXT,
    grade DECIMAL(5, 2) CHECK (grade IS NULL OR (grade BETWEEN 0 AND 100)),
    feedback TEXT,
    execution_time_ms INT CHECK (execution_time_ms >= 0),
    memory_used_mb DECIMAL(8, 2) CHECK (memory_used_mb >= 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'executed', 'error', 'timeout', 'graded')),
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    graded_at TIMESTAMP WITH TIME ZONE,
    retention_expires_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT execution_status_validation CHECK (
        (status = 'error' AND error_message IS NOT NULL) OR
        (status != 'error')
    )
);

-- Indexes
CREATE INDEX idx_code_submission_student_id ON code_submission(student_id);
CREATE INDEX idx_code_submission_exercise_id ON code_submission(exercise_id);
CREATE INDEX idx_code_submission_classroom_id ON code_submission(classroom_id);
CREATE INDEX idx_code_submission_submitted_at ON code_submission(submitted_at);
CREATE INDEX idx_code_submission_status ON code_submission(status);
CREATE INDEX idx_code_submission_grade ON code_submission(grade);
CREATE INDEX idx_code_submission_retention_expires ON code_submission(retention_expires_at);

-- Trigger to set retention expiration date based on enrollment end date
CREATE OR REPLACE FUNCTION set_code_submission_retention()
RETURNS TRIGGER AS $$
DECLARE
    enrollment_end_date TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Find the enrollment end date for this student and classroom
    SELECT ended_at INTO enrollment_end_date
    FROM enrollment
    WHERE student_id = NEW.student_id
      AND classroom_id = NEW.classroom_id;

    -- If enrollment has ended, set expiration to ended_at + 1 year
    -- Otherwise, leave NULL (will be set when enrollment ends)
    IF enrollment_end_date IS NOT NULL THEN
        NEW.retention_expires_at = enrollment_end_date + INTERVAL '1 year';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_code_submission_retention
BEFORE INSERT ON code_submission
FOR EACH ROW
EXECUTE FUNCTION set_code_submission_retention();
```

**Relationships**:
- Many-to-One with `users` (student)
- Many-to-One with `classroom` (optional, can be independent practice)

**Sample Data**:
```sql
INSERT INTO code_submission (id, student_id, exercise_id, classroom_id, code_text, output, grade, feedback, execution_time_ms, memory_used_mb, status, submitted_at, graded_at) VALUES
('01234567-89ab-cdef-0123-456789abcdef', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'ex_basics_variables_01', 'd4e5f6a7-b8c9-0123-def0-234567890123', 'name = "Maya"\nprint(f"Hello, {name}!")', 'Hello, Maya!', 95.00, 'Excellent! Clean code with proper string formatting.', 145, 2.3, 'graded', '2025-12-20 10:15:00+00', '2025-12-20 10:15:02+00'),
('12345678-9abc-def0-1234-56789abcdef0', 'b2c3d4e5-f6a7-8901-bcde-f12345678901', 'ex_basics_variables_02', 'd4e5f6a7-b8c9-0123-def0-234567890123', 'x = 10\nprint(x)', '10', 85.00, 'Good work! Consider adding descriptive variable names.', 98, 1.8, 'graded', '2025-12-20 11:30:00+00', '2025-12-20 11:30:01+00'),
('23456789-abcd-ef01-2345-6789abcdef01', 'b2c3d4e5-f6a7-8901-bcde-f12345678901', 'ex_control_for_01', 'd4e5f6a7-b8c9-0123-def0-234567890123', 'for i in range(5):\n  print(x)', NULL, NULL, NULL, NULL, NULL, 'error', '2025-12-21 09:45:00+00', NULL);
```

---

### 6. QuizResponse

Represents completed quiz attempts.

```sql
CREATE TABLE quiz_response (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quiz_id VARCHAR(100) NOT NULL,
    classroom_id UUID REFERENCES classroom(id) ON DELETE SET NULL,
    score DECIMAL(5, 2) NOT NULL CHECK (score BETWEEN 0 AND 100),
    answers JSONB NOT NULL,
    total_questions INT NOT NULL CHECK (total_questions > 0),
    correct_answers INT NOT NULL CHECK (correct_answers >= 0 AND correct_answers <= total_questions),
    time_taken_seconds INT CHECK (time_taken_seconds >= 0),
    completed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    retention_expires_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT score_accuracy_check CHECK (
        score = ROUND((correct_answers::DECIMAL / total_questions) * 100, 2)
    )
);

-- Indexes
CREATE INDEX idx_quiz_response_student_id ON quiz_response(student_id);
CREATE INDEX idx_quiz_response_quiz_id ON quiz_response(quiz_id);
CREATE INDEX idx_quiz_response_classroom_id ON quiz_response(classroom_id);
CREATE INDEX idx_quiz_response_completed_at ON quiz_response(completed_at);
CREATE INDEX idx_quiz_response_score ON quiz_response(score);
CREATE INDEX idx_quiz_response_retention_expires ON quiz_response(retention_expires_at);

-- Trigger to set retention expiration date
CREATE OR REPLACE FUNCTION set_quiz_response_retention()
RETURNS TRIGGER AS $$
DECLARE
    enrollment_end_date TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT ended_at INTO enrollment_end_date
    FROM enrollment
    WHERE student_id = NEW.student_id
      AND classroom_id = NEW.classroom_id;

    IF enrollment_end_date IS NOT NULL THEN
        NEW.retention_expires_at = enrollment_end_date + INTERVAL '1 year';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_quiz_response_retention
BEFORE INSERT ON quiz_response
FOR EACH ROW
EXECUTE FUNCTION set_quiz_response_retention();
```

**Relationships**:
- Many-to-One with `users` (student)
- Many-to-One with `classroom` (optional)

**Sample Data**:
```sql
INSERT INTO quiz_response (student_id, quiz_id, classroom_id, score, answers, total_questions, correct_answers, time_taken_seconds, completed_at) VALUES
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'quiz_basics_module1', 'd4e5f6a7-b8c9-0123-def0-234567890123', 90.00,
'[
  {"question_id": "q1", "student_answer": "int", "correct_answer": "int", "is_correct": true},
  {"question_id": "q2", "student_answer": "=", "correct_answer": "=", "is_correct": true},
  {"question_id": "q3", "student_answer": "mutable", "correct_answer": "immutable", "is_correct": false}
]'::jsonb, 10, 9, 420, '2025-12-19 15:30:00+00'),
('b2c3d4e5-f6a7-8901-bcde-f12345678901', 'quiz_basics_module1', 'd4e5f6a7-b8c9-0123-def0-234567890123', 45.00,
'[
  {"question_id": "q1", "student_answer": "str", "correct_answer": "int", "is_correct": false},
  {"question_id": "q2", "student_answer": "==", "correct_answer": "=", "is_correct": false}
]'::jsonb, 10, 4, 890, '2025-12-19 16:15:00+00');
```

---

### 7. StruggleAlert

Represents detected learning difficulties requiring teacher intervention.

```sql
CREATE TABLE struggle_alert (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    classroom_id UUID NOT NULL REFERENCES classroom(id) ON DELETE CASCADE,
    trigger_type VARCHAR(50) NOT NULL CHECK (trigger_type IN (
        'error_pattern',
        'time_stuck',
        'quiz_failure',
        'help_request',
        'execution_failures'
    )),
    description TEXT NOT NULL,
    metadata JSONB,
    severity VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    resolved BOOLEAN NOT NULL DEFAULT FALSE,
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE,
    notified_at TIMESTAMP WITH TIME ZONE,
    retention_expires_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT resolution_consistency CHECK (
        (resolved = TRUE AND resolved_at IS NOT NULL) OR
        (resolved = FALSE AND resolved_at IS NULL)
    )
);

-- Indexes
CREATE INDEX idx_struggle_alert_student_id ON struggle_alert(student_id);
CREATE INDEX idx_struggle_alert_classroom_id ON struggle_alert(classroom_id);
CREATE INDEX idx_struggle_alert_trigger_type ON struggle_alert(trigger_type);
CREATE INDEX idx_struggle_alert_severity ON struggle_alert(severity);
CREATE INDEX idx_struggle_alert_resolved ON struggle_alert(resolved);
CREATE INDEX idx_struggle_alert_created_at ON struggle_alert(created_at);
CREATE INDEX idx_struggle_alert_notified_at ON struggle_alert(notified_at);
CREATE INDEX idx_struggle_alert_retention_expires ON struggle_alert(retention_expires_at);

-- Composite index for unresolved alerts by classroom
CREATE INDEX idx_struggle_alert_unresolved_classroom
ON struggle_alert(classroom_id, resolved, created_at DESC)
WHERE resolved = FALSE;

-- Trigger to set retention expiration date
CREATE OR REPLACE FUNCTION set_struggle_alert_retention()
RETURNS TRIGGER AS $$
DECLARE
    enrollment_end_date TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT ended_at INTO enrollment_end_date
    FROM enrollment
    WHERE student_id = NEW.student_id
      AND classroom_id = NEW.classroom_id;

    IF enrollment_end_date IS NOT NULL THEN
        NEW.retention_expires_at = enrollment_end_date + INTERVAL '1 year';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_struggle_alert_retention
BEFORE INSERT ON struggle_alert
FOR EACH ROW
EXECUTE FUNCTION set_struggle_alert_retention();
```

**Relationships**:
- Many-to-One with `users` (student)
- Many-to-One with `classroom`

**Trigger Types**:
- `error_pattern`: Same error encountered 3+ times
- `time_stuck`: Student stuck on exercise >10 minutes
- `quiz_failure`: Quiz score <50%
- `help_request`: Student says "I don't understand" 3+ times
- `execution_failures`: 5+ consecutive execution failures

**Sample Data**:
```sql
INSERT INTO struggle_alert (student_id, classroom_id, trigger_type, description, metadata, severity, resolved, created_at, notified_at) VALUES
('b2c3d4e5-f6a7-8901-bcde-f12345678901', 'd4e5f6a7-b8c9-0123-def0-234567890123', 'error_pattern', 'James encountered NameError 3 times on exercise ex_control_for_01',
'{"error_type": "NameError", "occurrences": 3, "exercise_id": "ex_control_for_01", "error_message": "name ''x'' is not defined"}'::jsonb, 'high', FALSE, '2025-12-21 09:50:00+00', '2025-12-21 09:50:05+00'),
('b2c3d4e5-f6a7-8901-bcde-f12345678901', 'd4e5f6a7-b8c9-0123-def0-234567890123', 'quiz_failure', 'James scored 45% on quiz_basics_module1',
'{"quiz_id": "quiz_basics_module1", "score": 45.0, "threshold": 50.0}'::jsonb, 'medium', FALSE, '2025-12-19 16:16:00+00', '2025-12-19 16:16:02+00'),
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'd4e5f6a7-b8c9-0123-def0-234567890123', 'time_stuck', 'Maya stuck on ex_datastructures_dict_03 for 12 minutes',
'{"exercise_id": "ex_datastructures_dict_03", "time_stuck_minutes": 12}'::jsonb, 'low', TRUE, '2025-12-18 14:30:00+00', '2025-12-18 14:30:03+00');
```

---

## Kafka Event Schemas

### 1. code.executed Event

Published when student code executes successfully or with errors.

**Topic**: `learnflow.code.executed`

**Schema**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "event_id",
    "event_type",
    "timestamp",
    "data"
  ],
  "properties": {
    "event_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique identifier for this event"
    },
    "event_type": {
      "type": "string",
      "const": "code.executed",
      "description": "Event type identifier"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp when event occurred"
    },
    "data": {
      "type": "object",
      "required": [
        "submission_id",
        "student_id",
        "exercise_id",
        "status",
        "execution_time_ms"
      ],
      "properties": {
        "submission_id": {
          "type": "string",
          "format": "uuid",
          "description": "Reference to code_submission.id"
        },
        "student_id": {
          "type": "string",
          "format": "uuid",
          "description": "Reference to users.id (student)"
        },
        "exercise_id": {
          "type": "string",
          "description": "Exercise identifier"
        },
        "classroom_id": {
          "type": ["string", "null"],
          "format": "uuid",
          "description": "Reference to classroom.id (optional)"
        },
        "status": {
          "type": "string",
          "enum": ["executed", "error", "timeout"],
          "description": "Execution outcome"
        },
        "execution_time_ms": {
          "type": "integer",
          "minimum": 0,
          "description": "Time taken to execute code in milliseconds"
        },
        "memory_used_mb": {
          "type": "number",
          "minimum": 0,
          "description": "Memory consumed during execution"
        },
        "output": {
          "type": ["string", "null"],
          "description": "Stdout from code execution"
        },
        "error_message": {
          "type": ["string", "null"],
          "description": "Error message if status is error"
        },
        "error_type": {
          "type": ["string", "null"],
          "description": "Python exception type (e.g., NameError, SyntaxError)"
        }
      }
    }
  }
}
```

**Sample Event**:
```json
{
  "event_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "event_type": "code.executed",
  "timestamp": "2025-12-21T14:30:45.123Z",
  "data": {
    "submission_id": "01234567-89ab-cdef-0123-456789abcdef",
    "student_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "exercise_id": "ex_basics_variables_01",
    "classroom_id": "d4e5f6a7-b8c9-0123-def0-234567890123",
    "status": "executed",
    "execution_time_ms": 145,
    "memory_used_mb": 2.3,
    "output": "Hello, Maya!",
    "error_message": null,
    "error_type": null
  }
}
```

**Consumers**:
- Code Review Agent (triggers auto-grading)
- Progress Agent (updates mastery calculation)
- Struggle Detection Service (monitors error patterns)

---

### 2. quiz.submitted Event

Published when a student completes a quiz.

**Topic**: `learnflow.quiz.submitted`

**Schema**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "event_id",
    "event_type",
    "timestamp",
    "data"
  ],
  "properties": {
    "event_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique identifier for this event"
    },
    "event_type": {
      "type": "string",
      "const": "quiz.submitted",
      "description": "Event type identifier"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp when event occurred"
    },
    "data": {
      "type": "object",
      "required": [
        "response_id",
        "student_id",
        "quiz_id",
        "score",
        "total_questions",
        "correct_answers"
      ],
      "properties": {
        "response_id": {
          "type": "string",
          "format": "uuid",
          "description": "Reference to quiz_response.id"
        },
        "student_id": {
          "type": "string",
          "format": "uuid",
          "description": "Reference to users.id (student)"
        },
        "quiz_id": {
          "type": "string",
          "description": "Quiz identifier"
        },
        "classroom_id": {
          "type": ["string", "null"],
          "format": "uuid",
          "description": "Reference to classroom.id (optional)"
        },
        "score": {
          "type": "number",
          "minimum": 0,
          "maximum": 100,
          "description": "Quiz score as percentage"
        },
        "total_questions": {
          "type": "integer",
          "minimum": 1,
          "description": "Total number of questions in quiz"
        },
        "correct_answers": {
          "type": "integer",
          "minimum": 0,
          "description": "Number of correct answers"
        },
        "time_taken_seconds": {
          "type": ["integer", "null"],
          "minimum": 0,
          "description": "Time taken to complete quiz"
        },
        "module_number": {
          "type": "integer",
          "minimum": 1,
          "maximum": 8,
          "description": "Module this quiz belongs to"
        },
        "topic": {
          "type": "string",
          "description": "Specific topic being assessed"
        }
      }
    }
  }
}
```

**Sample Event**:
```json
{
  "event_id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
  "event_type": "quiz.submitted",
  "timestamp": "2025-12-19T15:30:12.456Z",
  "data": {
    "response_id": "c3d4e5f6-a7b8-9012-cdef-123456789012",
    "student_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "quiz_id": "quiz_basics_module1",
    "classroom_id": "d4e5f6a7-b8c9-0123-def0-234567890123",
    "score": 90.00,
    "total_questions": 10,
    "correct_answers": 9,
    "time_taken_seconds": 420,
    "module_number": 1,
    "topic": "Variables & Assignment"
  }
}
```

**Consumers**:
- Progress Agent (updates mastery level)
- Struggle Detection Service (triggers alert if score <50%)
- Teacher Dashboard Service (updates class analytics)

---

### 3. struggle.detected Event

Published when the system detects a student is struggling.

**Topic**: `learnflow.struggle.detected`

**Schema**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "event_id",
    "event_type",
    "timestamp",
    "data"
  ],
  "properties": {
    "event_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique identifier for this event"
    },
    "event_type": {
      "type": "string",
      "const": "struggle.detected",
      "description": "Event type identifier"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp when event occurred"
    },
    "data": {
      "type": "object",
      "required": [
        "alert_id",
        "student_id",
        "classroom_id",
        "trigger_type",
        "severity"
      ],
      "properties": {
        "alert_id": {
          "type": "string",
          "format": "uuid",
          "description": "Reference to struggle_alert.id"
        },
        "student_id": {
          "type": "string",
          "format": "uuid",
          "description": "Reference to users.id (student)"
        },
        "classroom_id": {
          "type": "string",
          "format": "uuid",
          "description": "Reference to classroom.id"
        },
        "trigger_type": {
          "type": "string",
          "enum": [
            "error_pattern",
            "time_stuck",
            "quiz_failure",
            "help_request",
            "execution_failures"
          ],
          "description": "Type of struggle detected"
        },
        "description": {
          "type": "string",
          "description": "Human-readable description of the struggle"
        },
        "severity": {
          "type": "string",
          "enum": ["low", "medium", "high", "critical"],
          "description": "Severity level for prioritization"
        },
        "metadata": {
          "type": "object",
          "description": "Additional context-specific data",
          "properties": {
            "exercise_id": {
              "type": "string"
            },
            "error_type": {
              "type": "string"
            },
            "occurrences": {
              "type": "integer"
            },
            "time_stuck_minutes": {
              "type": "integer"
            },
            "quiz_score": {
              "type": "number"
            }
          }
        }
      }
    }
  }
}
```

**Sample Event**:
```json
{
  "event_id": "d4e5f6a7-b8c9-0123-def0-234567890123",
  "event_type": "struggle.detected",
  "timestamp": "2025-12-21T09:50:03.789Z",
  "data": {
    "alert_id": "e5f6a7b8-c9d0-1234-ef01-345678901234",
    "student_id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
    "classroom_id": "d4e5f6a7-b8c9-0123-def0-234567890123",
    "trigger_type": "error_pattern",
    "description": "James encountered NameError 3 times on exercise ex_control_for_01",
    "severity": "high",
    "metadata": {
      "error_type": "NameError",
      "occurrences": 3,
      "exercise_id": "ex_control_for_01",
      "error_message": "name 'x' is not defined"
    }
  }
}
```

**Consumers**:
- Notification Service (sends in-app notifications and email digests to teachers)
- Exercise Agent (generates remedial exercises)
- Teacher Dashboard Service (updates notification badge count)

---

### 4. progress.updated Event

Published when a student's mastery level or progress metrics change.

**Topic**: `learnflow.progress.updated`

**Schema**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "event_id",
    "event_type",
    "timestamp",
    "data"
  ],
  "properties": {
    "event_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique identifier for this event"
    },
    "event_type": {
      "type": "string",
      "const": "progress.updated",
      "description": "Event type identifier"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp when event occurred"
    },
    "data": {
      "type": "object",
      "required": [
        "progress_id",
        "student_id",
        "module_number",
        "topic",
        "mastery_level",
        "previous_mastery_level"
      ],
      "properties": {
        "progress_id": {
          "type": "string",
          "format": "uuid",
          "description": "Reference to student_progress.id"
        },
        "student_id": {
          "type": "string",
          "format": "uuid",
          "description": "Reference to users.id (student)"
        },
        "module_number": {
          "type": "integer",
          "minimum": 1,
          "maximum": 8,
          "description": "Module number"
        },
        "topic": {
          "type": "string",
          "description": "Specific topic within the module"
        },
        "mastery_level": {
          "type": "number",
          "minimum": 0,
          "maximum": 100,
          "description": "New mastery percentage"
        },
        "previous_mastery_level": {
          "type": "number",
          "minimum": 0,
          "maximum": 100,
          "description": "Previous mastery percentage"
        },
        "mastery_tier": {
          "type": "string",
          "enum": ["beginner", "learning", "proficient", "mastered"],
          "description": "Mastery tier based on percentage"
        },
        "tier_changed": {
          "type": "boolean",
          "description": "Whether mastery tier changed (triggers celebration)"
        },
        "exercises_completed": {
          "type": "integer",
          "description": "Total exercises completed for this topic"
        },
        "quizzes_taken": {
          "type": "integer",
          "description": "Total quizzes taken for this topic"
        },
        "streak_days": {
          "type": "integer",
          "description": "Consecutive days with activity"
        }
      }
    }
  }
}
```

**Sample Event**:
```json
{
  "event_id": "f6a7b8c9-d0e1-2345-f012-456789012345",
  "event_type": "progress.updated",
  "timestamp": "2025-12-21T16:45:30.123Z",
  "data": {
    "progress_id": "01234567-89ab-cdef-0123-456789abcdef",
    "student_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "module_number": 2,
    "topic": "For Loops",
    "mastery_level": 72.50,
    "previous_mastery_level": 68.25,
    "mastery_tier": "proficient",
    "tier_changed": true,
    "exercises_completed": 9,
    "quizzes_taken": 2,
    "streak_days": 7
  }
}
```

**Consumers**:
- Student Dashboard Service (updates progress visualizations)
- Notification Service (sends tier-up celebration messages)
- Analytics Service (tracks learning velocity)
- Teacher Dashboard Service (updates class-wide progress metrics)

---

## Data Retention Rules

### Retention Policy Overview

**Purpose**: Balance historical data preservation for academic records with storage cost management and privacy compliance.

### Entity-Specific Retention

#### Permanent Retention (No Expiration)
- **users**: User accounts retained indefinitely
- **classroom**: Classroom records retained indefinitely (even when archived)
- **enrollment**: Enrollment history retained indefinitely for academic records
- **student_progress**: Progress records retained indefinitely for long-term learning history

#### Time-Limited Retention (Active Enrollment + 1 Year)
- **code_submission**: Retained during active enrollment + 1 year after enrollment ends
- **quiz_response**: Retained during active enrollment + 1 year after enrollment ends
- **struggle_alert**: Retained during active enrollment + 1 year after enrollment ends

### Retention Calculation Logic

**Trigger**: When an enrollment ends (either manually or via classroom archival)

**Formula**:
```
retention_expires_at = enrollment.ended_at + INTERVAL '1 year'
```

**Example Timeline**:
1. Student enrolls in classroom: Sept 1, 2025
2. Student submits code throughout semester
3. Classroom archived: Dec 20, 2025
4. Enrollment auto-ended: Dec 20, 2025
5. Retention expiration set: Dec 20, 2026
6. Data deleted: Dec 21, 2026 (by cleanup job)

### Automated Cleanup Job

**Implementation**: Kubernetes CronJob

**Schedule**: Daily at 2:00 AM UTC (low-traffic period)

**Job Specification**:
```yaml
# cleanup-expired-data-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: learnflow-data-cleanup
  namespace: learnflow
spec:
  schedule: "0 2 * * *"  # Daily at 2:00 AM UTC
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: learnflow-data-cleanup
        spec:
          restartPolicy: OnFailure
          containers:
          - name: cleanup
            image: learnflow/data-cleanup:latest
            env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: learnflow-db-secret
                  key: connection-string
            - name: DRY_RUN
              value: "false"
            - name: BATCH_SIZE
              value: "1000"
            - name: RETENTION_BUFFER_DAYS
              value: "7"  # Extra safety buffer
            resources:
              requests:
                memory: "256Mi"
                cpu: "100m"
              limits:
                memory: "512Mi"
                cpu: "500m"
```

**Cleanup SQL Queries**:
```sql
-- Delete expired code submissions
DELETE FROM code_submission
WHERE retention_expires_at IS NOT NULL
  AND retention_expires_at < NOW() - INTERVAL '7 days';

-- Delete expired quiz responses
DELETE FROM quiz_response
WHERE retention_expires_at IS NOT NULL
  AND retention_expires_at < NOW() - INTERVAL '7 days';

-- Delete expired struggle alerts
DELETE FROM struggle_alert
WHERE retention_expires_at IS NOT NULL
  AND retention_expires_at < NOW() - INTERVAL '7 days';
```

**Monitoring**:
- Emit metrics: `data_cleanup_records_deleted{table="code_submission"}`
- Emit metrics: `data_cleanup_duration_seconds`
- Log summary: `Deleted 1,245 expired code_submissions, 387 quiz_responses, 92 struggle_alerts`
- Alert if cleanup fails 2 consecutive days

### Manual Retention Extension

**Use Case**: Teacher requests extended access for grading disputes or academic review

**API Endpoint**:
```
POST /api/v1/admin/retention/extend
{
  "entity_type": "code_submission",
  "entity_ids": ["uuid1", "uuid2"],
  "extend_by_days": 90,
  "reason": "Grade dispute under review"
}
```

**Implementation**:
```sql
UPDATE code_submission
SET retention_expires_at = retention_expires_at + INTERVAL '90 days'
WHERE id = ANY($1::uuid[])
  AND retention_expires_at IS NOT NULL;
```

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LEARNFLOW DATA MODEL                                  │
└─────────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │    users     │
                              ├──────────────┤
                              │ id (PK)      │
                              │ email (UK)   │
                              │ name         │
                              │ password_hash│
                              │ role         │
                              │ created_at   │
                              │ updated_at   │
                              └──────┬───────┘
                                     │
          ┌─────────────────────────┼──────────────────────────┐
          │                         │                          │
          │ (teacher)               │ (student)                │ (student)
          │                         │                          │
          ▼                         ▼                          ▼
┌──────────────────┐      ┌───────────────────┐    ┌───────────────────┐
│   classroom      │      │   enrollment      │    │ student_progress  │
├──────────────────┤      ├───────────────────┤    ├───────────────────┤
│ id (PK)          │◄─────┤ id (PK)           │    │ id (PK)           │
│ name             │      │ student_id (FK)   │    │ student_id (FK)   │
│ teacher_id (FK)  │      │ classroom_id (FK) │    │ module_number     │
│ join_code (UK)   │      │ enrolled_at       │    │ topic             │
│ status           │      │ ended_at          │    │ mastery_level     │
│ created_at       │      └───────────────────┘    │ exercises_comp... │
│ archived_at      │                               │ quizzes_taken     │
│ updated_at       │                               │ last_quiz_score   │
└────────┬─────────┘                               │ code_quality_avg  │
         │                                         │ streak_days       │
         │                                         │ last_activity_at  │
         │                                         │ created_at        │
         │                                         │ updated_at        │
         │                                         └───────────────────┘
         │
         └─────────────┬─────────────────────────────────┐
                       │                                 │
                       ▼                                 ▼
              ┌──────────────────┐          ┌─────────────────────┐
              │ struggle_alert   │          │  code_submission    │
              ├──────────────────┤          ├─────────────────────┤
              │ id (PK)          │          │ id (PK)             │
              │ student_id (FK)  │          │ student_id (FK)     │
              │ classroom_id(FK) │          │ exercise_id         │
              │ trigger_type     │          │ classroom_id (FK)   │
              │ description      │          │ code_text           │
              │ metadata         │          │ output              │
              │ severity         │          │ error_message       │
              │ resolved         │          │ grade               │
              │ resolution_notes │          │ feedback            │
              │ created_at       │          │ execution_time_ms   │
              │ resolved_at      │          │ memory_used_mb      │
              │ notified_at      │          │ status              │
              │ retention_exp... │          │ submitted_at        │
              └──────────────────┘          │ graded_at           │
                                            │ retention_expires..│
                                            └─────────────────────┘

                       ┌─────────────────────┐
                       │   quiz_response     │
                       ├─────────────────────┤
                       │ id (PK)             │
                       │ student_id (FK)     │
                       │ quiz_id             │
                       │ classroom_id (FK)   │
                       │ score               │
                       │ answers (JSONB)     │
                       │ total_questions     │
                       │ correct_answers     │
                       │ time_taken_seconds  │
                       │ completed_at        │
                       │ retention_expires..│
                       └─────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│                           KAFKA EVENT TOPICS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  learnflow.code.executed ──────► Code Review Agent                           │
│                           ──────► Progress Agent                              │
│                           ──────► Struggle Detection Service                  │
│                                                                               │
│  learnflow.quiz.submitted ─────► Progress Agent                              │
│                            ─────► Struggle Detection Service                  │
│                            ─────► Teacher Dashboard Service                   │
│                                                                               │
│  learnflow.struggle.detected ──► Notification Service                        │
│                              ──► Exercise Agent                               │
│                              ──► Teacher Dashboard Service                    │
│                                                                               │
│  learnflow.progress.updated ───► Student Dashboard Service                   │
│                             ───► Notification Service                         │
│                             ───► Analytics Service                            │
│                             ───► Teacher Dashboard Service                    │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘

LEGEND:
  PK = Primary Key
  FK = Foreign Key
  UK = Unique Key
  ──► = Event Consumer Relationship
  └──┬ = One-to-Many Relationship
```

---

## Indexes and Performance

### Primary Indexes (Already Defined)

All primary keys automatically create unique B-tree indexes:
- `users(id)`, `classroom(id)`, `enrollment(id)`, etc.

### Secondary Indexes

#### High-Priority Indexes (Query Performance Critical)

**users**:
- `idx_users_email`: Fast login lookups
- `idx_users_role`: Filter by student/teacher

**classroom**:
- `idx_classroom_teacher_id`: Teacher's classroom list
- `idx_classroom_join_code`: Student enrollment via join code
- `idx_classroom_status`: Filter active vs. archived

**enrollment**:
- `idx_enrollment_student_id`: Student's classroom list
- `idx_enrollment_classroom_id`: Classroom roster
- `idx_enrollment_ended_at`: Find active enrollments (WHERE ended_at IS NULL)

**student_progress**:
- `idx_student_progress_student_id`: Student dashboard queries
- `idx_student_progress_mastery_level`: Leaderboard/analytics
- `idx_student_progress_last_activity`: Recent activity tracking

**code_submission**:
- `idx_code_submission_student_id`: Student submission history
- `idx_code_submission_exercise_id`: Exercise-level analytics
- `idx_code_submission_submitted_at`: Recent submissions
- `idx_code_submission_retention_expires`: Cleanup job efficiency

**quiz_response**:
- `idx_quiz_response_student_id`: Student quiz history
- `idx_quiz_response_quiz_id`: Quiz-level analytics
- `idx_quiz_response_score`: Score distribution queries

**struggle_alert**:
- `idx_struggle_alert_unresolved_classroom`: Teacher notification panel (WHERE resolved = FALSE)
- `idx_struggle_alert_notified_at`: Email digest job (WHERE notified_at IS NULL OR recent)

### Composite Indexes

**enrollment**:
```sql
CREATE INDEX idx_enrollment_student_classroom
ON enrollment(student_id, classroom_id);
-- Optimizes: "Which classrooms is student X in?"
```

**student_progress**:
```sql
CREATE INDEX idx_student_progress_student_module_topic
ON student_progress(student_id, module_number, topic);
-- Optimizes: "Get all progress for student X in module Y"
```

**code_submission**:
```sql
CREATE INDEX idx_code_submission_student_exercise
ON code_submission(student_id, exercise_id, submitted_at DESC);
-- Optimizes: "Get latest submission for student X on exercise Y"
```

**struggle_alert**:
```sql
CREATE INDEX idx_struggle_alert_classroom_severity
ON struggle_alert(classroom_id, severity, resolved, created_at DESC)
WHERE resolved = FALSE;
-- Optimizes: "Get unresolved high-severity alerts for classroom X"
```

### Partial Indexes (Storage Optimization)

```sql
-- Index only active enrollments
CREATE INDEX idx_enrollment_active
ON enrollment(student_id, classroom_id)
WHERE ended_at IS NULL;

-- Index only ungraded submissions
CREATE INDEX idx_code_submission_pending_grading
ON code_submission(submitted_at DESC)
WHERE status = 'executed' AND grade IS NULL;

-- Index only unnotified struggle alerts
CREATE INDEX idx_struggle_alert_pending_notification
ON struggle_alert(created_at DESC)
WHERE notified_at IS NULL;
```

### JSON Indexes (JSONB Fields)

```sql
-- Index quiz response answers for specific question lookups
CREATE INDEX idx_quiz_response_answers_gin
ON quiz_response USING gin(answers);

-- Index struggle alert metadata for filtering by error type
CREATE INDEX idx_struggle_alert_metadata_gin
ON struggle_alert USING gin(metadata);
```

**Query Example**:
```sql
-- Find all students who got question q5 wrong
SELECT student_id, quiz_id, score
FROM quiz_response
WHERE answers @> '[{"question_id": "q5", "is_correct": false}]';
```

### Index Maintenance

**Vacuum Strategy**:
```sql
-- Auto-vacuum settings for high-churn tables
ALTER TABLE code_submission SET (
  autovacuum_vacuum_scale_factor = 0.05,
  autovacuum_analyze_scale_factor = 0.02
);

ALTER TABLE struggle_alert SET (
  autovacuum_vacuum_scale_factor = 0.05
);
```

**Reindex Schedule**:
```bash
# Weekly reindex of fragmented indexes (Kubernetes CronJob)
# Schedule: Sunday 3:00 AM UTC
REINDEX TABLE CONCURRENTLY code_submission;
REINDEX TABLE CONCURRENTLY quiz_response;
REINDEX TABLE CONCURRENTLY struggle_alert;
```

---

## Migration Strategy

### Initial Schema Deployment

**Tool**: Alembic (Python migration framework)

**Migration File Structure**:
```
migrations/
├── versions/
│   ├── 001_initial_schema.py
│   ├── 002_add_retention_columns.py
│   ├── 003_add_classroom_archival.py
│   └── 004_add_json_indexes.py
├── alembic.ini
└── env.py
```

### Migration Process

**Development**:
```bash
# Generate new migration
alembic revision --autogenerate -m "Add classroom archival support"

# Review generated SQL
alembic upgrade --sql head > migration.sql

# Apply migration
alembic upgrade head
```

**Production**:
```bash
# Test migration on staging
alembic upgrade head --tag staging

# Backup production database
pg_dump learnflow_prod > backup_before_migration.sql

# Apply with rollback safety
alembic upgrade +1  # Apply one migration at a time
alembic downgrade -1  # Rollback if issues detected
```

### Zero-Downtime Migrations

**Strategy**: Multi-phase deployments for breaking changes

**Example: Adding NOT NULL constraint**

**Phase 1** (Week 1):
```sql
-- Add column as nullable
ALTER TABLE code_submission
ADD COLUMN classroom_id UUID REFERENCES classroom(id);

-- Backfill existing data
UPDATE code_submission cs
SET classroom_id = (
  SELECT e.classroom_id
  FROM enrollment e
  WHERE e.student_id = cs.student_id
  LIMIT 1
);
```

**Phase 2** (Week 2, after verifying no NULL values):
```sql
-- Add NOT NULL constraint
ALTER TABLE code_submission
ALTER COLUMN classroom_id SET NOT NULL;
```

### Schema Versioning

**Version Tracking**:
```sql
CREATE TABLE schema_migrations (
  version VARCHAR(255) PRIMARY KEY,
  applied_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  description TEXT,
  checksum VARCHAR(64)
);
```

**Rollback Safety**:
- Every migration must include `upgrade()` and `downgrade()` functions
- Test downgrade in staging before production deployment
- Document irreversible migrations (e.g., data deletion)

---

## Appendix: Sample Queries

### Common Query Patterns

**1. Get Student Dashboard Data**
```sql
SELECT
  sp.module_number,
  sp.topic,
  sp.mastery_level,
  CASE
    WHEN sp.mastery_level BETWEEN 0 AND 40 THEN 'beginner'
    WHEN sp.mastery_level BETWEEN 41 AND 70 THEN 'learning'
    WHEN sp.mastery_level BETWEEN 71 AND 90 THEN 'proficient'
    ELSE 'mastered'
  END as tier,
  sp.exercises_completed,
  sp.quizzes_taken,
  sp.last_quiz_score,
  sp.streak_days
FROM student_progress sp
WHERE sp.student_id = $1
ORDER BY sp.module_number, sp.topic;
```

**2. Get Teacher's Unresolved Struggle Alerts**
```sql
SELECT
  sa.id,
  sa.trigger_type,
  sa.description,
  sa.severity,
  sa.created_at,
  u.name as student_name,
  u.email as student_email
FROM struggle_alert sa
JOIN users u ON sa.student_id = u.id
WHERE sa.classroom_id IN (
  SELECT c.id
  FROM classroom c
  WHERE c.teacher_id = $1 AND c.status = 'active'
)
  AND sa.resolved = FALSE
ORDER BY
  CASE sa.severity
    WHEN 'critical' THEN 1
    WHEN 'high' THEN 2
    WHEN 'medium' THEN 3
    ELSE 4
  END,
  sa.created_at DESC
LIMIT 20;
```

**3. Get Class Progress Overview**
```sql
SELECT
  c.name as classroom_name,
  COUNT(DISTINCT e.student_id) as total_students,
  COUNT(DISTINCT CASE WHEN sp.last_activity_at > NOW() - INTERVAL '24 hours' THEN e.student_id END) as active_today,
  AVG(sp.mastery_level) as avg_mastery,
  COUNT(DISTINCT CASE WHEN sa.resolved = FALSE THEN sa.student_id END) as struggling_students
FROM classroom c
JOIN enrollment e ON c.id = e.classroom_id AND e.ended_at IS NULL
LEFT JOIN student_progress sp ON e.student_id = sp.student_id
LEFT JOIN struggle_alert sa ON e.student_id = sa.student_id AND sa.classroom_id = c.id
WHERE c.teacher_id = $1 AND c.status = 'active'
GROUP BY c.id, c.name
ORDER BY c.created_at DESC;
```

**4. Find Students with Expired Data Ready for Cleanup**
```sql
SELECT
  cs.student_id,
  COUNT(*) as submissions_to_delete
FROM code_submission cs
WHERE cs.retention_expires_at < NOW() - INTERVAL '7 days'
GROUP BY cs.student_id;
```

---

## Document Control

**Version History**:
- v1.0 (2025-12-22): Initial data model specification

**Review Status**: Draft - Pending technical review

**Related Documents**:
- `specs/004-learnflow-application/spec.md` - Feature specification
- `specs/004-learnflow-application/plan.md` - Implementation plan (to be created)
- `specs/004-learnflow-application/tasks.md` - Implementation tasks (to be created)

**Next Steps**:
1. Review data model with team
2. Validate schema against all user stories in spec.md
3. Run performance benchmarks with sample data (100K+ submissions)
4. Create Alembic migrations
5. Deploy schema to staging environment
6. Update plan.md with database deployment strategy

---

**End of Data Model Specification**
