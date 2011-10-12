class Zabbix::Sender::Buffer < Zabbix::Sender
  def initialize(opts={})
    @buffer = [] 
    super(opts)
  end

  def append(key, value, opts={})
    return false unless configured?
    @buffer << cons_zabbix_data_element(key, value, opts)
  end  

  def flush 
    return false unless @buffer.size > 0
    ret = send_zabbix_request(@buffer)
    @buffer.clear
    return ret
  end
  alias send! flush

end
