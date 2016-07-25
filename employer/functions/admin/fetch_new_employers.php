<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Profiles.php');

$class = new Profiles(
						NULL,
						NULL,
						NULL,
						NULL
					);

$data = $class->fetch_new_employers();

header("HTTP/1.0 404 Error saving contact");
if($data['status']){
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>