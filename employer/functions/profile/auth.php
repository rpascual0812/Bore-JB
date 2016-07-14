<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Accounts.php');

$class = new Accounts(
						$_POST['pin'],
						NULL,
						$_POST['password'],
						NULL
					);

$data = $class->auth();

header("HTTP/1.0 404 User Not Found");
if($data['status']){
	$pin = md5('PIN'); 

	setcookie($pin, md5($data['result'][0]['pin']), time()+43200, '/');
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>