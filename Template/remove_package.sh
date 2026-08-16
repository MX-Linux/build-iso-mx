#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <package_to_remove>"
  exit 1
fi

package_to_remove="$1"

grep -rl "$package_to_remove" . | while read -r file; do
  sed -i "/^$package_to_remove/d" "$file"
done
