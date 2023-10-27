::Activation Script v0.6
@echo off
@setlocal DisableDelayedExpansion

::===========================================================================================================================::
:: This code block sets some environment variables and color codes for the console window and then
:: checks the Windows build version to determine if the console supports New Console Features (NCS).

title Dark Net Studio
echo Requesting Admininistrator Priviledges ...

pushd %~dp0
set winbuild=1
set "nul=>nul 2>&1"
set psc=powershell.exe
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G

set _NCS=1
if %winbuild% LSS 10586 set _NCS=0
if %winbuild% GEQ 10586 reg query "HKCU\Console" /v ForceV2 2>nul | find /i "0x0" 1>nul && (set _NCS=0)
call :_colorprep

set "eline=echo: &call :_color %Red% "==== ERROR ====" &echo:"

::===========================================================================================================================::

    ::==============================================================================::
    ::  Softify Activation Script by Dark Net Studio
    ::
    ::  This script is a part of the Microdyne Systems Pvt Ltd (MDS) Project.
    ::  Homepage: https://www.youtube.com/@darknetstudio
    ::  Email: tricktoxicated5@gmail.com
    ::
    ::  Specal Thanks to WindowsAddict & Zig Zag, Creator of (MDS) Projects.
    ::  Made with Love    (='_'=)
    ::==============================================================================::

::===========================================================================================================================::
  :: Elevate Script As Admin (by WindowsAddict) v2 
::  Set Path variable, it helps if it is misconfigured in the system

set "PATH=%SystemRoot%\System32;%SystemRoot%\System32\wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
set "PATH=%SystemRoot%\Sysnative;%SystemRoot%\Sysnative\wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%PATH%"
)

:: Re-launch the script with x64 process if it was initiated by x86 process on x64 bit Windows
:: or with ARM64 process if it was initiated by x86/ARM32 process on ARM64 Windows

set "_cmdf=%~f0"
for %%# in (%*) do (
if /i "%%#"=="r1" set r1=1
if /i "%%#"=="r2" set r2=1
)

if exist %SystemRoot%\Sysnative\cmd.exe if not defined r1 (
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %* r1"
exit /b
)

:: Re-launch the script with ARM32 process if it was initiated by x64 process on ARM64 Windows

if exist %SystemRoot%\SysArm32\cmd.exe if %PROCESSOR_ARCHITECTURE%==AMD64 if not defined r2 (
setlocal EnableDelayedExpansion
start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" %* r2"
exit /b
)

::  Check if Null service is working, it's important for the batch script

sc query Null | find /i "RUNNING" >nul
if %errorlevel% NEQ 0 (
cls
echo:
echo Null service is not running, script may crash...
echo:
echo:
ping 127.0.0.1 -n 10
)

::  Check LF line ending

pushd "%~dp0"
>nul findstr /v "$" "%~nx0" && (
echo:
echo Error: Script either has LF line ending issue or an empty line at the end of the script is missing.
echo:
ping 127.0.0.1 -n 6 >nul
popd
exit /b
)
popd

:: Stores the command line arguments in the "_args" variable
::Checks for the command line arguments.

set _args=
set _elev=
set _Unattended=

set _args=%*
if defined _args set _args=%_args:"=%
if defined _args (
for %%A in (%_args%) do (
if /i "%%A"=="-el"                    set _elev=1
)
)

if defined _args echo "%_args%" | find /i "/" >nul && set _Unattended=1

::===========================================================================================================================::
:: This code block checks the Windows build version and the availability of Powershell in the system.

if %winbuild% LSS 7600 (
%eline%
echo Unsupported OS version detected [%winbuild%].
echo Project is supported only for Windows 7/8/8.1/10/11 and their Server equivalent.
goto DNSend
)

for %%# in (powershell.exe) do @if "%%~$PATH:#"=="" (
%eline%
echo Unable to find powershell.exe in the system.
echo Aborting...
goto DNSend
)

::  Fix for the special characters limitation in path name

set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"

set "_batf=%~f0"
set "_batp=%_batf:'=''%"
set _PSarg="""%~f0""" -el %_args%
set "_ttemp=%userprofile%\AppData\Local\Temp"

setlocal EnableDelayedExpansion

::===========================================================================================================================::
: This code block checks if the script is launched from the temp folder and prints 
:: an error message if the script is launched directly from an archive file.

