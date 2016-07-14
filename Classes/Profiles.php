<?php
require_once('../../../Classes/ClassParent.php');
class Profiles extends ClassParent{
    var $pin = NULL;
    var $profile = array();
    var $archived = NULL;

    public function __construct(
                                    $pin,
                                    $profile,
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

    public function create($data){

        $profile=array();
        foreach($this->profile as $k=>$v){
            $profile[$k] = pg_escape_string(trim(strip_tags($v)));
        }

        foreach($data as $k=>$v){
            $data[$k] = pg_escape_string(trim(strip_tags($v)));
        }        

        $json_profile = array(
            'personal' => array(
                'first_name' => $profile['first_name'],
                'last_name' => $profile['last_name']
            )
        );

        $json_profile = json_encode($json_profile);

        $sql = 'begin;';

        $pin = $this->pin;
        $email_address = $data['email_address'];
        $password = $data['password'];
        $usertype = $data['usertype'];


        $sql .= <<<EOT
                insert into accounts
                (
                    pin,
                    email_address,
                    password,
                    usertype
                )
                values
                (
                    '$pin',
                    '$email_address',
                    '$password',
                    '$usertype'
                );
EOT;

        $sql .= <<<EOT
                insert into profiles
                (
                    pin,
                    profile
                )
                values
                (
                    '$this->pin',
                    '$json_profile'
                );
EOT;

        if ($usertype == 'recruiter'){
            $company_name = $data['company_name'];
            $sql .= <<<EOT
                    insert into companies
                    (
                        name
                    )
                    values
                    (
                        '$company_name',
                        '$json_profile'
                    );
EOT;
        }
        $sql .= 'commit;';
    }

    public function fetch(){
        $sql = <<<EOT
                select
                    *
                from profiles
                where pin = '$this->pin'
                ;
EOT;

        return ClassParent::get($sql);
    }

    
}
?>