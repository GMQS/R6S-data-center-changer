@echo off
setlocal enabledelayedexpansion

rem バッチ自身のフォルダを取得
set "SCRIPT_DIR=%~dp0"

if "%~1"=="" (
    echo サーバー地域名がコマンド引数で指定されていません
    pause
    exit /b
)

rem 引数から値を取得
set "data_center_hint=%~1"
set "replace=DataCenterHint=%data_center_hint%"

rem config.iniから値を取得
set "game_settings_ini="
set "r6s_exe="
set "steam_r6s_link="
set "restart="

for /f "usebackq tokens=1,2 delims==" %%A in ("%SCRIPT_DIR%config.ini") do (
    if /i "%%A"=="game_settings_ini" set "game_settings_ini=%%B"
    if /i "%%A"=="r6s_exe"           set "r6s_exe=%%B"
    if /i "%%A"=="steam_r6s_link"    set "steam_r6s_link=%%B"
    if /i "%%A"=="restart"           set "restart=%%B"
)
if "%game_settings_ini%"=="" (
    echo 入力ファイルパスがconfig.iniから取得できませんでした
    pause
    exit /b
)

set "restart_result="
if "%restart%"=="1" (
    if "%r6s_exe%"=="" (
        echo "restart=1ですが、シージの実行ファイルパス(r6s_exe)がconfig.iniから取得できませんでした"
        pause
        exit /b
    )

    rem プロセス名を取得（拡張子付き）
    for %%F in ("!r6s_exe!") do set "proc_name=%%~nxF"

    rem プロセスの存在確認
    tasklist /FI "IMAGENAME eq !proc_name!" 2>NUL | find /I "!proc_name!" >NUL
    set restart_result=%ERRORLEVEL%
    if not "%restart_result%"=="1" (
        echo アプリケーションを終了します...
        taskkill /IM "!proc_name!"
        echo アプリケーションを終了しました
    )
)

set "backup_file=%game_settings_ini%.bk"
set "output_file=%game_settings_ini%.tmp"

echo 既存のGameSettings.iniをバックアップします
copy /Y "%game_settings_ini%" "%backup_file%" >nul

rem 空行も含めて全行処理
(
    for /f "usebackq delims=" %%A in (`findstr /N "^" "%game_settings_ini%"`) do (
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
move /Y "%output_file%" "%game_settings_ini%" >nul
echo GameSettings.iniのDataCenterHintを%data_center_hint%に変更しました

rem アプリケーション起動処理
if "%restart%"=="1" (
    echo アプリケーションを起動しています...
    if "%steam_r6s_link%"=="" (
        if not "%restart_result%"=="1" (
            
            timeout /t 30 >nul
        )
        start "" "%r6s_exe%"
    ) else (
	    if not "%restart_result%"=="1" (
            timeout /t 10 >nul
        )
        start "" "%steam_r6s_link%"
    )
)

set "close_interval=10"
echo 全ての処理が完了しました (このウィンドウは%close_interval%秒後に自動で閉じます)
timeout /t %close_interval% >nul
exit

endlocal