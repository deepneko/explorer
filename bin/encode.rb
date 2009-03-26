#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'encode'
require 'explorer'
require 'optparse'
require 'digest/md5'

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
  encodelist = $con.execute("select path, flv from filelist where flv=''" + movie_option)
elsif getopt[:d]
  encodelist = $con.execute("select path, flv from filelist where path like '#{getopt[:d]}%'" + movie_option)
elsif getopt[:f]
  encodelist = $con.execute("select path, flv from filelist where path like '%#{getopt[:f]}'" + movie_option)
end

$enconst.ENCODE_SERVER.each do |host, port|
  t = Thread.new do 
    encodelist.each do |path, flv|
      src = File.basename(path)
      dist = Digest::MD5.new.update(src).to_s + ".flv"

      p dist
      if flv != dist
        # 1. scp avi,wmv,mpg local2remote
        # 2. ffmpeg encode at remote host
        # 3. scp flv remote2local
        # 4. rm all tmp file
        scp_up = "scp -P #{port} \"#{path}\" #{host}:~/"
        #encode = "ssh -p #{port} #{host} '" + Encoder::ffmpeg(src, dist) + "'"
        #scp_down = "scp -P #{port} #{host}:~/#{dist} #{$enconst.FLV_DIRECTORY}"
        #rm = "ssh -p #{port} #{host} 'rm -f *.avi;rm -f *.AVI;rm -f *.flv;rm -f *.wmv'"

        # exec command
        `#{scp_up}`
        #`#{encode}`
        #`#{scp_down}`
        #`#{rm}`

        begin
          #$con.execute("update filelist set flv='#{dist}' where path=\"#{path}\"")
        rescue SQLite3::SQLException
          p "Exception:" + dist + ":" + path + "\n"
        end
      end
    end
  end
  t.join
end
