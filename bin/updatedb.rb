#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'explorer'
require 'optparse'

# command option
getopt = Hash.new
begin
  OptionParser.new do |opt|
    opt.on('-e VALUE') {|v| getopt[:e] = v }
    opt.parse!(ARGV)
  end
rescue
  p "usage: ./encode.rb [-e directory]"
  exit! 0
end

# this directory's file is not update
exdir = getopt[:e]

# if table doesn't exist, create table;
Explorer.createtable

# select alldata from table
allpath = $con.execute("select path from filelist").flatten
alldate = $con.execute("select date from filelist").flatten

# if file doesn't exist, delete from database
allpath.each do |path|
  if !File.exists?(path)
    print "delete:" + path + "\n"
    begin
      $con.execute("delete from filelist where path=\"#{path}\"")
    rescue SQLite3::SQLException
      print "Exception:" + date + " " + path + "\n"
    end
  end
end

# update or insert
Explorer.allfile.each do |path|
  if path.index(exdir) == 0
    next
  end

  date = File.mtime(path).strftime('%Y-%m-%d %H:%M:%S')
  #print date + " " + path + "\n"
  if i = allpath.index(path)
    if alldate[i] != date
      print "update:" + date + " " + path + "\n"
      begin
        $con.execute("update filelist set date='#{date}' where path=\"#{path}\"")
      rescue SQLite3::SQLException
        print "Exception:" + date + " " + path + "\n"
      end
    end
  else
    print "insert:" + date + " " + path + "\n"
    begin
      $con.execute("insert into filelist(path, date) values (\"#{path}\", '#{date}')")
    rescue SQLite3::SQLException
      print "Exception:" + date + " " + path + "\n"
    end
  end
end
