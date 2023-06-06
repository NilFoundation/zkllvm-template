#/usr/bin/env bash
set -euxo pipefail

# checking files that should be produced by the compiler
check_file_exists() {
  FILE1="${1}"
  if [ ! -e "$FILE1" ]
  then
      echo "File $FILE1 was not created" >&2
      exit 1
  else
      echo "File $FILE1 created successfully"
  fi
}

rm -rf build && mkdir build && cd build
cmake -DCIRCUIT_ASSEMBLY_OUTPUT=TRUE ..
make template

check_file_exists "./src/template.ll"

assigner \
  -b src/template.ll \
  -i ../src/main.inp \
  -c template.crct \
  -t template.tbl \
  -e pallas

check_file_exists "./template.crct"
check_file_exists "./template.tbl"

