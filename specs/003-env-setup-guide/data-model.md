# Data Model: Environment Setup Guide

**Feature**: 003-env-setup-guide
**Date**: 2025-12-21
**Phase**: 1 - Design & Contracts

## Overview

This document defines the content model for the environment setup guide documentation. Since this is a documentation feature (not a software system with persistent data), the "data model" describes the structure and relationships of documentation content entities.

## Content Entities

### 1. Tool

**Description**: Software component that must be installed and configured

**Attributes**:
- Name: string (e.g., "Docker", "Minikube", "kubectl")
- Version Requirement: semantic version constraint (e.g., "20.10+", "1.30+", "latest")
- Purpose: string (brief description of tool's role in hackathon)
- Installation Complexity: enum (simple | moderate | complex)
- Platform Variants: array of Platform (installation differs by OS)

**Relationships**:
- Has many **Installation Steps** (per Platform)
- Has one **Verification Check**
- May have many **Troubleshooting Entries**
- May depend on other Tools (e.g., Minikube depends on Docker)

**Example**:
```yaml
name: Docker
version: "20.10+"
purpose: Container runtime for Kubernetes and local development
complexity: moderate
platforms: [macOS, Linux, Windows-WSL]
dependencies: []
```

---

### 2. Platform

**Description**: Target operating system with specific installation procedures

**Attributes**:
- Name: enum (macOS | Linux-Ubuntu-Debian | Windows-WSL-2)
- Package Manager: string (e.g., "Homebrew", "apt-get", "Docker Desktop")
- Shell: string (e.g., "zsh", "bash")
- Estimated Setup Time: integer (minutes)
- System Requirements: SystemRequirements object

**Relationships**:
- Has many **Installation Steps** (for each Tool)
- Has specific **Package Manager Commands**

**Example**:
```yaml
name: macOS
package_manager: Homebrew
shell: zsh
estimated_time: 20
requirements:
  cpu: 4
  ram_gb: 8
  disk_gb: 50
```

---

### 3. Installation Step

**Description**: Atomic installation instruction for a specific Tool on a specific Platform

**Attributes**:
- Tool: reference to Tool
- Platform: reference to Platform
- Step Number: integer
- Title: string
- Prerequisites: array of string (conditions that must be met)
- Commands: array of Command
- Expected Duration: integer (minutes)
- Checkpoint Verification: VerificationCommand

**Relationships**:
- Belongs to one **Tool**
- Belongs to one **Platform**
- Has one **Checkpoint Verification** (verify before proceeding)
- May reference **Troubleshooting Entries** for common failures

**Example**:
```yaml
tool: Minikube
platform: macOS
step: 3
title: "Install Minikube"
prerequisites:
  - "Docker is running"
  - "Homebrew is installed"
commands:
  - "brew install minikube"
duration: 2
verification:
  command: "minikube version"
  expected_pattern: "minikube version: v1.30.0+"
```

---

### 4. Verification Check

**Description**: Automated or manual test confirming a Tool is correctly installed

**Attributes**:
- Tool: reference to Tool
- Check Type: enum (version | connectivity | functionality)
- Command: string (shell command to run)
- Expected Output Pattern: regex or literal string
- Remediation Steps: array of string (what to do if check fails)
- Diagnostic Details: boolean (whether to show version comparison)

**Relationships**:
- Belongs to one **Tool**
- Referenced by **Installation Steps** (checkpoint verification)
- Referenced by **Verification Script**

**Example**:
```yaml
tool: kubectl
type: version
command: "kubectl version --client --short"
expected: "Client Version: v1.27.0"
remediation:
  - "Check installation command completed successfully"
  - "Restart terminal to refresh PATH"
  - "Run: brew reinstall kubectl (macOS) or see troubleshooting"
diagnostic: true
```

---

### 5. Troubleshooting Entry

**Description**: Common problem with diagnostic steps and solution

**Attributes**:
- Title: string (problem description)
- Tools Affected: array of Tool references
- Symptoms: array of string
- Diagnostic Commands: array of string
- Solution Steps: array of string
- Platform-Specific: boolean
- Related Platforms: array of Platform (if platform-specific)

**Relationships**:
- Relates to one or more **Tools**
- May be specific to one or more **Platforms**

**Example**:
```yaml
title: "Docker won't start"
tools: [Docker]
symptoms:
  - "Cannot connect to Docker daemon"
  - "Docker Desktop shows error"
platforms: [macOS, Windows-WSL]
diagnostics:
  - "Check if Docker Desktop is running (macOS/Windows)"
  - "Run: sudo systemctl status docker (Linux)"
solutions:
  - "macOS: Open Docker Desktop from Applications"
  - "Linux: sudo systemctl start docker"
  - "Windows: Enable WSL 2 integration in Docker Desktop settings"
```

---

### 6. Repository Template

**Description**: Required repository structure for skills-library or learnflow-app

**Attributes**:
- Name: enum (skills-library | learnflow-app)
- Root Directory: path
- Required Subdirectories: array of DirectorySpec
- Initial Files: array of FileSpec (README.md, .gitignore, etc.)
- Git Configuration: GitConfig

**Relationships**:
- Has many **DirectorySpec** (required folders)
- Has many **FileSpec** (initial files to create)

**Example**:
```yaml
name: skills-library
root: "~/projects/skills-library"
directories:
  - path: ".claude/skills"
    purpose: "Claude CLI Skills compiled from CAPS playbooks"
  - path: ".goose/recipes"
    purpose: "Goose Recipes compiled from CAPS playbooks"
files:
  - path: "README.md"
    content_template: "skills-library-readme"
git:
  initial_commit: "Initial: Create skills-library"
```

---

### 7. Verification Script

**Description**: Automated bash script that checks all tools and reports status

**Attributes**:
- Script Name: string ("verify-environment.sh")
- Output Format: enum (colored-text | json | table)
- Checks: array of VerificationCheck references
- Diagnostic Level: enum (summary | detailed)
- Exit Codes: object (mapping status to exit code)

**Relationships**:
- Executes many **Verification Checks**
- Outputs many **Verification Results**

**Example**:
```yaml
name: verify-environment.sh
format: colored-text
diagnostic_level: detailed
checks: [git, docker, minikube, kubectl, helm, claude, goose]
exit_codes:
  all_pass: 0
  some_fail: 1
  script_error: 2
```

---

## Content Relationships Diagram

```
Platform (macOS, Linux, Windows)
    │
    ├──> Installation Steps (per Tool)
    │         │
    │         └──> Checkpoint Verification
    │
    └──> System Requirements

Tool (Docker, Minikube, kubectl, Helm, Claude, Goose, Git)
    │
    ├──> Installation Steps (per Platform)
    │         └──> Commands
    │         └──> Checkpoint Verification
    │
    ├──> Verification Check
    │         └──> Expected Output
    │         └──> Remediation Steps
    │
    ├──> Troubleshooting Entries
    │
    └──> Dependencies (other Tools)

Verification Script
    │
    └──> Executes all Verification Checks
             └──> Outputs Diagnostic Results

Repository Template (skills-library, learnflow-app)
    │
    ├──> Directory Structure
    │
    └──> Initial Files
```

## Content Validation Rules

### Tool Entity:
- Version requirement must be semantic version or "latest"
- Must have at least one Installation Step per target Platform
- Must have exactly one Verification Check

### Installation Step:
- Step numbers must be sequential within Tool+Platform
- Commands must be valid shell syntax for target Platform
- Checkpoint verification must be testable non-interactively

### Verification Check:
- Command must be non-interactive (no prompts)
- Expected output pattern must be specific enough to detect failures
- Remediation steps must reference troubleshooting section or specific commands

### Troubleshooting Entry:
- Solutions must be actionable (commands or specific instructions)
- Must reference at least one Tool
- Platform-specific entries must list affected platforms

### Repository Template:
- Root directory must use absolute path notation
- Required subdirectories must include `.claude/skills` and/or `.goose/recipes`
- Initial commit message must follow convention: "Initial: Create {repo-name}"

## State Transitions

### Installation Flow State Machine:

```
[Not Checked]
    │
    ├──> Run checkpoint verification
    │
    ↓
[Verified Absent] ──> Install ──> [Verified Present]
    │                    ↓
    │                 [Failed]
    │                    ↓
    │              Troubleshoot ──> Retry Install
    │                    ↓
    └────────────────> [Skip] (already installed)
```

### Verification Script State Machine:

```
[Start]
    │
    ├──> For each Tool:
    │      Check version
    │      ├──> [Pass] ✓ tool: found vX.Y.Z
    │      └──> [Fail] ✗ tool: expected vX.Y, found vA.B or not found
    │               └──> Print remediation steps
    │
    ↓
[All Checks Complete]
    │
    ├──> All Pass: Exit 0
    └──> Any Fail: Exit 1
```

## Content Organization

**Primary Navigation**:
1. **README.md**: Entry point with table of contents
2. **prerequisites.md**: Pre-installation checks (git, system requirements)
3. **{platform}-installation.md**: Platform-specific installation steps
4. **verification.md**: Post-installation verification procedures
5. **repository-setup.md**: skills-library and learnflow-app initialization
6. **troubleshooting.md**: Common problems and solutions

**Supporting Assets**:
- **scripts/verify-environment.sh**: Automated verification script
- **diagrams/** (optional): Visual representations of architecture

**Content Reuse**:
- Verification checks reused across platforms
- Troubleshooting entries reference multiple tools
- Repository templates shared between documentation sections
