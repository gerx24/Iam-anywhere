#!/bin/bash

aws_signing_helper serve \
    --trust-anchor-arn $TRUST_ANCHOR_ARN \
    --profile-arn $PROFILE_ARN \
    --role-arn $ROLE_ARN \
    --certificate $CERTIFICATE_PATH  \
    --private-key $PRIVATE_KEY_PATH
