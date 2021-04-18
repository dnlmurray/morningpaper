#!/usr/bin/env sh
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -f /docker-entrypoint-initdb.d/database_setup.sql