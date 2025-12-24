# AccuKnox DevOps Trainee Practical Assessment Submission

This repository contains the completed practical assessment for the DevOps Trainee position.

## 📁 Repository Structure

The solution is organized into three main directories, each corresponding to a problem statement:

### [Problem Statement 1: Containerization and Deployment](./Problem_Statement_1)
- **Objective**: Containerize and deploy the Wisecow application on Kubernetes with CI/CD and TLS.
- **Key Artifacts**:
  - `Dockerfile`: Multi-stage, lightweight Alpine-based image.
  - `deployment.yaml`: K8s deployment with resource limits and probes.
  - `service.yaml`: NodePort service for app exposure.
  - `ingress.yaml`: Ingress configuration with TLS support.
  - `.github/workflows/ci-cd.yml`: Automated build, push to GHCR, and Kind deployment.
  - `generate_tls_cert.sh`: Self-signed certificate generation script.

### [Problem Statement 2: DevOps Scripting](./Problem_Statement_2)
- **Objective**: Automation scripts for system monitoring and health checks.
- **Key Artifacts**:
  - `system_health_monitor.sh`: Monitors CPU, Memory, Disk, and Processes with alerts.
  - `app_health_checker.sh`: Checks web application availability via HTTP status codes.

### [Problem Statement 3: Zero-Trust Security](./Problem_Statement_3)
- **Objective**: Implement a Zero-Trust KubeArmor policy.
- **Key Artifacts**:
  - `kubearmor-policy.yaml`: Restrictive policy for the Wisecow workload.
  - `screenshots_guide.md`: Guide for verifying policy enforcement.

---

## 🚀 Getting Started

To deploy the entire solution locally:
1. Navigate to `Problem_Statement_1`.
2. run `docker build -t wisecow:latest .`.
3. Apply Kubernetes manifests using `kubectl apply -f .`.
4. Run the scripts in `Problem_Statement_2` to monitor health.
5. Apply the security policy in `Problem_Statement_3`.
