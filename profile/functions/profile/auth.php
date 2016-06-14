<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Candidates_accounts.php');

$class = new Candidates_accounts(
						$_POST['pin'],
						$_POST['pin'],
						$_POST['password']
					);

$data = $class->auth();

header("HTTP/1.0 404 User Not Found");
if($data['status']){
	$pin = md5('APPPIN'); 

	setcookie($pin, $data['result'][0]['pin'], time()+43200, '/');
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>