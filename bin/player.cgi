#!/usr/bin/ruby

require 'cgi'

cgi = CGI.new('html4')
source = cgi.params['src'][0]

$html1 = <<"HTML1"
<html>
<head>
<title>player</title>
</head>
<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
		id="FlvPlayer" width="660" height="572"
		codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
		<param name="movie" value="FlvPlayer.swf" />
		<param name="quality" value="high" />
		<param name="bgcolor" value="#869ca7" />
		<param name="allowScriptAccess" value="sameDomain" />
HTML1

$html2 =  "<param name=\"FlashVars\" value=\"src=#{source}\"/><embed src=\"/home/deepneko/swf/FlvPlayer.swf\" FlashVars=\"src=#{source}\""

$html3 = <<"HTML2"
			quality="high" bgcolor="#869ca7"
			width="660" height="572" name="FlvPlayer" align="middle"
			play="true"
			loop="false"
			quality="high"
			allowScriptAccess="sameDomain"
			type="application/x-shockwave-flash"
			pluginspage="http://www.adobe.com/go/getflashplayer">
		</embed>
</object>
</body>
</html>
HTML2

cgi.out(
	"type" => "text/html",
	"charset" => "Shift-JIS"
	)do
	cgi.html do
		cgi.body do
			$html1 + $html2 + $html3
		end
	end
end
