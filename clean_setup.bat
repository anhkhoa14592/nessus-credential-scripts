@echo off
echo ===============================================
echo  [*] BẮT ĐẦU QUÁ TRÌNH DỌN DẸP HỆ THỐNG
echo ===============================================
echo.

:: XÓA TÀI KHOẢN NESSUS
echo [*] Đang xóa tài khoản Nessus...
net localgroup Administrators nessus_scan /delete > nul 2>&1
net user nessus_scan /delete > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] Đã xóa tài khoản Nessus thành công.
) else (
    echo [!] Tài khoản Nessus có thể đã bị xóa trước đó.
)
echo.

:: TẮT & VÔ HIỆU HÓA WINRM
echo [*] Đang tắt dịch vụ WinRM...
winrm delete winrm/config/listener?Address=*+Transport=HTTP > nul 2>&1
sc config WinRM start= disabled > nul 2>&1
net stop WinRM > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] Dịch vụ WinRM đã bị vô hiệu hóa.
) else (
    echo [!] WinRM có thể đã bị tắt trước đó.
)
echo.

:: KHÔI PHỤC CÀI ĐẶT BẢO MẬT CỦA WINRM
echo [*] Khôi phục cài đặt bảo mật WinRM...
winrm set winrm/config/service/auth @{Basic="false"} > nul 2>&1
winrm set winrm/config/service @{AllowUnencrypted="false"} > nul 2>&1
echo [✓] Cấu hình bảo mật WinRM đã được khôi phục.
echo.

:: XÓA RULE FIREWALL CHO SMB
echo [*] Xóa rule firewall "Nessus SMB"...
netsh advfirewall firewall delete rule name="Nessus SMB" > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] Đã xóa rule firewall thành công.
) else (
    echo [!] Rule có thể đã bị xóa trước đó.
)
echo.

:: KIỂM TRA LẠI TRẠNG THÁI HỆ THỐNG
echo ===============================================
echo  [*] KIỂM TRA LẠI TRẠNG THÁI HỆ THỐNG
echo ===============================================

echo.
echo [*] Danh sách tài khoản người dùng:
net user
echo.

echo [*] Trạng thái dịch vụ WinRM:
sc query WinRM | findstr "STATE"
echo.

echo [*] Kiểm tra rule firewall "Nessus SMB":
netsh advfirewall firewall show rule name="Nessus SMB"
echo.

echo ===============================================
echo  [✓] QUÁ TRÌNH DỌN DẸP HOÀN TẤT
echo ===============================================
echo Hệ thống đã được khôi phục về trạng thái ban đầu.
pause
