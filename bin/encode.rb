#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'explorer'
require 'optparse'
require 'digest/md5'

def encode(src, dist, size="640x480", sampling=22050, bitrate="800k")
  "ffmpeg -i #{src} -vcodec flv -s #{size} -ar #{sampling} -b #{bitrate} #{dist}"
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
movie_option = " and (path like '%.avi' or path like '%.wmv' or path like '%.mpg')"

# select alldata from table
if getopt[:a]
  encodelist = $con.execute("select path from filelist where flv=''" + movie_option).flatten
elsif getopt[:d]
  encodelist = $con.execute("select path from filelist where path like '#{getopt[:d]}%'" + movie_option).flatten
elsif getopt[:f]
  encodelist = $con.execute("select path from filelist where path like '%#{getopt[:f]}'" + movie_option).flatten
end

# debug
#p getopt
#p encodelist

# scp avi,wmv,mpg local2remote
# ffmpeg encode at remote host
# scp flv remote2local
encodelist.each do |path|
  src = File.basename(path)
  dist = src + ".flv"
  #scp_up = "scp -P #{$const.SSH_PORT} \"#{path}\" #{$const.ENCODE_SERVER}"
  encode = "ssh -p #{$const.SSH_PORT} #{$const.ENCODE_SERVER} " + encode(src, dist)
  scp_down = "scp -P #{$const.SSH_PORT} #{$const.ENCODE_SERVER}:~/#{dist} ~/"
  #`#{scp_up}`
  `#{encode}`
  `#{scp_down}`
  exit

  #begin
  #  $con.execute("update filelist set flv='#{}' where path=\"#{path}\"")
  #rescue SQLite3::SQLException
  #  print "Exception:" + date + " " + path + "\n"
  #end
end
