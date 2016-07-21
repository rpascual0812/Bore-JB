<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Job_posts.php');

$_POST['details'] = json_decode($_POST['details'], true);
print_r($_POST['details']);
$class = new Job_posts(
                        NULL,
                        '1234-JJ',//cookie pin
                        $_POST['type'],
                        $_POST['details'],
                        NULL,
                        NULL,
                        NULL
                        );

$data = $class->create();


header("HTTP/1.0 404 Error saving job post");
if($data['status']){
    header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>