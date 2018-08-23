#!/bin/bash -e

set -x

#mv tool-om/om-linux-* tool-om/om-linux
chmod +x tool-om/om-linux
CMD=./tool-om/om-linux

RELEASE=`$CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k available-products | grep p-cloudcache`

PRODUCT_NAME=`echo $RELEASE | cut -d"|" -f2 | tr -d " "`
PRODUCT_VERSION=`echo $RELEASE | cut -d"|" -f3 | tr -d " "`

$CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k stage-product -p $PRODUCT_NAME -v $PRODUCT_VERSION

function fn_other_azs {
  local azs_csv=$1
  echo $azs_csv | awk -F "," -v braceopen='{' -v braceclose='}' -v name='"name":' -v quote='"' -v OFS='"},{"name":"' '$1=$1 {print braceopen name quote $0 quote braceclose}'
}

function pcc_azs {
        local azs_csv=$1
        echo $azs_csv | awk '{for (i=1;i<=NF;i++) $i="\""$i"\""}1' FS="," OFS=","
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

PLAN_1_AZS=$(pcc_azs $PLAN_1_AVAILABILITY_ZONES)
PLAN_2_AZS=$(pcc_azs $PLAN_2_AVAILABILITY_ZONES)
PLAN_3_AZS=$(pcc_azs $PLAN_3_AVAILABILITY_ZONES)
PLAN_4_AZS=$(pcc_azs $PLAN_4_AVAILABILITY_ZONES)
PLAN_5_AZS=$(pcc_azs $PLAN_5_AVAILABILITY_ZONES)

PROPERTIES=$(cat <<-EOF
{
    ".properties.errand_plan": {
      "value": "$SMOKE_TEST_PLAN"
    },
    ".properties.default_distributed_system_id": {
      "value": "$DIST_SYSTEM_ID"
    },
    ".properties.dev_plan_enable_service_plan": {
      "value": "$DEV_PLAN_STATUS"
    },
    ".properties.plan1_enable_service_plan": {
      "value": "$PLAN_1_STATUS"
    },
    ".properties.plan1_enable_service_plan.enable.plan_name": {
      "value": "$PLAN_1_NAME"
    },
    ".properties.plan1_enable_service_plan.enable.plan_description": {
      "value": "$PLAN_1_DESC"
    },
    ".properties.plan1_enable_service_plan.enable.service_metrics": {
      "value": "$PLAN_1_METRICS"
    },
    ".properties.plan1_enable_service_plan.enable.cf_service_access": {
      "value": "$PLAN_1_SERVICE_ACCESS"
    },
    ".properties.plan1_enable_service_plan.enable.service_instance_quota": {
      "value": "$PLAN_1_SERVICE_INSTANCE_QUOTA"
    },
    ".properties.plan1_enable_service_plan.enable.max_servers_per_cluster": {
      "value": "$PLAN_1_SERVERS_PER_CLUSTER"
    },
    ".properties.plan1_enable_service_plan.enable.default_num_servers": {
      "value": "$PLAN_1_DEFAULT_NUM_SERVERS"
    },
    ".properties.plan1_enable_service_plan.enable.service_instance_azs": {
      "value": [
        $PLAN_1_AZS
       ]
    }, 
    ".properties.plan1_enable_service_plan.enable.locator_vm_type": {
      "value": "$PLAN_1_LOCATOR_VM"
    },
    ".properties.plan1_enable_service_plan.enable.locator_persistent_disk_type": {
      "value": "$PLAN_1_PERSIS_DISK_LOCATOR"
    },
    ".properties.plan1_enable_service_plan.enable.server_vm_type": {
      "value": "$PLAN_1_SERVER_VM"
    },
    ".properties.plan1_enable_service_plan.enable.server_persistent_disk_type": {
      "value": "$PLAN_1_PERSIS_DISK_SERVER"
    }, 
    ".properties.plan2_enable_service_plan": {
      "value": "$PLAN_2_STATUS"
    },
    ".properties.plan2_enable_service_plan.enable.plan_name": {
      "value": "$PLAN_2_NAME"
    },
    ".properties.plan2_enable_service_plan.enable.plan_description": {
      "value": "$PLAN_2_DESC"
    },
    ".properties.plan2_enable_service_plan.enable.service_metrics": {
      "value": "$PLAN_2_METRICS"
    },
    ".properties.plan2_enable_service_plan.enable.cf_service_access": {
      "value": "$PLAN_2_SERVICE_ACCESS"
    },
    ".properties.plan2_enable_service_plan.enable.service_instance_quota": {
      "value": "$PLAN_2_SERVICE_INSTANCE_QUOTA"
    },
    ".properties.plan2_enable_service_plan.enable.max_servers_per_cluster": {
      "value": "$PLAN_2_SERVERS_PER_CLUSTER"
    },
    ".properties.plan2_enable_service_plan.enable.default_num_servers": {
      "value": "$PLAN_2_DEFAULT_NUM_SERVERS"
    },
    ".properties.plan2_enable_service_plan.enable.service_instance_azs": {
      "value": [
        $PLAN_2_AZS
       ]
    }, 
    ".properties.plan2_enable_service_plan.enable.locator_vm_type": {
      "value": "$PLAN_2_LOCATOR_VM"
    },
    ".properties.plan2_enable_service_plan.enable.locator_persistent_disk_type": {
      "value": "$PLAN_2_PERSIS_DISK_LOCATOR"
    },
    ".properties.plan2_enable_service_plan.enable.server_vm_type": {
      "value": "$PLAN_2_SERVER_VM"
    },
    ".properties.plan2_enable_service_plan.enable.server_persistent_disk_type": {
      "value": "$PLAN_2_PERSIS_DISK_SERVER"
    }, 
    ".properties.plan3_enable_service_plan": {
      "value": "$PLAN_3_STATUS"
    },
    ".properties.plan3_enable_service_plan.enable.plan_name": {
      "value": "$PLAN_3_NAME"
    },
    ".properties.plan3_enable_service_plan.enable.plan_description": {
      "value": "$PLAN_3_DESC"
    },
    ".properties.plan3_enable_service_plan.enable.service_metrics": {
      "value": "$PLAN_3_METRICS"
    },
    ".properties.plan3_enable_service_plan.enable.cf_service_access": {
      "value": "$PLAN_3_SERVICE_ACCESS"
    },
    ".properties.plan3_enable_service_plan.enable.service_instance_quota": {
      "value": "$PLAN_3_SERVICE_INSTANCE_QUOTA"
    },
    ".properties.plan3_enable_service_plan.enable.max_servers_per_cluster": {
      "value": "$PLAN_3_SERVERS_PER_CLUSTER"
    },
    ".properties.plan3_enable_service_plan.enable.default_num_servers": {
      "value": "$PLAN_3_DEFAULT_NUM_SERVERS"
    },
    ".properties.plan3_enable_service_plan.enable.service_instance_azs": {
      "value": [
        $PLAN_3_AZS
       ]
    }, 
    ".properties.plan3_enable_service_plan.enable.locator_vm_type": {
      "value": "$PLAN_3_LOCATOR_VM"
    },
    ".properties.plan3_enable_service_plan.enable.locator_persistent_disk_type": {
      "value": "$PLAN_3_PERSIS_DISK_LOCATOR"
    },
    ".properties.plan3_enable_service_plan.enable.server_vm_type": {
      "value": "$PLAN_3_SERVER_VM"
    },
    ".properties.plan3_enable_service_plan.enable.server_persistent_disk_type": {
      "value": "$PLAN_3_PERSIS_DISK_SERVER"
    }, 
    ".properties.plan4_enable_service_plan": {
      "value": "$PLAN_4_STATUS"
    },
    ".properties.plan4_enable_service_plan.enable.plan_name": {
      "value": "$PLAN_4_NAME"
    },
    ".properties.plan4_enable_service_plan.enable.plan_description": {
      "value": "$PLAN_4_DESC"
    },
    ".properties.plan4_enable_service_plan.enable.service_metrics": {
      "value": "$PLAN_4_METRICS"
    },
    ".properties.plan4_enable_service_plan.enable.cf_service_access": {
      "value": "$PLAN_4_SERVICE_ACCESS"
    },
    ".properties.plan4_enable_service_plan.enable.service_instance_quota": {
      "value": "$PLAN_4_SERVICE_INSTANCE_QUOTA"
    },
    ".properties.plan4_enable_service_plan.enable.max_servers_per_cluster": {
      "value": "$PLAN_4_SERVERS_PER_CLUSTER"
    },
    ".properties.plan4_enable_service_plan.enable.default_num_servers": {
      "value": "$PLAN_4_DEFAULT_NUM_SERVERS"
    },
    ".properties.plan4_enable_service_plan.enable.service_instance_azs": {
      "value": [
        $PLAN_4_AZS
       ]
    }, 
    ".properties.plan4_enable_service_plan.enable.locator_vm_type": {
      "value": "$PLAN_4_LOCATOR_VM"
    },
    ".properties.plan4_enable_service_plan.enable.locator_persistent_disk_type": {
      "value": "$PLAN_4_PERSIS_DISK_LOCATOR"
    },
    ".properties.plan4_enable_service_plan.enable.server_vm_type": {
      "value": "$PLAN_4_SERVER_VM"
    },
    ".properties.plan4_enable_service_plan.enable.server_persistent_disk_type": {
      "value": "$PLAN_4_PERSIS_DISK_SERVER"
    }, 
    ".properties.plan5_enable_service_plan": {
      "value": "$PLAN_5_STATUS"
    },
    ".properties.plan5_enable_service_plan.enable.plan_name": {
      "value": "$PLAN_5_NAME"
    },
    ".properties.plan5_enable_service_plan.enable.plan_description": {
      "value": "$PLAN_5_DESC"
    },
    ".properties.plan5_enable_service_plan.enable.service_metrics": {
      "value": "$PLAN_5_METRICS"
    },
    ".properties.plan5_enable_service_plan.enable.cf_service_access": {
      "value": "$PLAN_5_SERVICE_ACCESS"
    },
    ".properties.plan5_enable_service_plan.enable.service_instance_quota": {
      "value": "$PLAN_5_SERVICE_INSTANCE_QUOTA"
    },
    ".properties.plan5_enable_service_plan.enable.max_servers_per_cluster": {
      "value": "$PLAN_5_SERVERS_PER_CLUSTER"
    },
    ".properties.plan5_enable_service_plan.enable.default_num_servers": {
      "value": "$PLAN_5_DEFAULT_NUM_SERVERS"
    },
    ".properties.plan5_enable_service_plan.enable.service_instance_azs": {
      "value": [
        $PLAN_5_AZS
       ]
    }, 
    ".properties.plan5_enable_service_plan.enable.locator_vm_type": {
      "value": "$PLAN_5_LOCATOR_VM"
    },
    ".properties.plan5_enable_service_plan.enable.locator_persistent_disk_type": {
      "value": "$PLAN_5_PERSIS_DISK_LOCATOR"
    },
    ".properties.plan5_enable_service_plan.enable.server_vm_type": {
      "value": "$PLAN_5_SERVER_VM"
    },
    ".properties.plan5_enable_service_plan.enable.server_persistent_disk_type": {
      "value": "$PLAN_5_PERSIS_DISK_SERVER"
    } 
}
EOF
)

echo "Saving properties for minimum valuable configuration"

$CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k configure-product -n $PRODUCT_NAME -p "$PROPERTIES" -pn "$NETWORK"

if [[ "$SYSLOG_SELECTOR" == "enable" ]]; then
SYSLOG_PROPS=$(cat <<-EOF
{
    ".properties.syslog": {
      "value": "$SYSLOG_SELECTOR"
    },
    ".properties.syslog.enable.syslog_protocol": {
      "value": "$SYSLOG_PROTOCOL"
    },
    ".properties.syslog.enable.syslog_address": {
      "value": "$SYSLOG_HOST"
    },
    ".properties.syslog.enable.syslog_port": {
      "value": "$SYSLOG_PORT"
    },
     ".properties.syslog.enable.syslog_enabled_for_service_instances": {
      "value": "$SERVICE_LOG_EXTERNAL_SYSLOG"
    },
    ".properties.syslog.enable.syslog_tls": {
      "value": "$ENABLE_TLS"
    },
    ".properties.syslog.enable.syslog_permitted_peer": {
       "value": "$PERMITTED_PEER"
    },
    ".properties.syslog.enable.syslog_ca_cert": {
      "value": "$SYSLOG_SSL_CERT"
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

if [[ -z "$ERRANDS_TO_DISABLE" ]] || [[ "$ERRANDS_TO_DISABLE" == "none" ]]; then
  echo "No post-deploy errands to disable"
else
  enabled_errands=$(
  $CMD -t https://${OPS_MGR_HOST} -u $OPS_MGR_USR -p $OPS_MGR_PWD -k errands --product-name $PRODUCT_NAME |
  tail -n+4 | head -n-1 | grep -v false | cut -d'|' -f2 | tr -d ' '
  )
  if [[ "$ERRANDS_TO_DISABLE" == "all" ]]; then
    errands_to_disable="${enabled_errands[@]}"
  else
    errands_to_disable=$(echo "$ERRANDS_TO_DISABLE" | tr ',' '\n')
  fi
  
  will_disable=$(for i in $enabled_errands; do
      for j in $errands_to_disable; do
        if [ $i == $j ]; then
          echo $j
        fi
      done
    done
  )

  if [ -z "$will_disable" ]; then
    echo "All errands are already disable that were requested"
  else
    while read errand; do
      echo -n Disabling $errand...
      $CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k set-errand-state --product-name $PRODUCT_NAME --errand-name $errand --post-deploy-state "disabled"
      echo done
    done < <(echo "$will_disable")
  fi
fi

if [[ -z "$PREDELETE_ERRANDS_TO_DISABLE" ]] || [[ "$PREDELETE_ERRANDS_TO_DISABLE" == "none" ]]; then
  echo "No pre-delete errands to disable"
else
  enabled_errands=$(
  $CMD -t https://${OPS_MGR_HOST} -u $OPS_MGR_USR -p $OPS_MGR_PWD -k errands --product-name $PRODUCT_NAME |
  tail -n+4 | head -n-1 | grep -v false | cut -d'|' -f2 | tr -d ' '
  )
  if [[ "$PREDELETE_ERRANDS_TO_DISABLE" == "all" ]]; then
    errands_to_disable="${enabled_errands[@]}"
  else
    errands_to_disable=$(echo "$PREDELETE_ERRANDS_TO_DISABLE" | tr ',' '\n')
  fi
  
  will_disable=$(for i in $enabled_errands; do
      for j in $errands_to_disable; do
        if [ $i == $j ]; then
          echo $j
        fi
      done
    done
  )

  if [ -z "$will_disable" ]; then
    echo "All errands are already disable that were requested"
  else
    while read errand; do
      echo -n Disabling $errand...
      $CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k set-errand-state --product-name $PRODUCT_NAME --errand-name $errand --pre-delete-state "disabled"
      echo done
    done < <(echo "$will_disable")
  fi
fi
