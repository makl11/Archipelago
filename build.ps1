$ErrorActionPreference = 'Stop'

$ENEMIZER_VERSION = '7.1'
if (!(Test-Path -Path 'EnemizerCLI')) {
    if (!(Test-Path -Path 'enemizer.zip')) {
        Invoke-WebRequest -Uri "https://github.com/Ijwu/Enemizer/releases/download/$ENEMIZER_VERSION/win-x64.zip" -OutFile 'enemizer.zip'
    }
    Expand-Archive -Path 'enemizer.zip' -DestinationPath 'EnemizerCLI' -Force
    Remove-Item -Force -Path 'enemizer.zip'
}
Remove-Item -Recurse -Force '.\build\Archipelago' -ErrorAction SilentlyContinue
& python3.10.exe '.\setup.py' build_exe --yes
if ($LASTEXITCODE -gt 0) { 
    throw "Python build failed (code: $LASTEXITCODE)" 
}
$NAME = "$(Get-ChildItem '.\build\exe.win*' | Select-Object -ExpandProperty BaseName)" -replace 'exe.'
$TIMESTAMP = "$(((Get-Date).ToUniversalTime()).ToString('yyyyMMddTHHmmssZ'))"
$ZIP_NAME = "Archipelago_${NAME}_${TIMESTAMP}.7z"
Write-Output "$NAME -> $ZIP_NAME"
New-Item -Path '.\dist' -ItemType Directory -Force | Out-Null
Set-Location '.\build'
Move-Item "exe.$NAME" 'Archipelago'
& 'C:\Program Files\7-Zip\7z.exe' a -mx=9 -mhe=on -ms "..\dist\$ZIP_NAME" 'Archipelago'
if ($LASTEXITCODE -gt 0) {
    Remove-Item "..\dist\$ZIP_NAME" -Force
    throw "Creating 7z archive failed (code: $LASTEXITCODE)" 
}
Set-Location ..