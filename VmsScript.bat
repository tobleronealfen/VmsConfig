@Echo Off
setlocal EnableDelayedExpansion
chcp 65001 > NUL

:: Sæt standardfarve til grøn skrift
color 0A

:: Definer stien til logfilen i script-mappen
set "LOG_NAME=VmsConfig_%date:~-4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log"
set "LOG_NAME=%LOG_NAME: =0%"
set "LOGFILE=%~dp0!LOG_NAME!"

Title VMS server/klient konfiguration v1.0

:: 1. TJEK ADMINISTRATOR
Reg.exe query "HKU\S-1-5-19\Environment" > NUL 2>&1
If Not %ERRORLEVEL% EQU 0 (
    color 4F
    cls
    echo.
    echo =======================================================
    echo FEJL: SCRIPTET SKAL KØRES SOM ADMINISTRATOR
    echo =======================================================
    echo.
    pause
    exit
)

cd /d "%~dp0"

:: 2. DISCLAIMER
cls
echo =======================================================
echo          VMS server/klient konfiguration v1.0
echo =======================================================
echo Vær sikker på at du er klar over hvordan du bruger
echo dette script.
echo Læs mere på: kousholt.org/vms-script
echo.
echo    Jan Kousholt - jkousholt@gmail.com - 2025
echo =======================================================
echo.
echo Tryk på en vilkårlig tast for at acceptere og fortsætte...
pause > NUL

:: 3. BRUGER INPUT
cls
echo =======================================================
echo               VMS/klient opsætning
echo =======================================================
echo.

set "DoAutoLogin=N"
set /p "DoAutoLogin=1. Vil du aktivere Automatisk Login? (J/N): "
if /i "!DoAutoLogin!"=="J" (
    set /p "LogUser=   - Indtast Windows brugernavn: "
    set /p "LogPass=   - Indtast Windows password: "
)

echo.
set "DoPower=N"
set /p "DoPower=2. Vil du deaktivere Screensaver og Dvale? (J/N): "
echo.
set "DoUpdate=N"
set /p "DoUpdate=3. Vil du deaktivere Automatisk Windows Update? (J/N): "
echo.
set "DoPerf=N"
set /p "DoPerf=4. Vil du aktivere 'Høj Ydeevne' (HW + Visuelt)? (J/N): "
echo.
set "DoNTPServer=N"
set /p "DoNTPServer=5. Vil du gøre denne PC til NTP Server? (J/N): "
echo.
set "DoNTPClient=N"
set /p "DoNTPClient=6. Vil du synkronisere mod en NTP-adresse? (J/N): "
if /i "!DoNTPClient!"=="J" (
    set /p "NTPAddr=   - Indtast NTP adresse: "
)
echo.
set "DoSC=N"
set /p "DoSC=7. Vil du oprette autostart til Milestone Smart Client? (J/N): "
echo.
set "DoIndex=N"
set /p "DoIndex=8. Vil du deaktivere indeksering på en sti? (J/N): "
if /i "!DoIndex!"=="J" (
    set /p "IndexPath=   - Indtast sti (f.eks. D:\): "
)

echo.
set "DoWallpaper=N"
set "BG_FILE="
if exist "background.png" (set "BG_FILE=background.png") else if exist "background.jpg" (set "BG_FILE=background.jpg")
if defined BG_FILE set /p "DoWallpaper=9. Vil du sætte '!BG_FILE!' som baggrund? (J/N): "

