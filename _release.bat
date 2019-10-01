set target=html5
set releaseFileName=index.html
set haxelib="D:\Ten 90 Studios\SDK\Haxe\haxe\haxelib.exe"

%haxelib% run lime build "%~dp0xml\project.xml" %target% -verbose

cd "%~dp0bin\%target%\release\bin"

start "" %releaseFileName%