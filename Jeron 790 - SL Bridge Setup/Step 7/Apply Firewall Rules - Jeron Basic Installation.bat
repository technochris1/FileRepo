ECHO OFF
set PORT0=1947,46555,1433
set PROTO0=TCP
set RULE_NAME0="Jeron Base TCP %PORT0%"

netsh advfirewall firewall show rule name=%RULE_NAME0% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME0% already exists.
    echo Hey, you already got a out rule by that name, you cannot put another one in!
) else (
    echo Rule %RULE_NAME0% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME0% dir=in action=allow protocol=%PROTO0% localport=%PORT0%
)

set PORT1=1947,46050
set PROTO1=UDP
set RULE_NAME1="Jeron Base UDP %PORT1%"

netsh advfirewall firewall show rule name=%RULE_NAME1% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME1% already exists.
    echo Hey, you already got a out rule by that name, you cannot put another one in!
) else (
    echo Rule %RULE_NAME1% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME1% dir=in action=allow protocol=%PROTO1% localport=%PORT1%
)