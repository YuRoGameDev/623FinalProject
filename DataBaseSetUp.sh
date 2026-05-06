#!/bin/bash

set -e

set -a
source .env
set +a


# --- Install python packages locally for postgresql
if command -v python3 &> /dev/null
then
    PYTHON=python3
elif command -v python &> /dev/null
then
    PYTHON=python
else
    echo "Python is not installed."
    exit 1
fi

$PYTHON -m ensurepip --upgrade || true
$PYTHON -m pip install --upgrade pip

$PYTHON -m pip uninstall -y psycopg2 psycopg2-binary || true

$PYTHON -m pip cache purge || true

$PYTHON -m pip install --user --no-cache-dir "psycopg[binary]" python-dotenv

# --- Resets the Database to default

DB_NAME="finalproject"
DB_USER="postgres"

psql -U "$DB_USER" -h localhost -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
psql -U "$DB_USER" -h localhost -d postgres -c "CREATE DATABASE $DB_NAME;"

psql -U "$DB_USER" -h localhost -d "$DB_NAME" -f init.sql