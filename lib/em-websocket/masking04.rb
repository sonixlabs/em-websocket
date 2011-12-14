module EventMachine
  module WebSocket
    class MaskedString < String
      # Read a 4 bit XOR mask - further requested bytes will be unmasked
      def read_mask
        if respond_to?(:encoding) && encoding.name != "ASCII-8BIT"
          raise "MaskedString only operates on BINARY strings"
        end
        raise "Too short" if bytesize < 4 # TODO - change
        @masking_key = String.new(self[0..3])
      end

      def self.create_mask
        MaskedString.new "rAnD" #TODO make random 4 character string
      end

      def self.create_masked_string(original)
        masked_string = MaskedString.new
        masking_key = self.create_mask
        masked_string << masking_key
        original.size.times do |i|
          char = original.getbyte(i)
          masked_string << (char ^ masking_key.getbyte(i%4))
        end
        if masked_string.respond_to?(:force_encoding)
          masked_string.force_encoding("ASCII-8BIT")
        end
        masked_string.read_mask # get input string
        return masked_string
      end

      # Removes the mask, behaves like a normal string again
      def unset_mask
        @masking_key = nil
      end

      def slice_mask
        slice!(0, 4)
      end

      def getbyte(index)
        if @masking_key
          masked_char = super
          masked_char ? masked_char ^ @masking_key.getbyte(index % 4) : nil
        else
          super
        end
      end

      def getbytes(start_index, count)
        data = ''
        if @masking_key
          count.times do |i|
            data << getbyte(start_index + i)
          end
        else
          data = String.new(self[start_index..start_index+count])
        end
        data
      end
    end
  end
end
