<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Profiles.php');

$class = new Profiles(
						NULL,
						NULL,
						NULL,
						NULL,
						NULL						
					);

$data = $class->search($_POST['str']);

header("HTTP/1.0 404 No Applicants Found");
if($data['status']){
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>