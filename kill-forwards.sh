#!/bin/bash

# Kill all kubectl port-forward processes for argo & n8n
pkill -f "kubectl port-forward.*argo"
pkill -f "kubectl port-forward.*n8n"
