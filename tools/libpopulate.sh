#!/usr/bin/env bash

ROOTDIR="output/rootfs_staging"
OUTFILE=libdep

# Clear file content if it already exists
if [ -f "${OUTFILE}" ]; then
  truncate -s 0 "${OUTFILE}"
fi

# Check arg
if [[ -z $1 ]]; then
    echo "ERROR: no directory provided"
    exit 1
elif [[ ! -d $1 ]]; then
    echo "ERROR: directory $1 does not exist"
    exit 1
else
    ROOTDIR="$1"
fi


# List all files (recursively) under TOPDIR
readarray -d '' FILES < <(find "${ROOTDIR}" -type f -print0)

# For each file
for f in "${FILES[@]}"; do
  # Check if file elf format
  if file "${f}" | grep -q "ELF"; then
    "${CROSS_COMPILE}readelf" -a "${f}" | grep "Shared library:" | sed 's/.*\[\(.*\)\].*/\1/' >> "${OUTFILE}"
    "${CROSS_COMPILE}readelf" -a "${f}" | grep "Requesting program interpreter:" | sed -E 's|.*/([^]]*)\]|\1|' >> "${OUTFILE}"
  fi
done

# Clean up output file
cat "${OUTFILE}" | \
	sort -u | \
	sed -e 's/^[[:space:]]*//g' | \
	sed -e 's/[[:space:]]*$//g' | \
	cut -d'(' -f1 | \
	sed '/not a dynamic executable/d' > "${OUTFILE}.tmp" && mv "${OUTFILE}.tmp" "${OUTFILE}"

# Find and populate
while IFS= read -r lib; do
  libpath=$("${CROSS_COMPILE}gcc" -print-file-name="${lib}")
  # If the lib is not found in the toolchain sysroot, it still prints the inputed string
  if [[ "${libpath}" != "${lib}" ]]; then
    install -m 755 "${libpath}" ${ROOTDIR}/usr/lib/${lib}
  fi
done < "${OUTFILE}"