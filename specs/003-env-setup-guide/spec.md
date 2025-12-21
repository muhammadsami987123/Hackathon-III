# Feature Specification: Environment Setup Guide

**Feature Branch**: `003-env-setup-guide`
**Created**: 2025-12-21
**Status**: Draft
**Input**: User description: "Developer environment setup guide covering macOS, Linux, and Windows WSL installations for Docker, Kubernetes, Minikube, Helm, Claude Code, and Goose"

## Clarifications

### Session 2025-12-21

- Q: How should the guide handle mid-installation failures? → A: Resume-from-checkpoint approach - guide shows how to verify what's already installed and skip completed steps
- Q: What level of detail should the verification script provide in its output? → A: Detailed diagnostic output - for each tool show status, version found, expected version, and remediation steps for failures
- Q: How should the guide handle systems with insufficient resources? → A: Warning with reduced-resource instructions - guide warns about limitations but provides alternative configurations (e.g., Minikube with 2 CPU/4GB)
- Q: How should the guide handle version conflicts with existing installations? → A: Side-by-side installation - guide shows how to install required versions alongside existing ones using version managers or isolated environments
- Q: How should the guide address corporate firewall/proxy scenarios? → A: Basic proxy awareness - guide mentions common proxy environment variables and suggests verification steps, but deep troubleshooting is out of scope

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete Environment Setup (Priority: P1)

A developer new to Hackathon III needs to set up their complete development environment from scratch, including all required tools (Docker, Kubernetes, Minikube, Helm, Claude Code, Goose) and verify everything works together.

**Why this priority**: This is the foundation for all development work. Without a working environment, developers cannot participate in the hackathon. This is the critical path for onboarding.

**Independent Test**: Can be fully tested by following the guide on a clean machine and running the verification script. Success means all tools are installed, Minikube cluster is running, and kubectl can connect.

**Acceptance Scenarios**:

1. **Given** a macOS system with no development tools, **When** developer follows macOS installation steps, **Then** all tools (Docker, Minikube, kubectl, Helm, Claude Code, Goose) are installed and verified
2. **Given** a Linux (Ubuntu/Debian) system, **When** developer follows Linux installation steps, **Then** all tools are installed and Minikube cluster starts successfully
3. **Given** a Windows system with WSL 2, **When** developer follows Windows WSL installation steps, **Then** all tools work within WSL environment and Docker Desktop integrates correctly
4. **Given** all tools are installed, **When** developer runs verification script, **Then** all checks pass with green checkmarks

---

### User Story 2 - Repository Initialization (Priority: P2)

A developer with installed tools needs to create the required repository structure for skills-library and learnflow-app, initialize git, and verify the structure is correct.

**Why this priority**: Repository structure must be set up correctly for all subsequent development work with CAPS playbooks and skills.

**Independent Test**: Can be tested by creating both repositories from scratch and verifying directory structure matches expected layout with .claude/skills and proper git initialization.

**Acceptance Scenarios**:

1. **Given** tools are installed, **When** developer creates skills-library repository, **Then** .claude/skills directory exists and git is initialized
2. **Given** skills-library exists, **When** developer creates learnflow-app repository, **Then** both repositories have correct structure and initial commits
3. **Given** both repositories exist, **When** developer runs structure verification, **Then** all required directories and README files are present

---

### User Story 3 - Troubleshooting Common Issues (Priority: P3)

A developer encounters installation problems (Docker won't start, Minikube fails, kubectl can't connect) and needs to diagnose and fix the issues using the troubleshooting guide.

**Why this priority**: Not all installations go smoothly. Having documented solutions for common problems reduces setup time and frustration.

**Independent Test**: Can be tested by deliberately breaking each component (stopping Docker, deleting Minikube cluster) and verifying the troubleshooting steps restore functionality.

**Acceptance Scenarios**:

1. **Given** Docker is not running, **When** developer follows Docker troubleshooting steps, **Then** Docker starts and containers can be created
2. **Given** Minikube cluster fails with "DRV_NOT_HEALTHY", **When** developer deletes and recreates cluster, **Then** Minikube starts successfully
3. **Given** kubectl shows "connection refused", **When** developer restarts Minikube and updates context, **Then** kubectl can connect and list resources
4. **Given** Claude Code authentication fails, **When** developer re-authenticates, **Then** Claude Code login succeeds

---

### User Story 4 - Platform-Specific Setup (Priority: P2)

A developer on a specific platform (macOS, Linux, or Windows) needs clear, step-by-step instructions tailored to their operating system without confusion from other platforms.

**Why this priority**: Platform-specific guidance reduces errors and setup time by avoiding irrelevant instructions.

**Independent Test**: Each platform section can be tested independently by following only that platform's instructions on the corresponding OS.

**Acceptance Scenarios**:

1. **Given** a macOS developer, **When** following macOS section, **Then** all commands work without modification and use Homebrew as package manager
2. **Given** a Linux developer, **When** following Linux section, **Then** all commands use apt-get and don't reference macOS-specific tools
3. **Given** a Windows developer with WSL, **When** following Windows section, **Then** WSL 2 is configured, Docker Desktop integration works, and all tools run in Ubuntu WSL environment

---

### Edge Cases

