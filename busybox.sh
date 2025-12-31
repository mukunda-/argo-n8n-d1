#!/bin/bash

# Run bash on a pod in the busybox namespace
kubectl exec -it -n busybox $(kubectl get pod -n busybox -o jsonpath='{.items[0].metadata.name}') -- /bin/sh
