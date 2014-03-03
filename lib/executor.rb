module HipsterSqlToHbase

  # This class takes the magic provided by the ThriftCallGroup and
  # turns it into an HBase reality by opening a connection to a 
  # specified host and port and executing the pertinent Thrift calls.
  class Executor
    @@host=nil
    @@port=nil
    
    # Set class variable <b>host</b> when instantiated.
    def host=(host_s)
      self.class.host=host_s
    end
    
    # Get class variable <b>host</b> when instantiated.
    def host
      self.class.host
    end
    
    # Set class variable <b>host</b> when NOT instantiated.
    def self.host=(host_s)
      @@host=host_s
    end
    
    # Get class variable <b>host</b> when NOT instantiated.
    def self.host
      @@host
    end
    
    # Set class variable <b>port</b> when instantiated.
    def port=(port_n)
      self.class.port=port_n
    end
    
    # Get class variable <b>port</b> when instantiated.
    def port
      self.class.port
    end
    
    # Set class variable <b>port</b> when NOT instantiated.
    def self.port=(port_n)
      @@port=port_n
    end
    
    # Get class variable <b>port</b> when NOT instantiated.
    def self.port
      @@port
    end
    
    # Initialize a Thrift connection to the specified host and port
    # and execute the provided ThriftCallGroup object.
    def execute(thrift_call_group,host_s=nil,port_n=nil)
      @@host = host_s if !host_s.nil?
      @@port = port_n if !port_n.nil?
      socket = Thrift::Socket.new(@@host, @@port)

      transport = Thrift::BufferedTransport.new(socket)
      transport.open

      protocol = Thrift::BinaryProtocol.new(transport)
      client = HBase::Client.new(protocol)
      
      results = []
      
      thrift_call_group.each do |thrift_call|
        results << client.send(thrift_call[:method],*thrift_call[:arguments])
      end
      
      results
    end
  end
end