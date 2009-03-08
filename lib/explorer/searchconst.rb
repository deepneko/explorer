module Explorer
  class SearchConst
    attr_accessor :SEARCH_DIR
    attr_accessor :CGI_PATH
    attr_accessor :DIR_PATH
    attr_accessor :ICON_PATH
    attr_accessor :DIR_ICON
    attr_accessor :FILE_ICON
    attr_accessor :DB
    attr_accessor :LISTNEW_SIZE
    attr_accessor :ENCODE_SERVER
    attr_accessor :SSH_PORT
    
    def initialize
      @CGI_PATH = './explorer.cgi'
      @ICON_PATH = '../img/'
      @DIR_ICON = @ICON_PATH + 'dir.gif'
      @FILE_ICON = @ICON_PATH + 'text.gif'

      # need basic configuration
      @SEARCH_DIR = '/home/deepneko/tmp/'
      @DB = '/home/deepneko/allfile.db'
      @LISTNEW_SIZE = 10

      # encode configuration
      @ENCODE_SERVER = "tomoyo@deepneko.dyndns.org:~/ffmpeg/"
      @SSH_PORT = 20022
    end
  end
end
