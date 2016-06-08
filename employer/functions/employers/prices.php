<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Prices.php');

$class = new Prices(
						NULL,
						NULL,
						$_POST['currencies_pk'],
						NULL,
						NULL
					);

$data = $class->fetch();

header("HTTP/1.0 404 User Not Found");
if($data['status']){
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>