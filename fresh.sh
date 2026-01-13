#!/bin/bash

./gen-secrets.sh
make install-argo
sleep 1
make argo-cli-login-core
make create-argo-apps-for-local
make get-argo-password
