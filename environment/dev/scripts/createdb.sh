#!/bin/bash
set -euo pipefail

# Require env vars from Terraform instead of hardcoding
: "${POSTGRES_HOST:?POSTGRES_HOST is required}"
: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"

echo "Creating databases ..."
kubectl run postgres-client \
  --image=postgres:16 \
  --restart=Never \
  --env="PGHOST=${POSTGRES_HOST}" \
  --env="PGUSER=${POSTGRES_USER}" \
  --env="PGPASSWORD=${POSTGRES_PASSWORD}" \
  --env="PGSSLMODE=require" \
  --command -- bash -lc '
    set -e
    for DB in edhub_auth_db assignment_service_db catalog_db eduhub_videos; do
      if psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='\''$DB'\''" | grep -q 1; then
        echo "ℹ️ Already exists: $DB"
      else
        psql -d postgres -v ON_ERROR_STOP=1 -c "CREATE DATABASE \"$DB\";" && echo "Created: $DB"
      fi
    done
  '

kubectl wait --for=condition=Ready pod/postgres-client --timeout=5s 2>/dev/null || true
kubectl logs pod/postgres-client || true
kubectl delete pod postgres-client --ignore-not-found
