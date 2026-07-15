#!/bin/bash
# process-file.sh - counts lines in a given file

FILE="$1"

if [ -z "$FILE" ]; then
  echo "Usage: $0 <filename>" >&2
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "Error: file '$FILE' does not exist" >&2
  exit 2
fi

LINES=$(wc -l < "$FILE")
echo "File $FILE has $LINES lines"
exit 0
