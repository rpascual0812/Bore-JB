<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Profiles.php');


$profile = array(
        'first_name' => $_POST['first_name'],
        'last_name' => $_POST['last_name']
    );

$class = new Profiles(
                        generateRandomString(),
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


function generateRandomString($length = 6) {
        $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $charactersLength = strlen($characters);
        $randomString = '';
        
        for ($i = 0; $i < $length; $i++) {
            $randomString .= $characters[rand(0, $charactersLength - 1)];
        }

        return $randomString;
    }


header("HTTP/1.0 404 Error saving contact");
if($data['status']){
    header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>