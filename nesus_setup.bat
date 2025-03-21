@echo off
echo ===============================================
echo  [*] SETTING UP CREDENTIALS & SYSTEM CONFIGURATION FOR NESSUS SCAN
echo ===============================================
echo.

:: Define password (CAN BE HARD-CODED OR USER-INPUT)
set PASSWORD=StrongPassword123!   :: Change this if you want to hardcode the password.

:: If password is not hardcoded, prompt the user
if "%PASSWORD%"=="ASK" (
    set /p PASSWORD=Enter password for Nessus account: 
)

:: CREATE NESSUS ACCOUNT
echo [*] Creating Nessus account...
net user nessus_scan %PASSWORD% /add > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] Nessus account created successfully.
) else (
    echo [!] Error creating account! It may already exist.
)
echo.

:: ADD ACCOUNT TO ADMINISTRATORS GROUP
echo [*] Adding account to Administrators group...
net localgroup Administrators nessus_scan /add > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] Account added to Administrators group.
) else (
    echo [!] Account may already be in Administrators group.
)
echo.

:: ENABLE WINRM
echo [*] Enabling Windows Remote Management (WinRM)...
winrm quickconfig -q > nul 2>&1
winrm set winrm/config/service @{AllowUnencrypted="true"} > nul 2>&1
winrm set winrm/config/service/auth @{Basic="true"} > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] WinRM configured successfully.
) else (
    echo [!] WinRM may have been enabled previously.
)
echo.

:: ALLOW SMB (PORT 445) THROUGH FIREWALL
echo [*] Allowing SMB (port 445) through firewall...
netsh advfirewall firewall add rule name="Nessus SMB" dir=in action=allow protocol=TCP localport=445 > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] SMB port 445 opened successfully.
) else (
    echo [!] Firewall rule may already exist.
)
echo.

:: VERIFY CONFIGURATION STATUS
echo ===============================================
echo  [*] VERIFYING SYSTEM CONFIGURATION
echo ===============================================

echo.
echo [*] Listing user accounts:
net user
echo.

echo [*] Checking WinRM service status:
sc query WinRM | findstr "STATE"
echo.

echo [*] Checking firewall rule for Nessus SMB:
netsh advfirewall firewall show rule name="Nessus SMB"
echo.

echo ===============================================
echo  [✓] SETUP COMPLETE! SYSTEM IS READY FOR NESSUS SCAN.
echo ===============================================
pause
