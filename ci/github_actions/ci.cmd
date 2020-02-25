@ECHO OFF
IF NOT "%BE%"=="mingw-gcc" (
  IF NOT "%BE%"=="msvc" (
    ECHO Environment variable BE must be mingw-gcc or msvc
    EXIT /b 1
  )
)

SET ORIGPATH=%PATH%
IF "%BE%"=="mingw-gcc" (
  SET MINGWPATH=C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\Program Files\cmake\bin;C:\ProgramData\chocolatey\lib\mingw\tools\install\mingw64\bin
)

IF "%1%"=="configure" (
  IF "%BE%"=="mingw-gcc" (
    SET PATH=%MINGWPATH%
    MKDIR build_ci\cmake
    CD build_ci\cmake
    cmake -G "MinGW Makefiles" ..\.. || EXIT /b 1
  ) ELSE IF "%BE%"=="msvc" (
    MKDIR build_ci\cmake
    CD build_ci\cmake
    cmake -G "Visual Studio 16 2019" ..\.. || EXIT /b 1
  )
) ELSE IF "%1%"=="build" (
  IF "%BE%"=="mingw-gcc" (
    SET PATH=%MINGWPATH%
    CD build_ci\cmake
    mingw32-make VERBOSE=1 || EXIT /b 1
  ) ELSE IF "%BE%"=="msvc" (
    CD build_ci\cmake
    cmake --build . --target ALL_BUILD --config Release || EXIT /b 1
  )
) ELSE IF "%1%"=="test" (
  IF "%BE%"=="mingw-gcc" (
    ECHO "Skipping tests"
    EXIT /b 0
    REM SET PATH=%MINGWPATH%
    REM CD build_ci\cmake
    REM mingw32-make test VERBOSE=1 || EXIT /b 1
  ) ELSE IF "%BE%"=="msvc" (
    ECHO "Skipping tests"
    EXIT /b 0
    REM CD build_ci\cmake
    REM cmake --build . --target RUN_TESTS --config Release || EXIT /b 1
  )
) ELSE IF "%1%"=="install" (
  IF "%BE%"=="mingw-gcc" (
    SET PATH=%MINGWPATH%
    CD build_ci\cmake
    mingw32-make install || EXIT /b 1
  ) ELSE IF "%BE%"=="msvc" (
    CD build_ci\cmake
    cmake --build . --target INSTALL --config Release || EXIT /b 1
  )
) ELSE (
  ECHO "Usage: %0% deplibs|configure|build|test|install"
  @EXIT /b 0
)
@EXIT /b 0
