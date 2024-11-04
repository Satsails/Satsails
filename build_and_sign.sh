#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display error messages
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Check for OpenSSL installation
if ! command -v openssl &> /dev/null; then
    error_exit "OpenSSL could not be found. Please install OpenSSL."
fi

# Define paths to your existing RSA keys
PRIVATE_KEY_PATH="private_key.pem"
PUBLIC_KEY_PATH="public_key.pem"

# Verify that the private key exists
if [[ ! -f "$PRIVATE_KEY_PATH" ]]; then
    error_exit "Private key not found at $PRIVATE_KEY_PATH."
fi

# Verify that the public key exists
if [[ ! -f "$PUBLIC_KEY_PATH" ]]; then
    error_exit "Public key not found at $PUBLIC_KEY_PATH."
fi

# Build the APK
echo "Building the APK..."
fvm flutter build apk --release || error_exit "Flutter build failed."

# Define APK path
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

# Check if the APK was created
if [[ ! -f "$APK_PATH" ]]; then
    error_exit "APK build failed. Please check for errors."
fi

# Sign the APK
echo "Signing the APK..."
openssl dgst -sha256 -sign "$PRIVATE_KEY_PATH" -out "$APK_PATH.sig" "$APK_PATH" || error_exit "APK signing failed."

# Verify the APK signature
echo "Verifying the APK signature..."
if openssl dgst -sha256 -verify "$PUBLIC_KEY_PATH" -signature "$APK_PATH.sig" "$APK_PATH"; then
    echo "APK signature verified successfully."
else
    error_exit "APK signature verification failed."
fi

# Generate SHA-256 Hash
echo "Generating SHA-256 hash..."
sha256sum "$APK_PATH" > "$APK_PATH.hash" || error_exit "SHA-256 hash generation failed."

# Success message
echo "APK built, signed, and hash generated successfully."
echo "APK: $APK_PATH"
echo "Signature: $APK_PATH.sig"
echo "Hash: $APK_PATH.hash"
