#!/bin/bash

COVERAGE_THRESHOLD="${1:-80}"
COVERAGE_FILE="${2:-../frontend/coverage/lcov.info}"

if [ ! -f "$COVERAGE_FILE" ]; then
  echo "File ($COVERAGE_FILE) doesn't exist."
  echo "Please run 'flutter test --coverage' in /frontend directory."
  exit 1
fi

# Extract LF (Total lines) and LH (Lines covered)
LF=$(grep "LF:" "$COVERAGE_FILE" | awk -F: '{print $2}')
LH=$(grep "LH:" "$COVERAGE_FILE" | awk -F: '{print $2}')

if [ -z "$LF" ] || [ -z "$LH" ]; then
  echo "[FAILED] Failed to extract line counts (LF or LH)."
  exit 1
fi

# Calculate coverage percentage using simple shell math
coverage_percentage=$((LH * 100 / LF))

echo "[INFO] Coverage percentage: $coverage_percentage%"

if [ "$coverage_percentage" -ge "$COVERAGE_THRESHOLD" ]; then
  echo "[PASSED] The coverage rating is greater or equal to $COVERAGE_THRESHOLD%."
  exit 0
else
  echo "[FAILED] The coverage rating is less than $COVERAGE_THRESHOLD%."
  exit 1
fi
