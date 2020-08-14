#!/bin/bash

echo $(./chip_id)
sed -i "s_AA555A0000000000_$(./chip_id | grep "EUI:" | cut -d' ' -f4 | cut -c3-)_g" global_conf.json.sx1250.EU868

./lora_pkt_fwd -c global_conf.json.sx1250.EU868

#balena-idle --interval 60 --message "Container idle for debug..."
