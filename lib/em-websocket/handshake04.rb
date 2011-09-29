require 'digest/sha1'
require 'base64'

module EventMachine
  module WebSocket
    module Handshake04
      def handshake_server
        # Required
        unless key = request['sec-websocket-key']
          raise HandshakeError, "Sec-WebSocket-Key header is required"
        end
        
        # Optional
        origin = request['sec-websocket-origin']
        protocols = request['sec-websocket-protocol']
        extensions = request['sec-websocket-extensions']
        
        string_to_sign = "#{key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
        signature = Base64.encode64(Digest::SHA1.digest(string_to_sign)).chomp
        
        upgrade = ["HTTP/1.1 101 Switching Protocols"]
        upgrade << "Upgrade: websocket"
        upgrade << "Connection: Upgrade"
        upgrade << "Sec-WebSocket-Accept: #{signature}"
        
        # TODO: Support Sec-WebSocket-Protocol
        # TODO: Sec-WebSocket-Extensions
        
        debug [:upgrade_headers, upgrade]
        
        return upgrade.join("\r\n") + "\r\n\r\n"
      end

      def handshake_client
        request = ["GET /websocket HTTP/1.1"]
        request << "Host: #{@request[:host]}:#{@request[:port]}" # TODO: replace with connection ws loc
        request << "Connection: keep-alive, Upgrade"
        request << "Sec-WebSocket-Version: 8" # TODO: supply version somehow
        request << "Sec-WebSocket-Origin: null"
        request << "Sec-WebSocket-Key: j3aqDbLsk5fH5dqRrTJU8g==" # TODO: figure out from spec what key should be
        request << "Upgrade: websocket"
        # TODO: anything else needed?  nothing else parsed anyway
        return request.join("\r\n") + "\r\n\r\n"
      end

      def client_handle_server_handshake_response(data)
        @state = :connected #TODO - some actual logic would be nice
        @connection.trigger_on_open
      end
    end
  end
end
