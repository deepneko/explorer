module Encoder
  class EncoderConst
    attr_accessor :ENCODE_SERVER
    attr_accessor :FLV_DIRECTORY
    
    def initialize
      @FLV_DIRECTORY = "/usr/local/www/apache22/data/flv/"
      @ENCODE_SERVER = [["tomoyo@deepneko.dyndns.org", 20022],
                        ["tomoyo@deepneko.dyndns.org", 20023],
                        ["tomoyo@deepneko.dyndns.org", 20024],
                        ["tomoyo@deepneko.dyndns.org", 20025]]
    end
  end
end
