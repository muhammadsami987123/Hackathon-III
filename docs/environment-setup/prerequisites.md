# Prerequisites

**Before You Begin**: Verify these requirements before starting installation

---

## System Requirements Check

### Minimum Requirements (Basic Testing)

| Resource | Requirement | Check Command |
|----------|-------------|---------------|
| CPU Cores | 2+ | macOS: `sysctl -n hw.ncpu`<br>Linux: `nproc`<br>Windows: `wmic cpu get NumberOfCores` |
| RAM | 4GB+ | macOS: `sysctl -n hw.memsize` (bytes)<br>Linux: `free -h`<br>Windows: `systeminfo \| find "Total Physical Memory"` |
| Disk Space | 50GB+ free | macOS/Linux: `df -h`<br>Windows: `wmic logicaldisk get size,freespace,caption` |
| Internet | Stable connection | `ping -c 4 8.8.8.8` |

### Recommended Requirements (Full Development)

| Resource | Requirement |
|----------|-------------|
| CPU Cores | 4+ |
| RAM | 8GB+ |
| Disk Space | 100GB+ free |

⚠️ **Note**: Systems below minimum requirements may experience installation failures or poor performance.

---

## Git Installation

Git is required for all platform installations and repository management.

### Check if Git is Installed

```bash
git --version
```

**Expected Output**: `git version 2.40.0` or higher

### If Git is Not Installed

#### macOS
```bash
# Install Xcode Command Line Tools (includes git)
xcode-select --install
```

A dialog will appear - click "Install" and accept the license agreement.

**Verify**:
```bash
git --version
```

#### Linux (Ubuntu/Debian)
```bash
# Update package lists
sudo apt-get update

# Install git
sudo apt-get install -y git

# Verify
git --version
```

#### Windows (WSL 2)

First, ensure WSL 2 is installed (see [Windows installation guide](./windows-wsl-installation.md) for WSL setup).

Once inside WSL Ubuntu:
```bash
# Update package lists
sudo apt-get update

# Install git
sudo apt-get install -y git

# Verify
git --version
```

---

## Operating System Version Check

### macOS
```bash
sw_vers
```

**Supported**: macOS 11 (Big Sur) or later recommended

### Linux
```bash
lsb_release -a
```

**Supported**:
- Ubuntu 20.04 LTS or later
- Debian 10 (Buster) or later

### Windows
```powershell
# In PowerShell
winver
```

**Supported**: Windows 10 version 2004+ or Windows 11

**WSL 2 Check**:
```powershell
wsl --version
```

If WSL is not installed, follow [Windows installation guide](./windows-wsl-installation.md).

---

## Virtualization Support Check

Docker and Minikube require hardware virtualization support.

### macOS
Modern Macs (2010+) have virtualization enabled by default. No action needed.

### Linux
Check if virtualization is enabled:

```bash
# For Intel processors
grep -E '(vmx|svm)' /proc/cpuinfo
```

If no output appears, virtualization may be disabled in BIOS. Consult your system documentation to enable VT-x (Intel) or AMD-V (AMD).

### Windows
Virtualization is required for WSL 2 and Docker Desktop.

**Check in PowerShell (as Administrator)**:
```powershell
Get-ComputerInfo | Select-Object -Property HyperVisorPresent, HyperVRequirementVirtualizationFirmwareEnabled
```

Both should show `True`. If not, enable virtualization in BIOS settings.

---

## Network Connectivity Check

### Basic Connectivity Test
```bash
# Test DNS resolution and internet connectivity
ping -c 4 github.com
```

**Expected**: Successful ping with 0% packet loss

### Corporate Firewall/Proxy Users

If you're behind a corporate firewall, you may need to configure proxy settings. This is covered in each platform guide under "Network Connectivity (Optional)" sections.

**Common Proxy Environment Variables**:
- `HTTP_PROXY`
- `HTTPS_PROXY`
- `NO_PROXY`

Consult your IT department for specific proxy configuration if needed.

---

## Prerequisites Checklist

Before proceeding with platform-specific installation, ensure:

- [ ] System meets minimum requirements (2 CPU, 4GB RAM, 50GB disk)
- [ ] Git is installed and version 2.40+
- [ ] Operating system is officially supported version
- [ ] Virtualization is enabled (if applicable)
- [ ] Internet connection is stable
- [ ] You have administrative/sudo access to install software

**All checked?** Proceed to your platform-specific installation guide:
- [macOS Installation](./macos-installation.md)
- [Linux Installation](./linux-installation.md)
- [Windows WSL Installation](./windows-wsl-installation.md)

---

**Next**: [Choose Your Platform](./README.md#quick-start-choose-your-platform)
