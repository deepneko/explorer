#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'explorer'

cgi = CGI.new('html4')
keyword = cgi.params['keyword'][0]
dir = cgi.params['dir'][0]
count = cgi.params['count'][0]

cgi.out(
        "type"	=> "text/html" ,
        "charset"	=> "Shift-JIS"
        ) do
  cgi.html do
    cgi.head{ cgi.title{'File Search'} } +
      cgi.body do
      if count
        if keyword
          Explorer.search(keyword, count)
        elsif dir
          Explorer.explorer(dir, count)
        else
          Explorer.show(count)
        end
      else
        if keyword
          Explorer.search(keyword)
        elsif dir
          Explorer.explorer(dir)
        else
          Explorer.show
        end
      end
    end
  end
end
