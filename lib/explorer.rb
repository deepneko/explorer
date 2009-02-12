require 'cgi'
require 'thread'
require 'rubygems'
require 'sqlite3'
require 'explorer/searchthread'
require 'explorer/searchconst'
require 'explorer/folder'
require 'explorer/folderlist'

module Explorer
  $const = Explorer::SearchConst.new
  $rootFolder = Explorer::Folderlist.new
  $rootFolder.open($const.SEARCH_DIR)
  $con = SQLite3::Database.new($const.DB)

  $head = <<"HEAD"
<html><head>
<title>File Search</title>
<style>
BODY, TD, TR{font-size:12px}
A{text-decoration:none}
</style>
</head>
<body bgcolor=#ffffff link=#00004c vlink=#00004c alink=#eeeeee>
HEAD

  $form = <<"FORM"
<b>File Search</b>
<br><br>
<form action="./explorer.cgi" method="get">
Keyword: <input type="text" name="keyword"><br>
<input type="submit" value="Search">
</form>
<hr>
FORM

  def self.listnew(n=$const.LISTNEW_SIZE)
    cur = $con.execute("select path, date from filelist order by date desc limit #{n}")
    result = "<br>"
    cur.each do |elem|
      file = File.basename(elem[0])
      dir = File.dirname(elem[0]) + "/"
      result += " [#{elem[1]}]<b> <a href=\"" + $const.CGI_PATH + "?dir=" + elem[0]
      result += "\">" + file + "</a></b><br>"
    end
    "<b>Recent Update</b>" + result + "<hr>"
  end

  def self.search(keyword, count=nil)
    $const.LISTNEW_SIZE = count if count
    st = SearchThread.new($const.SEARCH_DIR, keyword, nil)
    st.start
    searchResult = st.getSearchResult
    
    result = ""
    for i in searchResult
      result += "<b> <a href=\"" + $const.CGI_PATH + "?dir=" + i
      result += "&count=" + count if count
      result += "\">" + i + "</a></b><br>"
    end
    $head + $form + result
  end

  def self.explorer(path, count=nil)
    $const.LISTNEW_SIZE = count if count
    $rootFolder.open(path)
    show
  end
  
  def self.show(count=nil)
    $const.LISTNEW_SIZE = count if count
    if count
      $head + $form + listnew(count) + $rootFolder.show
    else
      $head + $form + listnew + $rootFolder.show
    end
  end

  def self.allfile
    $rootFolder.allfile
  end

  def self.createtable
    begin
      $con.execute('create table filelist(path, date)')
    rescue SQLite3::SQLException
      p "tables already exist"
    end
  end
end
