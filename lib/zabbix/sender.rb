class Zabbix::Sender
  attr_reader :configured 

  def initialize(opts={})
    @configured = false 

    if opts[:config_file]
      config = Zabbix::Agent::Configuration.read(opts[:zabbit_config_file])
      @host = config.server
      @port = config.server_port
    end

    if opts[:host] and opts[:port]
      @host = opts[:host]
      @port = opts[:port]
    end
  end


  def configured?
    @configured
  end


  def connect
    @socket ||= TCPSocket.new(@host, @port)
  end


  def send_start(key)
    send_data("#{key}.start", 1)
  end


  def send_stop(key) 
    send_data("#{key}.stop", 1)
    send_data(:stop,  1)
  end


  def send_heartbeat(msg="")
    send_data("#{key}.beat", msg)
  end


  def send_data(key, value, ts=Time.now.to_i)
    return false unless configured? 

    # construct json
    json = Yajl::Encoder.encode({ 
      :request => "agent-data",
      :clock   => ts,
      :data    => [{
        :host       => Socket.gethostname,  
        :key        => key,
        :value      => value,
        :clock      => ts
      }]
    })

    # construct header
    @socket.write "ZBXD\x01"
    @socket.write [json.size].pack('q')
    @socket.write json
    @socket.flush

    return true
  end  
end
