<?php
require_once('../../../Functions/connect.php');
require_once('../../../Classes/Profiles.php');

$info=json_decode($_POST['info'],true);
$extended=json_decode($_POST['extended'],true);
// 	print_r($info);
// print_r($extended);

$type=($_POST['type']);
if($type==='education'){
	
	$educational_attainment_initial= pg_escape_string(strip_tags(trim($info['educational_attainment'])));
	$info_this=array();
	$info_this[0]['prompt']=$info['prompt'];
	$info_this[0][$educational_attainment_initial][0]['school']=$info['school'];
	if($info['major']==null){
	$info_this[0][$educational_attainment_initial][0]['major']="N/A";
	}else{
	$info_this[0][$educational_attainment_initial][0]['major']=$info['major'];
	}
	if($info['status']=="ongoing"){
	$info_this[0][$educational_attainment_initial][0]['end_date']['month']="N/A";
	$info_this[0][$educational_attainment_initial][0]['end_date']['year']="N/A";
	$info_this[0][$educational_attainment_initial][0]['expected_graduation']=$info['expected_graduation'];
	}else{
	$info_this[0][$educational_attainment_initial][0]['expected_graduation']['month']="N/A";
	$info_this[0][$educational_attainment_initial][0]['expected_graduation']['year']="N/A";
	$info_this[0][$educational_attainment_initial][0]['end_date']=$info['end_date'];
	}
	
	$info_this[0][$educational_attainment_initial][0]['start_date']=$info['start_date'];
	$info_this[0][$educational_attainment_initial][0]['status']=$info['status'];
	print_r("orignal");
	print_r($info_this);



	
	// print_r(sizeof($extended['educational_attainment'])+1);
	$num= count($extended['educational_attainment']);

	for ($x = 0 ; $x<  $num ; $x++){
	if($extended['educational_attainment'][$x]==""){
	unset($extended['status'][$x]);
	unset($extended['school'][$x]);
	unset($extended['major'][$x]);
	unset($extended['start_date']['year'][$x]);
	unset($extended['start_date']['month'][$x]);
	unset($extended['end_date']['month'][$x]);
	unset($extended['end_date']['year'][$x]);
	unset($extended['expected_graduation']['year'][$x]);
	unset($extended['expected_graduation']['month'][$x]);
	unset($extended['educational_attainment'][$x]);
	print_r("inside loooooooop");
	}}
	print_r($extended);
	$numm= count($extended['educational_attainment']);
	for ($y = 0 ; $y<=  $numm ; $y++){
	if($extended['status'][$y]=="ongoing"){
	$extended['end_date']['year'][$y]="N/A";
	$extended['end_date']['month'][$y]="N/A";
	ksort($extended['end_date']['month']);
	ksort($extended['end_date']['year']);
	}else{
	$extended['expected_graduation']['year'][$y]="N/A";
	$extended['expected_graduation']['month'][$y]="N/A";
	ksort($extended['expected_graduation']['month']);
	ksort($extended['expected_graduation']['year']);

	}
	}
	for ($z = 0 ; $z<=  $numm ; $z++){
	if($extended['major'][$z]==null){
	$extended['major'][$z]="N/A";
	ksort($extended['major']);
	}else{
	ksort($extended['major']);
	}
	}
	// print_r("AFTER NULLING");
	// print_r($extended);
	$extended['educational_attainment']=array_values($extended['educational_attainment']);
	$extended['school']=array_values($extended['school']);
	$extended['major']=array_values($extended['major']);
	$extended['start_date']['year']=array_values($extended['start_date']['year']);
	$extended['start_date']['month']=array_values($extended['start_date']['month']);
	$extended['status']=array_values($extended['status']);
	$extended['end_date']['month']=array_values($extended['end_date']['month']);
	$extended['end_date']['year']=array_values($extended['end_date']['year']);
	$extended['expected_graduation']['year']=array_values($extended['expected_graduation']['year']);
	$extended['expected_graduation']['month']=array_values($extended['expected_graduation']['month']);
	
	print_r("before adding");
	print_r($extended);
	$new_num=count($extended['educational_attainment']);
	print_r($new_num);

	if($num>0 && $new_num!== undefined){
	$a=0;
	for ($i = 0 ;$i < $new_num ; $i++){

	$extended['educational_attainment'][$i]=pg_escape_string(strip_tags(trim($extended['educational_attainment'][$i])));
	if($extended['educational_attainment'][$i]==$educational_attainment_initial){
	$info_this[0][$educational_attainment_initial][$i+1]['school']=$extended['school'][$i];
	$info_this[0][$educational_attainment_initial][$i+1]['major']=$extended['major'][$i];
	$info_this[0][$educational_attainment_initial][$i+1]['start_date']['year']=$extended['start_date']['year'][$i];
	$info_this[0][$educational_attainment_initial][$i+1]['start_date']['month']=$extended['start_date']['month'][$i];
	$info_this[0][$educational_attainment_initial][$i+1]['status']=$extended['status'][$i];
	$info_this[0][$educational_attainment_initial][$i+1]['end_date']['month']=$extended['end_date']['month'][$i];
	$info_this[0][$educational_attainment_initial][$i+1]['end_date']['year']=$extended['end_date']['year'][$i];
	$info_this[0][$educational_attainment_initial][$i+1]['expected_graduation']['year']=$extended['expected_graduation']['year'][$i];
	$info_this[0][$educational_attainment_initial][$i+1]['expected_graduation']['month']=$extended['expected_graduation']['month'][$i];
	
	$info_this[0][$educational_attainment_initial]=array_values($info_this[0][$educational_attainment_initial]);
	}else if(array_key_exists($extended['educational_attainment'][$i],$info_this[0][$NEW_EGG])){
	$educational_attainment_new=$extended['educational_attainment'][$i];
	$info_this[0][$educational_attainment_new][$i+1]['school']=$extended['school'][$i];
	$info_this[0][$educational_attainment_new][$i+1]['major']=$extended['major'][$i];
	$info_this[0][$educational_attainment_new][$i+1]['start_date']['year']=$extended['start_date']['year'][$i];
	$info_this[0][$educational_attainment_new][$i+1]['start_date']['month']=$extended['start_date']['month'][$i];
	$info_this[0][$educational_attainment_new][$i+1]['status']=$extended['status'][$i];
	$info_this[0][$educational_attainment_new][$i+1]['end_date']['month']=$extended['end_date']['month'][$i];
	$info_this[0][$educational_attainment_new][$i+1]['end_date']['year']=$extended['end_date']['year'][$i];
	$info_this[0][$educational_attainment_new][$i+1]['expected_graduation']['year']=$extended['expected_graduation']['year'][$i];
	$info_this[0][$educational_attainment_new][$i+1]['expected_graduation']['month']=$extended['expected_graduation']['month'][$i];	
	
	$info_this[0][$educational_attainment_new]=array_values($info_this[0][$educational_attainment_new]);
	}else {
	$educational_attainment_new=$extended['educational_attainment'][$i];
	$info_this[0][$educational_attainment_new][$i]['school']=$extended['school'][$i];
	$info_this[0][$educational_attainment_new][$i]['major']=$extended['major'][$i];
	$info_this[0][$educational_attainment_new][$i]['start_date']['year']=$extended['start_date']['year'][$i];
	$info_this[0][$educational_attainment_new][$i]['start_date']['month']=$extended['start_date']['month'][$i];
	$info_this[0][$educational_attainment_new][$i]['status']=$extended['status'][$i];
	$info_this[0][$educational_attainment_new][$i]['end_date']['month']=$extended['end_date']['month'][$i];
	$info_this[0][$educational_attainment_new][$i]['end_date']['year']=$extended['end_date']['year'][$i];
	$info_this[0][$educational_attainment_new][$i]['expected_graduation']['year']=$extended['expected_graduation']['year'][$i];
	$info_this[0][$educational_attainment_new][$i]['expected_graduation']['month']=$extended['expected_graduation']['month'][$i];

	$info_this[0][$educational_attainment_new]=array_values($info_this[0][$educational_attainment_new]);
	}
	}
	}
	}
else if($type==='personal_info'){
		$info['address']['country']= pg_escape_string(strip_tags(trim($info['address']['country'])));
		$info_this=$info;
}else{
	$info_this=$info;
}

$class = new Profiles(
					    $_POST['pin'],
                        $_POST['type'],
                        NULL,
                        NULL
	               );

print_r("laaaaaaaaaaaaaast");
print_r($info_this);
$data = $class->update($info_this,$type);

header("HTTP/1.0 404 No Profile Found");
if($data['status']){
    header("HTTP/1.0 200 OK");
}

header('Content-Type: application/json');
print(json_encode($data));
?>