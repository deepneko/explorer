#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'explorer'
require 'optparse'
require 'digest/md5'

def encode(src, dist, size="640x480", sampling=22050, bitrate="800k")
  "ffmpeg -i \"#{src}\" -vcodec flv -s #{size} -ar #{sampling} -b #{bitrate} -y #{dist}"
end

getopt = Hash.new
begin
  OptionParser.new do |opt|
    opt.on('-a') {|v| getopt[:a] = v }
    opt.on('-d VALUE') {|v| getopt[:d] = v }
    opt.on('-f VALUE') {|v| getopt[:f] = v }
    opt.parse!(ARGV)
  end
rescue
  p "usage: ./encode.rb [-a | -d directory | -f file]"
  exit! 0
end

# movie only
movie_option = " and (path like '%.avi' or path like '%.wmv')"

# select alldata from table
if getopt[:a]
  encodelist = $con.execute("select path, flv from filelist where flv=''" + movie_option).flatten
elsif getopt[:d]
  encodelist = $con.execute("select path, flv from filelist where path like '#{getopt[:d]}%'" + movie_option).flatten
elsif getopt[:f]
  encodelist = $con.execute("select path, flv from filelist where path like '%#{getopt[:f]}'" + movie_option).flatten
end

# 1. scp avi,wmv,mpg local2remote
# 2. ffmpeg encode at remote host
# 3. scp flv remote2local
encodelist.each do |path, flv|
  src = File.basename(path)
  dist = Digest::MD5.new.update(src).to_s + ".flv"

  if flv != dist
    # command
    scp_up = "scp -P #{$const.SSH_PORT} \"#{path}\" #{$const.ENCODE_SERVER}:~/"
    encode = "ssh -p #{$const.SSH_PORT} #{$const.ENCODE_SERVER} '" + encode(src, dist) + "'"
    scp_down = "scp -P #{$const.SSH_PORT} #{$const.ENCODE_SERVER}:~/#{dist} #{$const.FLV_DIRECTORY}"
    rm = "ssh -p #{$const.SSH_PORT} #{$const.ENCODE_SERVER} 'rm -f \"#{src}\";rm -f #{dist}'"

    # exec command
    `#{scp_up}`
    `#{encode}`
    `#{scp_down}`
    `#{rm}`

    begin
      $con.execute("update filelist set flv='#{dist}' where path=\"#{path}\"")
    rescue SQLite3::SQLException
      p "Exception:" + dist + ":" + path + "\n"
    end
  end
end

