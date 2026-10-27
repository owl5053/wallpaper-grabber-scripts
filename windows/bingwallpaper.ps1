$ErrorActionPreference = 'SilentlyContinue'

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    public static void Set(string path) {
        SystemParametersInfo(0x0014, 0, path, 0x01 | 0x02);
    }
}
"@

function Set-Wallpaper {
    param([string]$FileName)
    if (-not (Test-Path $FileName)) {
        throw "Wallpaper file not found: $FileName"
    }
    [Wallpaper]::Set($FileName)
}

$FSO = New-Object -ComObject Scripting.FileSystemObject
$bingfile = $FSO.GetSpecialFolder(2).Path
if ($bingfile.Substring($bingfile.Length - 1) -ne '\') { $bingfile = $bingfile + '\' }
$bingfile = $bingfile + 'bing.jpg'

$sUrlRequest = 'https://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=1'
$oXMLHTTP = New-Object -ComObject WinHttp.WinHttpRequest.5.1
$oXMLHTTP.Open('GET', $sUrlRequest, $false)
$oXMLHTTP.Send()
$xmlfile = $oXMLHTTP.ResponseText
$oXMLHTTP = $null

$beg = $xmlfile.ToLower().IndexOf('<urlbase>')
$ef  = $xmlfile.ToLower().IndexOf('</urlbase>')
$lnk = $xmlfile.Substring($beg + 9, $ef - $beg - 9)
$url = 'http://www.bing.com/' + $lnk + '_UHD.jpg'

$oXMLHTTP2 = New-Object -ComObject WinHttp.WinHttpRequest.5.1
$oXMLHTTP2.Open('GET', $url, $false)
$oXMLHTTP2.Send()

$oADOStream = New-Object -ComObject ADODB.Stream
$oADOStream.Mode = 3
$oADOStream.Type = 1
$oADOStream.Open()
$oADOStream.Write($oXMLHTTP2.ResponseBody)
$oADOStream.SaveToFile($bingfile, 2)
$oADOStream.Close()

Set-Wallpaper $bingfile

$oXMLHTTP2 = $null
$oADOStream = $null
$FSO = $null