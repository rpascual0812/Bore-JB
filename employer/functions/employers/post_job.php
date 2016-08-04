<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Job_posts.php');

$_POST['details'] = json_decode($_POST['details'], true);
	print_r("decoded: ");
	print_r($_POST['details']);

$tags = $_POST['details']['required_skills'];
	print_r("tags: ");
	print_r($tags);

unset($_POST['details']['required_skills']);
	print_r("details: ");
	print_r($_POST['details']);


$class = new Job_posts(
                        NULL,
                        $_POST['pin'],
                        $_POST['type'],
                        $_POST['details'],
                        NULL,
                        NULL,
                        NULL
                        );

$data = $class->create($tags);


header("HTTP/1.0 404 Error saving job post");
if($data['status']){
	

    header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>