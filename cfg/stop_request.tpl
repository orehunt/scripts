POST /admin/setClientCommand?clientId=home HTTP/1.1
User-Agent: command
Authorization: Basic ${AUTH:-Y2hhY2hhMjA6MTIz}
Accept: */*
Content-Type: application/json
Content-Length: 39

{"control_command":{"command":"STOP"}}