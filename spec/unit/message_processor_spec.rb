require 'helper'

describe EM::WebSocket::MessageProcessor06 do
  class MessageProcessorContainer06
    attr_accessor :connection
    include EM::WebSocket::MessageProcessor06
    def debug(*args); end    
  end
  
  before :each do
    @mp = MessageProcessorContainer06.new
    @mp.connection = Object.new
  end
  
  describe "#message" do
    it "accepts a close"
    it "accepts a ping"
    
    it "accepts a pong" do
      @mp.connection.should_receive(:trigger_on_message).with(:rock, :pong)
      @mp.message :pong, :fraggle, :rock
    end

    it "accepts a binary message" do
      @mp.connection.should_receive(:trigger_on_message).with(:rock, :binary)
      @mp.message :binary, :fraggle, :rock
    end
    
    it "accepts a non-UTF8 text message"
    
    it "accepts a text message" do
      @mp.connection.should_receive(:trigger_on_message).with(:rock, :text)
      @mp.message :text, :fraggle, :rock
    end    
  end
end
