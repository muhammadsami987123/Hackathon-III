#!/usr/bin/env python3
"""
Kafka Deployment Script
Deploys Kafka to Kubernetes via Helm
All work happens here - minimal output to agent
"""

import subprocess
import sys
import argparse
from typing import List, Tuple

class HelmDeployer:
    def __init__(self, namespace: str):
        self.namespace = namespace
        self.errors = []

    def run(self, cmd: List[str], description: str = "") -> Tuple[bool, str]:
        """Execute command, return success/error"""
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=600,
                check=True
            )
            return True, result.stdout
        except subprocess.CalledProcessError as e:
            error_msg = f"{description}: {e.stderr}"
            self.errors.append(error_msg)
            return False, error_msg
        except Exception as e:
            error_msg = f"{description}: {str(e)}"
            self.errors.append(error_msg)
            return False, error_msg

    def add_helm_repo(self) -> bool:
        """Add Bitnami Helm repository"""
        success, _ = self.run(
            ["helm", "repo", "add", "bitnami", "https://charts.bitnami.com/bitnami"],
            "Add Helm repo"
        )
        if not success:
            return False

        success, _ = self.run(["helm", "repo", "update"], "Update Helm repos")
        return success

    def create_namespace(self) -> bool:
        """Create namespace if it doesn't exist"""
        cmd = [
            "kubectl", "create", "namespace", self.namespace,
            "--dry-run=client", "-o", "yaml"
        ]
        success, yaml_output = self.run(cmd, "Generate namespace YAML")
        if not success:
            return False

        # Apply the YAML
        apply_cmd = ["kubectl", "apply", "-f", "-"]
        try:
            subprocess.run(
                apply_cmd,
                input=yaml_output,
                text=True,
                check=True,
                capture_output=True
            )
            return True
        except subprocess.CalledProcessError as e:
            self.errors.append(f"Create namespace: {e.stderr}")
            return False

    def install_kafka(self) -> bool:
        """Install Kafka via Helm"""
        cmd = [
            "helm", "install", "kafka", "bitnami/kafka",
            "--namespace", self.namespace,
            "--set", "replicaCount=1",
            "--set", "zookeeper.replicaCount=1",
            "--set", "resources.requests.memory=2Gi",
            "--wait",
            "--timeout", "5m"
        ]
        success, _ = self.run(cmd, "Install Kafka")
        return success

    def create_topics(self) -> bool:
        """Create default topics"""
        topics = ["learning.explained", "code.executed", "exercise.failed"]

        for topic in topics:
            cmd = [
                "kubectl", "exec", "-it", "kafka-0", "-n", self.namespace, "--",
                "kafka-topics.sh",
                "--create",
                "--topic", topic,
                "--bootstrap-server", "localhost:9092",
                "--partitions", "3",
                "--replication-factor", "1",
                "--if-not-exists"
            ]
            success, _ = self.run(cmd, f"Create topic {topic}")
            if not success:
                return False

        return True

    def deploy(self) -> bool:
        """Execute full deployment"""
        print("Step 1: Adding Helm repository...")
        if not self.add_helm_repo():
            return False

        print("Step 2: Creating namespace...")
        if not self.create_namespace():
            return False

        print("Step 3: Installing Kafka cluster...")
        if not self.install_kafka():
            return False

        print("Step 4: Creating default topics...")
        if not self.create_topics():
            return False

        print("Deployment complete!")
        return True

def main():
    parser = argparse.ArgumentParser(description="Deploy Kafka to Kubernetes")
    parser.add_argument("--namespace", default="kafka", help="Kubernetes namespace")
    args = parser.parse_args()

    deployer = HelmDeployer(namespace=args.namespace)
    success = deployer.deploy()

    if not success:
        print(f"Error: {deployer.errors[0] if deployer.errors else 'Unknown error'}")
        sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()
