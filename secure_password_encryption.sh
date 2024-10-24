#!/bin/bash

# Title: Secure Password Encryption Script
# Description: Encrypts a password or secret using GPG and stores it in a secure location.
#              The user can use the encrypted file to retrieve the password in their own scripts.
# Author: Simon .I
# Version: 2024.10.24

# ---------------------------
# Variables to edit by the user:
PASSWORD="xxxxx"  # Replace 'xxxxx' with your actual password or secret
PASSPHRASE="your-secure-passphrase"  # Replace with your secure passphrase for GPG encryption
# ---------------------------

# Optional variables (do not change unless necessary):
SECURE_FOLDER="/root/secure"
PASSWORD_FILE="$SECURE_FOLDER/password.gpg"

# Step 0: Check if gpg is installed
if ! command -v gpg &> /dev/null; then
  echo "Error: GPG is not installed. Please install GPG and try again."
  exit 1
fi

# Step 1: Create the secure folder if it doesn't exist
# This folder will hold the encrypted password.
mkdir -p $SECURE_FOLDER
chmod 700 $SECURE_FOLDER  # Only root can access this folder

# Step 2: Check if a password file already exists in the folder
# If a password file is already present, exit to avoid overwriting the existing key.
if [ -f "$PASSWORD_FILE" ]; then
  echo "A password already exists in $SECURE_FOLDER. Exiting to avoid overwriting."
  exit 1
fi

# Step 3: Encrypt the password using GPG
echo "$PASSWORD" | gpg --batch --yes --passphrase "$PASSPHRASE" --symmetric --cipher-algo AES256 -o $PASSWORD_FILE
unset PASSWORD  # Clear the password from memory
chmod 400 $PASSWORD_FILE  # Ensure only root can read the encrypted file
echo "Password has been securely encrypted and stored in $PASSWORD_FILE."

# --------------------------------------------------------
# Important Notes:
# - To use the encrypted password in your scripts, use the following line:
#   PASSWORD=$(gpg --quiet --batch --yes --passphrase "$PASSPHRASE" --decrypt $PASSWORD_FILE)
# - Ensure the passphrase is stored securely and not hardcoded in scripts that are exposed.
# - This script creates only the encrypted password. Any cron jobs or other automation should be added separately.
# --------------------------------------------------------

# Monitoring and Auditing Instructions:
# -------------------------------------
# To monitor access to the encrypted password file for security purposes, we recommend using the auditd tool.
# Below are instructions on how to set up monitoring and use the audit logs to see who accessed the file.

# Step 1: Set up Audit Rule to Monitor Access
# --------------------------------------------
# You can add an audit rule to monitor read access to the encrypted file using:
# sudo auditctl -w $PASSWORD_FILE -p r -k api_key_monitor
# This command will create an audit rule with the key 'api_key_monitor' to monitor read access to the password file.

# Step 2: Search Audit Logs for Access
# -------------------------------------
# To see access logs for the monitored file, use:
# sudo ausearch -k api_key_monitor

# Step 3: Clean Up the Audit Logs for Readability
# -----------------------------------------------
# Use the following `awk` and `sort` command to clean up and format the audit logs for better readability:
# sudo ausearch -k api_key_monitor | awk '
# /time->/ {if (data != "") {print ts, data}; ts=$3" "$4" "$5" "$6" "$7; data=""} 
# /uid=|auid=/ {for(i=1;i<=NF;i++) if($i ~ /^(uid|auid)=/ && data !~ $i) data=data" "$i} 
# END {if (data != "") print ts, data}
# ' | sort | uniq

# This command extracts the relevant information, including timestamps and user IDs (`uid` and `auid`), to provide
# an easy-to-read list of when and who accessed the encrypted file.
# --------------------------------------------------------
