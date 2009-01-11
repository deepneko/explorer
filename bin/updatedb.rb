#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'explorer'

# if table doesn't exist, create table;
Explorer.createtable

# select alldata from table
allpath = $con.execute("select path from filelist").flatten
alldate = $con.execute("select date from filelist").flatten

# if file doesn't exist, delete from database
allpath.each do |path|
  if !File.exists?(path)
    print "delete:" + path + "\n"
    $con.execute("delete from filelist where path='#{path}'")
  end
end

# update or insert
Explorer.allfile.each do |path|
  date = File.mtime(path).strftime('%Y-%m-%d %H:%M:%S')
  print date + " " + path + "\n"
  if i = allpath.index(path)
    if alldate[i] != date
      print "update:" + date + " " + path + "\n"
      $con.execute("update filelist set date='#{date}' where path='#{path}'")
    end
  else
    print "insert:" + date + " " + path + "\n"
    $con.execute("insert into filelist(path, date) values('#{path}', '#{date}')")
  end
end
