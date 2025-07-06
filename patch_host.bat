@echo off
echo.

net session >nul 2>&1 || (echo Please launch again as Admin & pause >nul & exit /b 1)

setlocal EnableDelayedExpansion
echo --- Patching Host ---

:: ===== SETTINGS =====
set "hostspath=%SystemRoot%\System32\drivers\etc\hosts"

:: ===== PARSE ARGUMENTS =====
set "undo="
set "count=0"
for %%A in (%*) do (
    if /i "%%~A"=="/undo" (
        set "undo=1"
    ) else (
        set /a count+=1
        set "site!count!=%%~A"
    )
)

if %count%==0 (
    echo [ERROR] Usage : %~nx0 <site1> [site2 ...] [/undo]
    echo Example       : %~nx0 www.google.com
    echo               : %~nx0 www.google.com www.yahoo.com /undo
    exit /b 1
)

if defined undo (
    rem === REMOVE mappings for every requested domain, whatever the IP ===
    >"%hostspath%.tmp" (
        for /f "usebackq tokens=* delims=" %%L in ("%hostspath%") do (
            set "line=%%L"
            set "keep=true"
            rem Tokenize: %%A = first token (IP or #), %%B = domain (if any)
            for /f "tokens=1,2* delims= " %%A in ("%%L") do (
                if not "%%A"=="#" (
                    for /L %%i in (1,1,%count%) do (
                        if /i "%%B"=="!site%%i!" set "keep="
                    )
                )
            )
            if defined keep echo(!line!
        )
    )
    move /y "%hostspath%.tmp" "%hostspath%" >nul || (echo Can't update %hostspath% & pause & exit /b 1)
    for /L %%i in (1,1,%count%) do echo - !site%%i! 1>&2
) else (
    rem === REWRITE mappings: purge old ones then append fresh 0.0.0.0 lines ===
    >"%hostspath%.tmp" (
        for /f "usebackq tokens=* delims=" %%L in ("%hostspath%") do (
            set "line=%%L"
            set "keep=true"
            for /f "tokens=1,2* delims= " %%A in ("%%L") do (
                if not "%%A"=="#" (
                    for /L %%i in (1,1,%count%) do (
                        if /i "%%B"=="!site%%i!" set "keep="
                    )
                )
            )
            if defined keep echo(!line!
        )
        rem Add clean mappings at the end
        for /L %%i in (1,1,%count%) do (
            echo 0.0.0.0 !site%%i!
        )
    )
    move /y "%hostspath%.tmp" "%hostspath%" >nul || (echo Can't update %hostspath% & pause & exit /b 1)
    for /L %%i in (1,1,%count%) do echo + 0.0.0.0 !site%%i! 1>&2
)

ipconfig /flushdns >nul

echo Done. & echo.
timeout /t 1 >nul
endlocal & exit /b
