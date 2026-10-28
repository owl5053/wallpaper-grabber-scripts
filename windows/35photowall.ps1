$ErrorActionPreference = 'SilentlyContinue'   # Stop for debug

# Win32 API
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    public static void Set(string path) {
        SystemParametersInfo(0x0014, 0, path, 0x01 | 0x02); // SPI_SETDESKWALLPAPER
    }
}
"@

function Set-Wallpaper {
    param([string]$FileName)
    if (-not (Test-Path $FileName)) {
        throw "Wallpaper file not found: $FileName"
    }
    [Wallpaper]::Set($FileName)
    Write-Host "[OK] Wallpaper set: $FileName" -ForegroundColor Green
}

$photoday = $null
$lnk = $null
$sUrlRequest = $null
$pos = $null
$c = $null
$photo = @()

$FSO = New-Object -ComObject Scripting.FileSystemObject
$photoday = $FSO.GetSpecialFolder(2).Path   # 2 = TemporaryFolder
if ($photoday.Substring($photoday.Length - 1) -ne '\') { $photoday = $photoday + '\' }
$photoday = $photoday + '35photowall.jpg'

# Genre: default 99, or pass a number as the first argument (e.g. .\35photowall.ps1 85)
$genre = 99
if ($args.Count -ge 1 -and $args[0] -match '^\d+$') {
    $genre = [int]$args[0]
}

$sUrlRequest = "https://35photo.pro/genre_$genre/new"   # 98 = only 18+

$oXMLHTTP = New-Object -ComObject WinHttp.WinHttpRequest.5.1
$oXMLHTTP.Open('GET', $sUrlRequest, $false)

$oXMLHTTP.setRequestHeader('Cookie', 'nude=true') # Personal wallpaper script. Use at your own risk.
$oXMLHTTP.Send()
$xmlfile = $oXMLHTTP.ResponseText
$oXMLHTTP = $null

$pos = 1
$c = 1
$photo = @()

do {
    $ef = $xmlfile.ToLower().IndexOf('_800n.jpg', $pos - 1)
    if ($ef -ne -1) {
        $ef = $ef + 1   
        $beg = $xmlfile.ToLower().LastIndexOf('https://35photo.pro', $ef - 1)
        if ($beg -ne -1) {
            $beg = $beg + 1
            $lnk = $xmlfile.Substring($beg - 1, $ef - $beg + 9)
            $lnk = $lnk -replace '_temp', '_main'
            $lnk = $lnk -replace '/sizes', ''
            $lnk = $lnk -replace '_800n\.jpg', '.jpg'
            $photo += $lnk
            $pos = $ef + 1
            $c = $c + 1
        } else {
            $ef = -1
        }
    }
} while ($ef -ne -1)

if ($photo.Count -eq 0) {
    Write-Host "[ERROR] No photo links found. Has the site changed its markup?" -ForegroundColor Red
    Read-Host "Press Enter to close..."
    return
}

# randomize
$rand = Get-Random -Minimum 1 -Maximum ($photo.Count + 1)
$lnk = $photo[$rand - 1]
Write-Host "[INFO] Selected link: $lnk" -ForegroundColor Cyan

$oXMLHTTP2 = New-Object -ComObject WinHttp.WinHttpRequest.5.1
$oXMLHTTP2.Open('GET', $lnk, $false)
$oXMLHTTP2.Send()

$oADOStream = New-Object -ComObject ADODB.Stream
$oADOStream.Mode = 3   # RW
$oADOStream.Type = 1   # Binary
$oADOStream.Open()
$oADOStream.Write($oXMLHTTP2.ResponseBody)
$oADOStream.SaveToFile($photoday, 2)   # 2 = adSaveCreateOverWrite
$oADOStream.Close()

$objWshShell = New-Object -ComObject WScript.Shell

Set-Wallpaper $photoday


$oXMLHTTP2 = $null
$oADOStream = $null
$FSO = $null
$objWshShell = $null
