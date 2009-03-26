module Encoder
  class EncoderConst
    attr_accessor :ENCODE_SERVER
    attr_accessor :FLV_DIRECTORY
    
    def initialize
      @FLV_DIRECTORY = "/usr/local/www/apache22/data/flv/"
      @ENCODE_SERVER = "tomoyo@deepneko.dyndns.org"
      @ENCODE_PORT = 20022
    end
  end
end
