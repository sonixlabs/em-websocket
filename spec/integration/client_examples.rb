# encoding: UTF-8

shared_examples_for "a websocket client" do
  it "should accept a single-frame binary message" do
    EM.run do
      start_server { |server|
        server.onmessage { |msg, type|
          msg.should == '\xFF\xFF'
          type.should == :binary
          EM.stop
        }
        server.onerror {
          failed
        }
      }

      options = { :host => '0.0.0.0', :port => 12345, :debug => false }
      client = EM.connect('0.0.0.0', 12345, EventMachine::WebSocket::ClientConnection, options) do |ws|
        ws.onopen do
          ws.send '\xFF\xFF', :binary
        end
      end
    end
  end

  it "should accept a text message in the same frame as the server handshake response" do
    EM.run do
      start_server { |server|
        server.onopen { server.send 'hello' }
        server.onerror { failed }
      }
      
      options = { :host => '0.0.0.0', :port => 12345, :debug => false }
      client = EM.connect( options[:host], options[:port], EventMachine::WebSocket::ClientConnection, options) do |ws|
        ws.onmessage{ |msg, type| 
          msg.should == 'hello'
          type.should == :text
          EM.stop
        }
        
        EventMachine::add_timer 3 do
          failed # ran out of time
        end
      end
    end
  end

end
