#!/usr/bin/env python3
"""
Script: Deploy Kafka to Kubernetes
Returns: Minimal status, errors handled internally
"""

import subprocess
import sys
import json
from typing import Dict, List

class KafkaDeployer:
    """Handles Kafka deployment with error handling"""

    def __init__(self, namespace: str = "kafka"):
        self.namespace = namespace
        self.errors = []

    def run_command(self, cmd: List[str]) -> bool:
        """Execute command, capture output, handle errors"""
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=300,
                check=True
            )
            return True
        except subprocess.CalledProcessError as e:
            self.errors.append(f"Command failed: {' '.join(cmd)}")
            self.errors.append(f"Error: {e.stderr}")
            return False
        except TimeoutError:
            self.errors.append(f"Command timed out: {' '.join(cmd)}")
            return False

    def deploy(self) -> bool:
        """Deploy Kafka - all work happens here"""

        # Add Helm repo
        if not self.run_command([
            "helm", "repo", "add", "bitnami",
            "https://charts.bitnami.com/bitnami"
        ]):
            return False

        if not self.run_command(["helm", "repo", "update"]):
            return False

        # Create namespace
        if not self.run_command([
            "kubectl", "create", "namespace", self.namespace,
            "--dry-run=client", "-o", "yaml", "|", "kubectl", "apply", "-f", "-"
        ]):
            return False

        # Install Kafka
        if not self.run_command([
            "helm", "install", "kafka", "bitnami/kafka",
            "--namespace", self.namespace,
            "--set", "replicaCount=1",
            "--set", "zookeeper.replicaCount=1",
            "--wait", "--timeout", "5m"
        ]):
            return False

        return True

    def get_status(self) -> Dict:
        """Return only minimal status to agent"""
        if self.errors:
            return {
                "status": "failed",
                "errors": self.errors[:3],  # First 3 errors only
                "message": f"Deployment failed: {self.errors[0]}"
            }
        else:
            return {
                "status": "success",
                "message": "✓ Kafka deployed to namespace 'kafka'"
            }

def main():
    deployer = KafkaDeployer(namespace="kafka")
    success = deployer.deploy()

    status = deployer.get_status()

    # Print only what agent needs to see
    print(status["message"])

    # All work is done, only minimal output goes to context
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
