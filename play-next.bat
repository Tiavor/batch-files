REM this batch is for creating a list of all videos in the current folder (or subfolders) and play the first
REM   at the next start of this file, the next in the list will be played
REM   when the created list is empty, a new list will be created and checked against all past played files, so only new get added
REM to include subfolders: create a shortcut to this bat and add -sub as commandline parameter
REM   if the path includes a space, encase the path in quotes and add the parameter after the quotes. e.g.: "F:\downloads\movies and series\play-videos.bat" -sub

REM summary of previous updates:
REM    removed "setlocal enabledelayedexpansion" as it doesn't with if the path/file includes exclamation mark(s)
REM    findstr doesn't work with subfolders. when -sub is activated, the full path is lsited and backslash is an escape character for findstr
REM    added subfolder search as command line parameter option
REM    automaticalls removes entries from watched.txt when files are not present anymore

@echo off

if exist next.txt goto play
REM if next.txt is not present, create a new file with all .avi, .mkv, .mov and .mp4 files in this folder and all sub folders (/s)
REM /b reduces the dir command to just the file name, /s searches through all sub folders and writes the complete path into the list
if "%1"=="-sub" goto yes
goto no
:yes
	dir *.mkv /b /s > temp.txt
	dir *.mp4 /b /s >> temp.txt
	dir *.avi /b /s >> temp.txt
	dir *.mov /b /s >> temp.txt
	echo included subfolders
	goto continue
:no
	dir *.mkv /b > temp.txt
	dir *.mp4 /b >> temp.txt
	dir *.avi /b >> temp.txt
	dir *.mov /b >> temp.txt
:continue

REM sorting the result in case file formats are mixed
sort temp.txt > list.txt
del temp.txt


REM if exists watched.txt compare with list.txt
REM    put not matching entries in next.txt
if exist list.txt (
	if exist watched.txt (
		echo filtering next.txt
		REM the given example for findstr weren't helpful. g: is the key(s) and the second parameter is the list to check for the key(s)
		REM if not exist next.txt echo.> next.txt
		REM note: removed findstr because it doesn't work with complete paths as backslash is an escape char
		for /f "tokens=*" %%f in (watched.txt) do (
			if exist %%f (
				echo %%f>> watched2.txt
				echo filtering "%%f"
				echo @echo off> sort.bat
				echo for /f "tokens=*" %%%%d in ^(list.txt^) do ^(>> sort.bat
				echo if not "%%%%d"=="%%f" ^(>> sort.bat
				echo echo %%%%d^>^> list2.txt>> sort.bat
				echo ^)>> sort.bat
				echo ^)>> sort.bat 
				echo del list.txt>> sort.bat
				echo ren list2.txt list.txt>> sort.bat
				call sort.bat
			)
		)
		del watched.txt
		ren watched2.txt watched.txt
		echo filter complete
		del sort.bat
	)
)
ren list.txt next.txt

:play
REM if playlist was already created, pick next title and play, ignore the rest
set /p line=< next.txt
for /f "tokens=*" %%a in (next.txt) do (
	REM check if line is not empty
	if not "%%a" == "" (
		if "%line%"=="%%a" (
			REM first line entry is started/played
			echo starting: %%a
			start "" "%%a"
			REM put entry in watched.txt
			echo %%a>> watched.txt
		) else (
			REM rest of the lines are copied into a new file, effectively reving the first line
			echo %%a>> temp.txt
		)
	)
)
del next.txt
ren temp.txt next.txt
