module Explorer
  class Folder
    def initialize(path, deps)
      @const = SearchConst.new

      @fileList = []
      @dirList = []
      @folderList = Hash.new
      @path = path
      @basename = File.basename(path)
      @absolutePath = @const.SEARCH_DIR + path.sub("./", "")
      @deps = deps
      @open = false
      
      init
    end

    def init
      begin
        @dir = Dir.open(@path)
        @dir.each do |file|
          basename = File.basename(file)
          absolutePath = @path + "/" + basename
          
          if /^\./ =~ basename
            next
          end
          
          if File.ftype(absolutePath)=="directory"
            @dirList.push(basename)
          else
            @fileList.push(basename)
          end
        end
        @fileList = @fileList.sort
        @dir.close
      rescue
        return
      end
    end
    
    def open(targetPath)
      if !@open
        for dir in @dirList
          @folderList[dir] = Folder.new(@path + dir + "/", @deps+1)
        end
        @open = true
      end
      
      childFolder = targetPath.sub(@path, "").split(/\//).shift
      
      if childFolder != nil
        @folderList[childFolder].open(targetPath)
      else
        return
      end
    end
    
    def close
      @open = false
      @folderList.clear
    end
    
    def show(html)
      @folderList.each_value do |folder|
        for i in 0..@deps
          html += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        end
        html += "<img src=\"" + @const.DIR_ICON + "\" align=\"absmiddle\" border=0>"
        html += "<b> <a href=\"" + @const.CGI_PATH + "?dir=" + folder.getAbsolutePath + "\">"
        html += folder.getBasename + "</a></b><br>"
        if folder.isOpen
          html = folder.show(html)
        end
      end
      
      for file in @fileList
        for i in 0..@deps
          html += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        end
        html += "<img src=\"" + @const.FILE_ICON + "\" align=\"absmiddle\" border=0>"
        html += " " + file + "<br>"
      end
      
      return html
    end

    def allfile
      a = []
      @fileList.each do |file|
        a << @absolutePath + file
      end

      @dirList.each do |dir|
        folder = Folder.new(@path + dir + "/", @deps+1)
        a << folder.allfile
      end
      a.flatten
    end
    
    def isOpen
      return @open
    end
    
    def getPath
      return @path
    end
    
    def getBasename
      return @basename
    end
    
    def getAbsolutePath
      return @absolutePath
    end
  end
end
