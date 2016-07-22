<?php
//require_once('../../../Classes/ClassParent.php');
/**/require_once('../../../Functions/connect.php');
require_once('../../../Classes/Profiles.php');

$class = new Profiles(
						$_POST['pin'],
						NULL,
						NULL
					);

$data = $class->fetch_profiles();

header("HTTP/1.0 404 No Profile Found");
if($data['status']){
	header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>