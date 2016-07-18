<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Profiles.php');
require_once('../../../Classes/Email_notifications.php');

$app_pin = generateRandomString();

$profile = array(
    'first_name' => $_POST['first_name'],
    'last_name' => $_POST['last_name']
);

$class = new Profiles(
						$app_pin,
                        $profile,
                        NULL
	               );

$info = array(
    'email_address' => $_POST['email'],
    'password' => $_POST['password'],
    'usertype' => 'candidate',
    'email' => array(
        'to_email' => $_POST['email'],
        'to_name' => $_POST['first_name'].' '.$_POST['last_name'],
        'return_url' => $_SERVER['HTTP_HOST'] . "/employer/#/manual_log/confirm/",
        'template' => 'candidate_registration'
    )
);

$data = $class->create($info);

function generateRandomString($length = 6) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }

    return $randomString;
}


if($data['status']){

    header("HTTP/1.0 200 OK");
}
else {
    header("HTTP/1.0 404 Internal server error");
}

header('Content-Type: application/json');
print(json_encode($data));
?>