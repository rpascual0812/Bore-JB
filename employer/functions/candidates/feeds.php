<?php
require_once('../../../Functions/connect_cats.php');
require_once('../../../Classes/Applicants.php');

$class = new Applicants(
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL
					);

$data = $class->employer_feeds();

header("HTTP/1.0 404 No Applicants Found");
if($data['status']){
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>