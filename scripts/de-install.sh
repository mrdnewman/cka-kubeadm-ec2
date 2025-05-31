#!/bin/bash
set -euo pipefail

echo "[CLEANUP] Stopping services..."
systemctl stop kubelet || true
systemctl stop containerd || true

echo "[CLEANUP] Disabling services..."
systemctl disable kubelet || true
systemctl disable containerd || true

echo "[CLEANUP] Purging Kubernetes packages..."
apt-get purge -y kubelet kubeadm kubectl kubernetes-cni cri-tools || true
apt-get purge -y containerd containerd.io runc || true

echo "[CLEANUP] Removing leftover packages and dependencies..."
apt-get autoremove -y
apt-get autoclean -y

echo "[CLEANUP] Deleting config directories and data..."
rm -rf /etc/kubernetes
rm -rf /var/lib/etcd
rm -rf /var/lib/kubelet
rm -rf /var/lib/containerd
rm -rf /run/containerd
rm -rf /etc/containerd
rm -rf /etc/cni
rm -rf /opt/cni
rm -rf /etc/systemd/system/kubelet.service.d
rm -rf /etc/systemd/system/containerd.service.d

echo "[CLEANUP] Removing APT keyrings and repo entries..."
rm -f /usr/share/keyrings/kubernetes-archive-keyring.gpg
rm -f /etc/apt/keyrings/docker.gpg
rm -f /etc/apt/sources.list.d/kubernetes.list
rm -f /etc/apt/sources.list.d/docker.list

echo "[CLEANUP] Flushing iptables and cleaning CNI state..."
iptables -F || true
iptables -X || true
rm -rf /etc/cni/net.d

echo "[CLEANUP] Resetting kubeadm state (ignore errors)..."
kubeadm reset -f || true

echo "[CLEANUP] Reloading systemd and updating APT..."
systemctl daemon-reload
apt-get update

echo "[CLEANUP] All done. System is now clean for a fresh install."
