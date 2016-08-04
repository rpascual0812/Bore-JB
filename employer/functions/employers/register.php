<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Profiles.php');


$profile = array(
        'first_name' => $_POST['first_name'],
        'last_name' => $_POST['last_name']
    );

$pin = generateRandomString();

$class = new Profiles(
                        $pin,
                        $profile,
                        NULL
                    );
$info = array(
        'company_name' => $_POST['company_name'],
        'office_number' => $_POST['office_number'],
        'extensions' => $_POST['extensions'],
        'email_address' => $_POST['email_address'],
        'contact_number' => $_POST['contact_number'],
        'usertype' => 'recruiter',
        'password' => '1'
    );

$data = $class->create($info);


function generateRandomString() {
    $length=4;

    $num = '0123456789';
    $numLength = strlen($num);
    $randomNum = '';
    
    for ($i = 0; $i < $length; $i++) {
        $randomNum .= $num[rand(0, $numLength - 1)];
    }
    

    $lengths=2;

    $characters = 'ABCDEFGHJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    
    for ($i = 0; $i < $lengths; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }

    $a=1;

    $c = '01';
    $cl = strlen($c);
    $rs = '';
    
    for ($i = 0; $i < $a; $i++) {
        $rs .= $c[rand(0, $cl - 1)];
    }


    $lengths2=2;

    $characters2 = 'ABCDEFGHJKLMNOPQRSTUVWXYZ';
    $charactersLength2 = strlen($characters2);
    $randomString2 = '';
    
    for ($i = 0; $i < $lengths2; $i++) {
        $randomString2 .= $characters2[rand(0, $charactersLength2 - 1)];
    }


    return $randomString."-".$randomNum."-".$randomString2;
}


header("HTTP/1.0 404 Error saving contact");
if($data['status']){
    $pin = md5('PIN'); 

    setcookie($pin, md5($pin), time()+43200, '/');
    header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>