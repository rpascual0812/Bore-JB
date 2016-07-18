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

    public function create($data){
        foreach($data as $k=>$v){
            if(is_array($v)){
                foreach($v as $key=>$val){
                    $data[$k][$key] = pg_escape_string(trim(strip_tags($val)));
                }
            }
            else {
                $data[$k] = pg_escape_string(trim(strip_tags($v)));    
            }
        }        

        $json_profile = array(
            'personal' => array(
                'first_name' => $this->profile['first_name'],
                'last_name' => $this->profile['last_name']
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
                    md5('$password'),
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
                        '$company_name'
                    );
EOT;
        }

        if($usertype == 'candidate'){
            $randomString = $this->generateRandomString(20);

            $template = $this->email_templates($data['email']['template']);

            //$data['email']['template'] = $template;
            //$data['email']['return_url'] .= $randomString;

            $email = json_encode($data['email']);

            $sql .= <<<EOT
                    insert into email_notifications
                    (
                        code,
                        email
                    )
                    values
                    (
                        '$randomString',
                        '$email'
                    )
                    ;
EOT;

            $sql .= <<<EOT
                    insert into confirmation
                    (
                        pin
                    )
                    values
                    (
                        '$this->pin'
                    );
EOT;

        }

        $sql .= 'commit;';

        return ClassParent::insert($sql);
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

    private function generateRandomString($length) {
        $characters = '0123456789abcdefghijklmnopqrstuvwxyz';
        $charactersLength = strlen($characters);
        $randomString = '';
        
        for ($i = 0; $i < $length; $i++) {
            $randomString .= $characters[rand(0, $charactersLength - 1)];
        }

        return $randomString;
    }
}
?>