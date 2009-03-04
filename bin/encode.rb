#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'explorer'
require 'optparse'

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
  encodelist = $con.execute("select path from filelist where path like '%#{getopt[:d]}%'" + movie_option).flatten
elsif getopt[:f]
  encodelist = $con.execute("select path from filelist where path like '%#{getopt[:f]}'" + movie_option).flatten
end

p getopt
p encodelist

# remote
#encodelist.each do |path|
#  begin
#    $con.execute("update filelist set date='#{date}' where path=\"#{path}\"")
#  rescue SQLite3::SQLException
#    print "Exception:" + date + " " + path + "\n"
#  end
#end
