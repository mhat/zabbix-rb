require 'socket'
require 'yajl'

class Zabbix::Sender

  DEFAULT_SERVER_PORT = 10051

  attr_reader :configured 

  def initialize(opts={})
    if opts[:config_file]
      config = Zabbix::Agent::Configuration.read(opts[:config_file])
      @host  = config.server
      @port  = config.server_port || DEFAULT_SERVER_PORT
    end

    if opts[:host]
      @host = opts[:host]
      @port = opts[:port] || DEFAULT_SERVER_PORT
    end

  end


  def configured?
    @configured ||= !(@host.nil? and @port.nil?)
  end


  def connect
    TCPSocket.new(@host, @port)
  end


  def send_start(key, opts={})
    send_data("#{key}.start", 1, opts)
  end


  def send_stop(key, opts={}) 
    send_data("#{key}.stop", 1, opts)
  end


  def send_heartbeat(key, msg="", opts={})
    send_data("#{key}.heartbeat", msg, opts)
  end

  def send_data(key, value, opts={})
    return false unless configured? 
    host   = opts[:host] || Socket.gethostname
    ts     = opts[:ts]   || Time.now.to_i 
    socket = connect 

    # construct json
    json = Yajl::Encoder.encode({ 
      :request => "agent data",
      :clock   => ts,
      :data    => [{
        :host       => host,
        :key        => key,
        :value      => value,
        :clock      => ts
      }]
    })

    # send the data
    socket.write "ZBXD\x01"
    socket.write [json.size].pack('q')
    socket.write json
    socket.flush

    # read the response message if desired
    #header = socket.read(5)
    #len    = socket.read(8)
    #len    = len.unpack('q').shift
    #msg    = socket.read(len)
    socket.close 

    return true
  end  
end
