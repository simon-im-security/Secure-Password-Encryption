#!/bin/bash

# Title: Secure Secret Encryption Script
# Description: Encrypts secrets using GPG and stores them in a secure location.
#              The user can replicate the process to add as many secrets as needed.
#              Access to the encrypted files can be monitored using auditd or a similar tool.
# Author: Simon .I
# Version: 2024.10.25

# ---------------------------
# Variables to edit by the user:
# Add as many secrets and passphrases as needed by replicating the pattern below.
SECRET1="secret_value_1"  # Replace with your actual secret
PASSPHRASE1="passphrase1"  # Replace with your secure passphrase for the first secret

# Uncomment and replicate this pattern to add more secrets:
# SECRET2="secret_value_2"
# PASSPHRASE2="passphrase2"
# SECRET3="secret_value_3"
# PASSPHRASE3="passphrase3"
# ...and so on...
# ---------------------------

# Optional variables (do not change unless necessary):
# Each secret will be stored in its own file under /root/secure.
SECURE_FOLDER="/root/secure"
SECRET_FILE1="$SECURE_FOLDER/secret_1.gpg"

# Uncomment and replicate these lines for additional secret files:
# SECRET_FILE2="$SECURE_FOLDER/secret_2.gpg"
# SECRET_FILE3="$SECURE_FOLDER/secret_3.gpg"
# ...and so on...
# ---------------------------

# Check if the script is being run as root (or with sudo)
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root (or using sudo). Exiting."
  exit 1
fi

# Step 0: Check if gpg is installed
if ! command -v gpg &> /dev/null; then
  echo "Error: GPG is not installed. Please install GPG and try again."
  exit 1
fi

# Step 1: Create the secure folder if it doesn't exist
# The folder /root/secure is static and hardcoded here for storing encrypted files.
# This folder will hold the encrypted secret file(s).
mkdir -p $SECURE_FOLDER
chmod 700 $SECURE_FOLDER  # Only root can access this folder

# Step 2: Encrypt the first secret (active)
if [ ! -f "$SECRET_FILE1" ]; then
  echo "$SECRET1" | gpg --batch --yes --passphrase "$PASSPHRASE1" --symmetric --cipher-algo AES256 -o $SECRET_FILE1
  chmod 400 $SECRET_FILE1  # Ensure only root can read the encrypted file
  echo "Secret 1 has been securely encrypted and stored in $SECRET_FILE1."
else
  echo "Secret 1 file already exists at $SECRET_FILE1. Exiting to avoid overwriting."
  exit 1
fi

# Uncomment and replicate this section to encrypt additional secrets:
# if [ ! -f "$SECRET_FILE2" ]; then
#   echo "$SECRET2" | gpg --batch --yes --passphrase "$PASSPHRASE2" --symmetric --cipher-algo AES256 -o $SECRET_FILE2
#   chmod 400 $SECRET_FILE2
#   echo "Secret 2 has been securely encrypted and stored in $SECRET_FILE2."
# else
#   echo "Secret 2 file already exists at $SECRET_FILE2. Exiting to avoid overwriting."
#   exit 1
# fi

# if [ ! -f "$SECRET_FILE3" ]; then
#   echo "$SECRET3" | gpg --batch --yes --passphrase "$PASSPHRASE3" --symmetric --cipher-algo AES256 -o $SECRET_FILE3
#   chmod 400 $SECRET_FILE3
#   echo "Secret 3 has been securely encrypted and stored in $SECRET_FILE3."
# else
#   echo "Secret 3 file already exists at $SECRET_FILE3. Exiting to avoid overwriting."
#   exit 1
# fi
# ...and so on...

# --------------------------------------------------------
# Important Notes:
# - To use the encrypted secret in your scripts, decrypt each secret with its matching passphrase.
# - Replicate the pattern below for additional secrets:
#
#   SECRET1=$(gpg --quiet --batch --yes --passphrase "$PASSPHRASE1" --decrypt /root/secure/secret_1.gpg)
#   SECRET2=$(gpg --quiet --batch --yes --passphrase "$PASSPHRASE2" --decrypt /root/secure/secret_2.gpg)
#   SECRET3=$(gpg --quiet --batch --yes --passphrase "$PASSPHRASE3" --decrypt /root/secure/secret_3.gpg)
#   ...and so on...
#
# - Ensure that each passphrase is securely stored and never hardcoded in exposed scripts.
# - **Monitoring access**: You can monitor access to the encrypted files using a tool like auditd.
#   - Example: Set up audit rules to track access attempts for each secret file (secret_1.gpg, secret_2.gpg, etc.).
#   - See the monitoring script below for an example setup.
# --------------------------------------------------------

# --------------------------------------------------------
# Example Monitoring Setup (Using auditd):
#
# To monitor access to each secret file, you can add audit rules like this:
#
#   auditctl -w /root/secure/secret_1.gpg -p r -k secret1_access
#   auditctl -w /root/secure/secret_2.gpg -p r -k secret2_access
#   auditctl -w /root/secure/secret_3.gpg -p r -k secret3_access
#
# This will log read attempts to the files. To view the logs for these access attempts, use:
#
#   ausearch -k secret1_access
#   ausearch -k secret2_access
#   ausearch -k secret3_access
#
# Step 3: Clean Up the Audit Logs for Readability
# -----------------------------------------------
# Use the following `awk` and `sort` command to clean up and format the audit logs for better readability:
#
# sudo ausearch -k secret1_access | awk '
# /time->/ {if (data != "") {print ts, data}; ts=$3" "$4" "$5" "$6" "$7; data=""} 
# /uid=|auid=/ {for(i=1;i<=NF;i++) if($i ~ /^(uid|auid)=/ && data !~ $i) data=data" "$i} 
# END {if (data != "") print ts, data}
# ' | sort | uniq
#
# Replicate the above command for each secret, replacing "secret1_access" with the corresponding key.
# --------------------------------------------------------