echo "!_batf!" | find /i "!_ttemp!" 1>nul && (
if /i not "!_work!"=="!_ttemp!" (
%eline%
echo Script is launched from the temp folder,
echo Most likely you are running the script directly from the archive file.
echo:
echo Extract the archive file and launch the script from the extracted folder.
goto DNSend
)
)
::===========================================================================================================================::
::  Elevate script as admin and pass arguments and preventing loop

>nul fltmc || (
if not defined _elev %nul% %psc% "start cmd.exe -arg '/c \"!_PSarg:'=''!\"' -verb runas" && exit /b
cls
%eline%
echo This script requires administrator privileges.
echo To do so, right click on this script and select 'Run as administrator'.
echo:
call :_color2 %_Yellow% "Press any key to exit..."
pause >nul
exit /b
)

if not exist "%SystemRoot%\Temp\" mkdir "%SystemRoot%\Temp" 1>nul 2>nul

::===========================================================================================================================::
::  Run script with parameters in unattended mode

SET "_args=%*"
set "nul=>nul 2>&1"

set _elev=
if defined _args echo "%_args%" | find /i "/S" %nul% && (set "_silent=%nul%") || (set _silent=)
if defined _args echo "%_args%" | find /i "/" %nul% && (

echo "%_args%" | find /i "/Activate"   %nul% && (setlocal & cls & (call :Activate   %_args% %_silent%) & endlocal)  
echo "%_args%" | find /i "/EZActivate"   %nul% && (setlocal & cls & (call :Activate2   %_args% %_silent%) & endlocal)
echo "%_args%" | find /i "/ClientID"  %nul% && (setlocal & cls & (call :ClientData  %_args% %_silent%) & endlocal)
echo "%_args%" | find /i "/ActStatus"   %nul% && (setlocal & cls & (call :ActivationStatus    %_args% %_silent%) & endlocal)
exit /b
)
goto :EActHome
::===========================================================================================================================::
:EsetInstalledChecker
:: This Code Checks if the Antivirus software is installed using registry. ::

set "regkey=HKEY_LOCAL_MACHINE\SOFTWARE\ESET\ESET Security\CurrentVersion\Info"
Reg Query "%regkey%" 2>nul | Find /i "InstallDir" >nul
if %errorlevel% equ 0 (goto :EActHome) else (goto :EsetNotInstalled)
exit

::===========================================================================================================================::
:EsetNotInstalled
title ESET Not Installed 
mode 70, 15 
color 4E

echo.
echo.
echo.                      ษออออออออออออออออออออออป
echo.                      บ  ESET Not Installed  บ
echo.                      ศออออออออออออออออออออออผ
echo. 
echo.             Have you installed ESET Internet Security?
echo.
echo.        * ESET Internet Security wasn't found in this system! 
echo.        * Please install ESET Internet Security and try again.
echo.
echo.               1. Retry      2. Continue      3. Exit
echo.
choice /C:123 /N /M "                 
set _erl=%errorlevel%

if %_erl%==3 exit
if %_erl%==2 goto :EActHome
if %_erl%==1 goto :EsetInstalledChecker
goto :EsetNotInstalled

::===========================================================================================================================::
:EActHome
title Softify Activation 0.6 
Color F
mode 69,28

echo.
echo:                                                   %date%
echo:
call :_color2 %_White% "                         " %Green% "MDS_PVT_LTD Edition"
call :_color2 %_White% "                       " %Green% "Softify Activation v0.6"
echo.
echo.         ษอออออออออออออออออออออออออออออออออออออออออออออออออป
echo.         บ                                                 บ
echo.         บ                                                 บ
echo.         บ     [1]. Activate - Eset Internet Security      บ
echo.         บ                                                 บ
echo.         บ     [2]. Client Data                            บ
echo.         บ                                                 บ
echo.         บ     [3]. Activation Status                      บ
echo.         บ                                                 บ
echo.         บ     [4]. Download Antivirus Product             บ
echo.         บ                                                 บ
echo.         บ     [5]. Exit                                   บ
echo.         บ                                                 บ
echo.         บ                                                 บ
echo.         ศอออออออออออออออออออออออออออออออออออออออออออออออออผ
echo:                                           
echo.
choice /C:12345 /N /M       ">              Enter Your Choice in the Keyboard : "
set dns=%errorlevel%

