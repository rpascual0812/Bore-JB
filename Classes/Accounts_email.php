<?php
require_once('../../../Classes/ClassParent.php');
class Accounts_email extends ClassParent{
    var $email_address  = NULL;

    public function __construct(
        $email_address
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

    public function fetch(){
        $sql = <<<EOT
                select
                    *
                from accounts
                where email_address = '$this->email_address'
                ;
EOT;

        return ClassParent::get($sql);
    }


}
?>