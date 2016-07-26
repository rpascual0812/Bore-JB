<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Accounts.php');

$class = new Accounts(
						$_GET['pin'],
						NULL,
						$_GET['password'],
						'candidate'
					);

$data = $class->auth();

header("HTTP/1.0 404 User Not Found");
if($data['status']){
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>