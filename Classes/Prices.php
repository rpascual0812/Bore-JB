<?php
require_once('../../../Classes/ClassParent.php');
class Prices extends ClassParent{
    var $pk = NULL;
    var $type = NULL;
    var $currencies_pk = NULL;
    var $prices = NULL;
    var $archvied = NULL;

    public function __construct(
                                    $pk,
                                    $type,
                                    $currencies_pk,
                                    $prices,
                                    $archived
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
                from prices
                where currencies_pk = '$this->currencies_pk'
                ;
EOT;

        return ClassParent::get($sql);
    }

    
}
?>