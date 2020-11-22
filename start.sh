#!/bin/bash

CONFIG_NAME_PREFIX=global_conf.json.sx1250
LORA_REGION=${APP_ENV_LORA_REGION}

case "$LORA_REGION" in

"EU868" )
chip_id_shift=0
;;

"US915" )
chip_id_shift=1
;;

* )
LORA_REGION=EU868
chip_id_shift=0
;;

esac

chip_id=$(./chip_id | grep "EUI:" | cut -d' ' -f4)
echo "SX1302 chip ID is : ${chip_id}"

gw_id_decimal=$((chip_id + 0x0000001000000000 * chip_id_shift))
gw_id=$(printf "%x\n" ${gw_id_decimal})
echo "Gateway ID is : 0x${gw_id}"

sed -i "s_AA555A0000000000_${gw_id}_g" ${CONFIG_NAME_PREFIX}.${LORA_REGION}

./lora_pkt_fwd -c ${CONFIG_NAME_PREFIX}.${LORA_REGION}

#balena-idle --interval 60 --message "Container idle for debug..."
