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
set "input_file="
set "r6s_exe="
set "restart="
for /f "usebackq tokens=1,2 delims==" %%A in ("%SCRIPT_DIR%config.ini") do (
    if /i "%%A"=="input_file" set "input_file=%%B"
    if /i "%%A"=="r6s_exe"    set "r6s_exe=%%B"
    if /i "%%A"=="restart"    set "restart=%%B"
)
if not defined input_file (
    echo ���̓t�@�C���p�X��config.ini����擾�ł��܂���ł���
    pause
    exit /b
)
if "%restart%"=="1" (
    if not defined r6s_exe (
        echo "restart=1�ł����A�V�[�W�̎��s�t�@�C���p�X(r6s_exe)��config.ini����擾�ł��܂���ł���"
        pause
        exit /b
    )

    rem �v���Z�X�����擾�i�g���q�t���j
    for %%F in ("!r6s_exe!") do set "proc_name=%%~nxF"

    rem �v���Z�X�̑��݊m�F
    tasklist /FI "IMAGENAME eq !proc_name!" 2>NUL | find /I "!proc_name!" >NUL
    if errorlevel 1 (
        rem �v���Z�X�����݂��Ȃ����ߏI�����Ȃ�
    ) else (
        echo �A�v���P�[�V�������I�����܂�...
        taskkill /IM "!proc_name!"
        echo �A�v���P�[�V�������I�����܂���
    )
)

set "backup_file=%input_file%.bk"
set "output_file=%input_file%.tmp"

echo ������GameSettings.ini���o�b�N�A�b�v���܂�
copy /Y "%input_file%" "%backup_file%" >nul

rem ��s���܂߂đS�s����
(
    for /f "usebackq delims=" %%A in (`findstr /N "^" "%input_file%"`) do (
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
move /Y "%output_file%" "%input_file%" >nul
echo GameSettings.ini��DataCenterHint��%data_center_hint%�ɕύX���܂���

rem �A�v���P�[�V�����N������
if "%restart%"=="1" (
    if defined r6s_exe (
        echo �A�v���P�[�V�������N�����Ă��܂�...
        timeout /t 7 >nul
        start "" "%r6s_exe%"
    )
)

set "close_interval=10"
echo �S�Ă̏������������܂��� (���̃E�B���h�E��%close_interval%�b��Ɏ����ŕ��܂�)
timeout /t %close_interval% >nul
exit

endlocal