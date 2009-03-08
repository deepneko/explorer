module Explorer
  class Folder
    def initialize(path, deps)
      @const = SearchConst.new

      @fileList = []
      @dirList = []
      @folderList = Hash.new
      @path = path
      @focusfile
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
        @dirList = @dirList.sort
        @fileList = @fileList.sort
        @dir.close
      rescue
        return
      end
    end
    
    def open(targetPath, file=nil)
      @focusfile = file
      if !@open
        for dir in @dirList
          @folderList[dir] = Folder.new(@path + dir + "/", @deps+1)
        end
        @open = true
      end
      
      childFolder = targetPath.sub(@path, "").split(/\//).shift
      
      if childFolder != nil
        @folderList[childFolder].open(targetPath, file)
      else
        return
      end
    end
    
    def close
      @open = false
      @folderList.clear
    end
    
    def show(html, count=nil)
      folderArray = @folderList.sort
      folderArray.each do |dir, folder|
        for i in 0..@deps
          html += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        end
        html += "<img src=\"" + @const.DIR_ICON + "\" align=\"absmiddle\" border=0>"
        html += "<b> <a href=\"" + @const.CGI_PATH + "?dir=" + folder.getAbsolutePath
        html += "&count=" + count.to_s
        html += "\">" + folder.getBasename + "</a></b><br>"
        if folder.isOpen
          html = folder.show(html, count)
        end
      end

      for file in @fileList
        for i in 0..@deps
          html += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        end

        #####################################
        # ToDo: this code can be bottleneck #
        #####################################
        fullpath = @path + "/" + file
        flv = $con.execute("select flv from filelist where path like \"%#{file}\"").flatten
        html += flv.size.to_s

        html += "<img src=\"" + @const.FILE_ICON + "\" align=\"absmiddle\" border=0>"
        if file == @focusfile
          html += " <font color=red>" + file + "</font><br>"
        else
          html += " " + file + "<br>"
        end
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
