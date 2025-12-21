#!/usr/bin/env python3
"""
Kafka Verification Script
Checks deployment health
Returns only status summary, not raw data
"""

import subprocess
import json
import sys
import argparse

class KafkaVerifier:
    def __init__(self, namespace: str):
        self.namespace = namespace
        self.checks_passed = []
        self.checks_failed = []

    def run_command(self, cmd):
        """Execute kubectl command"""
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr

    def check_pods(self) -> bool:
        """Verify all pods running"""
        success, stdout, _ = self.run_command([
            "kubectl", "get", "pods", "-n", self.namespace, "-o", "json"
        ])

        if not success:
            self.checks_failed.append("Cannot access pods")
            return False

        try:
            pods = json.loads(stdout)["items"]
            if not pods:
                self.checks_failed.append("No pods found")
                return False

            running = sum(1 for p in pods if p["status"]["phase"] == "Running")
            total = len(pods)

            # Return only summary
            if running == total:
                self.checks_passed.append(f"✓ All {total} pods running")
                return True
            else:
                self.checks_failed.append(f"Only {running}/{total} pods running")
                return False
        except json.JSONDecodeError:
            self.checks_failed.append("Cannot parse pod data")
            return False

    def check_services(self) -> bool:
        """Verify Kafka service exists"""
        success, stdout, _ = self.run_command([
            "kubectl", "get", "svc", "-n", self.namespace
        ])

        if "kafka" in stdout:
            self.checks_passed.append("✓ Kafka service exists")
            return True
        else:
            self.checks_failed.append("Kafka service not found")
            return False

    def check_topics(self) -> bool:
        """Verify default topics created"""
        cmd = [
            "kubectl", "exec", "-it", "kafka-0", "-n", self.namespace, "--",
            "kafka-topics.sh", "--list", "--bootstrap-server", "localhost:9092"
        ]
        success, stdout, _ = self.run_command(cmd)

        if success and "learning" in stdout:
            self.checks_passed.append("✓ Default topics created")
            return True
        else:
            self.checks_failed.append("Topics not accessible")
            return False

    def verify(self) -> bool:
        """Run all verification checks"""
        self.check_pods()
        self.check_services()
        self.check_topics()

        # Print only summary
        for check in self.checks_passed:
            print(check)

        for check in self.checks_failed:
            print(f"⚠ {check}")

        return len(self.checks_failed) == 0

def main():
    parser = argparse.ArgumentParser(description="Verify Kafka deployment")
    parser.add_argument("--namespace", default="kafka")
    args = parser.parse_args()

    verifier = KafkaVerifier(namespace=args.namespace)
    success = verifier.verify()

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
