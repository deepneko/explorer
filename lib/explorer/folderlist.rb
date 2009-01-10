module Explorer
  class Folderlist
    def initialize
      @const = SearchConst.new
      
      Dir.chdir(@const.SEARCH_DIR)
      @root = Folder.new("./", 0)
    end

    def open(path)
      path = path.sub(@const.SEARCH_DIR, "./")
      @root.open(path)
    end
    
    def show
      html = "<img src=\"" + @const.DIR_ICON + "\" align=\"absmiddle\" border=0>"
      html += "<b> " + @const.SEARCH_DIR + "</b><br>"
      return @root.show(html)
    end

    def allfile
      @root.allfile
    end
  end
end
