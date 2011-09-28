require 'addressable/uri'

module EventMachine
  module WebSocket
    class ClientConnection < EventMachine::WebSocket::Connection

      def initialize(options)
        super
        @handler = Handler08.new( self, options, options[:debug] )
        @handler.run_client
      end

      def dispatch(data)
        # server's handshake response
        @handler.client_handle_server_handshake_response(data)
      end
    end
  end
end
