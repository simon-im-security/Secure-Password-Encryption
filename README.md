Secure Secret Encryption
========================

Description
-----------

This script encrypts secrets using GPG and stores them in a secure directory (`/root/secure`). Each secret has a unique passphrase for encryption. You can add multiple secrets and monitor access using `auditd`.

Usage Guide
-----------

### Prerequisites

*   Run the script as `root` or with `sudo` privileges.
*   Install GPG if it's not already installed.
*   Use tools like `auditd` to monitor access to sensitive files.

### Script Overview

*   **Title:** Secure Secret Encryption Script
*   **Author:** Simon .I
*   **Version:** 2024.10.25

The script encrypts multiple secrets with GPG, stores them securely, and provides guidance for monitoring access.

### Features

*   Encrypt secrets using GPG with AES256.
*   Store encrypted files in `/root/secure` with restricted access.
*   Easily add more secrets as needed.
*   Monitor file access using `auditd`.

### Instructions

1.  **Define Secrets:** Edit the `SECRET1`, `PASSPHRASE1`, etc., to specify your secrets and passphrases.
2.  **Run the Script:** Run the script with root privileges to create the secure folder and encrypt the secrets.
3.  **Add Monitoring:** Use `auditd` to track access to encrypted files.

### Sample Usage

    # Encrypting the first secret
    SECRET1="my_secret_value"
    PASSPHRASE1="my_passphrase"
    
    # Run the script
    sudo ./encrypt_secret.sh
        

### Monitoring Access Using auditd

Use `auditd` to monitor access:

    # Monitor read attempts
    sudo auditctl -w /root/secure/secret_1.gpg -p r -k secret1_access
        

View access logs:

    # View logs for secret_1.gpg
    sudo ausearch -k secret1_access
        

### Decrypting Secrets

To decrypt a secret:

    # Decrypting a secret
    SECRET1=$(gpg --quiet --batch --yes --passphrase "$PASSPHRASE1" --decrypt /root/secure/secret_1.gpg)
