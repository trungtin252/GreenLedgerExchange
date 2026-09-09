#!/usr/bin/env bash
set -euo pipefail

psql --username "$POSTGRES_USER" --dbname postgres --set=ON_ERROR_STOP=1 \
  --set=registry_runtime_password="$REGISTRY_DB_PASSWORD" \
  --set=exchange_runtime_password="$EXCHANGE_DB_PASSWORD" \
  --set=registry_migrator_password="$REGISTRY_MIGRATOR_PASSWORD" \
  --set=exchange_migrator_password="$EXCHANGE_MIGRATOR_PASSWORD" <<'SQL'
CREATE ROLE registry_migrator LOGIN PASSWORD :'registry_migrator_password' NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
CREATE ROLE registry_runtime LOGIN PASSWORD :'registry_runtime_password' NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
CREATE ROLE exchange_migrator LOGIN PASSWORD :'exchange_migrator_password' NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
CREATE ROLE exchange_runtime LOGIN PASSWORD :'exchange_runtime_password' NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
CREATE DATABASE glx_registry OWNER registry_migrator;
CREATE DATABASE glx_exchange OWNER exchange_migrator;
REVOKE CONNECT ON DATABASE glx_registry FROM PUBLIC;
REVOKE CONNECT ON DATABASE glx_exchange FROM PUBLIC;
GRANT CONNECT ON DATABASE glx_registry TO registry_migrator, registry_runtime;
GRANT CONNECT ON DATABASE glx_exchange TO exchange_migrator, exchange_runtime;
SQL

psql --username "$POSTGRES_USER" --dbname glx_registry --set=ON_ERROR_STOP=1 <<'SQL'
CREATE EXTENSION postgis;
GRANT USAGE ON SCHEMA public TO registry_runtime;
ALTER DEFAULT PRIVILEGES FOR ROLE registry_migrator IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO registry_runtime;
ALTER DEFAULT PRIVILEGES FOR ROLE registry_migrator IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO registry_runtime;
SQL

psql --username "$POSTGRES_USER" --dbname glx_exchange --set=ON_ERROR_STOP=1 <<'SQL'
GRANT USAGE ON SCHEMA public TO exchange_runtime;
ALTER DEFAULT PRIVILEGES FOR ROLE exchange_migrator IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO exchange_runtime;
ALTER DEFAULT PRIVILEGES FOR ROLE exchange_migrator IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO exchange_runtime;
SQL
