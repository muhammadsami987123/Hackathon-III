# Contract: Platform Installation Guide Template

**Purpose**: Template structure for macOS, Linux, and Windows WSL installation guides

**Applies to**:
- `docs/environment-setup/macos-installation.md`
- `docs/environment-setup/linux-installation.md`
- `docs/environment-setup/windows-wsl-installation.md`

---

## Content Structure (All Platform Guides)

### Header Section
- **Title**: "{Platform} Installation"
- **Platform badge**: macOS | Linux (Ubuntu/Debian) | Windows (WSL 2)
- **Estimated time**: XX minutes
- **Prerequisites link**: → prerequisites.md

### Step 0: Prerequisites Check
**Content**:
- System requirements verification
- Git installation status check
- Package manager availability (Homebrew/apt-get/WSL)

**Pattern**:
```markdown
## Prerequisites Check

### Verify System Resources
```bash
# Check CPU cores
sysctl -n hw.ncpu  # macOS
nproc              # Linux
```
Expected: 4+ (recommended) or 2+ (minimum)

### Verify Git
```bash
git --version
```
Expected: git version 2.40+

[Platform-specific instructions if git missing]
```

### Step 1: Install Docker
**Content**:
- **Checkpoint verification**: Check if Docker already installed
- **Installation commands**: Platform-specific
- **Post-install verification**: `docker --version`
- **Expected output example**
- **Troubleshooting reference**: Link to troubleshooting.md#docker

**Pattern**:
```markdown
## Step 1: Install Docker

### Check Current State
```bash
docker --version
```
If command not found → proceed with installation
If version displayed → skip to verification step

### Installation
[Platform-specific commands]

### Verify Success
```bash
docker --version
```
Expected: Docker version 20.10.0+
```

### Step 2: Install Minikube
[Same pattern as Step 1]

### Step 3: Start Minikube
**Content**:
- Standard configuration command (4 CPU, 8GB)
- Collapsible "Low-Resource Alternative" (2 CPU, 4GB)
- Expected output
- First-time startup note (2-3 minutes)
- Verification command

**Pattern**:
```markdown
## Step 3: Start Minikube

### Recommended Configuration
```bash
minikube start --cpus=4 --memory=8192 --driver=docker
```

<details>
<summary>⚠️ Low-Resource Alternative</summary>

**Warning**: May experience slower performance

```bash
minikube start --cpus=2 --memory=4096 --driver=docker
```
</details>

### Verify Cluster Running
```bash
minikube status
```
Expected: host/kubelet/apiserver Running
```

### Step 4: Install Helm
[Same pattern as Step 1]

### Step 5: Verify kubectl
[Same pattern as Step 1]

### Step 6: Install Claude Code
**Content**:
- Installation commands
- Authentication setup (`claude auth login`)
- Browser-based authentication flow note
- Verification command

### Step 7: Install Goose
[Same pattern as Step 6]

### Step 8: Network Connectivity (Optional)
**Content**:
- Corporate firewall/proxy section (collapsible)
- Proxy environment variables
- Connectivity test command
- Reference to out-of-scope deep troubleshooting

**Pattern**:
```markdown
## Step 8: Network Connectivity (Optional)

<details>
<summary>Corporate Firewall/Proxy Configuration</summary>

### Set Proxy Variables
```bash
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.local"
```

### Test Connectivity
```bash
curl -I https://github.com
```
Expected: HTTP/2 200

**If fails**: Consult IT department. Deep proxy troubleshooting is out of scope.
</details>
```

### Step 9: Run Full Verification
**Content**:
- Link to verification.md
- Command to run verification script
- Expected output summary

### Next Steps
**Content**:
- Link to repository-setup.md
- Link to verification.md (if not run yet)
- Link back to README.md

---

## Platform-Specific Variations

### macOS Specifics:
- Uses Homebrew as primary package manager
- Docker Desktop installation via `brew install --cask docker`
- Shell profile: `~/.zshrc` (default on modern macOS)
- Open Docker Desktop app command: `open -a Docker`

### Linux (Ubuntu/Debian) Specifics:
- Uses apt-get as package manager
- Docker installation includes `docker.io` and `docker-compose` packages
- User group management: `sudo usermod -aG docker $USER`
- Shell profile: `~/.bashrc`
- System service management: `sudo systemctl` commands

### Windows WSL 2 Specifics:
- Prerequisites include WSL 2 enablement (PowerShell instructions)
- Ubuntu 22.04 LTS installation in WSL
- Docker Desktop integration settings (Resources → WSL integration)
- Mixed command examples (PowerShell for WSL setup, Bash for tools)
- Note about restarting required after WSL install

---

## Acceptance Criteria (Per Platform Guide)

- ✓ All 7 tools installation steps included
- ✓ Checkpoint verification before each installation
- ✓ Post-install verification after each step
- ✓ Expected output examples provided
- ✓ Low-resource alternatives documented (where applicable)
- ✓ Proxy configuration optional section included
- ✓ Troubleshooting references linked
- ✓ Platform-specific commands (no cross-platform confusion)
- ✓ Estimated time achievable (tested)
- ✓ All functional requirements (FR-001 through FR-017) satisfied
