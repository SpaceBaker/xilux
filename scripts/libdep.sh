#!/usr/bin/env bash

declare -a FILES
TOPDIR="."
VERBOSE=false
POSITIONAL_ARGS=()
OUTFILE=''
OUTFILE_EXT="libdep"

# Check args
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dir)
      TOPDIR="$2"
      shift # past argument
      shift # past value
      ;;
    -v|--verbose)
      VERBOSE=true
      shift # past argument
      ;;
    -o|--output)
      OUTFILE="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# Set default output file name if none provided
if [[ -z "${OUTFILE}" ]] && [[ "${TOPDIR}" == "." ]]; then
  OUTFILE="${OUTFILE_EXT}"
elif [[ -z "${OUTFILE}" ]]; then
  OUTFILE="${TOPDIR}.${OUTFILE_EXT}"
fi

# Clear file content if it already exists
if [ -f "${OUTFILE}" ]; then
  truncate -s 0 "${OUTFILE}"
fi

# List all files (recursively) under TOPDIR
readarray -d '' FILES < <(find "${TOPDIR}" -type f -print0)

# For each file
for f in "${FILES[@]}"; do
  # Check if file elf format
  if file "${f}" | grep -q "ELF"; then
    # Find lib dep and create dep file
    if [ "$VERBOSE" = true ]; then 
      echo "lib nedded for '${f}' :"
      "${CROSS_COMPILE}ldd" --root "${TOPDIR}" "${f}" | tee -a "${OUTFILE}"
    else
      #echo "$( ${CROSS_COMPILE}readelf -a ${f} | grep '\.so' )"
      # echo "$( "${CROSS_COMPILE}ldd" --root "${TOPDIR}" "${f}" | grep '\.so' )" >> "${OUTFILE}"
      "${CROSS_COMPILE}ldd" --root "${TOPDIR}" "${f}" >> "${OUTFILE}"
    fi
  fi
done

# Clean up output file
cat "${OUTFILE}" | \
	sort -u | \
	sed -e 's/^[[:space:]]*//g' | \
	sed -e 's/[[:space:]]*$//g' | \
	cut -d'(' -f1 | \
	sed '/not a dynamic executable/d' > "${OUTFILE}.tmp" && mv "${OUTFILE}.tmp" "${OUTFILE}"