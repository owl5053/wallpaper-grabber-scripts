On error resume next 'comment it for debug

Sub SetWallpaper(FileName)    
    Set oShA = CreateObject("Shell.Application")
    Set oShA = oShA.Windows.Item.document.Application
    If Not IsObject(oSHA) Then _
    Set oShA = GetObject("new:{C08AFD90-F2A1-11D1-8455-00A0C91F3880}").document.Application
    On Error GoTo 0: Er = Not IsObject(oSHA)
    If Er Then Set oShA = CreateObject("Shell.Application")
    oShA.NameSpace(0).ParseName(FileName).InvokeVerb "setdesktopwallpaper"
    If Er Then WSH.Sleep 4000
    Set oFSO = Nothing: Set oShA = Nothing
End Sub

set FSO=CreateObject ("Scripting.FileSystemObject")
bingfile = fso.GetSpecialFolder(2): if right(bingfile,1)<>"\" then bingfile=bingfile & "\" : bingfile = bingfile & "bing.jpg"

sUrlRequest = "https://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=1"
Set oXMLHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")
oXMLHTTP.Open "GET", sUrlRequest, False
oXMLHTTP.Send
xmlfile=oXMLHTTP.Responsetext
Set oXMLHTTP = Nothing

beg=instr(lcase(xmlfile),"<urlbase>")
ef=instr(lcase(xmlfile),"</urlbase>")
lnk=mid(xmlfile,beg+9,ef-beg-9)
url="http://www.bing.com/"+lnk+"_UHD.jpg"

Set oXMLHTTP2 = CreateObject("WinHttp.WinHttpRequest.5.1")
oXMLHTTP2.Open "GET", url, False
oXMLHTTP2.Send
Set oADOStream = CreateObject("ADODB.Stream")
oADOStream.Mode = 3 'RW
oADOStream.Type = 1 'Binary
oADOStream.Open
oADOStream.Write oXMLHTTP2.ResponseBody

oADOStream.SaveToFile bingfile, 2

Set objWshShell = WScript.CreateObject("Wscript.Shell")
SetWallpaper bingfile

'use irfanview if you want
'objWshShell.Run "c:\Programs\IrfanView\i_view64.exe """ & bingfile & """ /wall=2 /killmesoftly", 1, False 


Set oXMLHTTP2 = Nothing
Set oADOStream = Nothing
Set FSO = Nothing
Set objWshShell = Nothing
