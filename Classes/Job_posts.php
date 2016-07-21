<?php
require_once('../../../Classes/ClassParent.php');
class Job_posts extends ClassParent{
    var $pk = NULL;
    var $pin = NULL;
    var $type = NULL;
    var $details = NULL;
    var $date_created = NULL;
    var $archived = NULL;
    var $tsv = NULL;

    public function __construct(
                                    $pk,
                                    $pin,
                                    $type,
                                    $details,
                                    $date_created,
                                    $archived,
                                    $tsv
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
        $json_details = json_encode($this->details);
        print_r($json_details."mmmmmmmm");
        $sql = <<<EOT
            INSERT INTO job_posts
            (
                pin,
                type,
                details
            )
            VALUES
            (
                '$this->pin',
                '$this->type',
                '$json_details'
            );
EOT;

        return ClassParent::insert($sql);
    }

}
?>