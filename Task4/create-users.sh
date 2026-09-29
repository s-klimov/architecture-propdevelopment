#!/bin/bash
# Создание пользователей кластера Minikube.
# Пользователь входит по сертификату: CN = имя пользователя, O = группа.
# Сертификат подписывается CA из Minikube.

set -e

CA_DIR=~/.minikube
USERS_DIR=./users
mkdir -p "$USERS_DIR"

create_user() {
  local user=$1
  local group=$2

  # Ключ и запрос на сертификат
  openssl genrsa -out "$USERS_DIR/$user.key" 2048
  openssl req -new -key "$USERS_DIR/$user.key" \
    -out "$USERS_DIR/$user.csr" -subj "/CN=$user/O=$group"

  # Подписываем сертификат CA кластера
  openssl x509 -req -in "$USERS_DIR/$user.csr" \
    -CA "$CA_DIR/ca.crt" -CAkey "$CA_DIR/ca.key" -CAcreateserial \
    -out "$USERS_DIR/$user.crt" -days 365

  # Добавляем пользователя и контекст в kubeconfig
  kubectl config set-credentials "$user" \
    --client-certificate="$USERS_DIR/$user.crt" \
    --client-key="$USERS_DIR/$user.key" --embed-certs=true
  kubectl config set-context "$user" --cluster=minikube --user="$user"

  echo "Пользователь $user (группа $group) создан"
}

create_user viewer-user   viewers
create_user devops-user   devops
create_user sales-dev     sales-team
create_user security-user security
create_user admin-user    admins
