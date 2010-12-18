class Zabbix::Sender::Buffer < Zabbix::Sender
  def initialize(opts={})
    @buffer = [] 
    super(opts)
  end

  def append(key, value, opts={})
    return false unless configured?
    @buffer << {
      :host  => opts[:host] || Socket.gethostname,
      :clock => opts[:ts  ] || Time.now.to_i,
      :key   => key, 
      :value => value, 
    }
  end  

  def flush 
    return false unless @buffer.size > 0
    ret = send_zabbix_request(@buffer)
    @buffer.clear
    return ret
  end

end
