<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Job_posts.php');

$class = new Job_posts(
                        NULL,
                        $_GET['pin'],
                        NULL,
                        NULL,
                        NULL,
                        $_GET['archived'],
                        NULL
                        );

$data = $class->fetch();


header("HTTP/1.0 404 Error saving job post");
if($data['status']){
    header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>