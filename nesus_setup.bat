@echo off
echo ===============================================
echo  [*] CÀI ĐẶT TÀI KHOẢN & CẤU HÌNH HỆ THỐNG CHO NESSUS
echo ===============================================
echo.

:: Định nghĩa mật khẩu (CÓ THỂ HARD-CODED HOẶC NHẬP TỪ NGƯỜI DÙNG)
set PASSWORD=StrongPassword123!   :: Nếu muốn hardcode, chỉnh sửa giá trị tại đây.

:: Nếu mật khẩu chưa hardcoded, hỏi người dùng nhập vào
if "%PASSWORD%"=="ASK" (
    set /p PASSWORD=Nhập mật khẩu cho tài khoản Nessus: 
)

:: TẠO TÀI KHOẢN NESSUS
echo [*] Đang tạo tài khoản Nessus...
net user nessus_scan %PASSWORD% /add > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] Đã tạo tài khoản Nessus thành công.
) else (
    echo [!] Lỗi khi tạo tài khoản! Có thể tài khoản đã tồn tại.
)
echo.

:: THÊM TÀI KHOẢN VÀO NHÓM ADMINISTRATORS
echo [*] Đang thêm tài khoản vào nhóm Administrators...
net localgroup Administrators nessus_scan /add > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] Đã thêm tài khoản vào nhóm Administrators.
) else (
    echo [!] Tài khoản có thể đã nằm trong nhóm Administrators.
)
echo.

:: BẬT WINRM
echo [*] Đang bật Windows Remote Management (WinRM)...
winrm quickconfig -q > nul 2>&1
winrm set winrm/config/service @{AllowUnencrypted="true"} > nul 2>&1
winrm set winrm/config/service/auth @{Basic="true"} > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] WinRM đã được cấu hình thành công.
) else (
    echo [!] WinRM có thể đã được bật trước đó.
)
echo.

:: MỞ CỔNG 445 (SMB) TRONG FIREWALL
echo [*] Đang mở cổng 445 (SMB) trong firewall...
netsh advfirewall firewall add rule name="Nessus SMB" dir=in action=allow protocol=TCP localport=445 > nul 2>&1
if %ERRORLEVEL%==0 (
    echo [✓] Đã mở cổng 445 thành công.
) else (
    echo [!] Rule firewall có thể đã tồn tại.
)
echo.

:: KIỂM TRA LẠI TRẠNG THÁI CẤU HÌNH
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
echo  [✓] CẤU HÌNH HOÀN TẤT! HỆ THỐNG SẴN SÀNG CHO NESSUS SCAN.
echo ===============================================
pause
