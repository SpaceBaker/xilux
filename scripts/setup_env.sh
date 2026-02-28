# Source this file before running make.
# Allows a better handling of environment variables to build the project

# Disable and clear shell hash
set +h
hash -r

# Makes newly created files/directories writable only by the owner
umask 022

# Ensure a blank shell environment is used when invoking make (not carried by sub-make)
alias make="env -i PATH=${PATH} make"