module Zabbix
end

require "zabbix/agent/configuration"
require "zabbix/sender"
require "zabbix/sender/easy"

## we could use zabbix-sender, but that appears to be unecessary; we can instead 
## simply talk to the zabbit-server. we get there via the parent. 
## 
## thinking about what we want to be able to do there are a few types of messages
## we want to send to zabbix:
##   1. that a process has starting 
##   2. that a process is running 
##   3. that a process has finished 
## 
## there will be more in the future, but this is the minimum; it would be nice 
## to expose two interfaces: 

## Zabbix::Sender.run(:task_name, opts={}) do |zbx|
##   ... 
##   zbx.heartbeat
## end

## zbx = Zabbit::Zender::Easy.new(opts={})
## zbx.send_start
## zbx.send_heartbeat
## zbx.send_end

## That's pretty much it. 