if %dns%==5 exit /b
if %dns%==4 start https://itmds07-my.sharepoint.com/:f:/g/personal/shahin_itmds07_onmicrosoft_com/EqgGBKe7vNdKtwjCXKTRIlYB80Px7UAjYcQlSninOrbb7Q?e=19WolWs
if %dns%==3 call :ActivationStatus
if %dns%==2 call :ClientData
if %dns%==1 goto :Activate
goto :EActHome

::===========================================================================================================================::
#0_0#
:Activate3
set _act=0

mode 70,28
title Maintenance Work in Progress 

echo.
call :_color2 %Green%      "==== Maintenance  ==== "
echo.
echo.This Site is under Construction.
echo.And will be back soon Thank you for your Patience :)
echo.
call :_color2 %_Yellow%     "Press any key to go back ..."
pause >nul
goto dkdone

::===========================================================================================================================::
#0_0#
:Activate2

set _act=0
set temp1="%temp%\%random%\%random%\%random%\"
set temp2="%windir%\temp\%random%\%random%\%random%\"
set "regkey=HKEY_LOCAL_MACHINE\SOFTWARE\ESET\ESET Security\CurrentVersion\Info"
md %temp1% &md %temp2%

call :IntCheck
call :Curl_Checker
call :DevID
call :DwlFile
move /y %dwl_name% %temp1% >nul 2>nul || move /y %dwl_name% %temp2% >nul 2>nul

cls
echo. & echo.
echo Run ESET Installer and Install Eset Security
echo Press any key to Continue with Activation.
echo.
call :_color2 %_Yellow% "Press any key to continue" 
pause >nul
echo.
echo This is a tricky process please hold untill further notice..

:: ====== ::
:loop
if not exist "%ProgramData%\Eset\Eset Security\License\license.lf" (
    md "%ProgramData%\Eset\Eset Security\License\" 2>nul
    copy /y "%temp1%\%dwl_name%" "%ProgramData%\Eset\Eset Security\License\license.lf" >nul 2>nul || copy /y "%temp2%\%dwl_name%" "%ProgramData%\Eset\Eset Security\License\license.lf" >nul 2>nul
)
Reg Query "%regkey%" 2>nul | Find /i "InstallDir" 2>nul >nul
if %errorlevel% equ 1 (goto :loop)

IF NOT EXIST "%ProgramData%\Eset\Eset Security\License\license.lf" (goto :loop) else (ping localhost -n 2 2>nul >nul
call :HwlFile
move /y hosts "%windir%\System32\drivers\etc\hosts" >nul 2>nul
if errorlevel 1 (del /f /q hosts &set Act_Prot=Failed) else (set Act_Prot=Protected)
ping localhost -n 3 2>nul >nul
goto :Activ)
:: ====== ::

:Activ
color F
mode 76,22
del /q %temp1% >nul &del /q %temp2% >nul
call :RegistryCheck

title Softify Activation Information
cls
echo.
call :_color2 %_Green%  "***********************************************************"
call :_color2 %_Green%  "***                 Activation Information              ***"
call :_color2 %_Green%  "***********************************************************"
echo.
echo Name: %Prod_Name%
echo Description: ESET Security %Prod_Vers%
echo Activation Protection : %Act_Prot%
echo.
echo Expiration Date: Check Activation Status
echo Licensed Status: Licensed
echo.
call :_color2 %Green% "Product Activated Successfully. "
echo.
call :_color2 %_Yellow% "Press any key exit..." 
pause >nul
exit

::===========================================================================================================================::
#0_0#
:: Not used until a call from the code ::
:ECompatibleCheck
mode 80, 28

REG QUERY "%regkey%" 2>nul | FIND /I "ProductVersion" >nul
if %errorlevel% equ 1 (goto :EsetNotInstalled)

for /f "tokens=2*" %%a in ('reg query "%regkey%" /v "ProductVersion" ^| findstr "ProductVersion"') do (set version=%%b)
if "%version%" gtr "16.4.14.0" (goto :ENotSupported)
exit /b

:ENotSupported  :: Error 1 ::
title Product Not Supported

