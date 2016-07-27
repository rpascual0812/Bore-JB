<?php
require_once('../../../Classes/ClassParent.php');
class Profiles extends ClassParent{
    var $pin = NULL;
    var $profile = array();
    var $date_created = NULL;
    var $archived = NULL;

    public function __construct(
                                    $pin,
                                    $profile,
                                    $date_created,
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
        if ($usertype == 'recruiter')
            $json_profile['contacts'] = array(
                'office_number' => $this->profile['office_number'],
                'extensions' => $this->profile['extensions'],
                'mobile_number' => $this->profile['mobile_number']
        );

        if($usertype == 'candidate'){
            $json_profile['confirmed'] = 'false';
        }

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

            //$template = $this->email_templates($data['email']['template']);

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

        }

        $sql .= 'commit;';

        return ClassParent::insert($sql);
    }

    public function fetch(){
        $sql = <<<EOT
                select
                    pin,
                    profile,
                    case when (date_created + interval '30 days')::date - now()::date > 0 then false else true end as suspended,
                    archived
                from profiles
                where md5(pin) = '$this->pin'
                ;
EOT;

        return ClassParent::get($sql);
    }

    public function update($info){   
        $personal_info = json_encode($info);
        $sql = "begin;";
        $sql .= <<<EOT
            UPDATE profiles
            SET profile = jsonb_set(profile,'{personal_info}',
                '$personal_info',true) WHERE md5(pin)= '$this->pin';
EOT;
        $sql .= "commit;";
        return ClassParent::update($sql);
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

    public function fetch_new_employers(){
        $sql = <<<EOT
                select
                    (select email_address from accounts where pin = profiles.pin) as email_address,
                    profiles.pin,
                    profile,
                    date_created,
                    accounts.usertype
                from profiles left join accounts on (profiles.pin = accounts.pin)
                where accounts.usertype = 'recruiter' 
                ;
EOT;

        return ClassParent::get($sql);
    }
}
?>