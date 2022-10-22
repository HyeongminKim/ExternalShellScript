@ECHO OFF
title BootCamp Recover
chcp 1252 > NUL

set driverExist="false"

if NOT exist "%TEMP%\BootCamp_Driver" (
    if NOT "%SAFEBOOT_OPTION%" == "" (
        echo Unable to find BootCamp Dirver. Please enter normal mode and download BootCamp drivers...
        timeout 2 > NUL
        exit /b 1
    )

    brigadier --help > NUL
    if NOT "%ERRORLEVEL%" == "0" (
        echo error: Unable to launch brigadier. Please install brigadier to continue.
        explorer https://github.com/timsutton/brigadier
        timeout 2 > NUL
        exit /b 1
    )

    if NOT exist "C:\Program Files\7-Zip\7z.exe" (
        echo error: 7-Zip not found. Please install 7-Zip to continue.
        explorer https://7-zip.org
        timeout 2 > NUL
        exit /b 1
    )

    if "%COMPUTER_MODEL_ID%" == "" (
        echo Please set Mac model in COMPUTER_MODEL_ID.
        echo For example COMPUTER_MODEL_ID=iMac3,1
        explorer https://support.apple.com/en-us/HT201634
        timeout 2 > NUL
        exit /b 1
    )

    mkdir %TEMP%\BootCamp_Driver
    brigadier -m %COMPUTER_MODEL_ID% -o %TEMP%\BootCamp_Driver
    if "%ERRORLEVEL%" == "0" (
        for /F %%i in ('dir /b /a "%TEMP%\BootCamp_Driver\*"') do (
            goto driverExist
        )

        echo Unable to save driver. Please check permission in %TEMP%\BootCamp_Driver.
        rmdir /s /q %TEMP%\BootCamp_Driver > NUL
        if NOT "%ERRORLEVEL%" == "0" (
            echo Unable to delete downloaded driver directory. Please delete it manually.
            explorer %TEMP%\BootCamp_Driver
        )
        timeout 2 > NUL
        exit /b 1

        :driverExist
        echo Please set boot options to safe mode "Minimal" and enter safe mode.
        msconfig
        pause
        exit
    ) else (
        echo Unable to launch brigadier. The brigadier exit code is %ERRORLEVEL%.
        explorer https://github.com/timsutton/brigadier/issues
        if exist "%TEMP%\BootCamp_Driver" (
            rmdir /s /q %TEMP%\BootCamp_Driver > NUL
            if NOT "%ERRORLEVEL%" == "0" (
                echo Unable to delete empty driver directory. Please delete it manually.
                explorer %TEMP%\BootCamp_Driver
            )
        )
        timeout 2 > NUL
        exit /b 1
    )
) else (
    if NOT "%SAFEBOOT_OPTION%" == "MINIMAL" (
        echo BootCamp driver already exist. Please enter safe mode to upgrade drivers...
        timeout 2 > NUL
        exit /b 1
    )

    echo Please remove corrupted drivers completely
    echo NOTE: Please check "Delete the driver software for this device." either.
    echo.
    echo Install use "Browse my computer for drivers" and choose %TEMP%\BootCamp_Driver directory.
    echo NOTE: Please check "Include subfolders" option.
    explorer %TEMP%\BootCamp_Driver
    devmgmt.msc
    pause

    rmdir /s /q %TEMP%\BootCamp_Driver > NUL
    if NOT "%ERRORLEVEL%" == "0" (
        echo Unable to delete downloaded driver directory. Please delete it manually.
        explorer %TEMP%\BootCamp_Driver
        timeout 2 > NUL
        exit /b 1
    ) else (
        echo Please uncheck safe boot options.
        msconfig
        exit
    )
)

