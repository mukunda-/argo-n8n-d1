#!/bin/bash

./gen-secrets.sh
make install-argo
make argo-forward &
sleep 1
make argo-cli-login
make create-argo-apps
make get-argo-password
