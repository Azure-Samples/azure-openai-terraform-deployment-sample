#!/bin/bash

if [ -z "$ARM_CLIENT_ID" ]; then
    echo "ARM_CLIENT_ID is not set"
    exit 0
fi

# Check if $ARM_CLIENT_SECRET exists
if [ -z "$ARM_CLIENT_SECRET" ]; then
    echo "ARM_CLIENT_SECRET is not set"
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

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID