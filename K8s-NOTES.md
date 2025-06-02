
# Kubernetes Daily Commands Cheat Sheet

A no-nonsense, go-to reference for daily Kubernetes operations — works on **kubeadm**, **EKS**, or any cluster.

---

## Table of Contents

1. [Cluster Status & Info](#cluster-status--info)  
2. [Working With Pods](#working-with-pods)  
3. [Deployments & ReplicaSets](#deployments--replicasets)  
4. [Services](#services)  
5. [Namespaces](#namespaces)  
6. [Config & Secrets](#config--secrets)  
7. [Miscellaneous](#miscellaneous)  
8. [Context & Config Management](#context--config-management)  

---

## Cluster Status & Info

- Show nodes and their status
kubectl get nodes

- Get detailed node info
kubectl describe node <node-name>

- Check cluster version
kubectl version --short

- Show cluster info
kubectl cluster-info

---

# Working With Pods

- List all pods in current namespace
kubectl get pods

- List all pods across all namespaces
kubectl get pods --all-namespaces

- Describe pod details
kubectl describe pod <pod-name> -n <namespace>

- Stream logs of a pod
kubectl logs -f <pod-name> -n <namespace>

- Logs of a specific container in pod
kubectl logs -f <pod-name> -c <container-name> -n <namespace>

- Exec into a running pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash

- Delete pod
kubectl delete pod <pod-name> -n <namespace>

---

# Deployments & ReplicaSets

 List deployments
kubectl get deployments

- Describe deployment
kubectl describe deployment <deployment-name> -n <namespace>

- Scale deployment
kubectl scale deployment <deployment-name> --replicas=<count> -n <namespace>

- Rollout status
kubectl rollout status deployment/<deployment-name> -n <namespace>

- Rollout restart deployment
kubectl rollout restart deployment/<deployment-name> -n <namespace>

- Rollback to previous deployment revision
kubectl rollout undo deployment/<deployment-name> -n <namespace>

---

 Services

- List services
kubectl get svc

- Describe service
kubectl describe svc <service-name> -n <namespace>

- Get service endpoint details
kubectl get svc <service-name> -n <namespace> -o wide

---

# Namespaces

- List namespaces
kubectl get namespaces

- Switch default namespace
kubectl config set-context --current --namespace=<namespace>

- Create a new namespace
kubectl create namespace <namespace>

---

# Config & Secrets

- Get configmaps
kubectl get configmaps -n <namespace>

- Describe configmap
kubectl describe configmap <name> -n <namespace>

- Get secrets
kubectl get secrets -n <namespace>

- Describe secret
kubectl describe secret <secret-name> -n <namespace>

- Decode secret data
kubectl get secret <secret-name> -n <namespace> -o jsonpath="{.data.<key>}" | base64 --decode

---

# Miscellaneous

- Get multiple resource types
kubectl get pods,svc,deployments,replicasets -n <namespace>

- Apply config file
kubectl apply -f <file.yaml>

- Delete resource from file
kubectl delete -f <file.yaml>

- Get events sorted by time
kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp

- Watch pods in real-time
kubectl get pods -n <namespace> -w

- Explain resource schema
kubectl explain deployment

---

# Context & Config Management

- Show current context
kubectl config current-context

- List all contexts
kubectl config get-contexts

- Switch context
kubectl config use-context <context-name>

- View kubeconfig file
cat ~/.kube/config

---


















