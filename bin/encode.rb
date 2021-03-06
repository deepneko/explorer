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
    opt.parse!(ARGV)
  end
rescue
  p "usage: ./encode.rb [-a | -u | -d directory | -f file ]"
  exit! 0
end

# movie only
movie_option = " and (path like '%.avi' or path like '%.wmv')"

# if flv file size = 0 then delete flv file from db
# if flv file exists but doesn't exist from database, delete flv file
if getopt[:u]
  encodelist = $con.execute("select path, flv from filelist")
  encodelist.each do |path, flv|
    if flv && flv != ""
      flv = $enconst.FLV_DIRECTORY + flv
      if File.exists?(flv) && File.stat(flv).size <= 1000000
        $con.execute("update filelist set flv='' where flv='#{flv}'")
        `rm -f #{flv}`
      end
    end
  end

  Dir.glob($enconst.FLV_DIRECTORY + "*.flv").each do |file|
    flv = $con.execute("select path, flv from filelist where flv='#{File.basename(file)}'").flatten
    if flv.size == 0
      `rm -f #{file}`
    elsif File.stat(file).size <= 1000000
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
elsif getopt[:d] == "default"
  encodelist = $con.execute("select path, flv from filelist where path like '#{$enconst.ENCODE_DIRECTORY}%'" + movie_option)
elsif getopt[:d]
  encodelist = $con.execute("select path, flv from filelist where path like '#{getopt[:d]}%'" + movie_option)
end

# main loop
encodelist.each do |path, flv|
  src = File.basename(path)
  flv_name = Digest::MD5.new.update(src).to_s + ".flv"
  dist = $enconst.FLV_DIRECTORY + flv_name
  
  if flv != flv_name
    lock_file = flv_name

    if !File.exists?(lock_file)
      # generate lock file
      p lock_file
      `touch #{lock_file}`

      # ffmpeg encode
      encode = Encoder::ffmpeg(path, dist)
      
      # exec command
      `#{encode}`

      if File.exists?(dist)
        p "filesize:" + File.stat(dist).size.to_s
        if File.stat(dist).size > 1000000
          begin
            $con.execute("update filelist set flv='#{flv_name}' where path=\"#{path}\"")
          rescue SQLite3::SQLException
            p "Exception:" + dist + ":" + path + "\n"
          end
        else
          `rm -f #{dist}`
        end
      end

      # delete lock file
      `rm -f #{lock_file}`
    end
  end
end
