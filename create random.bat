REM this file creates a shortcut to the play-next.bat file onto the desktop
REM and sets a random subfolder as target and name of the shortcut

@echo off

dir /b /a:d > tmp1.txt

set count=1
for /f "tokens=*" %%a in (tmp1.txt) do (
	if exist tmp2.txt (
		echo A >> tmp2.txt
	) else (
		echo A > tmp2.txt
	)
)

SETLOCAL ENABLEDELAYEDEXPANSION
set count=0
for /f "tokens=*" %%a in (tmp2.txt) do (
	set /A count = !count! + 1
)
echo !count!>tmp2.txt
endlocal

set /P line=< tmp2.txt


echo number of next.bat: %line%
set /A maxval=%line%
set minval=1
set /A chosen=%RANDOM% %% %maxval% + %minval%
echo chosen number %chosen% out of %maxval%

(for /L %%i in (1,1,%chosen%) do set /P "result=")< tmp1.txt
set path=%CD%\%result%
echo %path%

set "par=%path%"
:loop
for /f "delims=\ tokens=1,*" %%A in ("%par%") do (
    set "folder=%%A"
    set "par=%%B"
)
if NOT "%par%"=="" goto loop
echo Anime: %folder%

set SCRIPT="%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo %SCRIPT%


echo Set oWS = WScript.CreateObject("WScript.Shell")>> %SCRIPT%
echo sLinkFile = "%USERPROFILE%\Desktop\%folder%.lnk">> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile)>> %SCRIPT%
echo oLink.TargetPath = "%CD%\play-next.bat">> %SCRIPT%
echo oLink.Arguments = "-sub">> %SCRIPT%
echo oLink.WorkingDirectory = "%path%">> %SCRIPT%
echo oLink.Save>> %SCRIPT%

c:\windows\system32\cscript.exe /nologo "%SCRIPT%"

del %SCRIPT%

del tmp1.txt
del tmp2.txt
del tmp3.txt

