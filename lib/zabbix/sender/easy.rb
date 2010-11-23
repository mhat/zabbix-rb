class Zabbix::Sender::Easy
  def self.run (task, opts={}, &block)
    zbx = Zabbix::Sender::Easy.new(opts)
    zbx.send_start 
    block.call(zbx)
    zbx.send_stop 
  end
end
