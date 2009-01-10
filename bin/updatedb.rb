#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'explorer'

# if table doesn't exist, create table;
Explorer.createtable

# select alldata from table
allpath = $con.execute("select path from filelist").flatten
alldate = $con.execute("select date from filelist").flatten

# update or insert
Explorer.allfile.each do |path|
  date = File.mtime(path).strftime('%Y-%m-%d %H:%M:%S')
  if i = allpath.index(path)
    print date + " " + path + "\n"
    if alldate[i] != date
      $con.execute("update filelist set date='#{date}' where path='#{path}'")
    end
  else
    $con.execute("insert into filelist(path, date) values('#{path}', '#{date}')")
  end
end
