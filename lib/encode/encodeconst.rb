module Encoder
  class EncoderConst
    attr_accessor :FLV_DIRECTORY
    attr_accessor :ENCODE_SERVER
    attr_accessor :ENCODE_PORT
    attr_accessor :ENCODE_DIRECTORY
    
    def initialize
      @FLV_DIRECTORY = "/usr/home/BACKUP/kotachu/flv/"
      @ENCODE_SERVER = "tomoyo@deepneko.dyndns.org"
      @ENCODE_PORT = 20022
      @ENCODE_DIRECTORY = "/usr/home/BACKUP/kotachu/Movie/\[\ Anime\ \]/"
    end
  end
end