echo.
call :_color2 %Red%        "==== Product Not Supported ==== "
echo.
echo This version ESET %version% is not supported by our Activation.
echo.
call :_color2 %_Yellow%     "Press any key to go back"
pause >nul
goto :EActHome

::===========================================================================================================================::
#0_0#
:: Not used until a call from the code ::
:IntCheck
mode 80, 28
echo.
echo Gathering Files from [MDS_PVT_LTD] Server...
set "Domain=eset.com"

ipconfig /flushdns >nul
ping -n 2 %Domain% >nul
if %errorlevel% equ 1 (goto :No_Internet)
exit /b

:No_Internet :: Error 2 ::
title No internet connection found
mode 80, 28

echo.
call :_color2 %Red%        "==== ERROR ==== "
echo.
echo Internet is not connected.
echo.
call :_color2 %_Yellow%     "Press any key to go back"
pause >nul
goto :EActHome

::===========================================================================================================================::
#0_0#
:Curl_Checker
:: Check if curl is installed
where curl.exe >nul 2>nul || (

cls &echo.
call :_color2 %Red%        "==== ERROR ==== "
echo.
echo. curl is not installed or not accessible.
echo. Please install curl or ensure it is in the system's PATH.
echo.
call :_color2 %_Yellow%     "Press any key to go back"
pause >nul
exit /b
)

    :: === #0_0# === ::
:: Check if Curl is accessible without antivirus interference
curl.exe https://pastebin.com/raw/WXhBSHks >nul 2>nul || (

title Curl Restricted Access
cls &echo.
call :_color2 %Red%        "==== ERROR ==== "
echo.
echo. Curl is being blocked by an Antivirus most probably.
echo. Please disable the antivirus temporarily.
echo.
echo. If you are still facing an Issue, Please
echo. try connecting to a different WiFI network
echo.
call :_color2 %_Yellow%     "Press any key to go back"
pause >nul
exit /b
)

    :: === #0_0# === ::
:: Set the raw paste URL 
:: Check if the raw URL is valid using curl

set "rawPasteUrl=https://pastebin.com/raw/WXhBSHks"
curl --head --silent --fail "%rawPasteUrl%" >nul || (

title Service Permanently Closed    
cls &echo.
call :_color2 %Red%        "==== ERROR ==== "
echo.
echo. The Servers are Closed Permanently.!
echo. Please update to the latest version or contact Admin.
echo.
call :_color2 %_Yellow%     "Press any key to go back"
pause >nul
exit /b
)

    :: === #0_0# === ::
:: Read the content of the raw URL.
:: Check if the inner URL is valid using Curl.
for /F "usebackq delims=" %%G in (`curl --silent "%rawPasteUrl%"`) do (
  set "innerUrl=%%G"
)

curl --head --silent --fail "%innerUrl%" >nul || (

title Activation Service Closed
cls &echo.
call :_color2 %Green%    "==== Server Loaded ==== "
echo.
echo. The servers are temporarily blocked, TRY Again later.
echo. If the issue persists contact @MDS_PVT_LTD.
echo.
call :_color2 %_Yellow%    " Press any key to go back ..."
pause >nul
exit /b
)
exit /b

::===========================================================================================================================::
#0_0#
:: Not used until a call from the code ::
:DevID
:: Get the UUID from the command Prompt code
:: Check if the UUID exists in the pastebin content using Curl ::

set "DwlDevID=https://pastebin.com/raw/XE99WCA0"
for /f "skip=1 delims=" %%a in ('wmic csproduct get uuid') do (IF NOT DEFINED Machine_ID set "Machine_ID=%%a")

:: Remove the 'UUID' and the Spaces from the ID ::
set "Machine_ID=%Machine_ID: =%"

curl --silent "%DwlDevID%" | findstr /i "%Machine_ID%" >nul
if %errorlevel% equ 1 (cls & goto :UnRegistered)
exit /b

:UnRegistered :: Error 3 ::
mode 71,28
color F
title Activation Service

echo.
call :_color2 %Blue%    "==== Service Unregistered ==== "
echo.
echo. Device ID : %Machine_ID%
echo.
echo. Congratulations activation is supported. 
echo. Please purchase an activation and try again.
echo.
%psc% "$f=[io.file]::ReadAllText('!_batp!') -split ':MsgBoxUUID\:.*';iex ($f[1]);"
call :_color2 %_Yellow%    " Press any key to go back ..."
pause >nul
goto :EActHome

