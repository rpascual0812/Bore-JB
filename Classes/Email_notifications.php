<?php
require_once('../../../Classes/ClassParent.php');
class Email_notifications extends ClassParent{
    var $pk                 = NULL;
    var $email              = array();
    var $date_created       = NULL;

    public function __construct(
                                    $pk,
                                    $email,
                                    $date_created
                                ){
        
        $fields = get_defined_vars();
        
        if(empty($fields)){
            return(FALSE);
        }

        //sanitize
        foreach($fields as $k=>$v){
            if(is_array($v)){
                foreach($v as $key=>$val){
                    $this->$k[$key] = pg_escape_string(trim(strip_tags($val)));
                }
            }
            else {
                $this->$k = pg_escape_string(trim(strip_tags($v)));    
            }
        }

        return(true);
    }

    public function create(){
        $email = json_encode($this->email);

        $sql = <<<EOT
                insert into email_notifications
                (
                    email
                )
                values
                (
                    '$email'
                )
                returning pk
                ;
EOT;

        return ClassParent::insert($sql);
    }
}
?>