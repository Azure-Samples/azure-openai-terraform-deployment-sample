#!/bin/bash

if [ -z "$ARM_CLIENT_ID" ]; then
    echo "ARM_CLIENT_ID is not set"
    exit 0
fi

# Check if both $ARM_CLIENT_SECRET and $ARM_CLIENT_CERTIFICATE are empty
if [ -z "$ARM_CLIENT_SECRET" ] && [ -z "$ARM_CLIENT_CERTIFICATE" ]; then
    echo "Either ARM_CLIENT_SECRET or ARM_CLIENT_CERTIFICATE should be set"
    exit 0
fi

# Check if $ARM_TENANT_ID exists
if [ -z "$ARM_TENANT_ID" ]; then
    echo "ARM_TENANT_ID is not set"
    exit 0
fi

# Check if $ARM_SUBSCRIPTION_ID exists
if [ -z "$ARM_SUBSCRIPTION_ID" ]; then
    echo "ARM_SUBSCRIPTION_ID is not set"
    exit 0
fi

# If ARM_CLIENT_CERTIFICATE is set, decode it and save to a temp file
if [ -n "$ARM_CLIENT_CERTIFICATE" ]; then
    echo "$ARM_CLIENT_CERTIFICATE" | base64 -d > /tmp/certfile.pem
    export ARM_CLIENT_CERTIFICATE_PATH="/tmp/certfile.pfx"
    export ARM_CLIENT_CERTIFICATE_PASSWORD=$(date '+%s')
    echo "$ARM_CLIENT_CERTIFICATE" | base64 -d | openssl pkcs12 -export -password pass:"${ARM_CLIENT_CERTIFICATE_PASSWORD}" -out $ARM_CLIENT_CERTIFICATE_PATH
    unset ARM_CLIENT_CERTIFICATE
    az login --service-principal -u $ARM_CLIENT_ID --tenant $ARM_TENANT_ID -p /tmp/certfile.pem

else
    # Otherwise, use ARM_CLIENT_SECRET
    az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
fi
