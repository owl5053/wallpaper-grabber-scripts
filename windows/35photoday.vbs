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

dim photoday, lnk, sUrlRequest
set FSO=CreateObject ("Scripting.FileSystemObject")
photoday = fso.GetSpecialFolder(2): if right(bingfile,1)<>"\" then photoday=photoday & "\" : photoday = photoday & "35photo.jpg"

sUrlRequest = "https://35photo.pro/rss/photo_day.xml"
Set oXMLHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")
oXMLHTTP.Open "GET", sUrlRequest, False
oXMLHTTP.Send
xmlfile=oXMLHTTP.Responsetext
Set oXMLHTTP = Nothing

beg=instr(lcase(xmlfile),"img src=")
ef=instr(lcase(xmlfile),".jpg")
lnk=mid(xmlfile,beg+14,ef-beg-10)

lnk=replace(lnk,"_temp","_main")
lnk=replace(lnk,"/sizes","")
lnk=replace(lnk,"_800n.jpg",".jpg")

Set oXMLHTTP2 = CreateObject("WinHttp.WinHttpRequest.5.1")
oXMLHTTP2.Open "GET", lnk, False
oXMLHTTP2.Send
Set oADOStream = CreateObject("ADODB.Stream")
oADOStream.Mode = 3 'RW
oADOStream.Type = 1 'Binary
oADOStream.Open
oADOStream.Write oXMLHTTP2.ResponseBody

oADOStream.SaveToFile photoday, 2

Set objWshShell = WScript.CreateObject("Wscript.Shell")


'use OS to set wallpaper
SetWallpaper photoday

'use irfanview if you want
'objWshShell.Run Chr(34) & "c:\Programs\IrfanView\i_view64.exe" & Chr(34) & " " & Chr(34) & photoday & Chr(34) & " /wall=3 /killmesoftly", 1, False 

Set oXMLHTTP2 = Nothing
Set oADOStream = Nothing
Set FSO = Nothing
Set objWshShell = Nothing
