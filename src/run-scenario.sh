#!/bin/bash

# Activate needed ONOS Apps
onos-app -uonos -procks 127.0.0.1 activate org.onosproject.odtn-service
onos-app -uonos -procks 127.0.0.1 activate org.onosproject.roadm
onos-app -uonos -procks 127.0.0.1 activate org.onosproject.gui2
onos-app -uonos -procks 127.0.0.1 activate org.onosproject.optical-rest

# Load devices and create links
onos-netcfg localhost /home/vagrant/src/topo/with-rest-tapi/device.json
onos-netcfg localhost /home/vagrant/src/topo/with-rest-tapi/link.json

# 1. Create line-side connectivity
execute-tapi-post-call.py 127.0.0.1 tapi-connectivity:create-connectivity-service line-side
# 2. Delete all line-side connectivities
execute-tapi-delete-call 127.0.0.1 line
# 3. Create client-side connectivity
execute-tapi-post-call.py 127.0.0.1 tapi-connectivity:create-connectivity-servic client-side
# 4. Delete all connectivities
execute-tapi-delete-call 127.0.0.1 both

available-wavelength netconf:127.0.0.1:11002/201
wavelength-config edit-config netconf:127.0.0.1:11002/201 4/50/1/dwdm

modulation-config get netconf:127.0.0.1:11002/201
modulation-config edit-config netconf:127.0.0.1:11002/201 dp_qpsk
