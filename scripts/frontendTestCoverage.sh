#!/bin/bash

COVERAGE_THRESHOLD="${1:-80}"
COVERAGE_FILE="${2:-../frontend/coverage/lcov.info}"

if [ ! -f "$COVERAGE_FILE" ]; then
  echo "File ($COVERAGE_FILE) doesn't exist."
  echo "Please run 'flutter test --coverage' in the /frontend directory."
  exit 1
fi

# Initialize sum variables for LF and LH
total_LF=0
total_LH=0

# Loop through the lcov file and sum all LF and LH values
while IFS= read -r line; do
  if [[ "$line" =~ ^LF: ]]; then
    LF_value=$(echo "$line" | awk -F: '{print $2}' | tr -d '[:space:]')
    total_LF=$((total_LF + LF_value))
  elif [[ "$line" =~ ^LH: ]]; then
    LH_value=$(echo "$line" | awk -F: '{print $2}' | tr -d '[:space:]')
    total_LH=$((total_LH + LH_value))
  fi
done < "$COVERAGE_FILE"

if [ $total_LF -eq 0 ]; then
  echo "[FAILED] No LF data found in $COVERAGE_FILE."
  exit 1
fi

if [ $total_LH -eq 0 ]; then
  echo "[FAILED] No LH data found in $COVERAGE_FILE."
  exit 1
fi

# Calculate coverage percentage using simple shell math
coverage_percentage=$(($total_LH * 100 / $total_LF))

echo "[INFO] Coverage percentage: $coverage_percentage%"

# Check if coverage is above the threshold
if [ "$coverage_percentage" -ge "$COVERAGE_THRESHOLD" ]; then
  echo "[PASSED] The coverage rating is greater or equal to $COVERAGE_THRESHOLD%."
  exit 0
else
  echo "[FAILED] The coverage rating is less than $COVERAGE_THRESHOLD%."
  exit 1
fi
