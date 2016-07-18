<?php
require_once('./Functions/connect.php');
require_once('./PHPMailer/PHPMailerAutoload.php');

$sql = <<<EOT
                select
                    *
                from email_notifications
                order by date_created
                ;
EOT;

$query = pg_query($sql);

if(pg_numrows($query)){
	while($data = pg_fetch_assoc($query)){
		send_email($data);
	}
}
else {
	echo "none";
}

function send_email($data){
	date_default_timezone_set('Asia/Manila');

	$content = json_decode($data['email']);

	//Create a new PHPMailer instance
	$mail = new PHPMailer;

	$mail->isSMTP();

	//Enable SMTP debugging
	// 0 = off (for production use)
	// 1 = client messages
	// 2 = client and server messages
	$mail->SMTPDebug = 2;

	//Ask for HTML-friendly debug output
	$mail->Debugoutput = 'html';

	//Set the hostname of the mail server
	$mail->Host = 'smtp.gmail.com';
	// use
	// $mail->Host = gethostbyname('smtp.gmail.com');
	// if your network does not support SMTP over IPv6

	//Set the SMTP port number - 587 for authenticated TLS, a.k.a. RFC4409 SMTP submission
	$mail->Port = 587;

	//Set the encryption system to use - ssl (deprecated) or tls
	$mail->SMTPSecure = 'tls';

	//Whether to use SMTP authentication
	$mail->SMTPAuth = true;

	//Username to use for SMTP authentication - use full email address for gmail
	$mail->Username = "joberfied@gmail.com";

	//Password to use for SMTP authentication
	$mail->Password = "user123456";

	//Set who the message is to be sent from
	$mail->setFrom('Notification@joberfied.com', 'Joberfied Notification');

	//Set an alternative reply-to address
	$mail->addReplyTo('joberfied@gmail.com', 'Joberfied');

	//Set who the message is to be sent to
	$mail->addAddress($content->to_email, $content->to_name);
	$mail->AddCC('joberfied@gmail.com', 'Rafael Pascual');

	//Set the subject line
	$mail->Subject = 'Please confirm your Joberfied account';

	//Read an HTML message body from an external file, convert referenced images to embedded,
	//convert HTML into a basic plain-text alternative body

	$url = $content->return_url . $data['code'];
	$template = templates($content->template);

	$mail->Body = $template;
	$mail->IsHTML(true);

	//Attach an image file
	//$mail->addAttachment('images/phpmailer_mini.png');

	//send the message, check for errors
	if (!$mail->send()) {
	    echo "Mailer Error: " . $mail->ErrorInfo;
	} else {
	    echo "Message sent!";

	    $code = $data['code'];
	    $sql = <<<EOT
                delete from email_notifications
                where code = '$code';
EOT;

		$query = pg_query($sql);
	}
}

function templates($temp){
	$return='';
	switch ($temp) {
		case 'candidate_registration':
			$return = '<div style="margin: 0 auto;width:50%;border: solid 2px #e30000;-webkit-border-radius: 5px;-moz-border-radius: 5px;border-radius: 5px;padding: 10%;">
                        <img src="http://www.joberfied.com/ASSETS/img/seagulls350_2.gif" style="width:50%; margin-left: 30%;" />

                        <h1 style="font-family:helvetica;font-size:2.5em;line-height:1.3em;margin-bottom:5px;text-align:center;">Welcome to Joberfied!</h1>

                        <p style="font-family:helvetica;font-size:1.0em;line-height:1.3em;margin-bottom:5px;text-align:center;">Click the button below to confirm you email address</p>
                        <p style="text-align:center;">
                            <a href="http://www.joberfied.com/profile/#/confirm/sfsdfsdf" style="-moz-box-shadow:inset 0px 1px 0px 0px #f29c93;-webkit-box-shadow:inset 0px 1px 0px 0px #f29c93;box-shadow:inset 0px 1px 0px 0px #f29c93;background:-webkit-gradient(linear, left top, left bottom, color-stop(0.05, #fe1a00), color-stop(1,#ce0100));background:-moz-linear-gradient(top, #fe1a00 5%, #ce0100 100%);background:-webkit-linear-gradient(top, #fe1a00 5%, #ce0100 100%);background:-o-linear-gradient(top, #fe1a00 5%, #ce0100 100%);background:-ms-linear-gradient(top, #fe1a00 5%, #ce0100 100%);background:linear-gradient(to bottom, #fe1a00 5%, #ce0100 100%);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=\'#fe1a00\',endColorstr=\'#ce0100\',GradientType=0);background-color:#fe1a00;-moz-border-radius:6px;-webkit-border-radius:6px;border-radius:6px;border:1px solid #d83526;display:inline-block;cursor:pointer;color:#ffffff;font-family:Arial;font-size:15px;font-weight:bold;padding:10px 44px;text-decoration:none;text-shadow:0px 1px 0px #b23e35;">CONFIRM</a>
                        </p>
                    </div>';
			break;
		
		default:
			# code...
			break;
	}

	return $return;
}
?>