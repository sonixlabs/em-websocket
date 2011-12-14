require 'digest/sha1'
require 'base64'

module EventMachine
  module WebSocket
    module Handshake04

      def handshake_key_response(key)
        string_to_sign = "#{key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
        Base64.encode64(Digest::SHA1.digest(string_to_sign)).chomp
      end

      def handshake_server
        # Required
        unless key = request['sec-websocket-key']
          raise HandshakeError, "Sec-WebSocket-Key header is required"
        end
        
        # Optional
        origin = request['sec-websocket-origin']
        protocols = request['sec-websocket-protocol']
        extensions = request['sec-websocket-extensions']
        
        upgrade = ["HTTP/1.1 101 Switching Protocols"]
        upgrade << "Upgrade: websocket"
        upgrade << "Connection: Upgrade"
        upgrade << "Sec-WebSocket-Accept: #{handshake_key_response(key)}"
        
        # TODO: Support Sec-WebSocket-Protocol
        # TODO: Sec-WebSocket-Extensions
        
        [:upgrade_headers, upgrade]
        
        return upgrade.join("\r\n") + "\r\n\r\n"
      end

      def handshake_client
        request = ["GET /websocket HTTP/1.1"]
        request << "Host: #{@request[:host]}:#{@request[:port]}"
        request << "Connection: keep-alive, Upgrade"
        request << "Sec-WebSocket-Version: 8" # TODO: supply version somehow
        request << "Sec-WebSocket-Origin: null"
        random16 = (0...16).map{rand(255).chr}.join
        random16_base64 = Base64.encode64(random16).chomp
        @correct_response = handshake_key_response random16_base64
        request << "Sec-WebSocket-Key: #{random16_base64}"
        request << "Upgrade: websocket"
        # TODO: anything else needed?  nothing else parsed anyway
        return request.join("\r\n") + "\r\n\r\n"
      end

      def client_handle_server_handshake_response(data)
        header, msg = data.split "\r\n\r\n"
        lines = header.split("\r\n")
        accept = false
        lines.each do |line|
          h = /^([^:]+):\s*(.+)$/.match(line)
          if !h.nil? and h[1].strip.downcase == "sec-websocket-accept"
            accept = (h[2] == @correct_response)
            break
          end
        end
        if accept
          @state = :connected #TODO - some actual logic would be nice
          @connection.trigger_on_open
          if msg # handle message bundled in with handshake response
            receive_data(msg)
          end
        else
          close_websocket(1002,nil)
        end
      end
    end
  end
end
