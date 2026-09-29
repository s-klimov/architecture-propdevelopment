#!/bin/bash
# Связывание групп пользователей с ролями.
# Права выдаются группе (O в сертификате), а не отдельному пользователю.

set -e

# Роли на весь кластер
kubectl create clusterrolebinding viewers-binding \
  --clusterrole=cluster-viewer --group=viewers
kubectl create clusterrolebinding devops-binding \
  --clusterrole=cluster-configurator --group=devops
kubectl create clusterrolebinding security-binding \
  --clusterrole=security-auditor --group=security
kubectl create clusterrolebinding admins-binding \
  --clusterrole=cluster-admin --group=admins

# Разработчики доменов: доступ только к namespace своего домена
for domain in sales housing finance data; do
  kubectl create rolebinding "$domain-developers" \
    --clusterrole=domain-developer --group="$domain-team" --namespace="$domain"
done
