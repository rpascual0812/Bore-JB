<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Accounts_email.php');

$class = new Accounts_email(
    $_POST['email']
);

$data = $class->fetch();

header("HTTP/1.0 404 No Applicants Found");
if($data['status']){
    header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>