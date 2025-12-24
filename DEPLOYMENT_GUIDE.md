# 🚀 Step-by-Step Deployment Guide for Wisecow

This guide provides a comprehensive path to deploying the Wisecow application to a production-like environment on a **Linux Virtual Machine (VM)**, including GitHub Actions secret management and Kubernetes configuration.

---

## 🏗️ Phase 1: Provisioning the VM

You can use any cloud provider (AWS, GCP, Azure, DigitalOcean) or a local VM (VirtualBox/VMware).

1.  **OS**: Ubuntu 22.04 LTS (Recommended).
2.  **Specs**: Minimum 2 vCPUs, 4GB RAM, 20GB Disk.
3.  **Network**: Open ports:
    - `22`: SSH
    - `80`: HTTP (For Ingress)
    - `443`: HTTPS (For TLS)
    - `6443`: Kubernetes API (Optional, if connecting remotely)

---

## ☸️ Phase 2: Installing Kubernetes on the VM

For a simple and lightweight setup, we will use **K3s**.

1.  **SSH into your VM**:
    ```bash
    ssh ubuntu@<YOUR_VM_IP>
    ```

2.  **Install K3s**:
    ```bash
    curl -sfL https://get.k3s.io | sh -
    # Check status
    sudo kubectl get nodes
    ```

3.  **Extract Kubeconfig**:
    You will need this for GitHub Actions.
    ```bash
    sudo cat /etc/rancher/k3s/k3s.yaml
    ```
    *Note: Replace `127.0.0.1` inside the output with your VM's Public IP.*

---

## 🔐 Phase 3: GitHub Actions Secrets & Permissions

To allow GitHub to talk to your VM and Registry, follow these steps:

### 1. Registry Secrets (GHCR)
By default, GitHub Actions can use `GITHUB_TOKEN`. Ensure your repository settings allow actions to write to packages:
- **Settings** > **Actions** > **General** > **Workflow permissions**: Set to "Read and write permissions".

### 2. Kubeconfig Secret
1.  Go to your GitHub Repository.
2.  Navigate to **Settings** > **Secrets and variables** > **Actions**.
3.  Click **New repository secret**.
4.  **Name**: `KUBE_CONFIG`
5.  **Value**: Paste the content of the `k3s.yaml` (with the Public IP) you extracted in Phase 2.

---

## 🔄 Phase 4: Updating the CI/CD Workflow

Your current workflow uses `kind`. To deploy to your **remote VM**, you need to use the `KUBE_CONFIG` secret. 

Add/Update this job in `.github/workflows/ci-cd.yml`:

```yaml
  deploy-remote:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Kubectl
        uses: azure/setup-kubectl@v4

      - name: Set Kubeconfig
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBE_CONFIG }}" > ~/.kube/config
          chmod 600 ~/.kube/config

      - name: Deploy to Remote Cluster
        run: |
          kubectl apply -f ./Problem_Statement_1/deployment.yaml
          kubectl apply -f ./Problem_Statement_1/service.yaml
          kubectl apply -f ./Problem_Statement_1/ingress.yaml
```

---

## 🌐 Phase 5: TLS & Ingress Configuration

The assessment requires secure TLS communication.

1.  **Deploy NGINX Ingress Controller** (if using K3s, it comes with Traefik, but we'll use Nginx for this assessment):
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
    ```

2.  **Generate Certificates**:
    Inside your `Problem_Statement_1` directory, run the `generate_tls_cert.sh` script to create the secret on the cluster.

3.  **Local DNS Mapping**:
    Since `wisecow.local` isn't a real public domain, you must map it on your laptop/PC:
    - **Windows**: Edit `C:\Windows\System32\drivers\etc\hosts`
    - **Linux/Mac**: Edit `/etc/hosts`
    - **Add line**: `<VM_IP> wisecow.local`

---

## ✅ Phase 6: Verification

1.  **Check Pods**:
    ```bash
    kubectl get pods -l app=wisecow
    ```
2.  **Accessibility**:
    Open your browser and go to `https://wisecow.local`.
3.  **Security**:
    Click the Lock icon in the address bar to verify the SSL certificate.

---

## 🛠️ Troubleshooting

- **ImagePullBackOff**: Ensure your Docker image in `deployment.yaml` matches the one in GHCR and that the registry is public.
- **Connection Refused**: Ensure the Security Groups/Firewall on your VM allow traffic on ports 80 and 443.
- **Validation Error**: Check if your YAML indentation is correct in the manifests.
