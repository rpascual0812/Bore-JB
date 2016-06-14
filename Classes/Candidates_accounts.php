<?php
require_once('../../../Classes/ClassParent.php');
class Candidates_accounts extends ClassParent{
    var $pin            = NULL;
    var $email_address  = NULL;
    var $password       = NULL;

    public function __construct(
                                    $pin,
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

    public function auth(){        
        $sql = <<<EOT
                select
                    *
                from candidates_accounts
                where (pin = '$this->pin' or email_address = '$this->email_address')
                and password = md5('$this->password')
                ;
EOT;

        return ClassParent::get($sql);
    }

    
}
?>