<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Employers.php');

$class = new Employers(
						NULL,
						NULL,
						NULL,
						NULL
					);

$data = $class->update_employer_bucket($_POST);

header("HTTP/1.0 404 User Not Found");
if($data['status']){
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>