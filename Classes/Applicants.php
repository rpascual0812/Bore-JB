<?php
require_once('../../../Classes/ClassParent.php');
class Applicants extends ClassParent{
    var $pk = NULL;
    var $applicant_id = NULL;
    var $requisitions_pk = NULL;
    var $created_by = NULL;
    var $sources_pk = NULL;
    var $date_created = NULL;
    var $date_received = NULL;
    var $first_name = NULL;
    var $last_name = NULL;
    var $middle_name = NULL;
    var $birthdate = NULL;
    var $profiled_for_pk = NULL;
    var $contact_number = NULL;
    var $email_address = NULL;
    var $clients_pk = NULL;
    var $cv = NULL;

    public function __construct(
                                    $pk,
                                    $applicant_id,
                                    $requisitions_pk,
                                    $created_by,
                                    $sources_pk,
                                    $date_created,
                                    $date_received,
                                    $first_name,
                                    $last_name,
                                    $middle_name,
                                    $birthdate,
                                    $profiled_for_pk,
                                    $contact_number,
                                    $email_address,
                                    $clients_pk,
                                    $cv
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

    function fetch(){
        $sql = <<<EOT
                select
                    pk,
                    applicant_id,
                    applicants.sources_pk,
                    (select source from sources where pk = applicants.sources_pk::int) as source,
                    requisitions_pk,
                    (
                        select
                            requisition_id
                        from requisitions
                        where requisitions.pk = requisitions_pk
                    ) as requisition_id,
                    (
                        select
                            position
                        from requisitions
                        left join job_positions on (requisitions.job_positions_pk = job_positions.pk)
                        where requisitions.pk = requisitions_pk
                    ) as requisition_job_position,
                    (
                         select 
                              case when alternate_title != ''
                              then alternate_title 
                              when alternate_title is null
                              then alternate_title 
                              else (select position from job_positions where job_positions.pk = job_positions_pk) 
                              end 
                         from requisitions
                         where requisitions.pk = applicants.requisitions_pk
                    ) as requisition,
                    created_by,
                    date_created::timestamp(0) as date_created,
                    date_received::date as date_received,
                    date_received::time as time_received,
                    (select employees_pk from applicants_talent_acquisition where applicants_pk = pk order by date_created desc limit 1) as talent_acquisitions_pk,
                    (select employee from applicants_talent_acquisition left join employees_permission on (applicants_talent_acquisition.employees_pk = employees_permission.employees_pk) where applicants_talent_acquisition.applicants_pk = pk order by applicants_talent_acquisition.date_created desc limit 1) as talent_acquisition,
                    -- date_interaction,
                    -- time_completed,
                    -- over_due,
                    -- (select min(date_created) from applicants_status where applicants_pk = pk) as date_interaction,
                    -- (select min(date_created) - applicants.date_created from applicants_status where applicants_pk = pk) as time_interval,
                    first_name,
                    last_name,
                    middle_name,
                    birthdate::date as birthdate,
                    applicants.job_positions_pk,
                    (select position from job_positions where pk = job_positions_pk) as job_position,
                    contact_number,
                    email_address,
                    (select max(endorsement::date) from applicants_endorser where applicants_pk = pk) as endorsement_date,
                    (select max(appointment::date) from applicants_appointer where applicants_pk = pk) as appointment_date,
                    -- endorcer,
                    -- endorcement_date,
                    applicants.clients_pk,
                    (select client from clients where pk = applicants.clients_pk) as client,
                    cv,
                    statuses_pk,
                    (
                        select 
                            status 
                        from statuses
                        left join applicants_status on (statuses.pk = applicants_status.statuses_pk) 
                        where applicants_status.applicants_pk = applicants.pk
                        order by applicants_status.date_created desc limit 1
                    ) as status
                from applicants
                where applicant_id = '$this->applicant_id'
                ;
EOT;

        return ClassParent::get($sql);
    }

    function employer_feeds(){
        $sql = <<<EOT
                select
                    *,
                    (
                        select 
                            status 
                        from statuses
                        left join applicants_status on (statuses.pk = applicants_status.statuses_pk) 
                        where applicants_status.applicants_pk = applicants.pk
                        order by applicants_status.date_created desc limit 1
                    ) as status,
                    (
                        select 
                            status 
                        from external_statuses
                        left join applicants_external_status on (external_statuses.pk = applicants_external_status.external_statuses_pk) 
                        where applicants_external_status.applicants_pk = applicants.pk
                        order by applicants_external_status.date_created desc limit 1
                    ) as external_status,
                    array_to_string(applicants_tags.tags, ',') as tags,
                    case when trunc(random() * 2) = 1 then true else false end as online
                from applicants
                left join applicants_logs on (applicants.pk = applicants_logs.applicants_pk)
                left join applicants_tags on (applicants.pk = applicants_tags.applicants_pk)
                order by applicants_logs.date_created desc
                ;
EOT;

        return ClassParent::get($sql);
    }
}
?>