:: 4. OVERSIGT
cls
echo =======================================================
echo               VALGTE KONFIGURATIONER
echo =======================================================
echo.
set "HasSelection=N"
if /i "!DoAutoLogin!"=="J" (echo [+] Aktiver Autologin & set "HasSelection=Y")
if /i "!DoPower!"=="J"     (echo [+] Deaktiver Screensaver/Dvale & set "HasSelection=Y")
if /i "!DoUpdate!"=="J"    (echo [+] Deaktiver Auto Update & set "HasSelection=Y")
if /i "!DoPerf!"=="J"      (echo [+] Sæt Ydeevne & set "HasSelection=Y")
if /i "!DoNTPServer!"=="J" (echo [+] Aktiver NTP Server & set "HasSelection=Y")
if /i "!DoNTPClient!"=="J" (echo [+] Synkroniser mod: !NTPAddr! & set "HasSelection=Y")
if /i "!DoSC!"=="J"        (echo [+] Autostart Smart Client & set "HasSelection=Y")
if /i "!DoIndex!"=="J"     (echo [+] Deaktiver indeksering: !IndexPath! & set "HasSelection=Y")
if /i "!DoWallpaper!"=="J" (echo [+] Skift baggrundsbillede & set "HasSelection=Y")

if "!HasSelection!"=="N" (
    echo [!] Ingen ændringer valgt.
    pause & exit
)

echo.
set "Confirm=N"
set /p "Confirm=Iværksæt ændringer? (J/N): "
if /i "!Confirm!" NEQ "J" exit

:: 5. START LOGFIL
cls
echo Arbejder...

(
echo =======================================================
echo VMS SERVER/KLIENT KONFIGURATION - LOG
echo =======================================================
echo Dato: !date! !time!
echo Computer: %COMPUTERNAME%
echo Bruger: %USERNAME%
echo Script version: 1.0
echo =======================================================
echo.
) > "%LOGFILE%"

:: 6. LOG ALLE VALG (inkl. fravalgte)
call :LOG "--- VALGTE KONFIGURATIONER ---"
call :LOG ""

if /i "!DoAutoLogin!"=="J" (
    call :LOG "[1] Automatisk Login: AKTIVERET"
    call :LOG "    Brugernavn: !LogUser!"
    call :LOG "    Password: ****** (gemt i registry)"
) else (
    call :LOG "[1] Automatisk Login: FRAVALGT"
)

if /i "!DoPower!"=="J" (
    call :LOG "[2] Screensaver/Dvale: DEAKTIVERET"
) else (
    call :LOG "[2] Screensaver/Dvale: FRAVALGT"
)

if /i "!DoUpdate!"=="J" (
    call :LOG "[3] Windows Update: DEAKTIVERET"
) else (
    call :LOG "[3] Windows Update: FRAVALGT"
)

if /i "!DoPerf!"=="J" (
    call :LOG "[4] Høj Ydeevne: AKTIVERET"
) else (
    call :LOG "[4] Høj Ydeevne: FRAVALGT"
)

if /i "!DoNTPServer!"=="J" (
    call :LOG "[5] NTP Server: AKTIVERET"
) else (
    call :LOG "[5] NTP Server: FRAVALGT"
)

if /i "!DoNTPClient!"=="J" (
    call :LOG "[6] NTP Synkronisering: AKTIVERET"
    call :LOG "    NTP Adresse: !NTPAddr!"
) else (
    call :LOG "[6] NTP Synkronisering: FRAVALGT"
)

if /i "!DoSC!"=="J" (
    call :LOG "[7] Smart Client Autostart: AKTIVERET"
) else (
    call :LOG "[7] Smart Client Autostart: FRAVALGT"
)

if /i "!DoIndex!"=="J" (
    call :LOG "[8] Deaktiver Indeksering: AKTIVERET"
    call :LOG "    Sti: !IndexPath!"
) else (
    call :LOG "[8] Deaktiver Indeksering: FRAVALGT"
)

if /i "!DoWallpaper!"=="J" (
    call :LOG "[9] Baggrundsbillede: AKTIVERET"
    call :LOG "    Fil: !BG_FILE!"
) else (
    call :LOG "[9] Baggrundsbillede: FRAVALGT"
)

call :LOG ""
call :LOG "--- EKSEKVERING STARTET ---"
call :LOG ""

