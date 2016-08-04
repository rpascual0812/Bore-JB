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

    public function create($tags){
        $json_details = json_encode($this->details);
        $tags = json_encode($tags);
            
            $sql = "BEGIN;";
            $sql .= <<<EOT
            INSERT INTO job_posts
            (
                pin,
                type,
                details
            )
            VALUES
            (
                (SELECT pin FROM accounts WHERE md5(pin)='$this->pin'),
                '$this->type',
                '$json_details'
            );

            UPDATE job_posts
                SET details = jsonb_set(details, '{tags}', '$tags', true)
                WHERE pk = currval('job_posts_pk_seq');

EOT;
        
        $sql .= "COMMIT;";

        return ClassParent::insert($sql);
    }

    public function fetch(){
        $sql = <<<EOT
            select
                pk,
                pin,
                type,
                details,
                date_created::timestamp(0) as date_created
            from job_posts
            where md5(pin) = '$this->pin'
            and archived = $this->archived
            ;
EOT;

        return ClassParent::get($sql);
    }

    public function feeds(){
        $sql = <<<EOT
            select
                *
            from job_posts
            ;
EOT;
        return ClassParent::get($sql);
    }

    public function job_post(){
        $sql = <<<EOT
            select
                pk,
                pin,
                type,
                details,
                date_created::date as date,
                date_created,
                archived
            from job_posts
            where pk = $this->pk
            ;
EOT;
        return ClassParent::get($sql);
    }    

}
?>