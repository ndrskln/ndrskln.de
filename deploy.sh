#!/bin/bash

HUGO_OUTPUT_DIR="public"

# -e: exit on error,
# -u: exit on unset var,
# -o pipefail: fail on first error in pipeline
set -euo pipefail

# load & export all vars from .env (if exists)
if [ -f ".env" ]; then
  set -o allexport
  source .env
  set +o allexport
fi

# check that required variables are set
if [[ -z "${DEPLOY_HOST:-}" || -z "${DEPLOY_USER:-}" || -z "${DEPLOY_PATH:-}" ]]; then
  echo "Please set DEPLOY_HOST, DEPLOY_USER and DEPLOY_PATH (e.g., in .env)"
  exit 1
fi

# prepare ssh command
if [ -n "${SSH_KEY:-}" ]; then
  echo "Using SSH key: $SSH_KEY"
  SSH_CMD="ssh -i ${SSH_KEY}"
else
  echo "Using default SSH keys"
  SSH_CMD="ssh"
fi

# build the Hugo site
hugo

# deploy via rsync over SSH
echo "Deploying to ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH} …"
rsync -avz --delete \
  -e "$SSH_CMD" \
  ${HUGO_OUTPUT_DIR}/ \
  "${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}"

echo "Deployment finished successfully."
