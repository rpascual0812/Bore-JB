<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Profiles.php');

$a=json_decode($_POST['info']);
//print_r($info);
$class = new Profiles(
					    $_POST['pin'],
                        $_POST['type'],
                        NULL,
                        NULL
	               );
$info = array();
$name = $a->name;
$address = $a->address;
$email = $a->email;
$number = $a->number;

$info['name']=$name;
$info['address']=$address;
$info['email']=$email;
$info['number']=$number;
$data = $class->update($info);

header("HTTP/1.0 404 No Profile Found");
if($data['status']){
    header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>