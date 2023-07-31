$ENEMIZER_VERSION = '7.1'
if (!(Test-Path -Path 'EnemizerCLI')) {
    if (!(Test-Path -Path 'enemizer.zip')) {
        Invoke-WebRequest -Uri "https://github.com/Ijwu/Enemizer/releases/download/$ENEMIZER_VERSION/win-x64.zip" -OutFile 'enemizer.zip'
    }
    Expand-Archive -Path 'enemizer.zip' -DestinationPath 'EnemizerCLI' -Force
}
Remove-Item -Recurse -Force '.\build\Archipelago' -ErrorAction SilentlyContinue
python3.10.exe '.\setup.py' build_exe --yes
$NAME = "$(Get-ChildItem '.\build' | Select-String -Pattern 'exe')".Split('.', 2)[1]
$TIMESTAMP = "$(((Get-Date).ToUniversalTime()).ToString('yyyyMMddTHHmmssZ'))"
$ZIP_NAME = "Archipelago_$NAME_$TIMESTAMP.7z"
Write-Output "$NAME -> $ZIP_NAME"
New-Item -Path '.\dist' -ItemType Directory -Force | Out-Null
Set-Location '.\build'
Move-Item "exe.$NAME" 'Archipelago'
& 'C:\Program Files\7-Zip\7z.exe' a -mx=9 -mhe=on -ms "..\dist\$ZIP_NAME" 'Archipelago'
Set-Location ..