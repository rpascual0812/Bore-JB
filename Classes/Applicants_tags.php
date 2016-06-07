<?php
require_once('../../../Classes/ClassParent.php');
class Applicants_tags extends ClassParent{
    var $applicants_pk              = NULL;
    var $tags                       = NULL;

    public function __construct(
                                    $applicants_pk,
                                    $tags
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

    public function search(){
        $sql = <<<EOT
                select
                    applicant_id,
                    first_name,
                    middle_name,
                    last_name
                from applicants_tags
                left join applicants on (applicants_tags.applicants_pk = applicants.pk)
                where '$this->tags' = any(tags)
                ;
EOT;

        return ClassParent::get($sql);
    }

    
}
?>