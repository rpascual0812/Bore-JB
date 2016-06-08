<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Employers.php');

$class = new Employers(
						$_POST['pin'],
						NULL,
						NULL,
						NULL
					);

$data = $class->profile();

header("HTTP/1.0 404 User Not Found");
if($data['status']){
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>