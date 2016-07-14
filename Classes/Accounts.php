<?php
require_once('../../../Classes/ClassParent.php');
class Accounts extends ClassParent{
    var $pin            = NULL;
    var $email_address  = NULL;
    var $password       = NULL;
    var $usertype       = NULL;

    public function __construct(
                                    $pin,
                                    $email_address,
                                    $password,
                                    $usertype
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
                from accounts
                where (pin = UPPER('$this->pin') or email_address = LOWER('$this->pin'))
                and password = md5('$this->password')
                ;
EOT;

        return ClassParent::get($sql);
    }

    
}
?>