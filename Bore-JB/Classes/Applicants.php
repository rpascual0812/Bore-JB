<?php
require_once('../../../Classes/ClassParent.php');
class Applicants extends ClassParent{
    var $pk = NULL;
    var $applicant_id = NULL;
    var $requisitions_pk = NULL;
    var $created_by = NULL;
    var $sources_pk = NULL;
    var $date_created = NULL;
    var $date_received = NULL;
    var $first_name = NULL;
    var $last_name = NULL;
    var $middle_name = NULL;
    var $birthdate = NULL;
    var $profiled_for_pk = NULL;
    var $contact_number = NULL;
    var $email_address = NULL;
    var $clients_pk = NULL;
    var $cv = NULL;

    public function __construct(
                                    $pk,
                                    $applicant_id,
                                    $requisitions_pk,
                                    $created_by,
                                    $sources_pk,
                                    $date_created,
                                    $date_received,
                                    $first_name,
                                    $last_name,
                                    $middle_name,
                                    $birthdate,
                                    $profiled_for_pk,
                                    $contact_number,
                                    $email_address,
                                    $clients_pk,
                                    $cv
                                ){
        
        $fields = get_defined_vars();
        
        if(empty($fields)){
            return(FALSE);
        }

        //sanitize
        foreach($fields as $k=>$v){
            $this->$k = pg_escape_string(trim(strip_tags($v)));
        }

        return(true);
    }

    public function profile(){
        $sql = <<<EOT
                select
                    *
                from applicants
                where applicant_id = '$this->applicant_id'
                ;
EOT;

        return ClassParent::get($sql);
    }

    
}
?>