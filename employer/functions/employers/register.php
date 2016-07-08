<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Employers.php');

$class = new Employers(
                        generateRandomString(),
                        $_POST['name'],
                        1,
                        1,
                        $_POST['contact_person'],
                        $_POST['contact_number'],
                        $_POST['best_time'],
                        $_POST['email']
    );

$data = $class->create();


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