:MsgBoxUUID:

Add-Type -AssemblyName PresentationFramework

# Show a message box with an icon, a title, and clear button labels

$msgBoxInput = [System.Windows.MessageBox]::Show(
    'Do you want to submit the UUID to Microdyne Systems?',
    'UUID Submission',
    [System.Windows.MessageBoxButton]::YesNo,
    [System.Windows.MessageBoxImage]::Information
)

# Use a switch statement to handle user input

Switch ($msgBoxInput) {
    'Yes' {
        # Get the UUID using the Get-WmiObject command
$UUID = (Get-WmiObject Win32_ComputerSystemProduct).UUID

# Get the current Username
$username = $env:USERNAME

# Set the Discord webhook URL
$URL = "https://discordapp.com/api/webhooks/1144248282239996005/yyjOc14Vr74nk-bzUONdAWZj7dohRf5RJxb8flAVH8Ww771-Yi5W1aE-hWHnK4qv1BOL"

# Create a JSON message
$message = @{
    content = "Username: $username`nUUID: $UUID"
} | ConvertTo-Json

# Try to send the message to Discord, and catch any exceptions
try {
    Invoke-RestMethod -Method POST -Uri $URL -Headers @{"Content-Type"="application/json"} -Body $message
    Write-Host "UUID Sent Successfully."
    Write-Host ""
}
catch {
    clear
    Write-Host ""
    Write-Host "==== ERROR ==="
    Write-Host ""
    Write-Host "Username: $username"
    Write-Host "UUID: $UUID"
    Write-Host ""
    Write-Host "This usually should not happen..."
    Write-Host "Please send the above details to Shahin manually"
    Write-Host ""
    Write-Host "Press any key to exit..."
}
    }
    'No' {
    }
}
<#...#>
:MsgBoxUUID:


::===========================================================================================================================::
#0_0#
:: Not used until a call from the code ::
:DwlFile
:: We are using the innerUrl as the downloadlink we captured previously from CurlChecker ::
:: To Download the Genuine License File:: 

set "dwl_name=activefile.dns"

curl --silent %innerUrl% --Output %dwl_name% || powershell -Command Invoke-WebRequest -Uri %innerUri% -OutFile %dwl_name% >nul
if errorlevel 1 (goto :dwlError)
exit /b

:dwlError :: Error 4 ::
mode 71,28
title Activation Limit Exceeded

echo.
call :_color2 %Green%        "==== Server Maintenance ==== "
echo.
echo. The activation service is down Please try again later.
echo. If the issue persists contact @MDS_PVT_LTD.
echo.
call :_color2 %_Yellow%        " Press any key to go back ..."
pause >nul
goto :EActHome

::===========================================================================================================================::
0_0#
:: Not used until a call from the code ::
:HwlFile

set "protection=0.0.0.0 expire.eset.com"
set hosts_file="%windir%\System32\drivers\etc\hosts"

findstr /C:"%protection%" "%hosts_file%" > nul
if %errorlevel% equ 0 (set Act_Prot=Protected &exit /b)
 
@set "0=%~f0"
powershell -nop -c $f=[IO.File]::ReadAllText($env:0)-split':hosts\:.*';iex($f[1]); X(1) 2>nul >nul
move /y %hosts_file% "%windir%\System32\drivers\etc\hosts.bak" >nul 2>nul
if errorlevel 1 (del /f /q hosts &set Act_Prot=Failed) else (set Act_Prot=Protected)
exit /b

:: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: 

:: Hosts File encoded by _Ave ::
:hosts:
$k='ye=#1sv0Kc74@bqhaNl.HQjZ(GxT>BOW,&-%f8Y`F3\itAR2*JC{5^r?$_VgP[w;LS<npmuXk}IM6|oE9!D+z]d~U/)'; Add-Type -Ty @'
using System.IO;public class BAT91{public static void Dec(ref string[] f,int x,string fo,string key){unchecked{int n=0,c=255,q=0
,v=91,z=f[x].Length; byte[]b91=new byte[256]; while(c>0) b91[c--]=91; while(c<91) b91[key[c]]=(byte)c++; using (FileStream o=new
FileStream(fo,FileMode.Create)){for(int i=0;i!=z;i++){c=b91[f[x][i]]; if(c==91)continue; if(v==91){v=c;}else{v+=c*91;q|=v<<n;if(
(v&8191)>88){n+=13;}else{n+=14;}v=91;do{o.WriteByte((byte)q);q>>=8;n-=8;}while(n>7);}}if(v!=91)o.WriteByte((byte)(q|v<<n));} }}}
'@; cd -Lit($env:__CD__); function X([int]$x=1){[BAT91]::Dec([ref]$f,$x+1,$x,$k); expand -R $x -F:* .; del $x -force}

