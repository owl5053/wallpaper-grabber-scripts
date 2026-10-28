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
$erowallfile = $FSO.GetSpecialFolder(2).Path
if ($erowallfile.Substring($erowallfile.Length - 1) -ne '\') { $erowallfile = $erowallfile + '\' }
$erowallfile = $erowallfile + 'erowall.jpg'

$sUrlRequest = 'https://erowall.com/?'
$oXMLHTTP = New-Object -ComObject WinHttp.WinHttpRequest.5.1
$oXMLHTTP.Open('GET', $sUrlRequest, $false)
$oXMLHTTP.setRequestHeader('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:65.0) Gecko/20100101 Firefox/65.0')
$oXMLHTTP.Send()
$httpfile = $oXMLHTTP.ResponseText
$oXMLHTTP = $null

$beg = $httpfile.ToLower().IndexOf('/w/')
$ef  = $httpfile.ToLower().IndexOf('/', $beg + 3)
$lnk = $httpfile.Substring($beg + 3, $ef - $beg - 3)

$r = Get-Random -Minimum 1 -Maximum ([int]$lnk + 1)

$url = 'https://erowall.com/wallpapers/original/' + $r + '.jpg'
$oXMLHTTP2 = New-Object -ComObject WinHttp.WinHttpRequest.5.1
$oXMLHTTP2.Open('GET', $url, $false)
$oXMLHTTP2.Send()

$oADOStream = New-Object -ComObject ADODB.Stream
$oADOStream.Mode = 3
$oADOStream.Type = 1
$oADOStream.Open()
$oADOStream.Write($oXMLHTTP2.ResponseBody)
$oADOStream.SaveToFile($erowallfile, 2)
$oADOStream.Close()

Set-Wallpaper $erowallfile

$oXMLHTTP2 = $null
$oADOStream = $null
$FSO = $null