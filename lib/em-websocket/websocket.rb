module EventMachine
  module WebSocket
    class WebSocketError < RuntimeError; end
    class HandshakeError < WebSocketError; end
    class DataError < WebSocketError; end

    #backwards compatibility
    def self.start(options, &blk)
      self.start_ws_server(options, &blk)
    end

    def self.start_ws_server(options, &blk)
      EM.epoll
      EM.run do

        trap("TERM") { stop; raise "TERM" }
        trap("INT")  { stop; raise "INT" }

        EventMachine::start_server(options[:host], options[:port],
          EventMachine::WebSocket::Connection, options) do |c|
          blk.call(c)
        end
      end
    end

    def self.start_ws_client(options, &blk)
      EM.epoll
      EM.run do

        trap("TERM") { stop; raise "TERM" }
        trap("INT")  { stop; raise "INT" }

        EM.connect(options[:host], options[:port],
          EventMachine::WebSocket::ClientConnection, options) do |c|
          blk.call(c)
        end
      end
    end

    def self.stop
      puts "Terminating WebSocket Server"
      EventMachine.stop
    end
  end
end
