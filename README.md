# Secure Password Management with GPG

This project demonstrates how to securely manage sensitive information, such as passwords or API keys, using GPG encryption in a Linux environment. This approach helps ensure that critical credentials are never exposed in plaintext, enhancing security and reducing the risk of compromise.

## Overview

The script provided here guides you through:

- Encrypting a password or API key with GPG.
- Storing the encrypted password in a secure directory.
- Decryption on-demand for use in other scripts.

## How It Works

The script follows these steps:

1. Check if `gpg` is installed. If not, the script will prompt the user to install it before proceeding.
2. Create a secure folder (e.g., `/root/secure`) with restricted permissions to store the encrypted file.
3. Encrypt the password using GPG and store the encrypted file in the secure folder.
4. Provide an easy way to decrypt and use the password on-demand in your scripts.

## Setup Instructions

To use the script, follow these steps:

1. Edit the variables `PASSWORD` and `PASSPHRASE` in the script to set your password and encryption passphrase.
2. Run the script to generate an encrypted file that securely stores your password.
3. In your other scripts, use the provided command to decrypt and use the password whenever required:

   ```bash
   PASSWORD=$(gpg --quiet --batch --yes --passphrase "$PASSPHRASE" --decrypt /root/secure/password.gpg)
   ```

## Auditing (Optional and Recommended)

To enhance security, it is recommended to audit access to the encrypted file. This can help you detect any unauthorised attempts to access sensitive credentials.

### Step-by-Step Auditing Setup

1. Add an audit rule to monitor read access to the encrypted file:

   ```bash
   sudo auditctl -w /root/secure/password.gpg -p r -k api_key_monitor
   ```

2. To review audit logs, use:

   ```bash
   sudo ausearch -k api_key_monitor
   ```

3. To clean up the logs and extract relevant information, run:

   ```bash
   sudo ausearch -k api_key_monitor | awk '/time->/ {if (data != "") {print ts, data}; ts=$3" "$4" "$5" "$6" "$7; data=""} \
   /uid=|auid=/ {for(i=1;i<=NF;i++) if($i ~ /^(uid|auid)=/ && data !~ $i) data=data" "$i} \
   END {if (data != "") print ts, data}' | sort | uniq
   ```

By monitoring access to the encrypted file, you can gain insight into when and by whom the file is accessed, helping to detect any unauthorised attempts.

## Benefits of This Approach

Using GPG to manage sensitive information provides several key benefits:

- **Enhanced Security**: Passwords are stored in an encrypted format, reducing the risk of exposure.
- **On-Demand Decryption**: The password is decrypted only when needed, preventing it from being stored in plaintext on disk.
- **Access Control**: By restricting permissions to the encrypted file and its containing folder, only authorised users (typically root) can access the data.
- **Auditing**: Optional auditing allows for proactive monitoring of access attempts, improving the overall security posture.

## Conclusion

This project offers a practical example of how to securely manage sensitive information in a Linux environment using GPG. By encrypting passwords and storing them securely, you minimise the risk of credential exposure. Adding auditing helps you monitor and react to any unauthorised access attempts, making this approach robust for sensitive use cases.