:: 7. EKSEKVERING MED LOGGING
set "HAD_ERROR=N"

:: PUNKT 1 - AUTOLOGIN
if /i "!DoAutoLogin!"=="J" (
    call :LOG "[1] Konfigurerer Autologin..."
    Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t REG_SZ /d "1" /f >NUL 2>&1
    if !ERRORLEVEL! EQU 0 (
        Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /t REG_SZ /d "!LogUser!" /f >NUL 2>&1
        Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /t REG_SZ /d "!LogPass!" /f >NUL 2>&1
        call :LOG "    [OK] Autologin aktiveret"
    ) else (
        call :LOG "    [FEJL] Kunne ikke aktivere Autologin"
        set "HAD_ERROR=Y"
    )
)

:: PUNKT 2 - POWER
if /i "!DoPower!"=="J" (
    call :LOG "[2] Deaktiverer Screensaver og Dvale..."
    powercfg /change monitor-timeout-ac 0 >NUL 2>&1
    powercfg /change monitor-timeout-dc 0 >NUL 2>&1
    powercfg /change standby-timeout-ac 0 >NUL 2>&1
    powercfg /change standby-timeout-dc 0 >NUL 2>&1
    powercfg /change hibernate-timeout-ac 0 >NUL 2>&1
    powercfg /change hibernate-timeout-dc 0 >NUL 2>&1
    Reg.exe add "HKCU\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d 0 /f >NUL 2>&1
    if !ERRORLEVEL! EQU 0 (
        call :LOG "    [OK] Screensaver og Dvale deaktiveret"
    ) else (
        call :LOG "    [FEJL] Kunne ikke deaktivere alle indstillinger"
        set "HAD_ERROR=Y"
    )
)

:: PUNKT 3 - WINDOWS UPDATE
if /i "!DoUpdate!"=="J" (
    call :LOG "[3] Deaktiverer Windows Update..."
    Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f >NUL 2>&1
    if !ERRORLEVEL! EQU 0 (
        call :LOG "    [OK] Windows Update deaktiveret"
    ) else (
        call :LOG "    [FEJL] Kunne ikke deaktivere Windows Update"
        set "HAD_ERROR=Y"
    )
)

:: PUNKT 4 - PERFORMANCE
if /i "!DoPerf!"=="J" (
    call :LOG "[4] Aktiverer Høj Ydeevne..."
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >NUL 2>&1
    Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >NUL 2>&1
    if !ERRORLEVEL! EQU 0 (
        call :LOG "    [OK] Høj Ydeevne aktiveret"
    ) else (
        call :LOG "    [FEJL] Kunne ikke aktivere Høj Ydeevne"
        set "HAD_ERROR=Y"
    )
)

:: PUNKT 5 - NTP SERVER
if /i "!DoNTPServer!"=="J" (
    call :LOG "[5] Aktiverer NTP Server..."
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer" /v Enabled /t REG_DWORD /d 1 /f >NUL 2>&1
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v AnnounceFlags /t REG_DWORD /d 5 /f >NUL 2>&1
    net stop w32time >NUL 2>&1
    net start w32time >NUL 2>&1
    if !ERRORLEVEL! EQU 0 (
        call :LOG "    [OK] NTP Server aktiveret"
    ) else (
        call :LOG "    [ADVARSEL] NTP Server aktiveret, men tjenestegenstart fejlede"
    )
)

:: PUNKT 6 - NTP CLIENT
if /i "!DoNTPClient!"=="J" (
    call :LOG "[6] Synkroniserer mod NTP: !NTPAddr!"
    w32tm /config /manualpeerlist:"!NTPAddr!" /syncfromflags:manual /reliable:YES /update >NUL 2>&1
    net stop w32time >NUL 2>&1
    net start w32time >NUL 2>&1
    w32tm /resync >NUL 2>&1
    if !ERRORLEVEL! EQU 0 (
        call :LOG "    [OK] NTP synkronisering konfigureret"
    ) else (
        call :LOG "    [ADVARSEL] NTP konfigureret, men synkronisering fejlede"
    )
)

