#!/usr/bin/env bash  

# Display host name on prompt (user@hostname)
sed -i 's/\[ ! -z \"${GITHUB_USER:-}\" \] && echo -n \"\\\[\\033\[0;32m\\\]@${GITHUB_USER:-} \" || echo -n \"\\\[\\033\[0;32m\\\]\\u /echo -n \"\\\[\\033\[0;32m\\\]\\u@\\h /' ~/.bashrc
# Initialize login UID to fix missed User build name (getlogin()) in Package Version
echo -e '\n# Initialize login UID\necho $UID > /proc/self/loginuid' >> ~/.bashrc