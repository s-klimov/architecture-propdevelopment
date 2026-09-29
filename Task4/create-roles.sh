#!/bin/bash
# Создание namespace доменов и ролей из таблицы roles.md.
# Роль cluster-admin встроенная, её создавать не нужно.

set -e

# Namespace для каждого домена компании
for ns in sales housing finance data; do
  kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
done

kubectl apply -f - <<EOF
# Только просмотр ресурсов кластера, без секретов
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-viewer
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "services", "configmaps", "namespaces", "nodes", "persistentvolumeclaims", "events"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps", "batch", "networking.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
---
# Настройка кластера, без доступа к секретам
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-configurator
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "services", "configmaps", "namespaces", "nodes", "persistentvolumeclaims", "persistentvolumes", "events", "serviceaccounts"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps", "batch", "networking.k8s.io", "autoscaling"]
  resources: ["*"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
# Разработчик домена: работает только в namespace своего домена (через RoleBinding)
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: domain-developer
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "services", "configmaps", "events"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
# Привилегированная роль ИБ: просмотр всего, включая секреты
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: security-auditor
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
EOF
