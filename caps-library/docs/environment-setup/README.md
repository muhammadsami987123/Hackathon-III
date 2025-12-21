# SP Specify Part 4: Environment Setup

**Step-by-Step Developer Environment Configuration**

[![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux%20%7C%20Windows%20WSL-blue)]()

---

## TABLE OF CONTENTS

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [macOS Installation](#macos-installation)
4. [Linux Installation (Ubuntu/Debian)](#linux-installation-ubuntudebian)
5. [Windows Installation (WSL)](#windows-installation-wsl)
6. [Verification](#verification)
7. [Repository Setup](#repository-setup)
8. [Troubleshooting](#troubleshooting)
9. [Next Steps](#next-steps)

---

## OVERVIEW

This section guides you through setting up your complete development environment for Hackathon III.

### What You'll Install

| Tool | Purpose | Version |
|------|---------|---------|
| Docker | Container runtime | 20.10+ |
| Minikube | Local Kubernetes | 1.30+ |
| kubectl | Kubernetes CLI | 1.27+ |
| Helm | Package manager | 3.12+ |
| Claude Code | AI coding agent | Latest |
| Goose | Open-source agent | Latest |
| Git | Version control | 2.40+ |

### Time Required

| Platform | Estimated Time |
|----------|----------------|
| macOS | 15-20 minutes |
| Linux (Ubuntu/Debian) | 20-30 minutes |
| Windows (WSL 2) | 25-35 minutes |

### System Requirements

#### Minimum (Basic Testing Only)
- **CPU**: 2 cores
- **RAM**: 4GB
- **Disk**: 50GB free space
- **Internet**: Stable connection

#### Recommended (Full Development)
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Disk**: 100GB free space
- **Internet**: Stable connection

⚠️ **Note**: Minimum requirements support basic testing with reduced Minikube resources but may experience slower performance.

---

## Quick Start: Choose Your Platform

Select your operating system to begin installation:

### [→ macOS Installation](./macos-installation.md)
**For**: macOS developers (Intel or Apple Silicon)
**Package Manager**: Homebrew
**Time**: ~20 minutes

### [→ Linux (Ubuntu/Debian) Installation](./linux-installation.md)
**For**: Ubuntu 20.04+, Debian 10+ users
**Package Manager**: apt-get
**Time**: ~30 minutes

### [→ Windows (WSL 2) Installation](./windows-wsl-installation.md)
**For**: Windows 10/11 with WSL 2
**Package Manager**: apt-get (within WSL)
**Time**: ~35 minutes

---

## Common Sections

After completing your platform-specific installation, proceed with these common steps:

### Prerequisites Check
[→ Prerequisites](./prerequisites.md) - Verify git and system requirements before starting

### Verification
[→ Verification Guide](./verification.md) - Post-installation validation and automated verification script

### Repository Setup
[→ Repository Setup](./repository-setup.md) - Initialize skills-library and learnflow-app repositories

### Troubleshooting
[→ Troubleshooting Guide](./troubleshooting.md) - Common problems and solutions

---

## Installation Workflow

```
1. Prerequisites Check
   └─> Verify git installed
   └─> Check system resources
        ↓
2. Platform-Specific Installation
   └─> Follow your OS guide (macOS/Linux/Windows)
   └─> Install all 7 tools
   └─> Verify each step
        ↓
3. Verification
   └─> Run verification script
   └─> Confirm all tools working
        ↓
4. Repository Setup
   └─> Create skills-library
   └─> Create learnflow-app
        ↓
5. Start Hacking! 🚀
```

---

## Support Resources

- **Troubleshooting**: [troubleshooting.md](./troubleshooting.md)
- **Verification Script**: [scripts/verify-environment.sh](./scripts/verify-environment.sh)
- **Project Constitution**: `../../.specify/memory/constitution.md`
- **CAPS Playbooks**: `../../caps-library/playbooks/`

---

## Next Steps

Once environment is set up:

1. **Verify everything works** - Run verification script
2. **Initialize repositories** - Follow repository-setup.md
3. **Explore CAPS playbooks** - Review caps-library/playbooks/
4. **Read Project Constitution** - Understand development principles
5. **Start Building** - Create your first CAPS playbook or LearnFlow feature

---

**Happy Hacking!** 🎉

For questions or issues not covered in troubleshooting, consult the project team or constitution documentation.

---

*Last Updated: 2025-12-21*
*Part of Hackathon III: SP Constitution (Spec-Kit Plus)*
