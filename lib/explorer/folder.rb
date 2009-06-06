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

      flvlist = $con.execute("select path,flv from filelist where path like '#{@absolutePath}%' and path not like '#{@absolutePath}%/%' and flv!=''")
#      flvlist.each do |fullpath, flv|
#        html += fullpath + ":" + flv
#      end
#      for file in @fileList
      for fullpath,flv in flvlist
        for i in 0..@deps
          html += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        end

        #####################################
        # ToDo: this code can be bottleneck #
        #####################################
        #fullpath = @absolutePath + file
        #flv = $con.execute("select flv from filelist where path=\"#{fullpath}\" and flv!=''").flatten
        #img = "<a href=\"javascript:;\" onclick=\"window.open('http://tomoyo.uraz.org/cgi-bin/explorer/bin/player.cgi?src=/flv/" + flv[0].to_s + "', 'winName', 'left=0,top=0,width=670,height=590,status=0,scrollbars=0,menubar=0,location=0,toolbar=0,resizable=0');\"><img src=\"" + @const.PLAY_ICON + "\" align=\"absmiddle\" border=0></a> "
        #html += img * flv.size

        html += "<img src=\"" + @const.FILE_ICON + "\" align=\"absmiddle\" border=0>"
        if file == @focusfile
          html += " <font color=red>" + File.basename(fullpath) + "</font><br>"
        else
          html += " " + File.basename(fullpath) + "<br>"
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