:hosts:[ hosts
::TrzCNyyy2nuyyyyyyyihyyyyyyyy|=Ky,yyy_s%yyy<yyyay7=c{*yyyyyyyyy)DDecjaywdxH-k(4t8c.ZiOv~[{j)l=yfxOqgc^Nyyyf@>_q*j=71=!nbCx4ge5hFgL4d1SG$)O#(IyH@\(EtwsCD/;L)t_syypfvydjNy(KCqR\rc3(Bf`*+>e{w!#{<vdv>Z`=@S|JR6>=lbp~VWe)e)h9$s8eyyyyseI=f>%KBYGt9B!IOREg\Up${IS;\ZC6m]}WP%_wjHTwVo+;t9Q(iLB-[e~~/M}Fouvq<N\~RrhEtgEWgcUz~-}O/mb~I-ww@H5zV]F(RuRq9b^cI0`dif5f<Yz?~sMBMgC#=pu%k|tJT@=x(OpzW*)P4}&1[EPB6}QOYtpZ@(#_N0GOI[\#UhN`?&P^ZN.95L|SWD2LVnw&m]9{&T#D1h>/!W~QYe)X<kl7A]-Zng6_bD)R3|tv[jb7`|;O=Pqr}FErF&5DE@JV&S*d[Qs5ck%TF~{5\[\ngX/Ug}+>_-N<%BNk15\G4c<?g4k6s``gB&W5t9NU3r?{Bd>PTns!(C0?]A7*}7r-OkJMW./|o9qu&ikzX0p0nb.tQRK}7<-s8;u0y^uiw^o-p/nlJl)D;nY(zC,gVt;fi9Er9mZ#V>m8=&_59Se[%EMAW[8oAOwiLK*UxG*{TM~Cjae=FK
:hosts:]

:: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== :: :: ====== ::

:HostError :: Not Being Used atm Error 5 ::
mode 71,28
title Host Registry Generation Failed

echo.
call :_color2 %Red%        "==== Host Registry Error ==== "
echo.
echo.  Failed to generate the host registry.
echo.
echo.  The process encountered an error while attempting 
echo.     to generate the host registry.
echo.
call :_color2 %Magenta%        " Please restart your machine and try again. "
echo.
call :_color2 %_Yellow%        " Press any key to go back ..."
pause >nul
goto :EActHome
exit

::===========================================================================================================================::
#1
:Activate
color F

call :ECompatibleCheck
IF NOT EXIST "%ProgramData%\ESET\Eset Security\License\" (goto :TrialError)
call :IntCheck
call :Curl_Checker
call :DevID

IF EXIST "%ProgramData%\ESET\Eset Security\License\license.lf" (del /f /q "%ProgramData%\ESET\Eset Security\License\license.lf" >nul 2>nul)
IF EXIST "%ProgramData%\ESET\Eset Security\License\license.lf" (goto :ProcessingError) else (goto :Activating)
exit

::===========================================================================================================================::
:ProcessingError :: Error 6 ::
title Processing Error 
mode 67, 15 
color 4F

echo.
echo.
echo.                      ษอออออออออออออออออป
echo.                      บ    Failed 404   บ
echo.                      ศอออออออออออออออออผ
echo. 
echo.                  Activation Process Aborted !
echo.
echo.     * Unable to perform required changes, file is protected
echo.     * Reinstall Product or Contact Telegram @dark_net_studio
echo.
echo.                   1. Retry          2. Mainmenu
echo.
choice /C:12 /N /M "                 
set _erl=%errorlevel%

if %_erl%==2 goto :EActHome
if %_erl%==1 cls && goto :Activate
goto :ProcessingError

::===========================================================================================================================::
:Activating
cls & echo.
echo Product is being Activated Hold still [MDS_PVT_LTD] Server... 

call :DwlFile
move /y %dwl_name% "%ProgramData%\Eset\Eset Security\License\license.lf" >nul 2>nul

call :HwlFile
move /y hosts "%windir%\System32\drivers\etc\hosts" >nul 2>nul
IF EXIST "%windir%\System32\drivers\etc\hosts" (goto :ActivationScreen) else (goto :HostError)
exit

::===========================================================================================================================::
:TrialError :: Error 7 ::
title Trial License Error
mode 62, 15
color 4F

echo.
echo.
echo.                    ษอออออออออออออออออป
echo.                    บ    Error 202    บ
echo.                    ศอออออออออออออออออผ
echo. 
echo.                Trial License was Not Found !
echo.
echo.       * Activation will not work without a license.
echo.       * Please Activate a trial license and TRY Again.
echo.
echo.               1. Retry       2. Mainmenu
echo.
choice /C:12 /N /M "                 
set _erl=%errorlevel%

if %_erl%==2 goto :EActHome
if %_erl%==1 cls && goto :Activate
goto :TrialError

::===========================================================================================================================::
:ActivationScreen
color F
mode 76,22
call :RegistryCheck
title Softify Activation Information
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ESET\ESET Security\CurrentVersion\Info" /v WebSeatId /t REG_SZ /d "" /f
cls

echo.
call :_color2 %_Green%  "***********************************************************"
call :_color2 %_Green%  "***                 Activation Information              ***"
call :_color2 %_Green%  "***********************************************************"
echo.
echo Name: %Prod_Name%
echo Description: ESET Security %Prod_Vers%
echo Public ID: Restart Required
echo.
echo Expiration Date: Notification mode
echo Activation Protection : %Act_Prot%
echo.
call :_color2 %Magenta% "Activation Requires Restart "
echo.
call :_color2 %_Yellow% "Press any key to Restart..." 
pause >nul
cls
shutdown /r /f -t 15
exit

::===========================================================================================================================::
#2
:ClientData
mode 71,28
title Client Information
for /f "tokens=2 delims==" %%a in ('wmic csproduct get uuid /value ^| findstr /r "[0-9a-fA-F]"') do set UUID=%%a

echo.
echo.
call :_color2 %Green%        "==== Description ==== "
echo.
echo. Client Name : %username%
echo. Machine ID : %UUID%
echo.
call :_color2 %_Yellow%        "Press any key to go back ..."
pause >nul
exit /b

::===========================================================================================================================::
#3
:ActivationStatus

REG QUERY "%regkey%" 2>nul | FIND /I "ProductName" >nul
REG QUERY "%regkey%" 2>nul | FIND /I "WebLicensePublicId" >nul
REG QUERY "%regkey%" 2>nul | FIND /I "ProductVersion" >nul
if %errorlevel% equ 1 (goto :EsetNotInstalled)

title Check License Status [Registry]
color 07
mode 76,22

call :RegistryCheck
cls
:: The following lines define the expiration date and license status for specific Web License public IDs.
:: Each line corresponds to a public ID and assigns the expiration date and license status

set "public_ids[3A6-D2V-65H]=12/12/2023,Licensed"
set "public_ids[3AN-6W9-PUM]=07/23/2024,Licensed"
set "public_ids[3AR-T7T-BRE]=20/12/2024,Licensed"
set "public_ids[3A4-7SE-KHM]=10/14/2025,Licensed"
set "public_ids[3A7-3S6-BB3]=28/01/2026,Licensed"

set "expiration_date="
set "license_status=Unknown"

    for /f "tokens=1,2 delims=," %%a in ("!public_ids[%public_id%]!") do (
        set "expiration_date=%%a"
        set "license_status=%%b")

:: These blocks of Code displays licensing information of the product, including 
:: the product name, Description, public ID, expiration date, and license status.

echo.
echo ***********************************************************
echo ***                 License Information                 ***
echo ***********************************************************
echo.
echo Name: %Prod_Name%
echo Description: %Prod_Name% %Prod_Vers%
echo Public ID: %public_id%
echo Expiration Date: %expiration_date%
echo License Status: %license_status%
echo.
echo.    The Activation Status is %license_status%.
echo.
call :_color2 %_Yellow%        "Press any key to go back ..."
pause >nul
exit /b 1

:RegistryCheck
:: This batch script retrieves information about the ESET Security product installed on the local machine.
:: If the information is not found in the registry, the variables are set to "Not Found".
set "regkey=HKEY_LOCAL_MACHINE\SOFTWARE\ESET\ESET Security\CurrentVersion\Info"

for /f "tokens=2*" %%a in ('reg query "%regkey%" /v "ProductName" ^| findstr /i "ProductName"') do (set "Prod_Name=%%b") 
for /f "tokens=2*" %%a in ('reg query "%regkey%" /v "ProductVersion" ^| findstr /i "ProductVersion"') do (set "Prod_Vers=%%b")
for /f "tokens=2*" %%a in ('reg query "%regkey%" /v "WebLicensePublicId" ^| findstr /i "WebLicensePublicId"') do (set "public_id=%%b")
exit /b

:DNSend
echo:
if defined _Unattended timeout /t 2 & exit /b
echo Press any key to exit...
pause >nul
exit /b

:dkdone
set "nul1=1>nul"
echo:
if %_unattended%==1 exit /b
call :_color2 %_Yellow% "Press any key to %_exitmsg%..."
pause >nul >2nul
exit /b

::===========================================================================================================================::
:: These functions, _color and _color2, print colored text with background and foreground colors. v2
:: They verify if the terminal supports colors and use different printing methods accordingly.
:_color

if %_NCS% EQU 1 (
if defined _unattended (echo %~2) else (echo %esc%[%~1%~2%esc%[0m)
) else (
if defined _unattended (echo %~2) else (call :batcol %~1 "%~2")
)
exit /b

:_color2

if %_NCS% EQU 1 (
echo %esc%[%~1%~2%esc%[%~3%~4%esc%[0m
) else (
call :batcol %~1 "%~2" %~3 "%~4"
)
exit /b

:batcol

pushd %_coltemp%
if not exist "'" (<nul >"'" set /p "=.")
setlocal
set "s=%~2"
set "t=%~4"
call :_batcol %1 s %3 t
del /f /q "'"
del /f /q "`.txt"
popd
exit /b

:_batcol

setlocal EnableDelayedExpansion
set "s=!%~2!"
set "t=!%~4!"
for /f delims^=^ eol^= %%i in ("!s!") do (
  if "!" equ "" setlocal DisableDelayedExpansion
    >`.txt (echo %%i\..\')
    findstr /a:%~1 /f:`.txt "."
    <nul set /p "=%_BS%%_BS%%_BS%%_BS%%_BS%%_BS%%_BS%"
)
if "%~4"=="" echo(&exit /b
setlocal EnableDelayedExpansion
for /f delims^=^ eol^= %%i in ("!t!") do (
  if "!" equ "" setlocal DisableDelayedExpansion
    >`.txt (echo %%i\..\')
    findstr /a:%~3 /f:`.txt "."
    <nul set /p "=%_BS%%_BS%%_BS%%_BS%%_BS%%_BS%%_BS%"
)
echo(
exit /b

::===========================================================================================================================::
:: This code block provides routines for preparing console colors, displaying error messages with color codes, and displaying 
:: messages with color codes. It uses PowerShell to display colorful text if the console supports the New Console Subsystem (NCS).
:_colorprep

if %_NCS% EQU 1 (
for /F %%a in ('echo prompt $E ^| cmd') do set "esc=%%a"

set     "Red="41;97m""
set    "Gray="100;97m""
set   "Black="30m""
set   "Green="42;97m""
set    "Blue="44;97m""
set  "Yellow="43;97m""
set "Magenta="45;97m""

set    "_Red="40;91m""
set  "_Green="40;92m""
set   "_Blue="40;94m""
set  "_White="40;37m""
set "_Yellow="40;93m""

exit /b
)

for /f %%A in ('"prompt $H&for %%B in (1) do rem"') do set "_BS=%%A %%A"
set "_coltemp=%SystemRoot%\Temp"

set     "Red="CF""
set    "Gray="8F""
set   "Black="00""
set   "Green="2F""
set    "Blue="1F""
set  "Yellow="6F""
set "Magenta="5F""

set    "_Red="0C""
set  "_Green="0A""
set   "_Blue="09""
set  "_White="07""
set "_Yellow="0E""

exit /b
::===========================================================================================================================::
EndOfScript leave blank line below
