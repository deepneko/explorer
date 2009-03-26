#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'encode'
require 'explorer'
require 'optparse'
require 'digest/md5'

# command option
getopt = Hash.new
begin
  OptionParser.new do |opt|
    opt.on('-a') {|v| getopt[:a] = v }
    opt.on('-u') {|v| getopt[:u] = v }
    opt.on('-d VALUE') {|v| getopt[:d] = v }
    opt.on('-f VALUE') {|v| getopt[:f] = v }
    opt.on('-p VALUE') {|v| getopt[:p] = v }
    opt.on('-s VALUE') {|v| getopt[:s] = v }
    opt.parse!(ARGV)
  end
rescue
  p "usage: ./encode.rb [-a | -u | -d directory | -f file | -p port | -s server]"
  exit! 0
end

# movie only
movie_option = " and (path like '%.avi' or path like '%.wmv')"

# if flv file size = 0 then delete flv file from db
# if flv file exists but doesn't exist from database, delete flv file
if getopt[:u]
  encodelist = $con.execute("select path, flv from filelist")
  encodelist.each do |path, flv|
    if flv
      flv = $enconst.FLV_DIRECTORY + flv
      if File.exists?(flv) && File.stat(flv).size <= 1
        $con.execute("update filelist set flv='' where flv='#{flv}'")
        `rm -f #{flv}`
      end
    end
  end

  Dir.glob($enconst.FLV_DIRECTORY + "*.flv").each do |file|
    flv = $con.execute("select path, flv from filelist where flv='#{File.basename(file)}'").flatten
    if flv.size == 0
      `rm -f #{file}`
    elsif File.stat(file).size <= 1
      `rm -f #{file}`
    end
  end
  
  exit! 0
end

# select alldata from table
if getopt[:a]
  encodelist = $con.execute("select path, flv from filelist where flv=''" + movie_option)
elsif getopt[:f]
  encodelist = $con.execute("select path, flv from filelist where path like '%#{getopt[:f]}'" + movie_option)
end

if getopt[:d] == "1"
  encodelist = $con.execute("select path, flv from filelist where path like '#{$enconst.ENCODE_DIRECTORY}%'" + movie_option)
elsif getopt[:d]
  encodelist = $con.execute("select path, flv from filelist where path like '#{getopt[:d]}%'" + movie_option)
end

# host
if getopt[:s]
  host = getopt[:s]
else
  host = $enconst.ENCODE_SERVER
end

# port
if getopt[:p]
  port = getopt[:p]
else
  port = $enconst.ENCODE_PORT
end

# main loop
encodelist.each do |path, flv|
  src = File.basename(path)
  dist = Digest::MD5.new.update(src).to_s + ".flv"
  
  if flv != dist
    lock_file = dist

    if !File.exists?(lock_file)
      # generate lock file
      p lock_file
      `touch #{lock_file}`

      # 1. scp avi,wmv,mpg local2remote
      # 2. ffmpeg encode at remote host
      # 3. scp flv remote2local
      # 4. rm all tmp file
      scp_up = "scp -P #{port} \"#{path}\" #{host}:~/"
      encode = "ssh -p #{port} #{host} '" + Encoder::ffmpeg(src, dist) + "'"
      scp_down = "scp -P #{port} #{host}:~/#{dist} #{$enconst.FLV_DIRECTORY}"
      rm = "ssh -p #{port} #{host} 'rm -f *.avi;rm -f *.AVI;rm -f *.flv;rm -f *.wmv'"
      
      # exec command
      `#{scp_up}`
      `#{encode}`
      `#{scp_down}`
      `#{rm}`

      if File.exists?($enconst.FLV_DIRECTORY + dist)
        if File.stat($enconst.FLV_DIRECTORY + dist).size > 0
          begin
            $con.execute("update filelist set flv='#{dist}' where path=\"#{path}\"")
          rescue SQLite3::SQLException
            p "Exception:" + dist + ":" + path + "\n"
          end
        end
      end

      # delete lock file
      `rm -f #{lock_file}`
    end
  end
end
