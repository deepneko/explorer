module Encoder
  class EncoderConst
    attr_accessor :FLV_DIRECTORY
    attr_accessor :ENCODE_SERVER
    attr_accessor :ENCODE_PORT
    
    def initialize
      @FLV_DIRECTORY = "/usr/home/BACKUP/kotachu/flv/"
      @ENCODE_SERVER = "tomoyo@deepneko.dyndns.org"
      @ENCODE_PORT = 20022
    end
  end
end
