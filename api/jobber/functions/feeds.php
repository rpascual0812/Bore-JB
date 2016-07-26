<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Job_posts.php');

$class = new Job_posts(
                        NULL,
                        $_GET['pin'],
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL
                        );

$data = $class->feeds();


header("HTTP/1.0 404 No feeds found");
if($data['status']){
    header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>