#!/bin/bash

set -e


# end of subs definitions

# if we are a crispranalyzer
if [ "$1" = 'crisprvariantslite' ]; then
  if [ "$websockets_behind_proxy" ]; then
     echo "[CUSTOM] setting enhanced websocket settings"
     # make changes to the app config, this is needed for some problematic
     # cooperate proxy servers
     sed -i.bak.proxy 's#location / {#location / {\napp_init_timeout 18000;\napp_idle_timeout 18000;\ndisable_protocols  xhr-streaming xhr-polling xdr-polling iframe-xhr-polling jsonp-polling;\n#g' /etc/shiny-server/shiny-server.conf 
  fi  
  if [ "$verbose_logfiles" ]; then
     echo "[CUSTOM] setting verbose shiny server and application logfiles"
     # this is a very useful setting for debugging your shiny application..this keeps all logfiles in /var/log/shiny-server. 
     # otherwise log files get deleted if the app crashes[CUSTOM] which is usually not what we want when debugging
     # but dont use this option on production server[CUSTOM] this will fill up space easily
     sed -i.bak.verbose 's#run_as shiny;#run_as shiny;\npreserve_logs true; #g' /etc/shiny-server/shiny-server.conf
     # enable full debugging output for the shiny server
     sed -i.bak.verbose 's#exec shiny-server\(.*\)#export SHINY_LOG_LEVEL=TRACE\nexec shiny-server \1#g' /usr/bin/shiny-server.sh
	 
  fi 
  
  exec /usr/bin/shiny-server.sh
fi
