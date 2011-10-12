class Zabbix::Sender

  DEFAULT_SERVER_PORT = 10051

  attr_reader :configured

  def initialize(opts={})
    @client_host = Socket.gethostbyname(Socket.gethostname)[0]

    if opts[:config_file]
      config = Zabbix::Agent::Configuration.read(opts[:config_file])
      @server_host  = config.server
      @server_port  = config.server_port || DEFAULT_SERVER_PORT
    end

    if opts[:host]
      @server_host = opts[:host]
      @server_port = opts[:port] || DEFAULT_SERVER_PORT
    end

  end


  def configured?
    @configured ||= !(@server_host.nil? and @server_port.nil?)
  end


  def connect
    @socket ||= TCPSocket.new(@server_host, @server_port)
  end

  def disconnect
    if @socket
      @socket.close unless @socket.closed?
      @socket = nil
    end
    return true
  end

  def send_start(key, opts={})
    send_data("#{key}.start", 1, opts)
  end


  def send_stop(key, opts={})
    send_data("#{key}.stop", 1, opts)
  end

  def send_break(key, err, opts={})
    send_data("#{key}.break", err, opts)
  end

  def send_heartbeat(key, msg="", opts={})
    send_data("#{key}.heartbeat", msg, opts)
  end

  def send_data(key, value, opts={})
    return false unless configured?
    return send_zabbix_request([
      cons_zabbix_data_element(key, value, opts)
    ])
  end

  private

  def cons_zabbix_data_element(key, value, opts={})
    return {
      :key   => key,
      :value => value,
      :host  => opts[:host] || @client_host,
      :clock => opts[:ts  ] || Time.now.to_i,
    }
  end

  def send_zabbix_request(data)
    status  = false
    request = Yajl::Encoder.encode({
      :request => 'agent data' ,
      :clock   => Time.now.to_i,
      :data    => data
    })

    begin
      sock = connect
      sock.write "ZBXD\x01"
      sock.write [request.size].pack('q')
      sock.write request
      sock.flush

      # FIXME: check header to make sure it's the message we expect?
      header   = sock.read(5)
      len      = sock.read(8)
      len      = len.unpack('q').shift
      response = Yajl::Parser.parse(sock.read(len))
      status   = true if response['response'] == 'success'
    rescue => e
      ## FIXME
    ensure
      disconnect
    end

    return status
  end
end
