@echo off
setlocal enabledelayedexpansion

rem �o�b�`���g�̃t�H���_���擾
set "SCRIPT_DIR=%~dp0"

rem config.ini����input_file�̒l���擾
set "input_file="
for /f "usebackq tokens=1,2 delims==" %%A in ("%SCRIPT_DIR%config.ini") do (
    if /i "%%A"=="input_file" set "input_file=%%B"
)
if not defined input_file (
    echo ���̓t�@�C���p�X��config.ini����擾�ł��܂���ł���
    pause
    exit /b
)

set "backup_file=%input_file%.bk"
set "output_file=%input_file%.tmp"
set "replace=DataCenterHint=playfab/japaneast"

rem �o�b�N�A�b�v�쐬
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

echo �������܂����B
pause
endlocal