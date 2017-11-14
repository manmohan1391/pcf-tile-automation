#!/bin/bash -e

set -xe 

#mv tool-om/om-linux-* tool-om/om-linux
chmod +x tool-om/om-linux
CMD=./tool-om/om-linux

RELEASE=`$CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k available-products | grep p-rabbitmq`

PRODUCT_NAME=`echo $RELEASE | cut -d"|" -f2 | tr -d " "`
PRODUCT_VERSION=`echo $RELEASE | cut -d"|" -f3 | tr -d " "`

$CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k stage-product -p $PRODUCT_NAME -v $PRODUCT_VERSION

function fn_other_azs {
  local azs_csv=$1
  echo $azs_csv | awk -F "," -v braceopen='{' -v braceclose='}' -v name='"name":' -v quote='"' -v OFS='"},{"name":"' '$1=$1 {print braceopen name quote $0 quote braceclose}'
}

OTHER_AZS=$(fn_other_azs $OTHER_JOB_AZS)

NETWORK=$(cat <<-EOF
{
  "singleton_availability_zone": {
    "name": "$SINGLETON_JOB_AZ"
  },
  "other_availability_zones": [
    $OTHER_AZS
  ],
  "network": {
    "name": "$NETWORK_NAME"
  },
  "service_network": {
    "name": "$SERVICE_NETWORK"
  }
}
EOF
)


#
#    ".rabbitmq-server.rsa_certificate": {
#      "value": {
#        "private_key_pem": "$PRIVATE_KEY_PEM",
#        "cert_pem": "$CERT_PEM"
#      }
#    },
PROPERTIES=$(cat <<-EOF
{
    ".rabbitmq-server.plugins": {
      "value": [
        "rabbitmq_management"
      ]
    },
    ".rabbitmq-server.server_admin_credentials": {
      "value": {
        "identity": "$RABBITMQ_ADMIN",
        "password": "$RABBITMQ_PW"
      }
    },
    ".properties.disk_alarm_threshold": {
      "value": "mem_relative_1_0"
    },
    ".rabbitmq-server.ssl_cacert": {
      "value": null
    },
    ".rabbitmq-server.ssl_verify": {
      "value": $SSL_VERIFY 
    },
    ".rabbitmq-server.ssl_verification_depth": {
      "value": $SSL_VERIFY_DEPTH
    },
    ".rabbitmq-server.ssl_fail_if_no_peer_cert": {
      "value": $SSL_FAIL_IF_NO_PEER_CERT
    },
    ".rabbitmq-server.cookie": {
      "value": null
    },
    ".rabbitmq-server.config": {
      "value": null
    }
}
EOF
)

if [[ "$SYSLOG_SELECTOR" == "true" ]]; then
SYSLOG_PROPS=$(cat <<-EOF
{
    ".properties.syslog_selector": {
      "value": "enabled"
    },
    ".properties.syslog_selector.enabled.syslog_transport": {
      "value": "$SYSLOG_PROTOCOL"
    },
    ".properties.syslog_selector.enabled.address": {
      "value": "$SYSLOG_HOST"
    },
    ".properties.syslog_selector.enabled.port": {
      "value": $SYSLOG_PORT
    }
}
EOF
)

else
SYSLOG_PROPS=$(cat <<-EOF
{
    ".properties.syslog_selector": {
      "value": "No"
    }
}
EOF
)
fi

echo "Applying syslog settings..."
$CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k configure-product -n $PRODUCT_NAME -p "$SYSLOG_PROPS"

RESOURCES=$(cat <<-EOF
{
}
EOF
)

$CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k configure-product -n $PRODUCT_NAME -p "$PROPERTIES" -pn "$NETWORK" -pr "$RESOURCES"

#
# Single node config bits
#
export SINGLE_NODE_AZ_ARRAY = `echo $SINGLE_NODE_AZS | jq --raw-input 'split(",")'`

SINGLE_NODE_PROPS=$(cat <<-EOF
{
    ".properties.on_demand_broker_dedicated_single_node_plan_cf_service_access": {
      "value": "$SINGLE_NODE_ACCESS"
    },
    ".properties.on_demand_broker_dedicated_single_node_plan_rabbitmq_az_placement": {
      "value": "[$SINGLE_NODE_AZS]"
    },
    ".properties.on_demand_broker_dedicated_single_node_plan_rabbitmq_vm_type": {
      "value": "$SINGLE_NODE_VM_TYPE"
    },
    ".properties.on_demand_broker_dedicated_single_node_plan_rabbitmq_persistent_disk_type": {
      "value": "$SINGLE_NODE_PERS_DISK_TYPE"
    },
    ".properties.on_demand_broker_dedicated_single_node_plan_disk_limit_acknowledgement": {
      "value": "$SINGLE_NODE_ACK"
    }
}
EOF
)

echo "Applying single node settings..."
$CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k configure-product -n $PRODUCT_NAME -p "$SINGLE_NODE_PROPS"
