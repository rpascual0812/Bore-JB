<?php
require_once('../../Classes/ClassParent.php');
class Employers extends ClassParent{
    var $pin            = NULL;
    var $name           = NULL;

    public function __construct(
                                    $pin,
                                    $name
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

    public function create($data){
        // $sql = "begin;";

        $sql = <<<EOT
            insert into employees
            (
                pin,
                name
            )
            values
            (
                '$this->ntlogin',
                '$this->employeeid',
                '$this->name'
            )
            ;
EOT;

        // $sql .= "commit;";
        return ClassParent::insert($sql);
    }

    

    
}
?>