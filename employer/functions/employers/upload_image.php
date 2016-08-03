<?php # Script 11.2 - upload_image.php

// Check if the form has been submitted:
if ($_SERVER['REQUEST_METHOD'] == 'POST') {

	$return = array();
	// Check for an uploaded file:
	if (isset($_FILES['file'])) {
		
		// Validate the type. Should be JPEG or PNG.
		$allowed = array ('image/pjpeg', 'image/jpeg', 'image/JPG', 'image/X-PNG', 'image/PNG', 'image/png', 'image/x-png');
		if (in_array($_FILES['file']['type'], $allowed)) {
		
			// Move the file over.
			if (move_uploaded_file ($_FILES['file']['tmp_name'], "../../../ASSETS/TMP/ads/".$_FILES['file']['name'])) {
				$return = array( 'status' => true, 'message' => 'File transfer completed', 'file' => $_FILES['file']['tmp_name'], "../../../ASSETS/TMP/ads/".$_FILES['file']['name']);	

				header("HTTP/1.0 200 OK");
				header('Content-Type: application/json');
				$return = json_encode($return);
				print($return);
			} // End of move... IF.
			
		} else { // Invalid type.
			$return = array( 'status' => false, 'message' => 'Please upload a JPEG or PNG image.');	
			
			header("HTTP/1.0 404 Error uploading file");
			header('Content-Type: application/json');
			$return = json_encode($return);
			print($return);
		}

	} // End of isset($_FILES['file']) IF.
	
	// Check for an error:
	if ($_FILES['file']['error'] > 0) {
		$error = 'The file could not be uploaded because: ';
	
		// Print a message based upon the error.
		switch ($_FILES['file']['error']) {
			case 1:
				$error .= 'The file exceeds the upload_max_filesize setting in php.ini.';
				break;
			case 2:
				$error .= 'The file exceeds the MAX_FILE_SIZE setting in the HTML form.';
				break;
			case 3:
				$error .= 'The file was only partially uploaded.';
				break;
			case 4:
				$error .= 'No file was uploaded.';
				break;
			case 6:
				$error .= 'No temporary folder was available.';
				break;
			case 7:
				$error .= 'Unable to write to the disk.';
				break;
			case 8:
				$error .= 'File upload stopped.';
				break;
			default:
				$error .= 'A system error occurred.';
				break;
		} // End of switch.
		$return = array( 'status' => false, 'message' => $error);
			
		header("HTTP/1.0 404 Error uploading file");
		header('Content-Type: application/json');
		$return = json_encode($return);
		print($return);
	} // End of error IF.
	
	// Delete the file if it still exists:
	if (file_exists ($_FILES['file']['tmp_name']) && is_file($_FILES['upload']['tmp_name']) ) {
		unlink ($_FILES['upload']['tmp_name']);
	}
			
} // End of the submitted conditional.
?>
