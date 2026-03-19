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
wallherefile = fso.GetSpecialFolder(2): if right(wallherefile,1)<>"\" then wallherefile=wallherefile & "\" : wallherefile = wallherefile & "wallhere.jpg"

searchstring=""

'=== part 1 ====
sUrlRequest = "https://wallhere.com/en/random?q=" & searchstring & "&direction=horizontal"
Set oXMLHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")
oXMLHTTP.Open "GET", sUrlRequest, False
oXMLHTTP.Send
httpfile=oXMLHTTP.Responsetext
Set oXMLHTTP = Nothing

beg=instr(lcase(httpfile),"/en/wallpaper/")
ef=instr(lcase(httpfile),"current-item-photo")
lnk=mid(httpfile,beg,ef-beg-10)
url="https://wallhere.com" & lnk


'=== part 2 ====
sUrlRequest = url
Set oXMLHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")
oXMLHTTP.Open "GET", sUrlRequest, False
oXMLHTTP.Send
httpfile=oXMLHTTP.Responsetext
Set oXMLHTTP = Nothing

beg=instr(lcase(httpfile),"https://get.wallhere.com/photo/")
ef=instr(lcase(httpfile),"current-page-photo")
url=mid(httpfile,beg,ef-beg-9)

Set oXMLHTTP2 = CreateObject("MSXML2.XMLHTTP")
oXMLHTTP2.Open "GET", url, False
oXMLHTTP2.Send
Set oADOStream = CreateObject("ADODB.Stream")
oADOStream.Mode = 3 'RW
oADOStream.Type = 1 'Binary
oADOStream.Open
oADOStream.Write oXMLHTTP2.ResponseBody

oADOStream.SaveToFile wallherefile, 2

Set objWshShell = WScript.CreateObject("Wscript.Shell")

SetWallpaper wallherefile

'use irfanview if you want
'objWshShell.Run "c:\Programs\IrfanView\i_view64.exe """ & wallherefile & """ /wall=3 /killmesoftly", 2, False 

Set oXMLHTTP2 = Nothing
Set oADOStream = Nothing
Set FSO = Nothing
Set objWshShell = Nothing
