@echo off
setlocal enabledelayedexpansion

rem �o�b�`���g�̃t�H���_���擾
set "SCRIPT_DIR=%~dp0"

if "%~1"=="" (
    echo �T�[�o�[�n�於���R�}���h�����Ŏw�肳��Ă��܂���
    pause
    exit /b
)

rem ��������l���擾
set "data_center_hint=%~1"
set "replace=DataCenterHint=%data_center_hint%"

rem config.ini����l���擾
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
    echo ���̓t�@�C���p�X��config.ini����擾�ł��܂���ł���
    pause
    exit /b
)

set "restart_result="
if "%restart%"=="1" (
    if "%r6s_exe%"=="" (
        echo "restart=1�ł����A�V�[�W�̎��s�t�@�C���p�X(r6s_exe)��config.ini����擾�ł��܂���ł���"
        pause
        exit /b
    )

    rem �v���Z�X�����擾�i�g���q�t���j
    for %%F in ("!r6s_exe!") do set "proc_name=%%~nxF"

    rem �v���Z�X�̑��݊m�F
    tasklist /FI "IMAGENAME eq !proc_name!" 2>NUL | find /I "!proc_name!" >NUL
    set restart_result=%ERRORLEVEL%
    if not "%restart_result%"=="1" (
        echo �A�v���P�[�V�������I�����܂�...
        taskkill /IM "!proc_name!"
        echo �A�v���P�[�V�������I�����܂���
    )
)

set "backup_file=%game_settings_ini%.bk"
set "output_file=%game_settings_ini%.tmp"

echo ������GameSettings.ini���o�b�N�A�b�v���܂�
copy /Y "%game_settings_ini%" "%backup_file%" >nul

rem ��s���܂߂đS�s����
(
    for /f "usebackq delims=" %%A in (`findstr /N "^" "%game_settings_ini%"`) do (
        set "line=%%A"
        set "line=!line:*:=!"
        rem DataCenterHint=�Ŏn�܂�s��u��
        if /i "!line:~0,15!"=="DataCenterHint=" (
            echo !replace!
        ) else (
            echo(!line!
        )
    )
) > "%output_file%"

rem ���t�@�C�����㏑��
move /Y "%output_file%" "%game_settings_ini%" >nul
echo GameSettings.ini��DataCenterHint��%data_center_hint%�ɕύX���܂���

rem �A�v���P�[�V�����N������
if "%restart%"=="1" (
    echo �A�v���P�[�V�������N�����Ă��܂�...
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
echo �S�Ă̏������������܂��� (���̃E�B���h�E��%close_interval%�b��Ɏ����ŕ��܂�)
timeout /t %close_interval% >nul
exit

endlocal