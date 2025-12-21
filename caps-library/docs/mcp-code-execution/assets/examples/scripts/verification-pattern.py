#!/usr/bin/env python3
"""
Script: Verify Kafka deployment
Returns: Simple status, no raw pod data
"""

import subprocess
import json
import sys

def check_pods(namespace: str) -> bool:
    """Check if all pods running"""
    result = subprocess.run(
        ["kubectl", "get", "pods", "-n", namespace, "-o", "json"],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print(f"✗ Cannot access namespace {namespace}")
        return False

    pods = json.loads(result.stdout)["items"]

    if not pods:
        print(f"✗ No pods found in {namespace}")
        return False

    running = sum(1 for p in pods if p["status"]["phase"] == "Running")
    total = len(pods)

    # Return only summary, not full pod list
    if running == total:
        print(f"✓ All {total} pods running")
        return True
    else:
        print(f"⚠ {running}/{total} pods running")
        return False

def check_services(namespace: str) -> bool:
    """Check if services created"""
    result = subprocess.run(
        ["kubectl", "get", "svc", "-n", namespace],
        capture_output=True,
        text=True
    )

    if "kafka" in result.stdout:
        print("✓ Kafka service exists")
        return True
    else:
        print("✗ Kafka service not found")
        return False

def main():
    namespace = "kafka"

    all_ok = True
    all_ok = check_pods(namespace) and all_ok
    all_ok = check_services(namespace) and all_ok

    # Simple exit code
    sys.exit(0 if all_ok else 1)

if __name__ == "__main__":
    main()
