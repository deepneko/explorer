module Explorer
  class Folderlist
    def initialize
      @const = SearchConst.new
      
      Dir.chdir(@const.SEARCH_DIR)
      @root = Folder.new("./", 0)
    end

    def open(path)
      path = path.sub(@const.SEARCH_DIR, "./")
      if File.file?(path)
        dir = File.dirname(path) + "/"
        file = File.basename(path)
        @root.open(dir, file)
      else
        @root.open(path)
      end
    end
    
    def show(count=nil)
      html = "<img src=\"" + @const.DIR_ICON + "\" align=\"absmiddle\" border=0>"
      html += "<b> " + @const.SEARCH_DIR + "</b><br>"
      @root.show(html, count)
    end

    def allfile
      @root.allfile
    end
  end
end
