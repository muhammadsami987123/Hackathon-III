# Contract: Verification Script Specification

**Purpose**: Automated bash script that validates all tools are correctly installed

**Location**: `docs/environment-setup/scripts/verify-environment.sh`

**Fulfills**: FR-004, SC-004 (detailed diagnostic output with remediation steps)

---

## Script Interface

### Invocation
```bash
bash docs/environment-setup/scripts/verify-environment.sh
```

### Exit Codes
- `0`: All checks passed
- `1`: One or more checks failed
- `2`: Script error (invalid environment, missing dependencies)

### Output Format
Colored text with detailed diagnostics (per clarification answer 2)

---

## Script Structure

### Header
```bash
#!/bin/bash
# verify-environment.sh
# Hackathon III Environment Verification
# Checks: git, docker, minikube, kubectl, helm, claude, goose
```

### Color Definitions
```bash
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
```

### Helper Function: check_command
**Signature**: `check_command <tool_name> <version_command> <expected_pattern>`

**Behavior**:
```bash
check_command() {
    tool=$1
    version_cmd=$2
    expected_pattern=$3

    echo -n "Checking $tool..."

    if command -v $tool &> /dev/null; then
        version=$($version_cmd 2>&1 | head -1)
        echo -e "${GREEN}✓${NC} found"
        echo "  Version: $version"

        if [[ $version =~ $expected_pattern ]]; then
            echo -e "  Status: ${GREEN}PASS${NC} (meets requirement)"
        else
            echo -e "  Status: ${RED}FAIL${NC} (expected: $expected_pattern)"
            echo "  Remediation: [platform-specific command]"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo -e "${RED}✗${NC} not found"
        echo "  Remediation: Install $tool following platform guide"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    echo ""
}
```

### Main Verification Sequence

#### Section 1: Core Tools
```bash
echo "=========================================="
echo "Core Tools Verification"
echo "=========================================="

check_command "git" "git --version" "2\.4[0-9]\+"
check_command "docker" "docker --version" "20\.10\."
```

#### Section 2: Kubernetes Tools
```bash
echo "=========================================="
echo "Kubernetes Tools Verification"
echo "=========================================="

check_command "minikube" "minikube version" "v1\.30\."
check_command "kubectl" "kubectl version --client --short" "v1\.27\."
check_command "helm" "helm version" "v3\.12\."
```

#### Section 3: AI Agent Tools
```bash
echo "=========================================="
echo "AI Agent Tools Verification"
echo "=========================================="

check_command "claude" "claude --version" "."  # Any version (latest)
check_command "goose" "goose --version" "."    # Any version (latest)
```

#### Section 4: Cluster Connectivity
```bash
echo "=========================================="
echo "Cluster Connectivity"
echo "=========================================="

if minikube status > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Minikube cluster is running"
else
    echo -e "${RED}✗${NC} Minikube cluster is NOT running"
    echo "  Remediation: Run 'minikube start --cpus=4 --memory=8192'"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if kubectl cluster-info > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} kubectl can connect to cluster"
else
    echo -e "${RED}✗${NC} kubectl cannot connect"
    echo "  Remediation: Check minikube status and run 'minikube update-context'"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
```

### Summary Section
```bash
echo "=========================================="
echo "Verification Summary"
echo "=========================================="

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo "Your environment is ready for Hackathon III."
    echo ""
    echo "Next steps:"
    echo "  1. Set up repositories: docs/environment-setup/repository-setup.md"
    echo "  2. Explore CAPS playbooks: caps-library/playbooks/"
    exit 0
else
    echo -e "${RED}✗ $FAIL_COUNT check(s) failed${NC}"
    echo ""
    echo "Please review the remediation steps above."
    echo "For detailed troubleshooting: docs/environment-setup/troubleshooting.md"
    exit 1
fi
```

---

## Platform-Specific Remediation

### Remediation Command Matrix

| Tool | macOS Remediation | Linux Remediation | Windows WSL Remediation |
|------|-------------------|-------------------|------------------------|
| git | `brew install git` | `sudo apt-get install git` | `sudo apt-get install git` |
| docker | `brew install --cask docker && open -a Docker` | `sudo apt-get install docker.io` | Enable Docker Desktop WSL integration |
| minikube | `brew install minikube` | `curl -LO [url] && sudo install...` | Same as Linux |
| kubectl | `brew install kubectl` | Installed with minikube | Installed with minikube |
| helm | `brew install helm` | `curl [helm-install-script] \| bash` | Same as Linux |
| claude | `brew install --cask claude-code` | `curl [install.sh] \| bash` | Same as Linux |
| goose | `brew install --cask block-goose` | `curl [download_cli.sh] \| bash` | Same as Linux |

**Implementation**: Script detects OS via `uname -s` and shows platform-appropriate remediation

---

## Example Output

```
==========================================
Hackathon III Environment Verification
==========================================

Core Tools Verification
==========================================
Checking git...✓ found
  Version: git version 2.40.1
  Status: PASS (meets requirement)

Checking docker...✓ found
  Version: Docker version 20.10.23
  Status: PASS (meets requirement)

==========================================
Kubernetes Tools Verification
==========================================
Checking minikube...✓ found
  Version: minikube version: v1.30.1
  Status: PASS (meets requirement)

Checking kubectl...✓ found
  Version: Client Version: v1.27.3
  Status: PASS (meets requirement)

Checking helm...✗ not found
  Remediation: Install helm following platform guide
  macOS: brew install helm
  Linux: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

==========================================
AI Agent Tools Verification
==========================================
Checking claude...✓ found
  Version: Claude Code v1.0.0
  Status: PASS (meets requirement)

Checking goose...✓ found
  Version: Goose v0.1.2
  Status: PASS (meets requirement)

==========================================
Cluster Connectivity
==========================================
✓ Minikube cluster is running
✓ kubectl can connect to cluster

==========================================
Verification Summary
==========================================
✗ 1 check(s) failed

Please review the remediation steps above.
For detailed troubleshooting: docs/environment-setup/troubleshooting.md
```

---

## Acceptance Criteria

- ✓ Checks all 7 required tools (FR-002)
- ✓ Shows detailed diagnostic output (SC-004)
- ✓ Displays version found vs expected
- ✓ Provides platform-specific remediation steps
- ✓ Tests Minikube cluster connectivity
- ✓ Tests kubectl connectivity
- ✓ Colored output for quick scanning
- ✓ Exit code 0 for success, 1 for failure
- ✓ Summary with actionable next steps
- ✓ Non-interactive (automatable)
- ✓ Works on all 3 target platforms
