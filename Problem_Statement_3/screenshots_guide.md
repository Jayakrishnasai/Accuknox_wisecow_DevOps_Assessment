# KubeArmor Policy Violations - Screenshots

This directory should contain screenshots demonstrating KubeArmor policy violations.

## Required Screenshots
1. `01-policies-applied.png`: `kubectl get kubeArmorpolicies`
2. `02-violation-blocked.png`: Attempting to read a sensitive file (e.g., `/etc/passwd`) being blocked.
3. `03-kubearmor-logs.png`: Output of KubeArmor logs showing the violation.
