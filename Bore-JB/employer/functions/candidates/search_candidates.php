<?php
require_once('../../../Functions/connect_cats.php');
require_once('../../../Classes/Applicants_tags.php');

$class = new Applicants_tags(
						NULL,
						$_POST['tags']
					);

$data = $class->search();

header("HTTP/1.0 404 No Applicants Found");
if($data['status']){
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>