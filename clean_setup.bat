@echo off
echo ===============================================
echo  [*] RESTORING SYSTEM CONFIGURATION TO DEFAULT
echo ===============================================
echo.

:: REMOVE ACCOUNT FROM ADMINISTRATORS GROUP
echo [*] Removing Nessus account from Administrators group (if exists)...
net localgroup Administrators nessus_scan /delete > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [*] Nessus account removed from Administrators group.
) else (
    echo [!] Nessus account was not in Administrators group.
)
echo.

:: REMOVE NESSUS ACCOUNT
echo [*] Deleting Nessus account...
net user nessus_scan /delete > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [*] Nessus account deleted successfully.
) else (
    echo [!] Nessus account may not exist.
)
echo.

:: DISABLE AND STOP WINRM SERVICE
echo [*] Disabling and stopping WinRM service...
winrm delete winrm/config/listener?Address=*+Transport=HTTP > nul 2>&1
sc config WinRM start= disabled > nul 2>&1
net stop WinRM > nul 2>&1
winrm set winrm/config/service/auth @{Basic="false"} > nul 2>&1
winrm set winrm/config/service @{AllowUnencrypted="false"} > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [*] WinRM disabled successfully.
) else (
    echo [!] WinRM may already be disabled.
)
echo.

:: REMOVE SMB FIREWALL RULE
echo [*] Removing firewall rule for Nessus SMB...
netsh advfirewall firewall delete rule name="Nessus SMB" > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [*] Firewall rule removed successfully.
) else (
    echo [!] Firewall rule may not exist.
)
echo.

:: VERIFY SYSTEM STATUS AFTER CLEANUP
echo ===============================================
echo  [*] VERIFYING SYSTEM AFTER CLEANUP
echo ===============================================

echo.
echo [*] Listing remaining user accounts:
net user
echo.

echo [*] Checking WinRM service status:
sc query WinRM | findstr "STATE"
echo.

echo [*] Checking if Nessus SMB firewall rule still exists:
netsh advfirewall firewall show rule name="Nessus SMB"
echo.

echo ===============================================
echo  [*] SYSTEM RESTORED TO DEFAULT SETTINGS.
echo ===============================================
pause
