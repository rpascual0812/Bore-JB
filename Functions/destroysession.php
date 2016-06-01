<?php
$pin = md5("PIN");

setcookie ($pin, "", time() - 3600, '/');

header("HTTP/1.0 200 OK");
header('Content-Type: application/json');
print(json_encode(array('status'=>true)));
?>