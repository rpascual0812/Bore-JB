<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Profiles.php');

$info=json_decode($_POST['info'],true);
$type=($_POST['type']);
//print_r($info);
$class = new Profiles(
					    $_POST['pin'],
                        $_POST['type'],
                        NULL,
                        NULL
	               );
$data = $class->update($info,$type);

header("HTTP/1.0 404 No Profile Found");
if($data['status']){
    header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>