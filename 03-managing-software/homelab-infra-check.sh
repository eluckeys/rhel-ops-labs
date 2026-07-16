#!/bin/bash
# Homelab MLOps Infra Verification Script
# Run this on your Ubuntu homelab laptop to see what's ready vs missing

echo "=================================================="
echo "  HOMELAB MLOPS INFRA CHECK - $(date)"
echo "=================================================="

check() {
    if eval "$2" &>/dev/null; then
        echo "[OK]      $1"
    else
        echo "[MISSING] $1"
    fi
}

echo ""
echo "--- Layer 1: Core Infra ---"
check "KVM/libvirt installed"        "command -v virsh"
check "K3s installed"                "command -v k3s || command -v kubectl"
check "K3s cluster reachable"        "kubectl get nodes"
check "Docker installed"             "command -v docker"
check "Prometheus running"           "kubectl get pods -A | grep -i prometheus"
check "Grafana running"              "kubectl get pods -A | grep -i grafana"
check "Zabbix running"               "docker ps | grep -i zabbix || kubectl get pods -A | grep -i zabbix"

echo ""
echo "--- Layer 2: Experiment Tracking ---"
check "MLflow running"               "docker ps | grep -i mlflow || kubectl get pods -A | grep -i mlflow"
check "MinIO running"                "docker ps | grep -i minio || kubectl get pods -A | grep -i minio"

echo ""
echo "--- Layer 3: Model Serving ---"
check "BentoML installed"            "python3 -c 'import bentoml' 2>/dev/null || pip show bentoml"
check "Seldon Core running"          "kubectl get pods -A | grep -i seldon"

echo ""
echo "--- Layer 4: CI/CD ---"
check "Jenkins running"              "docker ps | grep -i jenkins || kubectl get pods -A | grep -i jenkins"
check "gh CLI authenticated"         "gh auth status"

echo ""
echo "--- Layer 5: Monitoring/Drift ---"
check "Evidently AI installed"       "python3 -c 'import evidently' 2>/dev/null || pip show evidently"

echo ""
echo "--- Layer 6: GitOps ---"
check "ArgoCD running"               "kubectl get pods -A | grep -i argocd"

echo ""
echo "--- System Health ---"
echo "Disk usage:"
df -h | grep -E "GROWTH_STATION|HOME_LAB|/$" 2>/dev/null || df -h /
echo ""
echo "Memory:"
free -h
echo ""
echo "K3s node status:"
kubectl get nodes 2>/dev/null || echo "kubectl not accessible"

echo ""
echo "=================================================="
echo "  Done. Fix [MISSING] items in your build order."
echo "=================================================="
