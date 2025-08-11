@echo off
setlocal enabledelayedexpansion

rem バッチ自身のフォルダを取得
set "SCRIPT_DIR=%~dp0"

rem config.iniからinput_fileの値を取得
set "input_file="
for /f "usebackq tokens=1,2 delims==" %%A in ("%SCRIPT_DIR%config.ini") do (
    if /i "%%A"=="input_file" set "input_file=%%B"
)
if not defined input_file (
    echo 入力ファイルパスがconfig.iniから取得できませんでした
    pause
    exit /b
)

set "backup_file=%input_file%.bk"
set "output_file=%input_file%.tmp"
set "replace=DataCenterHint=playfab/japaneast"

rem バックアップ作成
copy /Y "%input_file%" "%backup_file%" >nul

rem 空行も含めて全行処理
(
    for /f "usebackq delims=" %%A in (`findstr /N "^" "%input_file%"`) do (
        set "line=%%A"
        set "line=!line:*:=!"
        rem DataCenterHint=で始まる行を置換
        if /i "!line:~0,15!"=="DataCenterHint=" (
            echo !replace!
        ) else (
            echo(!line!
        )
    )
) > "%output_file%"

rem 元ファイルを上書き
move /Y "%output_file%" "%input_file%" >nul

echo 完了しました。
pause
endlocal