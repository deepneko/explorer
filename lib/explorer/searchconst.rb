module Explorer
  class SearchConst
    attr_accessor :SEARCH_DIR
    attr_accessor :URL_PATH
    attr_accessor :CGI_PATH
    attr_accessor :DIR_PATH
    attr_accessor :ICON_PATH
    attr_accessor :DIR_ICON
    attr_accessor :FILE_ICON
    attr_accessor :DB
    attr_accessor :LISTNEW_SIZE
    
    def initialize
      #@SEARCH_DIR = "/home/deepneko/tmp/"
      #@URL_PATH = 'http://deepneko.dyndns.org/kokotech/archives/'
      @SEARCH_DIR = "/Users/deepneko/study/"
      @URL_PATH = 'http://localhost/'
      @CGI_PATH = './explorer.cgi'
      #@DIR_PATH = '/home/deepneko/tmp/'
      @DIR_PATH = '/Users/deepneko/study/'
      @ICON_PATH = '../img/'
      @DIR_ICON = @ICON_PATH + 'dir.gif'
      @FILE_ICON = @ICON_PATH + 'text.gif'
      @DB = "allfile.db"
      @LISTNEW_SIZE = 10
    end
  end
end
