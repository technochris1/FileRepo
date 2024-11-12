ECHO OFF
set PORT0=5060,9001,18005,18009
set PROTO0=TCP
set RULE_NAME0="Jeron SIP TCP %PORT0%"

netsh advfirewall firewall show rule name=%RULE_NAME0% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME0% already exists.
    echo Hey, you already got a out rule by that name, you cannot put another one in!
) else (
    echo Rule %RULE_NAME0% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME0% dir=in action=allow protocol=%PROTO0% localport=%PORT0%
)

set PORT1=5060,19000-19800
set PROTO1=UDP
set RULE_NAME1="Jeron SIP UDP %PORT1%"

netsh advfirewall firewall show rule name=%RULE_NAME1% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME1% already exists.
    echo Hey, you already got a out rule by that name, you cannot put another one in!
) else (
    echo Rule %RULE_NAME1% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME1% dir=in action=allow protocol=%PROTO1% localport=%PORT1%
)