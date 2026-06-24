@echo off
echo Dang khoi dong IIS Express cho du an HIS...
echo Mo trinh duyet tai: http://localhost:53559/
"C:\Program Files\IIS Express\iisexpress.exe" /path:"%~dp0HIS" /port:53559
