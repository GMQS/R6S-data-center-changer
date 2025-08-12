@echo off
rem サーバー値を変更する場合はここを書き換えてください
set "DATACENTER=playfab/southeastasia"

call "%~dp0change_datacenter.bat" "%DATACENTER%"
