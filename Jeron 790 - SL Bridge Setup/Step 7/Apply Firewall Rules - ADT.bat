ECHO OFF
set PORT0=5050,17430,17432
set PROTO0=TCP
set RULE_NAME0="Jeron ADT TCP %PORT0%"

netsh advfirewall firewall show rule name=%RULE_NAME0% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME0% already exists.
    echo Hey, you already got a out rule by that name, you cannot put another one in!
) else (
    echo Rule %RULE_NAME0% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME0% dir=in action=allow protocol=%PROTO0% localport=%PORT0%
)
