# frozen_string_literal: true
module Mail
  module Encodings
    class UnixToUnix < TransferEncoding
      NAME = "x-uuencode"

      def self.decode(str)
        str.sub(/\Abegin \d+ [^\n]*\n/, '').unpack1('u')
      end

      def self.encode(str)
        [str].pack("u")
      end

      Encodings.register(NAME, self)
      Encodings.register("uuencode", self)
      Encodings.register("x-uue", self)
    end
  end
end
