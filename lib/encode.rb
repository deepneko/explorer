require 'encode/encodeconst'

module Encoder
  $enconst = Encoder::EncoderConst.new

  def self.ffmpeg(src, dist, size="640x480", sampling=22050, bitrate="800k")
    "ffmpeg -i \"#{src}\" -vcodec flv -s #{size} -ar #{sampling} -b #{bitrate} -y #{dist}"
  end
end
