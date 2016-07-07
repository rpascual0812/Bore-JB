<?php
require_once('../../../Classes/ClassParent.php');
class Candidates extends ClassParent{
    var $pin            = NULL;
    var $firstName      = NULL;
    var $lastName       = NULL;
    var $email_address  = NULL;
    var $password       = NULL;

    public function __construct(
                                    $pin,
                                    $firstName,
                                    $lastName,
                                    $email_address,
                                    $password
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

    public function create(){
        $sql = <<<EOT
            begin;
            insert into candidates
            (
                pin,
                first_name,
                last_name
            )
            values
            (
                '$this->pin',
                '$this->firstName',
                '$this->lastName'
            );
            insert into candidates_accounts
            (
                pin,
                email_address,
                password
            )
            values
            (
                '$this->pin',
                '$this->email_address',
                md5('$this->password')
            );
            commit;
EOT;

        return ClassParent::insert($sql);
    }
    

    
}
?>