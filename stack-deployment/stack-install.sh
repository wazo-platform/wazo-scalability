#!/bin/bash 

source ./setup.env
STACK_IP=$(jq -r '.resources[] | select(.type == "openstack_networking_floatingip_v2") | .instances[0].attributes.address' terraform.tfstate)
if [ -z $STACK_IP ];then
    echo "missing stack ip. check the terraform.state file"
    exit 1
fi

# Start probing the stack
CODE=500
while [ $CODE -ne 200 ]
do
    CODE=$(curl -s -o /dev/null -w "%{http_code}"  -k https://$STACK_IP)
    sleep 30
done


CONFD_JSON=confd.json
curl -s -X GET \
  --header 'Accept: application/json' \
  -k -o $CONFD_JSON "https://$STACK_IP:$STACK_PORT/api/confd/1.1/wizard/discover"

STACK_PRIVATE_IP=$(jq -r '.interfaces[0].ip_address' $CONFD_JSON)
if [ -z $STACK_PRIVATE_IP ];then
    echo "missing private ip. check the result of GET 'https://$STACK_IP:$STACK_PORT/api/confd/1.1/wizard/discover'"
    exit 1
fi

# Generate the setup file from the template
template_file="./setup.json.tpl"
output_file="./setup.json"
sed -e "s/__ENGINE_PASSWORD__/\"$ENGINE_PASSWORD\"/" \
    -e "s/__STACK_IP__/\"$STACK_IP\"/" \
    -e "s/__STACK_PORT__/$STACK_PORT/" \
    -e "s/__PORTAL_FQDN__/\"$PORTAL_FQDN\"/" \
    -e "s/__NAME_INSTANCE__/\"$NAME_INSTANCE\"/" \
    -e "s/__PORTAL_PORT__/$PORTAL_PORT/" \
    -e "s/__PORTAL_ID__/\"$PORTAL_ID\"/" \
    -e "s/__PORTAL_PASSWORD__/\"$PORTAL_PASSWORD\"/" \
    -e "s/__STACK_PRIVATE_IP__/\"$STACK_PRIVATE_IP\"/" \
    "$template_file" > "$output_file"

# Pause before continuing stack configuration. The stack needs a bit of time to get ready
DELAY=400
sleep $DELAY 
# Setup the stack
curl -s -k -XPOST https://$STACK_IP:$STACK_PORT/api/setupd/1.0/setup \
  -H "Content-Type: application/json" \
  -d @$output_file

# Create the required token
TOKEN_JSON=token.json
curl -s -XPOST -o $TOKEN_JSON \
  --header 'Content-Type: application/json' \
  -u "root:$ENGINE_PASSWORD" \
  --header 'Accept: application/json' \
  -d '{"access_type": "online", "backend": "wazo_user", "expiration": 600000}' \
  "https://$STACK_IP:$STACK_PORT/api/auth/0.1/token" -k
INITIAL_TOKEN=$(jq -r .data.token token.json)


# Create the tenant uuid
TENANT_JSON=tenant.json
curl -s -o $TENANT_JSON -X POST \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  -d '{}' "https://$STACK_IP:$STACK_PORT/api/auth/0.1/tenants" \
  -k -H "X-Auth-Token: $INITIAL_TOKEN"

TENANT_UUID=$(jq -r .uuid $TENANT_JSON)


# Create the webrtc UUID
WEBRTC_UUID_JSON=werbrtc_sip_uuid.json
curl -s -X GET -o $WEBRTC_UUID_JSON \
  --header 'Accept: application/json' \
  --header "Wazo-Tenant: $TENANT_UUID" \
  --header "X-Auth-Token: $INITIAL_TOKEN" \
  "https://$STACK_IP:$STACK_PORT/api/confd/1.1/endpoints/sip/templates?search=webrtc" -k
WEBRTC_UUID=$(jq -r .items[].uuid werbrtc_sip_uuid.json)

# Create the internal tenant's context
CONTEXT_JSON=context.json
CONTEXT_ID=$(tr -dc A-Za-z0-9 < /dev/urandom|head -c 5)
CONTEXT=internal-$CONTEXT_ID
curl -s -o $CONTEXT_JSON -X POST \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header "Wazo-Tenant: $TENANT_UUID" \
  --header "X-Auth-Token: $INITIAL_TOKEN" \
  -d "{\"name\": \"$CONTEXT\", \"enabled\": true, \"label\": \"$CONTEXT\", \"type\": \"internal\", \"user_ranges\": [{\"end\": \"9999\", \"start\": \"1000\"}]}" \
  "https://$STACK_IP:$STACK_PORT/api/confd/1.1/contexts" -k

cd ../load-generator/users/
cat <<EOF >usergen_params.json
{
	"uuid":"$TENANT_UUID",
	"token":"$INITIAL_TOKEN",
	"ip":"$STACK_IP",
    "webrtc_uuid":"$WEBRTC_UUID",
    "context":"$CONTEXT"
}
EOF
make usergen5000