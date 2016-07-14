<?php
require_once('../../../Classes/ClassParent.php');
class Employers extends ClassParent{
    var $pin            = NULL;
    var $name           = NULL;
    var $currencies_pk  = NULL;
    var $plans_pk  = NULL;
    var $first_name  = NULL;
    var $last_name  = NULL;
    var $best_time  = NULL;
    var $email_address  = NULL;


    public function __construct(
                                    $pin,
                                    $name,
                                    $currencies_pk,
                                    $plans_pk,
                                    $first_name,
                                    $last_name,
                                    $best_time,
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

    public function create($data){
        // $sql = "begin;";

        $sql = <<<EOT
            insert into employers
            (
                pin,
                name,
                currencies_pk,
                plans_pk,              
                first_name,
                last_name,
                best_time,
                email
            )
            values
            (
                '$this->pin',
                '$this->name',
                1,
                '$this->plans_pk',
                '$this->first_name',
                '$this->last_name',
                '$this->best_time',
                '$this->email'


            )
            ;
EOT;

        // $sql .= "commit;";
        return ClassParent::insert($sql);
    }

    public function profile(){
        $sql = <<<EOT
            select 
                employers.pin,
                employers.name,
                employers.currencies_pk,
                (select currencies.currency from currencies where pk = employers.currencies_pk) as currency,
                plans_pk,
                (select plan from plans where plans.pk = employers.plans_pk) as plan,
                credits.available
            from employers
            left join credits on (employers.pin = credits.pin)
            where md5(employers.pin) = '$this->pin'
EOT;

        return ClassParent::get($sql);
    }

    public function update_credit($post){
        $pin        = $post['pin'];
        $deduction  = $post['deduction'];

        $sql = <<<EOT
            update credits set
            (available)
            =
            (available - $deduction)
            where pin = '$pin'
EOT;

        return ClassParent::update($sql);
    }

    public function get_employer_bucket($post){
        $pin = $post['pin'];

        $sql = <<<EOT
            select
                *
            from employers_bucket
            where pin = '$pin'
            ;
EOT;

        return ClassParent::get($sql);
    }

    public function update_employer_bucket($post){
        $pin            = $post['pin'];
        $applicant_id   = $post['applicant_id'];

        $sql = "begin;";
        $sql .= <<<EOT
            insert into employers_bucket
            (
                pin,
                applicant_id
            )
            values
            (
                '$pin',
                '$applicant_id'
            );
EOT;

        $sql .= <<<EOT
            insert into employers_logs
            (
                pin,
                log
            )
            values
            (
                '$pin',
                'Added new candidate to bucket'
            );
EOT;

        $sql .= "commit;";

        return ClassParent::update($sql);
    }
}
?>