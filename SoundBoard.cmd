REM PowerShell Jukebox by Jason Groce and improved by Tim Salmonson (renamed to SoundBoard)

PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""%~dpn0.ps1""'}"
PAUSE