- What happens when a developer has insufficient system resources (less than 4 CPU cores or 8GB RAM)? → Guide provides warning about limitations and offers reduced-resource configuration options (e.g., Minikube with 2 CPU/4GB RAM for basic testing)
- How does the setup handle existing installations of tools (e.g., Docker already installed)? → Verification commands check existing installations; guide supports skipping completed steps
- What if a developer is behind a corporate firewall or proxy? → Guide provides basic proxy awareness (common environment variables like HTTP_PROXY, HTTPS_PROXY) and connection verification steps; deep proxy troubleshooting is out of scope
- How are version conflicts handled (e.g., older version of Kubernetes already installed)? → Side-by-side installation approach using version managers or isolated environments to avoid breaking existing tool installations
- What happens when Minikube runs out of disk space during setup?
- How are authentication failures with Claude Code or Goose handled?
- What if git is not installed at the prerequisite check stage?
- What happens if installation fails mid-process? → Resume-from-checkpoint approach allows developers to verify completed steps and continue from point of failure

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Guide MUST provide complete installation instructions for macOS, Linux (Ubuntu/Debian), and Windows (WSL 2)
- **FR-002**: Guide MUST cover installation of Docker 20.10+, Minikube 1.30+, kubectl 1.27+, Helm 3.12+, Claude Code (latest), Goose (latest), and Git 2.40+
- **FR-003**: Guide MUST include verification steps for each installed tool with expected output examples
- **FR-004**: Guide MUST provide a complete verification script that checks all tools and reports detailed diagnostic output including: tool status (pass/fail), version found, expected version, and remediation steps for any failures
- **FR-005**: Guide MUST include repository setup instructions for skills-library and learnflow-app
- **FR-006**: Guide MUST provide troubleshooting sections for common installation problems
- **FR-007**: Guide MUST include time estimates for each platform's installation process
- **FR-008**: Guide MUST specify minimum and recommended system requirements
- **FR-009**: Guide MUST provide environment variable configuration for shell profiles
- **FR-010**: Guide MUST include step-by-step Minikube cluster initialization with correct resource allocation (4 CPU, 8GB RAM)
- **FR-011**: Guide MUST provide platform-specific package manager commands (Homebrew for macOS, apt-get for Linux)
- **FR-012**: Guide MUST include Docker Desktop configuration steps for WSL 2 integration
- **FR-013**: Guide MUST provide clear next steps after environment setup completion
- **FR-014**: Guide MUST include checkpoint verification commands that allow developers to determine which tools are already installed and skip completed installation steps
- **FR-015**: Guide MUST include resource requirement warnings and provide reduced-resource configuration alternatives (minimum 2 CPU/4GB RAM) for systems that don't meet recommended specifications
- **FR-016**: Guide MUST provide instructions for side-by-side installation of required tool versions using version managers or isolated environments when version conflicts exist with existing installations
- **FR-017**: Guide MUST mention common proxy environment variables (HTTP_PROXY, HTTPS_PROXY, NO_PROXY) and include basic network connectivity verification steps for developers behind corporate firewalls

### Key Entities

- **Development Environment**: Complete set of installed tools, repositories, and configurations required for Hackathon III participation
- **Tool**: Individual software component (Docker, Minikube, kubectl, Helm, Claude Code, Goose, Git) with version requirements
- **Repository**: Git-initialized directory structure (skills-library or learnflow-app) with specific layout requirements
- **Verification Check**: Automated or manual test that confirms a tool is correctly installed and functional
- **Platform**: Target operating system (macOS, Linux Ubuntu/Debian, Windows WSL 2) with platform-specific instructions
- **Troubleshooting Entry**: Problem description with diagnostic steps and solution for common installation issues

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developers can complete full environment setup on macOS in 20 minutes or less following the guide
- **SC-002**: Developers can complete full environment setup on Linux in 30 minutes or less following the guide
- **SC-003**: Developers can complete full environment setup on Windows WSL in 35 minutes or less following the guide
- **SC-004**: Verification script provides detailed diagnostic output for each tool (status, version found vs expected) and includes remediation steps for any failed checks
- **SC-005**: 95% of developers successfully start Minikube cluster on first attempt without errors
- **SC-006**: Troubleshooting section resolves 80% of common installation problems without external help
- **SC-007**: Repository structure verification confirms all required directories exist for both skills-library and learnflow-app
- **SC-008**: Developers can successfully run kubectl cluster-info after setup completion
- **SC-009**: Claude Code and Goose authentication completes successfully for all developers
- **SC-010**: Guide supports systems meeting recommended requirements (4 CPU, 8GB RAM, 50GB disk) and provides reduced-resource alternatives for systems with 2 CPU/4GB RAM minimum

## Assumptions

- Developers have administrative/sudo access on their machines
- Developers have stable internet connection for downloading tools and packages
- Developers are using officially supported OS versions (recent macOS, Ubuntu 20.04+/Debian 10+, Windows 10/11 with WSL 2)
- Package managers (Homebrew, apt-get) are accessible and repositories are not blocked by corporate firewalls
- Docker Desktop is available and licensed for the developer's use case
- Developers have basic command-line familiarity for running shell commands
- Git is either pre-installed or can be installed as a prerequisite
- Developers can create and configure git repositories with initial commits
- System BIOS supports virtualization (required for Docker and Minikube)

## Out of Scope

- Advanced Kubernetes configuration beyond basic Minikube setup
- Production-grade Kubernetes cluster setup (this is for local development only)
- Detailed Docker or Kubernetes tutorials (guide focuses on installation, not usage)
- CI/CD pipeline configuration
- Cloud provider integrations (AWS, GCP, Azure)
- Alternative container runtimes besides Docker
- Alternative local Kubernetes solutions (Kind, k3s, MicroK8s)
- Detailed CAPS playbook development (covered in separate feature)
- Goose recipe authoring (covered in separate feature)
- Deep network proxy or VPN troubleshooting (basic proxy awareness is in scope)
- Corporate security policies and compliance requirements
- Automated setup scripts (manual step-by-step preferred for learning)
