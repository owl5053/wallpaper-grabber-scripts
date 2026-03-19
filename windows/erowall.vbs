'On error resume next 'comment it for debug

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
erowallfile = fso.GetSpecialFolder(2): if right(erowallfile,1)<>"\" then erowallfile=erowallfile & "\" : erowallfile = erowallfile & "erowall.jpg"

searchstring=""

'=== part 1 ====
sUrlRequest = "https://erowall.com/?"
Set oXMLHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")
oXMLHTTP.Open "GET", sUrlRequest, True
oXMLHTTP.SetRequestHeader "User-Agent", "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:65.0) Gecko/20100101 Firefox/65.0"
oXMLHTTP.Send
oXMLHTTP.WaitForResponse
httpfile=oXMLHTTP.Responsetext
Set oXMLHTTP = Nothing


beg=instr(lcase(httpfile),"/w/")
ef=instr(beg+3,lcase(httpfile),"/")
lnk=mid(httpfile,beg+3,ef-beg-3)

randomize
r = int(rnd*CLng(lnk)) + 1

'=== part 2 ====
url="https://erowall.com/wallpapers/original/" + cstr(r) + ".jpg"
Set oXMLHTTP2 = CreateObject("WinHttp.WinHttpRequest.5.1")
oXMLHTTP2.Open "GET", url, False
oXMLHTTP2.Send
Set oADOStream = CreateObject("ADODB.Stream")
oADOStream.Mode = 3 'RW
oADOStream.Type = 1 'Binary
oADOStream.Open
oADOStream.Write oXMLHTTP2.ResponseBody

oADOStream.SaveToFile erowallfile, 2

Set objWshShell = WScript.CreateObject("Wscript.Shell")
'use OS to set wallpaper

SetWallpaper erowallfile


'use irfanview if you want
'objWshShell.Run "c:\Programs\IrfanView\i_view64.exe """ & erowallfile & """ /wall=3 /killmesoftly", 1, False 


Set oXMLHTTP2 = Nothing
Set oADOStream = Nothing
Set FSO = Nothing
Set objWshShell = Nothing