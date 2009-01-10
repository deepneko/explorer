module Explorer
  class SearchThread
    def initialize(path, keyword, parent)
      @searchResult = []
      @workingThread = 0
      @lock = Mutex.new

      @path = path
      @parent = parent
      
      @keyword = keyword
      k = keyword.split
      @pattern = []
      for i in k
        @pattern.push("*" + i + "*")
      end
    end

    def start
      begin
        @dir = Dir.open(@path)
        
        #search directory
        @dir.each do |file|
          basename = File.basename(file)
          absolutePath = @path + basename
          if File.ftype(absolutePath)=="directory"
            absolutePath += "/"
            if /^\./ =~ basename
              next
            end

            #create search directory thread
            @workingThread += 1
            child = SearchThread.new(absolutePath, @keyword, self)
            t = Thread.new(child) do |childThread|
              childThread.start
            end
            t.join
          else
          keywordNum = @pattern.size
            for i in @pattern
              if File.fnmatch(i, basename)
                keywordNum -= 1
              else
                break
              end
            end
            
            if keywordNum == 0
              @searchResult.push(absolutePath)
            end
          end
        end
        @dir.close
      rescue
        return
      end
      
      if @parent != nil
        while @workingThread != 0 do
          sleep 0.1
        end
        @parent.addSearchResult(@searchResult)
      end
    end
    
    #called by child thread
    def addSearchResult(obj)
      @lock.synchronize{
        @workingThread -= 1
        @searchResult.concat(obj)
      }
    end
    
    def getSearchResult
      return @searchResult
    end
  end
end
