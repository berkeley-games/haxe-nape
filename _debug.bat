@echo off

set target=flash
set debugFileName=sandbox.swf

set sdk=D:\Ten 90 Studios\SDK
set haxelib="%sdk%\Haxe\haxe\haxelib.exe"
set flashBin=%sdk%\AIR\24\bin
set flashDebugger="%flashBin%\fdb"
set debugFolder=%~dp0bin\%target%\debug\bin
set debugFilePath=%debugFolder%\%debugFileName%

@echo on

%haxelib% run lime build "%~dp0xml\project.xml" %target% -verbose -debug -Ddebug -Dfdb

cd %debugFolder%

start "" "%debugFilePath%"

(echo run %debugFilePath%&echo continue)| %flashDebugger% -unit