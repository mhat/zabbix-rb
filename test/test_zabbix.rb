require 'helper'

class TestZabbix < Test::Unit::TestCase

  should "not be configured" do 
    zbx = Zabbix::Sender.new 
    assert_equal false, zbx.configured?
  end

  should "be configured by args" do
    zbx = Zabbix::Sender.new :host => 'localhost'
    assert_equal true, zbx.configured?
  end
 
  should "be configured by zabbix_agentd.conf" do
    config_file = "#{File.dirname(__FILE__)}/zabbix_agentd.conf"
    zbx = Zabbix::Sender.new :config_file => config_file
    assert_equal true, zbx.configured?
  end 

  should "send some data" do
    config_file = "#{File.dirname(__FILE__)}/zabbix_agentd.conf"
    zbx  = Zabbix::Sender.new :config_file => config_file
    key  = :"foo.bar.baz"
    host = "testhost.example.com"
    assert_equal true, zbx.send_start(key, :host => host)
    assert_equal true, zbx.send_heartbeat(key, "8==D", :host => host)
    assert_equal true, zbx.send_stop(key, :host => host)
  end

  
end
