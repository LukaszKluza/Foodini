#!/bin/bash

# Domyślny próg pokrycia i plik raportu
COVERAGE_THRESHOLD="${1:-80}"
COVERAGE_FILE="${2:-../backend/report.html}"

# Sprawdzenie, czy plik lcov.info istnieje
if [ ! -f "$COVERAGE_FILE" ]; then
  echo "File ($COVERAGE_FILE) doesn't exist."
  echo "Please run 'run -m pytest' in /backedn directory."
  exit 1
fi

cd ../backend

coverage report --fail-under=$COVERAGE_THRESHOLD

coverage html