:: PUNKT 7 - SMART CLIENT
if /i "!DoSC!"=="J" (
    call :LOG "[7] Opretter Smart Client autostart..."
    set "SC_PATH=C:\Program Files\Milestone\XProtect Smart Client\Client.exe"
    if exist "!SC_PATH!" (
        Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "MilestoneSmartClient" /t REG_SZ /d "\"!SC_PATH!\"" /f >NUL 2>&1
        if !ERRORLEVEL! EQU 0 (
            call :LOG "    [OK] Smart Client autostart oprettet"
        ) else (
            call :LOG "    [FEJL] Kunne ikke oprette autostart"
            set "HAD_ERROR=Y"
        )
    ) else (
        call :LOG "    [FEJL] Smart Client ikke fundet: !SC_PATH!"
        set "HAD_ERROR=Y"
    )
)

:: PUNKT 8 - INDEKSERING
if /i "!DoIndex!"=="J" (
    call :LOG "[8] Deaktiverer indeksering: !IndexPath!"
    if exist "!IndexPath!" (
        powershell -NoProfile -Command "$ErrorActionPreference='Stop'; try { $f = Get-Item '!IndexPath!'; $f.Attributes = $f.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed; exit 0 } catch { exit 1 }" >NUL 2>&1
        if !ERRORLEVEL! EQU 0 (
            call :LOG "    [OK] Indeksering deaktiveret"
        ) else (
            call :LOG "    [FEJL] Kunne ikke deaktivere indeksering (PowerShell fejl)"
            set "HAD_ERROR=Y"
        )
    ) else (
        call :LOG "    [FEJL] Stien findes ikke: !IndexPath!"
        set "HAD_ERROR=Y"
    )
)

:: PUNKT 9 - BAGGRUNDSBILLEDE
if /i "!DoWallpaper!"=="J" (
    call :LOG "[9] Sætter baggrundsbillede: !BG_FILE!"
    if exist "!BG_FILE!" (
        set "FULL_BG_PATH=%~dp0!BG_FILE!"
        Reg.exe add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "!FULL_BG_PATH!" /f >NUL 2>&1
        RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters >NUL 2>&1
        if !ERRORLEVEL! EQU 0 (
            call :LOG "    [OK] Baggrundsbillede sat"
        ) else (
            call :LOG "    [FEJL] Kunne ikke sætte baggrundsbillede"
            set "HAD_ERROR=Y"
        )
    ) else (
        call :LOG "    [FEJL] Billedfil ikke fundet: !BG_FILE!"
        set "HAD_ERROR=Y"
    )
)

:: 8. AFSLUT LOG
call :LOG ""
call :LOG "--- EKSEKVERING AFSLUTTET ---"
call :LOG ""
if "!HAD_ERROR!"=="Y" (
    call :LOG "RESULTAT: AFSLUTTET MED FEJL"
) else (
    call :LOG "RESULTAT: ALLE ÆNDRINGER UDFØRT KORREKT"
)
call :LOG ""
call :LOG "=======================================================

"

:: 9. VIS RESULTAT
cls
echo.
echo =======================================================
echo                  PROCES FÆRDIG
echo =======================================================
echo.
if "!HAD_ERROR!"=="Y" (
    color 4E
    echo [!] DER OPSTOD EN ELLER FLERE FEJL UNDER KØRSLEN.
    echo.
) else (
    color 0A
    echo [+] Alle ændringer blev udført korrekt.
    echo.
)
echo Logfil gemt i script-mappen:
echo %LOGFILE%
echo.
pause
exit

:: FUNKTION TIL LOGGING
:LOG
if "%~1"=="" (
    echo. >> "%LOGFILE%"
) else (
    echo %~1 >> "%LOGFILE%"
)
exit /b