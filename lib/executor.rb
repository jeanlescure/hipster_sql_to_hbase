module HipsterSqlToHbase
  class Executor
    @@host=nil
    @@port=nil
    def host=(host_s)
      self.class.host=host_s
    end
    def host
      self.class.host
    end
    def self.host=(host_s)
      @@host=host_s
    end
    def self.host
      @@host
    end
    def port=(port_n)
      self.class.port=port_n
    end
    def port
      self.class.port
    end
    def self.port=(port_n)
      @@port=port_n
    end
    def self.port
      @@port
    end
    def execute(thrift_calls,host_s=nil,port_n=nil)
      @@host = host_s if !host_s.nil?
      @@port = port_n if !port_n.nil?
      socket = Thrift::Socket.new(@@host, @@port)

      transport = Thrift::BufferedTransport.new(socket)
      transport.open

      protocol = Thrift::BinaryProtocol.new(transport)
      client = HBase::Client.new(protocol)
      
      results = []
      
      thrift_calls.each do |thrift_call|
        results << client.send(thrift_call[:method],*thrift_call[:arguments])
      end
      
      results
    end
  end
end