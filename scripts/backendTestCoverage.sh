#!/bin/bash

# Domyślny próg pokrycia i plik raportu
COVERAGE_THRESHOLD="${1:-80}"
COVERAGE_FILE="${2:-../.coverage}"

# Sprawdzenie, czy plik .coverage istnieje
if [ ! -f "$COVERAGE_FILE" ]; then
  echo "File ($COVERAGE_FILE) doesn't exist."
  echo "Please run 'run -m pytest' in main directory."
  exit 1
fi

cd ..

coverage report --fail-under=$COVERAGE_THRESHOLD

coverage html
