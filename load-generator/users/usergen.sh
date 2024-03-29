#!/bin/bash
# Copyright 2023 The Wazo Authors  (see the AUTHORS file)
# SPDX-License-Identifier: GPL-3.0-or-later

START_SEQ=0

if [ $# -ne 3 ]; then
    echo "missing sequence parameter"
    echo "usage ./usergen.sh SEQ EXTEN_LEN PARAMS_FILE"
    echo "example ./usergen.sh 134 4 usergen_params.json"
    echo "  For user with extension \"0134\""
    exit 2
fi

# user_gen is aimed to create the json file representing a user.
user_gen () {
    local SEQUENCE=$1
    local EXTEN_LEN=$2
    local PASSWORD=htegrnadf
    local EXTENSION=$(printf "%0${EXTEN_LEN}d" $(echo $START_SEQ+$SEQUENCE|bc))
    local USERNAME=user$EXTENSION@wazo.io
    local USERS_CSV=user-files/users.csv
    local WEBRTC_UUID=$(jq -r .webrtc_uuid $PARAMS)
    local CONTEXT=$(jq -r .context $PARAMS)
    local INCALL_CONTEXT=$(jq -r .incall_context $PARAMS)
    local INCALL_PREFIX=$(jq -r .incall_prefix $PARAMS)

    echo "$USERNAME;$PASSWORD;$EXTENSION" >> $USERS_CSV

    cp user.json.tpl user-files/$EXTENSION.json

    sed  -i "s/__SEQUENCE__/$SEQUENCE/g" user-files/$EXTENSION.json
    sed  -i "s/__USERNAME__/$USERNAME/g" user-files/$EXTENSION.json
    sed  -i "s/__PASSWORD__/$PASSWORD/g" user-files/$EXTENSION.json
    sed  -i "s/__EXTENSION__/$EXTENSION/g" user-files/$EXTENSION.json
    sed  -i "s/__WEBRTC_UUID__/$WEBRTC_UUID/g" user-files/$EXTENSION.json
    sed  -i "s/__CONTEXT__/$CONTEXT/g" user-files/$EXTENSION.json
    sed  -i "s/__INCALL_CONTEXT__/$INCALL_CONTEXT/g" user-files/$EXTENSION.json
    sed  -i "s/__INCALL_PREFIX__/$INCALL_PREFIX/g" user-files/$EXTENSION.json

    echo user-files/$EXTENSION.json
}

# push_users is aimed to create the user into a specific stack by calling the API
# and posting the JSON generated by the user_gen func.
# you'll need to specify the stack IP, a valid token that should be generated before
# using this script and the tenant uuid specific to the stack as well.
push_users () {
    local tenant_uuid=$1
    local token=$2
    local stack_ip=$3
    local user_file=$4
    local call_permission_id_1=$5
    local call_permission_id_2=$6
    local output_file=user_output.json

    STATUS=$(curl -k -v -X POST "https://$stack_ip:443/api/confd/1.1/users" \
        -w "%{http_code}" -s -o $output_file \
        --header "Content-Type: application/json" \
        --header "Accept: application/json" \
        --header "Wazo-Tenant: $tenant_uuid" \
        --header "X-Auth-Token: $token" \
        --data @$user_file)
    if [ $STATUS -ne 201 ]; then
        USERNAME=$(echo $user_file | jq -r .lines[].name)
        echo "$USERNAME; STATUS CODE: $status" >> user-files/users.err
        mv $user_file user-files/err/
        return -1
    fi

    user_uuid=$(jq -r .uuid $output_file)
    curl -skv -X PUT "https://$stack_ip:443/api/confd/1.1/users/${user_uuid}/callpermissions/${call_permission_id_1}" \
        --header "Content-Type: application/json" \
        --header "Accept: application/json" \
        --header "Wazo-Tenant: $tenant_uuid" \
        --header "X-Auth-Token: $token"

    curl -skv -X PUT "https://$stack_ip:443/api/confd/1.1/users/${user_uuid}/callpermissions/${call_permission_id_2}" \
        --header "Content-Type: application/json" \
        --header "Accept: application/json" \
        --header "Wazo-Tenant: $tenant_uuid" \
        --header "X-Auth-Token: $token"

    echo $STATUS
}

SEQ=$1
EXTEN_LEN=$2
PARAMS=$3
UUID=$(jq  -r .uuid $PARAMS)
TOKEN=$(jq -r .token $PARAMS)
STACK_IP=$(jq  -r .ip $PARAMS)

GLOBAL_CALL_PERMISSION_ID=$(jq -r .global_call_permission_id $PARAMS)
EMERGENCY_CALL_PERMISSION_ID=$(jq -r .emergency_call_permission_id $PARAMS)

JSON=$(user_gen $SEQ $EXTEN_LEN)

mkdir -p  user-files/err
push_users $UUID $TOKEN $STACK_IP $JSON $GLOBAL_CALL_PERMISSION_ID $EMERGENCY_CALL_PERMISSION_ID
