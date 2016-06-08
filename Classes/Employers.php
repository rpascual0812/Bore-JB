<?php
require_once('../../../Classes/ClassParent.php');
class Employers extends ClassParent{
    var $pin            = NULL;
    var $name           = NULL;
    var $currencies_pk  = NULL;
    var $plans_pk  = NULL;

    public function __construct(
                                    $pin,
                                    $name,
                                    $plans_pk
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
                name,
                currencies_pk,
                plans_pk
            )
            values
            (
                '$this->pin',
                '$this->name',
                '$this->currencies_pk',
                '$this->plans_pk'
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

        $sql = <<<EOT
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

        return ClassParent::update($sql);
    }
}
?>