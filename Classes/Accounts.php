<?php
require_once('../../../Classes/ClassParent.php');
class Accounts extends ClassParent{
    var $pin            = NULL;
    var $password       = NULL;

    public function __construct(
                                    $pin,
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
                from accounts
                where pin = '$this->pin'
                and password = md5('$this->password')
                ;
EOT;

        return ClassParent::get($sql);
    }

    
}
?>