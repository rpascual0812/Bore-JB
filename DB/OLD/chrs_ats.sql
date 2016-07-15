--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: plpythonu; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: wennie
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpythonu;


ALTER PROCEDURAL LANGUAGE plpythonu OWNER TO wennie;

SET search_path = public, pg_catalog;

--
-- Name: insertlogs(); Type: FUNCTION; Schema: public; Owner: wennie
--

CREATE FUNCTION insertlogs() RETURNS trigger
    LANGUAGE plpythonu
    AS $_$

def generatecomment(colname, colordinal):
    comment = None
    exceptlist = ['pk','date_created','created_by','applicant_id']
    coldesc = plpy.execute("select col_description("+ repr(TD['relid']) +", "+ repr(colordinal) +")")

    if colname not in exceptlist:
        ##ANONYMOUS COLUMN -- APPLIES TO ALL TABLES
        if colname == 'archived':
            if TD['old']['archived'] <> TD['new']['archived']:
                oldval=""
                newval=""

                if TD['old']['archived'] == True:
                    oldval = 'Disabled'
                else:
                    oldval = 'Enabled'

                if TD['new']['archived'] == True:
                    newval = 'Disabled'
                else:
                    newval = 'Enabled'

                comment = str(coldesc[0].get('col_description')) + ' was changed from ' + str(oldval) + ' to ' + str(newval)
            else:
                pass
        ##APPLICANTS TABLE
        elif TD['table_name'] == "applicants":
            if colname == 'profiled_for':
                if TD['old']['profiled_for'] <> TD['new']['profiled_for']:
                    oldval=""
                    oldvalq = plpy.execute("SELECT position from job_positions where pk = "+ str(TD['old']['profiled_for']))
                    for i in oldvalq:
                        oldval = i['position']

                    newval=""
                    newvalq = plpy.execute("SELECT position from job_positions where pk = "+ str(TD['new']['profiled_for']))
                    for i in newvalq:
                        newval = i['position']

                    comment = str(coldesc[0].get('col_description')) + ' was changed from ' + str(oldval) + ' to ' + str(newval)
                else:
                    pass

        
            elif colname == 'status':
                if TD['old']['status'] <> TD['new']['status']:
                    oldval=""
                    oldvalq = plpy.execute("SELECT status from statuses where pk = "+ str(TD['old']['status']))
                    for i in oldvalq:
                        oldval = i['status']

                    newval=""
                    newvalq = plpy.execute("SELECT status from statuses where pk = "+ str(TD['new']['status']))
                    for i in newvalq:
                        newval = i['status']

                    comment = str(coldesc[0].get('col_description')) + ' was changed from ' + str(oldval) + ' to ' + str(newval)
                else:
                    pass

            elif colname == 'source':
                if TD['old']['source'] <> TD['new']['source']:
                    oldval=""
                    oldvalq = plpy.execute("SELECT source from sources where pk = "+ str(TD['old']['source']))
                    for i in oldvalq:
                        oldval = i['source']

                    newval=""
                    newvalq = plpy.execute("SELECT source from sources where pk = "+ str(TD['new']['source']))
                    for i in newvalq:
                        newval = i['source']

                    comment = str(coldesc[0].get('col_description')) + ' was changed from ' + str(oldval) + ' to ' + str(newval)
                else:
                    pass

            elif colname == 'cv':
                if TD['old']['cv'] <> TD['new']['cv']:
                    #a = strip_tags('<a ng-click="download_cv("'+ str(TD['old']['cv']) +'")" >Old</a>')
                    #b = strip_tags('<a ng-click="download_cv("'+ str(TD['new']['cv']) +'")" >New</a>')
                    a = '"' + str(TD["old"]["cv"]) + '"'
                    b = '"' + str(TD["new"]["cv"]) + '"'
                    c = "<a ng-click='download_cv("+ a +")'>Old</a>"
                    d = "<a ng-click='download_cv("+ b +")'>New</a>"
                    comment = str(coldesc[0].get('col_description')) + ' was changed from '+ c +' to '+ d
                else:
                    pass
            
        ##END APPLICANTS TABLE
        elif TD['table_name'] == "clients":
        ##CLIENTS TABLE
            if colname == 'code':
                if TD['old']['code'] <> TD['new']['code']:
                    comment = str(coldesc[0].get('col_description')) + ' was changed from ' + str(TD['old']['code']) + ' to ' + str(TD['new']['code'])
                else:
                    pass

            elif colname == 'client':
                if TD['old']['client'] <> TD['new']['client']:
                    comment = str(coldesc[0].get('col_description')) + ' was changed from ' + str(TD['old']['client']) + ' to ' + str(TD['new']['client'])
                else:
                    pass

        ##END OF CLIENTS TABLE

        elif TD['table_name'] == "sources":
        ##SOURCES TABLE
            if colname == 'source':
                if TD['old']['source'] <> TD['new']['source']:
                    comment = str(coldesc[0].get('col_description')) + ' was changed from ' + str(TD['old']['source']) + ' to ' + str(TD['new']['source'])
                else:
                    pass
        ##END OF SOURCES TABLE

        

            
        ##END OF ANONYMOUS COLUMN -- APPLIES TO ALL

            return comment
    else:
        pass

#def strip_tags(html):

    #SELECT regexp_replace(regexp_replace($1, E'(?x)<[^>]*?(\s alt \s* = \s* ([\'"]) ([^>]*?) \2) [^>]*? >', E'\3'), E'(?x)(< [^>]*? >)', '', 'g')
    #return plpy.execute("SELECT regexp_replace(regexp_replace("+html+", E'(?x)<[^>]*?(\s alt \s* = \s* ([\'\"]) ([^>]*?) \2) [^>]*? >', E'\3'), E'(?x)(< [^>]*? >)', '', 'g')")

tablename = TD['table_name']
tablecols = plpy.execute("SELECT attname, attnum from pg_attribute where attrelid = (select distinct(tableoid) from "+ tablename +") and attnum > 0 and attisdropped = 'f'")
systemcomment = []

for i in tablecols:
    data = generatecomment(i['attname'], i['attnum'])
    if data:
       	systemcomment.append(data)

if systemcomment:
    systemcomment = '\n'.join(systemcomment)

    if tablename in ['applicants','applicants_tags']:
        plpy.execute("insert into applicants_logs(applicants_pk,type,details,created_by) values ("+ str(TD['old']['pk']) +", $$Logs$$, $$"+ str(systemcomment) + "$$, $$0$$);")
    elif tablename in ['job_positions']:
        plpy.execute("insert into job_positions_logs(position_pk,type,details,created_by) values ("+ str(TD['old']['pk']) +", $$Logs$$, $$"+ str(systemcomment) + "$$, $$0$$);")
    elif tablename in ['clients']:
        plpy.execute("insert into clients_logs(client_pk,type,details,created_by) values ("+ str(TD['old']['pk']) +", $$Logs$$, $$"+ str(systemcomment) + "$$, $$0$$);")
    elif tablename in ['sources']:
        plpy.execute("insert into sources_logs(source_pk,type,details,created_by) values ("+ str(TD['old']['pk']) +", $$Logs$$, $$"+ str(systemcomment) + "$$, $$0$$);")                

$_$;


ALTER FUNCTION public.insertlogs() OWNER TO wennie;

--
-- Name: strip_tags(text); Type: FUNCTION; Schema: public; Owner: wennie
--

CREATE FUNCTION strip_tags(text) RETURNS text
    LANGUAGE sql
    AS $_$
    SELECT regexp_replace(regexp_replace($1, E'(?x)<[^>]*?(\s alt \s* = \s* ([\'"]) ([^>]*?) \2) [^>]*? >', E'\3'), E'(?x)(< [^>]*? >)', '', 'g')
$_$;


ALTER FUNCTION public.strip_tags(text) OWNER TO wennie;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: applicants; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE applicants (
    pk integer NOT NULL,
    applicant_id text NOT NULL,
    sources_pk text NOT NULL,
    created_by integer NOT NULL,
    date_created timestamp with time zone DEFAULT now() NOT NULL,
    date_received timestamp with time zone NOT NULL,
    date_interaction timestamp with time zone,
    time_completed timestamp with time zone,
    over_due boolean DEFAULT false,
    first_name text NOT NULL,
    last_name text NOT NULL,
    middle_name text,
    birthdate timestamp with time zone,
    job_positions_pk integer,
    contact_number text NOT NULL,
    endorcer text,
    endorcement_date timestamp with time zone,
    clients_pk integer,
    cv text NOT NULL,
    email_address text,
    appointment_date timestamp with time zone,
    statuses_pk integer DEFAULT 1554,
    requisitions_pk integer
);


ALTER TABLE public.applicants OWNER TO cats;

--
-- Name: COLUMN applicants.sources_pk; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.sources_pk IS 'SOURCE';


--
-- Name: COLUMN applicants.date_received; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.date_received IS 'DATE RECEIVED';


--
-- Name: COLUMN applicants.date_interaction; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.date_interaction IS 'DATE INTERACTION';


--
-- Name: COLUMN applicants.time_completed; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.time_completed IS 'TIME COMPLETED';


--
-- Name: COLUMN applicants.over_due; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.over_due IS 'OVERDUE';


--
-- Name: COLUMN applicants.first_name; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.first_name IS 'FIRST NAME';


--
-- Name: COLUMN applicants.last_name; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.last_name IS 'LAST NAME';


--
-- Name: COLUMN applicants.middle_name; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.middle_name IS 'MIDDLE NAME';


--
-- Name: COLUMN applicants.birthdate; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.birthdate IS 'BIRTHDATE';


--
-- Name: COLUMN applicants.job_positions_pk; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.job_positions_pk IS 'PROFILED FOR';


--
-- Name: COLUMN applicants.contact_number; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.contact_number IS 'CONTACT NUMBER';


--
-- Name: COLUMN applicants.endorcer; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.endorcer IS 'ENDORCER';


--
-- Name: COLUMN applicants.endorcement_date; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.endorcement_date IS 'ENDORCEMENT DATE';


--
-- Name: COLUMN applicants.clients_pk; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.clients_pk IS 'CLIENT';


--
-- Name: COLUMN applicants.cv; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.cv IS 'CV';


--
-- Name: COLUMN applicants.email_address; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.email_address IS 'EMAIL ADDRESS';


--
-- Name: COLUMN applicants.appointment_date; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.appointment_date IS 'APPOINTMENT DATE';


--
-- Name: COLUMN applicants.statuses_pk; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.statuses_pk IS 'STATUS';


--
-- Name: COLUMN applicants.requisitions_pk; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants.requisitions_pk IS 'REQUISITION';


--
-- Name: applicants_appointer; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE applicants_appointer (
    applicants_pk integer,
    employees_pk integer,
    date_created timestamp with time zone DEFAULT now(),
    appointment timestamp with time zone
);


ALTER TABLE public.applicants_appointer OWNER TO cats;

--
-- Name: applicants_endorser; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE applicants_endorser (
    applicants_pk integer,
    employees_pk integer,
    date_created timestamp with time zone DEFAULT now(),
    endorsement timestamp with time zone
);


ALTER TABLE public.applicants_endorser OWNER TO cats;

--
-- Name: applicants_external_status; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE applicants_external_status (
    applicants_pk integer,
    external_statuses_pk integer,
    created_by integer NOT NULL,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE public.applicants_external_status OWNER TO cats;

--
-- Name: applicants_logs; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE applicants_logs (
    applicants_pk integer,
    type text NOT NULL,
    details text NOT NULL,
    created_by integer NOT NULL,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE public.applicants_logs OWNER TO cats;

--
-- Name: applicants_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE applicants_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.applicants_pk_seq OWNER TO cats;

--
-- Name: applicants_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE applicants_pk_seq OWNED BY applicants.pk;


--
-- Name: applicants_remarks; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE applicants_remarks (
    applicants_pk integer,
    remarks text NOT NULL,
    created_by integer NOT NULL,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE public.applicants_remarks OWNER TO cats;

--
-- Name: applicants_status; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE applicants_status (
    applicants_pk integer,
    statuses_pk integer NOT NULL,
    created_by integer NOT NULL,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE public.applicants_status OWNER TO cats;

--
-- Name: applicants_tags; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE applicants_tags (
    applicants_pk integer,
    tags text[] NOT NULL
);


ALTER TABLE public.applicants_tags OWNER TO cats;

--
-- Name: COLUMN applicants_tags.tags; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN applicants_tags.tags IS 'TAGS';


--
-- Name: applicants_talent_acquisition; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE applicants_talent_acquisition (
    applicants_pk integer,
    employees_pk integer,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE public.applicants_talent_acquisition OWNER TO cats;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE clients (
    pk integer NOT NULL,
    code text NOT NULL,
    client text NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE public.clients OWNER TO cats;

--
-- Name: COLUMN clients.code; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN clients.code IS 'CODE';


--
-- Name: COLUMN clients.client; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN clients.client IS 'CLIENT';


--
-- Name: COLUMN clients.archived; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN clients.archived IS 'STATUS';


--
-- Name: clients_logs; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE clients_logs (
    client_pk integer,
    type text NOT NULL,
    details text NOT NULL,
    created_by integer NOT NULL,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE public.clients_logs OWNER TO cats;

--
-- Name: clients_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE clients_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clients_pk_seq OWNER TO cats;

--
-- Name: clients_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE clients_pk_seq OWNED BY clients.pk;


--
-- Name: employees_permission; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE employees_permission (
    employees_pk integer NOT NULL,
    employee_id text NOT NULL,
    employee text NOT NULL,
    roles_pk integer,
    title text,
    department text[],
    supervisor integer,
    permission json
);


ALTER TABLE public.employees_permission OWNER TO cats;

--
-- Name: COLUMN employees_permission.roles_pk; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN employees_permission.roles_pk IS 'ROLE';


--
-- Name: employees_permission_logs; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE employees_permission_logs (
    employees_pk integer,
    type text NOT NULL,
    details text NOT NULL,
    created_by integer NOT NULL,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE public.employees_permission_logs OWNER TO cats;

--
-- Name: external_statuses; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE external_statuses (
    pk integer NOT NULL,
    status text NOT NULL,
    seq integer NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE public.external_statuses OWNER TO cats;

--
-- Name: external_statuses_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE external_statuses_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.external_statuses_pk_seq OWNER TO cats;

--
-- Name: external_statuses_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE external_statuses_pk_seq OWNED BY external_statuses.pk;


--
-- Name: job_positions; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE job_positions (
    pk integer NOT NULL,
    "position" text NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE public.job_positions OWNER TO cats;

--
-- Name: COLUMN job_positions."position"; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN job_positions."position" IS 'PROFILE';


--
-- Name: COLUMN job_positions.archived; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN job_positions.archived IS 'STATUS';


--
-- Name: job_positions_logs; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE job_positions_logs (
    position_pk integer,
    type text NOT NULL,
    details text NOT NULL,
    created_by integer NOT NULL,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE public.job_positions_logs OWNER TO cats;

--
-- Name: job_positions_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE job_positions_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_positions_pk_seq OWNER TO cats;

--
-- Name: job_positions_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE job_positions_pk_seq OWNED BY job_positions.pk;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE notifications (
    employees_pk integer NOT NULL,
    notification text NOT NULL,
    type text NOT NULL,
    table_pk integer NOT NULL,
    date_created timestamp with time zone DEFAULT now(),
    read boolean DEFAULT false,
    pk integer NOT NULL
);


ALTER TABLE public.notifications OWNER TO cats;

--
-- Name: notifications_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE notifications_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_pk_seq OWNER TO cats;

--
-- Name: notifications_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE notifications_pk_seq OWNED BY notifications.pk;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE permissions (
    pk integer NOT NULL,
    parent text NOT NULL,
    item text NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE public.permissions OWNER TO cats;

--
-- Name: permissions_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE permissions_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.permissions_pk_seq OWNER TO cats;

--
-- Name: permissions_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE permissions_pk_seq OWNED BY permissions.pk;


--
-- Name: reminders; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE reminders (
    pk integer NOT NULL,
    message text NOT NULL,
    remind_on timestamp with time zone,
    date_created timestamp with time zone DEFAULT now(),
    created_by integer
);


ALTER TABLE public.reminders OWNER TO cats;

--
-- Name: reminders_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE reminders_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reminders_pk_seq OWNER TO cats;

--
-- Name: reminders_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE reminders_pk_seq OWNED BY reminders.pk;


--
-- Name: requisitions; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE requisitions (
    pk integer NOT NULL,
    job_positions_pk integer NOT NULL,
    total integer NOT NULL,
    created_by integer,
    date_created timestamp with time zone DEFAULT now(),
    archived boolean DEFAULT false,
    end_date timestamp with time zone,
    requisition_id text,
    alternate_title text
);


ALTER TABLE public.requisitions OWNER TO cats;

--
-- Name: COLUMN requisitions.job_positions_pk; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN requisitions.job_positions_pk IS 'PROFILE';


--
-- Name: COLUMN requisitions.total; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN requisitions.total IS 'TOTAL';


--
-- Name: COLUMN requisitions.archived; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN requisitions.archived IS 'STATUS';


--
-- Name: COLUMN requisitions.end_date; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN requisitions.end_date IS 'END DATE';


--
-- Name: requisitions_logs; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE requisitions_logs (
    requisitions_pk integer,
    type text NOT NULL,
    details text NOT NULL,
    created_by integer NOT NULL,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE public.requisitions_logs OWNER TO cats;

--
-- Name: requisitions_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE requisitions_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.requisitions_pk_seq OWNER TO cats;

--
-- Name: requisitions_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE requisitions_pk_seq OWNED BY requisitions.pk;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE roles (
    pk integer NOT NULL,
    role text NOT NULL,
    archived boolean DEFAULT false,
    r_order integer NOT NULL
);


ALTER TABLE public.roles OWNER TO cats;

--
-- Name: roles_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE roles_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_pk_seq OWNER TO cats;

--
-- Name: roles_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE roles_pk_seq OWNED BY roles.pk;


--
-- Name: sources; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE sources (
    pk integer NOT NULL,
    source text NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE public.sources OWNER TO cats;

--
-- Name: COLUMN sources.source; Type: COMMENT; Schema: public; Owner: cats
--

COMMENT ON COLUMN sources.source IS 'SOURCE';


--
-- Name: sources_logs; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE sources_logs (
    source_pk integer,
    type text NOT NULL,
    details text NOT NULL,
    created_by integer NOT NULL,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE public.sources_logs OWNER TO cats;

--
-- Name: sources_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE sources_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sources_pk_seq OWNER TO cats;

--
-- Name: sources_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE sources_pk_seq OWNED BY sources.pk;


--
-- Name: statuses; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE statuses (
    pk integer NOT NULL,
    status text NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE public.statuses OWNER TO cats;

--
-- Name: statuses_pk_seq; Type: SEQUENCE; Schema: public; Owner: cats
--

CREATE SEQUENCE statuses_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.statuses_pk_seq OWNER TO cats;

--
-- Name: statuses_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cats
--

ALTER SEQUENCE statuses_pk_seq OWNED BY statuses.pk;


--
-- Name: talent_acquisition_group; Type: TABLE; Schema: public; Owner: cats; Tablespace: 
--

CREATE TABLE talent_acquisition_group (
    employees_pk integer NOT NULL,
    supervisor_pk integer NOT NULL
);


ALTER TABLE public.talent_acquisition_group OWNER TO cats;

--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants ALTER COLUMN pk SET DEFAULT nextval('applicants_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY clients ALTER COLUMN pk SET DEFAULT nextval('clients_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY external_statuses ALTER COLUMN pk SET DEFAULT nextval('external_statuses_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY job_positions ALTER COLUMN pk SET DEFAULT nextval('job_positions_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY notifications ALTER COLUMN pk SET DEFAULT nextval('notifications_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY permissions ALTER COLUMN pk SET DEFAULT nextval('permissions_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY reminders ALTER COLUMN pk SET DEFAULT nextval('reminders_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY requisitions ALTER COLUMN pk SET DEFAULT nextval('requisitions_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY roles ALTER COLUMN pk SET DEFAULT nextval('roles_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY sources ALTER COLUMN pk SET DEFAULT nextval('sources_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: cats
--

ALTER TABLE ONLY statuses ALTER COLUMN pk SET DEFAULT nextval('statuses_pk_seq'::regclass);


--
-- Data for Name: applicants; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY applicants (pk, applicant_id, sources_pk, created_by, date_created, date_received, date_interaction, time_completed, over_due, first_name, last_name, middle_name, birthdate, job_positions_pk, contact_number, endorcer, endorcement_date, clients_pk, cv, email_address, appointment_date, statuses_pk, requisitions_pk) FROM stdin;
47	8Z726U	6	28	2016-02-15 10:07:29.744397+08	2016-02-15 10:05:00+08	\N	\N	f	Scarlett	Johansson	A.	1111-11-11 00:00:00-15:56	742	1111-111-1111	\N	\N	288	../ASSETS/uploads/CV/20160215/201602151007VG68siU5B336RBMYC7n5.doc	aslkdjfaksdjfklasjdfklj	\N	1554	\N
2	9F5J32	7	160002	2016-02-01 09:30:38.026818+08	2016-02-25 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	1231-312-3123	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
3	7W798T	7	160002	2016-02-01 11:24:11.843109+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
4	H565Q1	7	160002	2016-02-01 11:24:12.698046+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
5	W873A2	7	160002	2016-02-01 11:24:13.181187+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
6	W5619M	7	160002	2016-02-01 11:24:13.378588+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
7	79KN54	7	160002	2016-02-01 11:24:13.572926+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
8	36B55J	7	160002	2016-02-01 11:24:13.755158+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
9	7828PE	7	160002	2016-02-01 11:24:13.928068+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
10	L53T79	7	160002	2016-02-01 11:24:14.113647+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
11	69MA68	7	160002	2016-02-01 11:24:14.287924+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
12	AA8374	7	160002	2016-02-01 11:24:14.471425+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
13	P898P4	7	160002	2016-02-01 11:24:14.635086+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
14	E88C61	7	160002	2016-02-01 11:24:14.833337+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
15	578B3C	7	160002	2016-02-01 11:24:15.019139+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
16	9893SN	7	160002	2016-02-01 11:24:15.182542+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
17	W5A571	7	160002	2016-02-01 11:24:15.36527+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
18	51K3F1	7	160002	2016-02-01 11:24:15.537415+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
19	4J5F73	7	160002	2016-02-01 11:24:15.716331+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
20	16T7S2	7	160002	2016-02-01 11:24:15.883096+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
36	K53U51	3	1	2016-02-09 16:10:34.96185+08	2016-02-09 16:10:00+08	\N	\N	f	kajsd	ksladflkajsdf	klasjdfklajsdf	1234-12-12 00:00:00-15:56	1106	1231-241-3423	\N	\N	3		x,mvcnzx,cmvnz,mcvnzxcmv,	\N	982	\N
32	8Q684K	7	160002	2016-02-04 07:20:58.167889+08	2016-02-04 07:20:00+08	\N	\N	f	Rafael	Pascual	Aurelio	1986-08-12 00:00:00+08	246	0906-447-1398	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
34	5F1R39	4	1	2016-02-07 16:34:40.61068+08	2016-02-05 14:10:00+08	\N	\N	f	Ni	Ichi	San	1987-02-12 00:00:00+08	556	1231-231-2312	\N	\N	20	CV	kalsdjfaskdf@gmail.com	\N	1554	\N
21	72KZ64	7	160002	2016-02-01 11:24:16.067766+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
22	6A962H	7	160002	2016-02-01 11:24:16.23542+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
23	64D33D	7	160002	2016-02-01 11:24:16.420873+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
24	127MM8	7	160002	2016-02-01 11:24:16.584765+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
25	166JR9	7	160002	2016-02-01 11:24:16.782973+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
26	4Z39V4	7	160002	2016-02-01 11:24:16.947663+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
27	83N8F6	7	160002	2016-02-01 11:24:17.11857+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
28	781HJ9	7	160002	2016-02-01 11:24:17.300448+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
29	KZ1755	7	160002	2016-02-01 11:24:17.481063+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
30	88FN48	7	160002	2016-02-01 11:24:17.635189+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
31	ZN2583	7	160002	2016-02-01 11:24:17.816481+08	2016-02-18 00:00:00+08	\N	\N	f	two	one	three	1233-12-12 00:00:00-15:56	246	4324-234-2423	\N	\N	349	CV	noemail@chrsglobal.com	\N	1554	\N
43	9L43D3	3	1	2016-02-14 08:24:29.638347+08	2016-02-13 08:25:00+08	\N	\N	f	aa	aaa	a	1111-11-11 00:00:00-15:56	899	1111-111-1111	\N	\N	87	../ASSETS/uploads/CV/20160214/201602140824mT7VmTMRlexNE39Tbo1J.pdf	alskdjfklasjdfklasd	\N	1100	\N
40	KR1984	3	1	2016-02-12 09:35:03.291614+08	2016-02-12 09:35:00+08	\N	\N	f	Rafael	Pascual	Aurelio	1986-08-12 00:00:00+08	742	1231-231-2312	\N	\N	288	../ASSETS/uploads/CV/20160214/201602140635uZBlDmQ2Yt7rEeLEV1hH.doc	skfjasklfjkasjfd	\N	1554	\N
35	2356ZU	4	1	2016-02-09 16:07:46.897155+08	2016-02-09 16:05:00+08	\N	\N	f	b	a	c	1234-12-12 00:00:00-15:56	556	1231-231-2312	\N	\N	146	CV	abc@yahoo.com	\N	1554	\N
45	A8776V	5	1	2016-02-14 12:21:23.569225+08	2016-02-14 12:20:00+08	\N	\N	f	Tom	Jerry	&	1111-11-11 00:00:00-15:56	618	1111-111-1111	\N	\N	171	../ASSETS/uploads/CV/20160214/201602141220Fc5JG3W3lSUBgJegUUr5.doc	ajsdkfjaskldfjklasdf	\N	982	\N
48	P2621L	4	28	2016-02-15 13:30:13.584056+08	2016-02-15 13:30:00+08	\N	\N	f	ni	ichi	san	1111-11-11 00:00:00-15:56	618	1111-111-1111	\N	\N	66	../ASSETS/uploads/CV/20160215/201602151329zDyXrW25g0KcMo4uxDBE.doc	jfaksdjfkjsdlf	\N	1554	\N
51	79E3D7	4	28	2016-02-15 14:14:22.354009+08	2016-02-15 14:15:00+08	\N	\N	f	bbbbbb	aaaaaaa	ccccccc	1111-11-11 00:00:00-15:56	742	1111-111-1111	\N	\N	300	../ASSETS/uploads/CV/20160215/2016021514139oH9gnJIRARnVEBKGLyr.doc	kljsdfaksdfkalsdf	\N	812	\N
55	Z997T5	6	28	2016-03-19 11:31:39.587352+08	2016-03-19 10:25:00+08	\N	\N	f	lkfj	asldfjas	kalsdjfkasld	1986-01-11 00:00:00+08	618	2342-342-3423	\N	\N	300	../ASSETS/uploads/CV/20160319/201603191159lI91Rra5mzZ8mEHCE0N7.jpg	dofajsdfasdfasdjfos@	\N	402	11
56	83Q5F1	17	27	2016-04-01 13:42:44.91917+08	2016-04-01 13:40:00+08	\N	\N	f	Gokou	Son	Daw	1984-12-12 00:00:00+08	598	1231-231-2312	\N	\N	375	../ASSETS/uploads/CV/20160401/201604011342gMPebUJpuLtPZrb45mUJ.pdf	sdkfjaksdfjkjf@gouku.com	\N	1554	12
57	88N2R2	3	28	2016-05-15 17:05:57.799348+08	2016-05-14 15:15:00+08	\N	\N	f	s;ldfklk	sdfasdf	kasldfjskadf	2014-09-09 00:00:00+08	742	1231-231-2312	\N	\N	300	null	askdfjlksdjfkl@gmail.com	\N	1000	13
58	425EM1	3	28	2016-06-01 17:27:59.612882+08	2016-06-01 17:25:00+08	\N	\N	f	kljaskldjf	sksladjf	kljaklsjdflk	1923-09-09 00:00:00+08	618	3323-423-4234	\N	\N	288	../ASSETS/uploads/CV/20160601/201606011727Wz6D1diyIliLOfVKf8r5.pdf	kajsdflkjaskfj	\N	1554	14
59	PA6351	8	28	2016-06-03 13:05:50.57265+08	2016-06-03 09:05:00+08	\N	\N	f	Patrick	Rimando	NA	1995-05-29 00:00:00+08	725	0929-865-7948	\N	\N	87	../ASSETS/uploads/CV/20160603/201606031305jnuTzK9K3XKmwRol8L2P.doc	pachpogi245@gmail.com	\N	1554	14
\.


--
-- Data for Name: applicants_appointer; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY applicants_appointer (applicants_pk, employees_pk, date_created, appointment) FROM stdin;
\.


--
-- Data for Name: applicants_endorser; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY applicants_endorser (applicants_pk, employees_pk, date_created, endorsement) FROM stdin;
55	28	2016-03-22 12:40:37.981225+08	2016-03-21 17:00:00+08
\.


--
-- Data for Name: applicants_external_status; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY applicants_external_status (applicants_pk, external_statuses_pk, created_by, date_created) FROM stdin;
47	3	27	2016-06-19 23:06:37.106526+08
2	3	27	2016-06-19 23:06:37.106526+08
3	3	27	2016-06-19 23:06:37.106526+08
4	3	27	2016-06-19 23:06:37.106526+08
5	3	27	2016-06-19 23:06:37.106526+08
6	3	27	2016-06-19 23:06:37.106526+08
7	3	27	2016-06-19 23:06:37.106526+08
8	3	27	2016-06-19 23:06:37.106526+08
9	3	27	2016-06-19 23:06:37.106526+08
10	3	27	2016-06-19 23:06:37.106526+08
11	3	27	2016-06-19 23:06:37.106526+08
12	3	27	2016-06-19 23:06:37.106526+08
13	3	27	2016-06-19 23:06:37.106526+08
14	3	27	2016-06-19 23:06:37.106526+08
15	3	27	2016-06-19 23:06:37.106526+08
16	3	27	2016-06-19 23:06:37.106526+08
17	3	27	2016-06-19 23:06:37.106526+08
18	3	27	2016-06-19 23:06:37.106526+08
19	3	27	2016-06-19 23:06:37.106526+08
20	3	27	2016-06-19 23:06:37.106526+08
36	3	27	2016-06-19 23:06:37.106526+08
32	3	27	2016-06-19 23:06:37.106526+08
34	3	27	2016-06-19 23:06:37.106526+08
21	3	27	2016-06-19 23:06:37.106526+08
22	3	27	2016-06-19 23:06:37.106526+08
23	3	27	2016-06-19 23:06:37.106526+08
24	3	27	2016-06-19 23:06:37.106526+08
25	3	27	2016-06-19 23:06:37.106526+08
26	3	27	2016-06-19 23:06:37.106526+08
27	3	27	2016-06-19 23:06:37.106526+08
28	3	27	2016-06-19 23:06:37.106526+08
29	3	27	2016-06-19 23:06:37.106526+08
30	3	27	2016-06-19 23:06:37.106526+08
31	3	27	2016-06-19 23:06:37.106526+08
43	3	27	2016-06-19 23:06:37.106526+08
40	3	27	2016-06-19 23:06:37.106526+08
35	3	27	2016-06-19 23:06:37.106526+08
45	3	27	2016-06-19 23:06:37.106526+08
48	3	27	2016-06-19 23:06:37.106526+08
51	3	27	2016-06-19 23:06:37.106526+08
55	3	27	2016-06-19 23:06:37.106526+08
56	3	27	2016-06-19 23:06:37.106526+08
57	3	27	2016-06-19 23:06:37.106526+08
58	3	27	2016-06-19 23:06:37.106526+08
59	3	27	2016-06-19 23:06:37.106526+08
\.


--
-- Data for Name: applicants_logs; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY applicants_logs (applicants_pk, type, details, created_by, date_created) FROM stdin;
35	Logs	PROFILED FOR was changed from Accenture-Mandarin to ACN Ops HR People Advisor Manager	0	2016-02-11 08:36:43.576781+08
35	Remarks	asdkfajsdf	1	2016-02-11 08:36:43.576781+08
35	Logs	CLIENT was changed from Accenture to DSLMC	0	2016-02-11 08:48:34.997124+08
35	Remarks	Changed client ^_^	1	2016-02-11 08:48:34.997124+08
35	Logs	SOURCE was changed from Avaya Voice Network to CebuJobs	0	2016-02-11 08:52:15.610152+08
35	Remarks	laskdfklasdf	1	2016-02-11 08:52:15.610152+08
35	Logs	FIRST NAME was changed from jalksdjfkljasdf to b\nLAST NAME was changed from slfjlkasdjfkl to a\nMIDDLE NAME was changed from klasjdlkfajdsf to c	0	2016-02-11 08:53:30.364177+08
35	Remarks	lskdajfklasdf	1	2016-02-11 08:53:30.364177+08
35	Logs	EMAIL ADDRESS was changed from klajsdfkjaldkfjasdf to abc@yahoo.com	0	2016-02-11 09:14:39.247012+08
35	Remarks	adsfjasdklfjasdlk	1	2016-02-11 09:14:39.247012+08
40	Logs	Added new applicant.	1	2016-02-12 09:35:03.291614+08
40	Logs	CV was changed from ../ASSETS/uploads/CV/20160212/20160212093504DapA0OX6qVn0oB7Vqn.doc to ../ASSETS/uploads/CV/20160213/2016021309460LGhGjCByxsI0nwicEor.pdf	0	2016-02-13 09:46:45.661898+08
40	Remarks	aksldjklafs	1	2016-02-13 09:46:45.661898+08
40	Logs	CV was changed from <a ng-click="download_cv(../ASSETS/uploads/CV/20160213/2016021309460LGhGjCByxsI0nwicEor.pdf)" >Old</a> to <a ng-click="download_cv(../ASSETS/uploads/CV/20160213/201602130956qnZdvx3RtnudfBLMf80J.doc)" >New</a>	0	2016-02-13 09:56:41.762971+08
40	Remarks	askdfkalsdjf	1	2016-02-13 09:56:41.762971+08
40	Logs	CV was changed from <a ng-click="download_cv("../ASSETS/uploads/CV/20160213/201602130956qnZdvx3RtnudfBLMf80J.doc")" >Old</a> to <a ng-click="download_cv("../ASSETS/uploads/CV/20160213/201602131834RkmhTNppfwUfikmoMtNa.pdf")" >New</a>	0	2016-02-13 18:34:00.467426+08
40	Remarks	sdfsd	1	2016-02-13 18:34:00.467426+08
40	Logs	CV was changed from <a ng-click='download_cv('../ASSETS/uploads/CV/20160213/201602131834RkmhTNppfwUfikmoMtNa.pdf')' >Old</a> to <a ng-click='download_cv('../ASSETS/uploads/CV/20160213/201602131836PT7sErUwrO6lC5S7iUgS.doc')' >New</a>	0	2016-02-13 18:36:12.090059+08
40	Remarks	sdfsdsdf	1	2016-02-13 18:36:12.090059+08
40	Logs	CV was changed from <a ng-click='download_cv(+ str(TD["old"]["cv"]) +)' >Old</a> to <a ng-click='download_cv(+ str(TD["new"]["cv"]) +)' >New</a>	0	2016-02-13 18:39:48.559495+08
40	Remarks	sdfsdsdf	1	2016-02-13 18:39:48.559495+08
40	Logs	CV was changed from <a ng-click='download_cv("../ASSETS/uploads/CV/20160213/201602131839Tx6woYhbWYSQgPtnICHK.pdf")'>Old</a> to <a ng-click='download_cv("../ASSETS/uploads/CV/20160213/201602131843ZyHDGZIr1oxKhQbOBwgv.pdf")'>New</a>	0	2016-02-13 18:43:56.024745+08
40	Remarks	sdfsdsdf	1	2016-02-13 18:43:56.024745+08
40	Logs	CV was changed from <a ng-click='download_cv('../ASSETS/uploads/CV/20160213/201602131843ZyHDGZIr1oxKhQbOBwgv.pdf')'>Old</a> to <a ng-click='download_cv('../ASSETS/uploads/CV/20160213/2016021318451U5GA4vP1VQ4zIss4RD4.doc')'>New</a>	0	2016-02-13 18:45:48.555629+08
40	Remarks	sdfsd	1	2016-02-13 18:45:48.555629+08
40	Logs	CV was changed from <a ng-click='download_cv('../ASSETS/uploads/CV/20160213/2016021318451U5GA4vP1VQ4zIss4RD4.doc')'>Old</a> to <a ng-click='download_cv('../ASSETS/uploads/CV/20160213/201602131848Ml0SQdEuT5HPjVQdRHsh.pdf')'>New</a>	0	2016-02-13 18:48:06.830895+08
40	Remarks	sdfsd	1	2016-02-13 18:48:06.830895+08
40	Logs	CV was changed from <a ng-click='download_cv("../ASSETS/uploads/CV/20160213/201602131848Ml0SQdEuT5HPjVQdRHsh.pdf")'>Old</a> to <a ng-click='download_cv("../ASSETS/uploads/CV/20160213/201602131851dhHVAsnznCJG5m4ZQpaE.pdf")'>New</a>	0	2016-02-13 18:51:13.443914+08
40	Remarks	sdfsdfs	1	2016-02-13 18:51:13.443914+08
40	Logs	CV was changed from <a ng-click='download_cv("../ASSETS/uploads/CV/20160213/201602131851dhHVAsnznCJG5m4ZQpaE.pdf")'>Old</a> to <a ng-click='download_cv("../ASSETS/uploads/CV/20160214/201602140635uZBlDmQ2Yt7rEeLEV1hH.doc")'>New</a>	0	2016-02-14 06:35:06.930338+08
40	Remarks	test 1	1	2016-02-14 06:35:06.930338+08
43	Logs	Added new applicant.	1	2016-02-14 08:24:29.638347+08
43	Remarks	sdfsdf	1	2016-02-14 10:30:04.391633+08
43	Remarks	A hey	1	2016-02-14 10:32:12.493504+08
43	Remarks	A hey	2	2016-02-14 10:32:23.356737+08
43	Remarks	A hey	4	2016-02-14 10:34:34.717656+08
43	Remarks	ibex	1	2016-02-14 11:03:31.98163+08
43	Remarks	already	1	2016-02-14 11:07:27.104797+08
43	Remarks	UHG	1	2016-02-14 11:09:17.222081+08
45	Logs	Added new applicant.	1	2016-02-14 12:21:23.569225+08
45	Remarks	for callback pa	1	2016-02-14 12:29:50.07405+08
45	Logs	STATUS was changed from For callback  to For callback, not available for phone interview	0	2016-02-14 14:29:26.083543+08
45	Remarks	sdfsdf	1	2016-02-14 14:29:26.083543+08
45	Logs	TALENT ACQUISITION was changed from  to 	1	2016-02-14 15:24:03.414877+08
45	Remarks	asdas	1	2016-02-14 15:24:03.414877+08
45	Logs	TALENT ACQUISITION was changed from Rafael Pascual to Rafael Pascual	1	2016-02-14 15:32:02.49346+08
45	Remarks	yey	1	2016-02-14 15:32:02.49346+08
45	Logs	TALENT ACQUISITION was changed from Rafael Pascual to Lita	1	2016-02-14 15:35:19.391855+08
45	Remarks	asdasfd	1	2016-02-14 15:35:19.391855+08
45	Logs	Added DATE OF ENDORSEMENT	1	2016-02-14 15:55:00.618576+08
45	Remarks	sdsd	1	2016-02-14 15:55:00.618576+08
45	Remarks	sdfsdf	1	2016-02-14 15:56:26.190409+08
45	Remarks	here	1	2016-02-14 16:01:56.007632+08
45	Remarks	here	1	2016-02-14 16:03:33.014759+08
45	Remarks	dsd	1	2016-02-14 16:04:22.486128+08
45	Logs	STATUS was changed from For callback, not available for phone interview to Candidate not available 	0	2016-02-14 16:08:06.964662+08
45	Remarks	123	1	2016-02-14 16:08:06.964662+08
45	Logs	Changed DATE OF APPOINTMENT date_appointed	1	2016-02-14 16:36:57.564181+08
45	Remarks	done	1	2016-02-14 16:36:57.564181+08
45	Logs	Set DATE OF APPOINTMENT to 2016-02-14	1	2016-02-14 16:37:56.487212+08
45	Remarks	Done again	1	2016-02-14 16:37:56.487212+08
45	Logs	STATUS was changed from Candidate not available  to Already Employed	0	2016-02-14 16:39:51.6643+08
45	Remarks	dd	1	2016-02-14 16:39:51.6643+08
45	Remarks	This is a test post	1	2016-02-14 17:47:16.700052+08
45	Remarks	This is another test post with autoclear function	1	2016-02-14 17:47:55.187371+08
45	Remarks		1	2016-02-14 17:49:42.178359+08
45	Remarks	I love you weneshara	1	2016-02-14 17:52:46.16913+08
35	Logs	Set DATE OF ENDORSEMENT to 2016-02-12	0	2016-02-14 21:40:32.520654+08
35	Remarks	Endorsed	4	2016-02-14 21:40:32.520654+08
36	Logs	STATUS was changed from For Processing to Already Employed	0	2016-02-14 21:43:43.254303+08
36	Remarks	jjj	4	2016-02-14 21:43:43.254303+08
47	Logs	Added new applicant.	28	2016-02-15 10:07:29.744397+08
48	Logs	Added new applicant.	28	2016-02-15 13:30:13.584056+08
51	Logs	Added new applicant.	28	2016-02-15 14:14:22.354009+08
51	Remarks	Testing	28	2016-02-15 14:33:34.034207+08
51	Remarks	sdgfhgfdfhgf	28	2016-02-15 18:50:05.573217+08
51	Logs	STATUS was changed from For Processing to Candidate is not interested	0	2016-02-15 18:50:45.717104+08
51	Remarks	hjjhggh	28	2016-02-15 18:50:45.717104+08
47	Remarks	HP	28	2016-02-17 11:06:04.873354+08
55	Logs	Added new applicant.	28	2016-03-19 11:31:39.587352+08
55	Remarks	d	28	2016-03-19 11:59:05.868181+08
55	Remarks	s	28	2016-03-19 12:08:08.51634+08
55	Remarks	s	28	2016-03-19 12:09:07.260509+08
55	Remarks	aaaa	28	2016-03-21 17:38:38.955557+08
55	Remarks	kljasdf	28	2016-03-21 17:39:24.387563+08
55	Remarks	sadas	28	2016-03-21 17:41:06.197718+08
55	Remarks	dddd	28	2016-03-21 17:42:56.165837+08
55	Remarks	sfdsf	28	2016-03-21 17:45:19.101835+08
55	Remarks	dfasdf	28	2016-03-21 17:48:03.893804+08
55	Remarks	sfdsd	28	2016-03-21 17:48:43.566682+08
55	Remarks	sas	28	2016-03-21 17:49:07.72097+08
55	Remarks	sdfsd	28	2016-03-21 17:49:30.037743+08
55	Remarks	sdsdds	28	2016-03-21 17:55:50.210574+08
55	Logs	TALENT ACQUISITION was changed from Rheyan Lipardo to Rafael Pascual	0	2016-03-21 18:01:43.252723+08
55	Remarks	sdfsd	28	2016-03-21 18:01:43.252723+08
55	Logs	Set DATE OF ENDORSEMENT to 2016-03-21 17:00	0	2016-03-22 12:40:37.981225+08
55	Remarks	jjj	28	2016-03-22 12:40:37.981225+08
55	Remarks	sdkjfasdjkf	28	2016-03-22 14:29:51.950608+08
55	Remarks	sadfasd	28	2016-03-31 14:24:38.281434+08
55	Remarks	sdsd	28	2016-03-31 14:25:09.901193+08
56	Logs	Added new applicant.	27	2016-04-01 13:42:44.91917+08
56	Remarks	dffd	28	2016-04-05 14:17:11.281447+08
57	Logs	Added new applicant.	28	2016-05-15 17:05:57.799348+08
57	Remarks	ss	28	2016-05-15 17:12:08.185412+08
57	Logs	Set STATUS to (select status from statuses where pk = 1000)	0	2016-05-15 18:40:25.579168+08
57	Remarks	dd	28	2016-05-15 18:40:25.579168+08
57	Logs	Set STATUS to Cannot be reached	0	2016-05-15 18:41:04.990301+08
57	Remarks	dd	28	2016-05-15 18:41:04.990301+08
58	Logs	Added new applicant.	28	2016-06-01 17:27:59.612882+08
59	Logs	Added new applicant.	28	2016-06-03 13:05:50.57265+08
\.


--
-- Name: applicants_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('applicants_pk_seq', 59, true);


--
-- Data for Name: applicants_remarks; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY applicants_remarks (applicants_pk, remarks, created_by, date_created) FROM stdin;
2	Added New Applicant	1	2016-02-07 00:14:02.036824+08
3	Added New Applicant	1	2016-02-07 00:14:02.036824+08
4	Added New Applicant	1	2016-02-07 00:14:02.036824+08
5	Added New Applicant	1	2016-02-07 00:14:02.036824+08
6	Added New Applicant	1	2016-02-07 00:14:02.036824+08
7	Added New Applicant	1	2016-02-07 00:14:02.036824+08
8	Added New Applicant	1	2016-02-07 00:14:02.036824+08
9	Added New Applicant	1	2016-02-07 00:14:02.036824+08
10	Added New Applicant	1	2016-02-07 00:14:02.036824+08
11	Added New Applicant	1	2016-02-07 00:14:02.036824+08
12	Added New Applicant	1	2016-02-07 00:14:02.036824+08
13	Added New Applicant	1	2016-02-07 00:14:02.036824+08
14	Added New Applicant	1	2016-02-07 00:14:02.036824+08
15	Added New Applicant	1	2016-02-07 00:14:02.036824+08
16	Added New Applicant	1	2016-02-07 00:14:02.036824+08
17	Added New Applicant	1	2016-02-07 00:14:02.036824+08
18	Added New Applicant	1	2016-02-07 00:14:02.036824+08
19	Added New Applicant	1	2016-02-07 00:14:02.036824+08
20	Added New Applicant	1	2016-02-07 00:14:02.036824+08
32	Added New Applicant	1	2016-02-07 00:14:02.036824+08
21	Added New Applicant	1	2016-02-07 00:14:02.036824+08
22	Added New Applicant	1	2016-02-07 00:14:02.036824+08
23	Added New Applicant	1	2016-02-07 00:14:02.036824+08
24	Added New Applicant	1	2016-02-07 00:14:02.036824+08
25	Added New Applicant	1	2016-02-07 00:14:02.036824+08
26	Added New Applicant	1	2016-02-07 00:14:02.036824+08
27	Added New Applicant	1	2016-02-07 00:14:02.036824+08
28	Added New Applicant	1	2016-02-07 00:14:02.036824+08
29	Added New Applicant	1	2016-02-07 00:14:02.036824+08
30	Added New Applicant	1	2016-02-07 00:14:02.036824+08
31	Added New Applicant	1	2016-02-07 00:14:02.036824+08
32	Endorsed	1	2016-02-07 00:25:29.806016+08
32	Transferred to Demand Sci	1	2016-02-07 00:28:32.333306+08
3	test	1	2016-02-07 01:03:49.875877+08
32	saf	1	2016-02-07 01:07:20.591994+08
34	Already applied.	1	2016-02-07 16:42:26.297678+08
\.


--
-- Data for Name: applicants_status; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY applicants_status (applicants_pk, statuses_pk, created_by, date_created) FROM stdin;
47	1554	28	2016-05-15 16:59:38.391272+08
2	1554	160002	2016-05-15 16:59:38.391272+08
3	1554	160002	2016-05-15 16:59:38.391272+08
4	1554	160002	2016-05-15 16:59:38.391272+08
5	1554	160002	2016-05-15 16:59:38.391272+08
6	1554	160002	2016-05-15 16:59:38.391272+08
7	1554	160002	2016-05-15 16:59:38.391272+08
8	1554	160002	2016-05-15 16:59:38.391272+08
9	1554	160002	2016-05-15 16:59:38.391272+08
10	1554	160002	2016-05-15 16:59:38.391272+08
11	1554	160002	2016-05-15 16:59:38.391272+08
12	1554	160002	2016-05-15 16:59:38.391272+08
13	1554	160002	2016-05-15 16:59:38.391272+08
14	1554	160002	2016-05-15 16:59:38.391272+08
15	1554	160002	2016-05-15 16:59:38.391272+08
16	1554	160002	2016-05-15 16:59:38.391272+08
17	1554	160002	2016-05-15 16:59:38.391272+08
18	1554	160002	2016-05-15 16:59:38.391272+08
19	1554	160002	2016-05-15 16:59:38.391272+08
20	1554	160002	2016-05-15 16:59:38.391272+08
36	982	1	2016-05-15 16:59:38.391272+08
32	1554	160002	2016-05-15 16:59:38.391272+08
34	1554	1	2016-05-15 16:59:38.391272+08
21	1554	160002	2016-05-15 16:59:38.391272+08
22	1554	160002	2016-05-15 16:59:38.391272+08
23	1554	160002	2016-05-15 16:59:38.391272+08
24	1554	160002	2016-05-15 16:59:38.391272+08
25	1554	160002	2016-05-15 16:59:38.391272+08
26	1554	160002	2016-05-15 16:59:38.391272+08
27	1554	160002	2016-05-15 16:59:38.391272+08
28	1554	160002	2016-05-15 16:59:38.391272+08
29	1554	160002	2016-05-15 16:59:38.391272+08
30	1554	160002	2016-05-15 16:59:38.391272+08
31	1554	160002	2016-05-15 16:59:38.391272+08
43	1100	1	2016-05-15 16:59:38.391272+08
40	1554	1	2016-05-15 16:59:38.391272+08
35	1554	1	2016-05-15 16:59:38.391272+08
45	982	1	2016-05-15 16:59:38.391272+08
48	1554	28	2016-05-15 16:59:38.391272+08
51	812	28	2016-05-15 16:59:38.391272+08
55	402	28	2016-05-15 16:59:38.391272+08
56	1554	27	2016-05-15 16:59:38.391272+08
57	1554	28	2016-05-15 17:05:57.799348+08
57	1000	28	2016-05-15 18:40:25.579168+08
57	1000	28	2016-05-15 18:41:04.990301+08
58	1554	28	2016-06-01 17:27:59.612882+08
59	1554	28	2016-06-03 13:05:50.57265+08
\.


--
-- Data for Name: applicants_tags; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY applicants_tags (applicants_pk, tags) FROM stdin;
40	{PHP,PostgreSQL}
43	{aaa,aaaa,aaaaa}
45	{PHP,AngularJS}
47	{Acting,Singing}
48	{SQL,Linux}
51	{aaaaaaaa,bbbbbb,cccccccc}
55	{dsfs}
56	{kajsdflkasd}
57	{Java,PHP}
58	{Linux}
59	{MAKATI,Business-Administartion,Building-and-Property-Administration}
\.


--
-- Data for Name: applicants_talent_acquisition; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY applicants_talent_acquisition (applicants_pk, employees_pk, date_created) FROM stdin;
55	10	2016-03-19 11:31:39.587352+08
55	28	2016-03-21 18:01:43.252723+08
56	12	2016-04-01 13:42:44.91917+08
57	12	2016-05-15 17:05:57.799348+08
58	12	2016-06-01 17:27:59.612882+08
59	12	2016-06-03 13:05:50.57265+08
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY clients (pk, code, client, archived) FROM stdin;
1	TP	TP	f
3	Acquire	Acquire	f
577	one	Client	f
581	claire	Claire Company	f
18	IBEX	IBEX	f
19	Acquire - Shaw	Acquire - Shaw	f
20	TP EDSA	TP EDSA	f
28	UHG	UHG	f
32	HGS	HGS	f
36	Teleperformance	Teleperformance	f
40	IBEX PQ	IBEX PQ	f
42	IBEX Davao	IBEX Davao	f
66	EXL	EXL	f
70	BPOI	BPOI	f
71	Teleperfromance	Teleperfromance	f
74	Sitel	Sitel	f
79	teleperformance	teleperformance	f
87	Accenture        	Accenture        	f
89	IGT	IGT	f
93	PC	PC	f
113	Teleperformane	Teleperformane	f
123	KSI	KSI	f
135	TP-Cebu	TP-Cebu	f
138	NNIT	NNIT	f
141	DLSMC	DLSMC	f
146	DSLMC	DSLMC	f
578	test 1	test 1	f
162	Teleperformance 	Teleperformance 	f
171	CSS Corp	CSS Corp	f
172	TELEPERFORMANCE	TELEPERFORMANCE	f
209	COMODO	COMODO	f
288	ACQUIRE	ACQUIRE	f
579	aaa	aaa	t
300	Citistores	Citistores	f
319	TP/Accenture 	TP/Accenture 	f
325	CSS Corp.	CSS Corp.	f
336	CSS COrp.	CSS COrp.	f
349	Demand Science	Demand Science	f
363	Teleperformancae	Teleperformancae	f
375	Amikat	Amikat	f
376	Comodo	Comodo	f
392	Citistore	Citistore	f
396	AMIKAT	AMIKAT	f
406	Personal Collection	Personal Collection	f
408	Telepeformance	Telepeformance	f
580	Google	Google	f
463	WNS	WNS	f
465	YSA	YSA	f
493	GPC	GPC	f
517	YSa	YSa	f
528	YSA Pampanga	YSA Pampanga	f
558	YSA-Pampanga	YSA-Pampanga	f
\.


--
-- Data for Name: clients_logs; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY clients_logs (client_pk, type, details, created_by, date_created) FROM stdin;
577	Logs	None was changed from  to \nNone was changed from  to 	0	2016-02-21 15:54:13.794103+08
577	Remarks	aksdfjkasjdf	28	2016-02-21 15:54:13.794103+08
577	Logs	None was changed from aksdjfk to aksdjfk\nNone was changed from kljlkasjdf to kljlkasjdf	0	2016-02-21 16:04:31.773957+08
577	Remarks	sdfgs	28	2016-02-21 16:04:31.773957+08
578	Logs	None was changed from  to \nNone was changed from  to 	0	2016-02-22 09:33:49.321708+08
578	Remarks	alksdf	28	2016-02-22 09:33:49.321708+08
579	Logs	None was changed from  to \nNone was changed from  to 	0	2016-02-22 09:49:56.320819+08
579	Remarks	aaa	28	2016-02-22 09:49:56.320819+08
579	Logs	STATUS was changed from Enabled to Disabled	0	2016-02-22 09:51:46.376113+08
579	Remarks	ksadjfkasdf	28	2016-02-22 09:51:46.376113+08
\.


--
-- Name: clients_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('clients_pk_seq', 581, true);


--
-- Data for Name: employees_permission; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY employees_permission (employees_pk, employee_id, employee, roles_pk, title, department, supervisor, permission) FROM stdin;
13	201400078	Lita Elejido	3	\N	\N	\N	{"Requisitions":{"Menu":true,"Modules":{"New":true,"List":true}},"Candidates":{"Menu":false,"Modules":{"New":false,"List":false},"Functions":{"Status":false,"Date_endorsement":false,"Date_appointment":false,"Talent_acquisition":false}},"Reports":{"Menu":false,"Modules":{"Productivity":false}},"Admin":{"Menu":false,"Modules":{"Permission":false,"Clients":false,"Sources":false,"Job_positions":false,"Groups":false}}}
45	201400126	Michelle De Guzman	4	null	\N	\N	{"Requisitions":{"Menu":true,"Modules":{"New":true,"List":true}},"Candidates":{"Menu":false,"Modules":{"New":false,"List":false},"Functions":{"Status":false,"Date_endorsement":false,"Date_appointment":false,"Talent_acquisition":false}},"Reports":{"Menu":false,"Modules":{"Productivity":false}},"Admin":{"Menu":false,"Modules":{"Permission":false,"Clients":false,"Sources":false,"Job_positions":false,"Groups":false}}}
10	201000001	Rheyan Lipardo	1	\N	\N	\N	\N
29	201400106	Eralyn May Adino	1	\N	\N	\N	\N
30	201400107	Ana Margarita Galero	1	\N	\N	\N	\N
31	201400108	Irone John Amor	1	\N	\N	\N	\N
32	201400109	Angelica Abaleta	1	\N	\N	\N	\N
19	201300004	Mary Grace Lacerna	5	null	{BRT,CSRT}	\N	{"Requisitions":{"Menu":true,"Modules":{"New":true,"List":true}},"Candidates":{"Menu":true,"Modules":{"New":true,"List":true},"Functions":{"Status":false,"Date_endorsement":false,"Date_appointment":false,"Talent_acquisition":false}},"Reports":{"Menu":false,"Modules":{"Productivity":false}},"Admin":{"Menu":false,"Modules":{"Permission":false,"Clients":false,"Sources":false,"Job_positions":false,"Groups":false}}}
11	201400066	Judy Ann Reginaldo	3	null	{NVRT}	\N	{"Requisitions":{"Menu":true,"Modules":{"New":true,"List":true}},"Candidates":{"Menu":false,"Modules":{"New":false,"List":false},"Functions":{"Status":false,"Date_endorsement":false,"Date_appointment":false,"Talent_acquisition":false}},"Reports":{"Menu":false,"Modules":{"Productivity":false}},"Admin":{"Menu":false,"Modules":{"Permission":false,"Clients":false,"Sources":false,"Job_positions":false,"Groups":false}}}
33	201400110	Shena Mae Nava	6	HR Associate Intern	{VRT}	14	{"Requisitions":{"Menu":true,"Modules":{"New":true,"List":true}},"Candidates":{"Menu":false,"Modules":{"New":false,"List":false},"Functions":{"Status":false,"Date_endorsement":false,"Date_appointment":false,"Talent_acquisition":false}},"Reports":{"Menu":false,"Modules":{"Productivity":false}},"Admin":{"Menu":false,"Modules":{"Permission":false,"Clients":false,"Sources":false,"Job_positions":false,"Groups":false}}}
12	201400072	Ken Tapdasan	5	HR & Admin Associate	{TRT}	28	{"Requisitions":{"Menu":true,"Modules":{"New":true,"List":true}},"Candidates":{"Menu":true,"Modules":{"New":true,"List":true},"Functions":{"Status":true,"Date_endorsement":true,"Date_appointment":true,"Talent_acquisition":true}},"Reports":{"Menu":true,"Modules":{"Productivity":true}},"Admin":{"Menu":false,"Modules":{"Permission":false,"Clients":false,"Sources":false,"Job_positions":false,"Groups":false}}}
27	201400104	Eliza Mandique	6	Corporate Quality Supervisor	{CQT}	10	{"Requisitions":{"Menu":true,"Modules":{"New":true,"List":true}},"Candidates":{"Menu":true,"Modules":{"New":true,"List":true},"Functions":{"Status":false,"Date_endorsement":false,"Date_appointment":false,"Talent_acquisition":false}},"Reports":{"Menu":false,"Modules":{"Productivity":false}},"Admin":{"Menu":false,"Modules":{"Permission":false,"Clients":false,"Sources":false,"Job_positions":false,"Groups":false}}}
28	201400105	Rafael Pascual	1	IT Project Manager	{IIT}	10	{"Requisitions":{"Menu":true,"Modules":{"New":true,"List":true}},"Candidates":{"Menu":true,"Modules":{"New":true,"List":true},"Functions":{"Status":true,"Date_endorsement":true,"Date_appointment":true,"Talent_acquisition":true}},"Reports":{"Menu":false,"Modules":{"Productivity":false}},"Admin":{"Menu":true,"Modules":{"Permission":true,"Clients":true,"Sources":true,"Job_positions":false,"Groups":true,"Job_position":true}}}
14	201400081	Vincent Ramil	5	Client & Recruitment Supervisor	{VRT}	45	{"Requisitions":{"Menu":true,"Modules":{"New":true,"List":true}},"Candidates":{"Menu":true,"Modules":{"New":true,"List":true},"Functions":{"Status":true,"Date_endorsement":true,"Date_appointment":true,"Talent_acquisition":true}},"Reports":{"Menu":false,"Modules":{"Productivity":false}},"Admin":{"Menu":true,"Modules":{"Permission":true,"Clients":false,"Sources":false,"Job_positions":false,"Groups":false}}}
\.


--
-- Data for Name: employees_permission_logs; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY employees_permission_logs (employees_pk, type, details, created_by, date_created) FROM stdin;
13	Remarks		28	2016-03-30 18:54:54.23116+08
45	Remarks	undefined	28	2016-03-30 23:55:59.734066+08
11	Remarks	undefined	28	2016-03-30 23:58:10.821949+08
28	Remarks	undefined	28	2016-03-31 00:21:53.776084+08
19	Remarks	undefined	28	2016-03-31 00:24:55.965301+08
11	Remarks	undefined	28	2016-03-31 00:27:34.568926+08
28	Remarks	undefined	28	2016-03-31 00:28:29.647295+08
33	Remarks	undefined	28	2016-03-31 09:33:33.706599+08
28	Remarks	sss	28	2016-03-31 09:45:22.083416+08
28	Remarks	undefined	28	2016-03-31 09:53:50.001713+08
28	Remarks	sdfasdf	28	2016-03-31 11:09:47.413028+08
28	Remarks	undefined	28	2016-03-31 11:14:49.348072+08
28	Remarks	undefined	28	2016-04-01 10:04:48.058325+08
33	Remarks	sdsd	28	2016-04-01 11:33:40.07179+08
12	Remarks	undefined	28	2016-04-01 12:08:21.503125+08
27	Remarks	undefined	28	2016-04-01 12:08:41.002713+08
14	Remarks	undefined	28	2016-04-05 12:02:42.185803+08
14	Remarks	undefined	28	2016-04-05 12:03:00.733198+08
\.


--
-- Data for Name: external_statuses; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY external_statuses (pk, status, seq, archived) FROM stdin;
1	Unemployed, willing to start ASAP	1	f
2	Happily employed	2	f
3	Currently exploring	3	f
4	Looking for part-time jobs only	4	f
5	Looking for internship	5	f
6	Willing to consider new job offers	6	f
7	Looking for home-based jobs	7	f
8	Looking for oversees jobs	8	f
9	Looking for project-based jobs	9	f
10	Looking for commission-based jobs	10	f
11	Looking for consultancy jobs	11	f
12	Looking for freelance jobs	12	f
13	Looking for working student jobs	13	f
\.


--
-- Name: external_statuses_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('external_statuses_pk_seq', 13, true);


--
-- Data for Name: job_positions; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY job_positions (pk, "position", archived) FROM stdin;
1	CSR - Marketing and Sales	f
2	CSR - Media	f
3	Customer Sales Agent	f
4	CSR	f
5	CSR - Banking Fraud	f
1341	Google	f
15	TSR	f
21	CSR - Non Voice	f
24	CSR - Office Supplies	f
30	IT Internal Support	f
32	CSR-Telco	f
34	CSR-Banking Fraud	f
40	CSR- Banking Fraud	f
41	CSR/TSR	f
43	Sales Training Officer	f
47	CSR- MEdia & Publishing	f
48	FSR/Specialist	f
57	TSR- Gaming	f
59	TSR for Gaming	f
61	Bank Compliance Officer	f
66	CSR Telco	f
68	CSR-Consumer Voice 	f
71	CSR - Business Writing	f
75	CSR media & publishing	f
89	Healthcare Associates 	f
91	CSR- Telco	f
94	TSR-Cable	f
97	CSR-non voice	f
98	CSR-Healthcare	f
100	TSR Cable & Internet	f
104	Japanese CSR	f
108	CSR for Pioneer Non Voice	f
111	CSR Sales Agent	f
120	CSR Travel-Airline	f
121	CSR Travel Account	f
122	CSR Non Voice	f
124	CSR-Consumer Services	f
125	CSR for Travel Account	f
126	Dayshift CSR - telecom	f
127	CSR -Banking Retail	f
128	CSR-Travel airline	f
130	CSR for Sales	f
131	CSR for marketing & Sales	f
135	CSR Pioneer Non Voice	f
136	CSR for Travel Airline	f
137	TSR for Cable, Int. & Phone	f
140	TSR Cable	f
143	CSR- Pioneer Non Voice	f
145	Recruitment phone inter.	f
149	Mobilization Analyst	f
150	CSR- Consumer Services	f
153	No position attached	f
159	local account	f
161	CSR Banking fraud	f
1342	Yahoo	f
175	CSR-Banking	f
182	Mandarin CSR	f
184	Javascript Developer	f
185	CSR Office Supplies	f
186	CSR Gaming Console	f
191	CSR Sales	f
202	Japanese Language Specialist	f
204	Bahasa Indo CSR	f
205	CSR-Banking retail	f
206	CSR-Pioneer Non Voice	f
209	Java Developer	f
216	Dayshift CSR Telecom	f
217	Customer Service Representative	f
219	CSR-Banking Retail	f
238	CSR-Travel Airline	f
240	Finance and Enterprise Mgr	f
241	Facilities Ops Manager	f
242	Purchasing Manager	f
243	People Program Associate Mgr.	f
244	Risk and Compliance Mgr.	f
245	Treasury and Billing Manager	f
246	Analytics Manager	f
247	HR BPO Manager	f
248	USRN	f
250	TSR - Cable Company	f
256	CSR - Banking Retail	f
265	CSR - Operating System	f
274	TSR for Pioneer Account	f
276	CSR for Ordertaking, telco & travel account	f
279	CSR - Travel Airline	f
281	CSR -Gaming Console	f
286	CSR-Email Support	f
287	CSR/TSR Pioneer Gaming	f
288	Technical Support Representative	f
290	USRN - EXL	f
292	Care Mgt Global Process Owner	f
293	Project Manager	f
296	Marketing Specialist	f
306	CSR for Gaming Account	f
1343	Duck Duck Go	f
316	CSR-Telecom	f
329	CSR - BAnking	f
349	TSR for Printers	f
350	CSR-Cable Company	f
351	TSR for Cable, Internet & Phone	f
356	CSR-Banking Pilot Class (Wave 1)	f
362	CSR for travel, hotel & entertainment	f
367	CSR for travel airline	f
374	CSR for Travel - Airline	f
379	CSR Non voice for pioneer account	f
381	CSR Gaming Account	f
382	CSR for pilot class (wave 1)	f
384	CSR for Travel	f
386	CSR Travel 	f
390	Healthcare Specialist CSR non voice	f
391	CSR for Australian Retail	f
392	CSR-Consumer Services (Email)	f
396	CSR Australian Retail	f
405	CSR Travel, Hotel & Entertainment	f
409	CSR for Travel, Hotel & Entertainment	f
413	Finance and Enterprise Performance Mgr	f
415	Customer service Representative	f
419	CSR for Consumer Services ( Email)	f
426	CSR for Travel -Airline	f
430	CSR - gaming account	f
434	CSR - Cable Company	f
435	STO	f
436	Business Development Manager	f
445	Customer service Representative for Sales	f
450	CSR - Billing & Sales	f
1344	aaaaa	t
454	CSR Pilot Class ( Wave 1)	f
456	CSR for Travel airline	f
461	Customer Service Representative for Travel	f
462	CSR for Pioneer Healthcare	f
477	CSR - Pioneer Non Voice	f
484	CSR Healtcare	f
495	Marketing Associate	f
496	Customer Service Representative - Sales	f
497	Dayshift CSR	f
500	Customer Service Representative-Banking	f
507	Branch Operations Supervisor	f
508	PH RN Medical Coder	f
509	Care Management Global Process Owner	f
511	CSR- Pilot class (Wave 1)	f
514	CSR-Pilot Class (Wave 1)	f
517	Customer Service Representative -travel airline	f
520	Dayshift CSR - Telecom	f
522	CSR - Travel account	f
523	Customer Service Representative 	f
525	Facilities Operations Manager	f
531	Customer Service Representative - Banking	f
533	CSR Travel, Hotel & Restaurant	f
542	CSR for a Pioneer Healthcare Account	f
543	Field Sales Specialists	f
544	USRN - Accenture	f
556	ACN Ops HR People Advisor Manager	f
618	Accountant (Non CPA)...	f
560	IBEX	f
562	Senior Project Manager	f
563	JAPANESE CSR FOR SALES	f
564	Graphic Designer	f
566	AVP - Human Resource	f
567	IT Project Manager	f
568	Design Senior Analyst - Art Director	f
569	Unit Manager	f
572	Workforce Management Lead	f
577	CSR-Travel Account	f
578	CSR-Travel	f
580	CSR- Travel Airline	f
582	Corporate Sales Represenatives	f
585	Nurse Practitioner Representatives	f
587	Japanese CSR - Sales	f
588	Customer Service Representatives	f
589	CSR - Consumer Services	f
598	AVP - Human Resources	f
605	MS EXCHANGE Server Administration	f
606	Mobilization Sr. Analyst	f
607	Inventory Manager	f
610	Technical Trainer	f
619	Arabic Analyst	f
620	 IT TECHNICAL TEAM LEAD	f
621	MS OFFICE 365 Support Engineer	f
623	SAP Business Planning and Consolidation	f
624	SAP Basis	f
626	 DevOps	f
627	SAP Basis Specialist	f
628	Mobilization Team Lead	f
629	Spanish Analyst	f
632	TSR - IT Helpdesk	f
635	HR Talent Strategy Manager	f
638	Senior Java Developer	f
641	System Implementation Analytics	f
642	DevOps Engineer	f
643	Brand Manager	f
646	Pharmacy Unit Manager	f
650	SAP BASIS Specialist	f
651	Senior.NET DEVELOPER	f
652	Senior IT Project Manager	f
656	 MS EXCHANGE Server Administrator	f
659	Nurse Practitioner	f
660	Corporate Training Manager	f
663	USRN Clinical Analyst	f
664	Supply Chain and Procurement Mgr	f
665	System Implementation- Delivery	f
666	 IT SYSTEM MANAGEMENT ANALYST	f
669	CSR - Travel, Hotel and Entertainment	f
672	Japanese Speaking CSR 	f
677	German Language 	f
678	Cantonese Speaking CSR	f
679	Sales	f
685	IT Operations Manager	f
687	CSR for Banking	f
694	Nurse Practitioner Representative	f
695	Business Development Managers	f
696	Supply Chain and Procurement Manager	f
699	Internal Audit Manager	f
742	Accentures-Mandarin	f
702	CSR For Travel Airline	f
712	Korean Speaking 	f
714	Design Senior Analyst	f
716	Corporate Communication Senior Manager	f
725	Sales Representative	f
727	CSR Travel, Hotel And Entertainment	f
732	Medical Representative	f
737	CSR - Healthcare	f
743	MS-SQL Server Integration Services	f
744	System Implementation Project Manager	f
746	AX Functional Consultant	f
747	M3 ERP Business Consultant	f
748	Functional Consultant	f
752	CSR DAYSHIFT	f
760	EDI LEAD	f
761	Workstation Engineer	f
762	CSR - Travel, Hotel and Entertainment 	f
772	CSR Healthcare	f
775	CSR for Banking Retail	f
778	CSR - Travel	f
781	CSR for Healthcare	f
785	Email Support Representative	f
786	CSR for Banking Loans	f
792	Retail Unit Head	f
793	Procurement Manager	f
794	Mechanical Engineer	f
797	Sales training Officer	f
798	Project Managers	f
799	Design Senior Analyst - Video	f
804	CSR Travel Airlines	f
810	CSR Banking	f
821	Workstation Engineer (Ilocos)	f
825	Thai. Language 	f
826	CSR For Hotel Reservations	f
829	CSR for Cable TV and Internet	f
831	Customer Sales Agent (Utilities)	f
834	WORKSTATION ENGINEER	f
835	Collections Specialist	f
839	Not in the Phil.	f
846	CSR Travel Airline	f
849	CSR Financial	f
854	CSR Travel, Hotel and Entertainment	f
856	Associate Software Engineer	f
858	CSR for Banking claims	f
860	CSR Financial Account	f
871	Solution Architect	f
876	CSR Hotel Reservations	f
877	CSR Hotel Reservations and Sales	f
882	CSR For Healthcare	f
884	IT System Management Analyst	f
886	Sr Voice/Data Network Analyst	f
896	Voice/Data Network Analyst	f
898	Operations Excellent Associate Managers	f
899	Accounting Officer	f
900	RN	f
902	PHRN	f
908	Data Sales Account Executive	f
910	SAP BPC Professional	f
911	Japanese Speaker	f
918	CSA	f
919	CSR for Hotel Reservations	f
921	CSR - Telecom	f
925	CSR Telecom	f
928	Salesforce.com Software Development	f
936	Report Analyst	f
940	CSR for Travel Hotel Sales	f
953	CSR For Travel E. Services	f
965	Oracle Hyperion Consultant	f
971	Intelligent Network Engineer	f
974	IT Client Engagement Manager	f
977	Associate Software Engr.	f
983	Japanese CSR 	f
988	Software Engineer	f
992	Front-End Web Developer	f
1001	CSR For Airlines	f
1002	Social Media Expert	f
1106	Accentures	f
1008	(Dayshift) CSR - Telecom	f
1013	CSR Travel Hotel Sales	f
1021	CSR for Financial	f
1025	CSR - Travel E. Services	f
1029	Mandarin Language	f
1034	Mangento Developer	f
1037	MS SQL Server Analysis	f
1039	IT Security Management Analyst	f
1043	General Manager	f
1044	Design Senior Analyst (Art Director)	f
1046	Thai Language	f
1047	Merchandising Manager	f
1059	CSR for Financial Services	f
1064	CSR For Financial	f
1065	CSR For Banking	f
1068	Technology Architect	f
1072	Liferay Portal Developer	f
1083	CSR - Financial	f
1085	CSR - Travel Hotel Sales	f
1086	CSR - Travel and Hospitality	f
1088	Area Sales Manager	f
1090	CSR - Healthcare account	f
1091	USR Case Manager	f
1094	CSR - Premiere Financial	f
1099	Design Senior Analyst-Video	f
1109	Corporate Communication  Manager	f
1117	CSR For Banking Retail	f
1118	Application Developer.Net	f
1119	Associate IT Security Analyst	f
1128	TSR - Cable, Internet and Phone	f
1129	CSR - Hotel Reservations	f
1133	Magento Developer	f
1134	CSR - Banking Claims	f
1139	Sr. Recruitment Manager	f
1153	TSR 	f
1160	CSR -  Travel and Hospitality	f
1168	Sales Agent	f
1175	Vietnamese Analyst	f
1176	Bahasa Indo Analyst	f
1180	Japanese Language	f
1181	Spanish Language	f
1184	German Language	f
1185	Korean Language	f
1188	Team Leader	f
1190	Vietnamese Language	f
1206	Facilities Manager	f
1208	Operation Manager	f
1210	Cashier	f
1224	Bahasa Indo Language	f
1232	Bahasa Malay Language	f
1233	Cantonese Language	f
1234	RN/Skin Care Advisor 	f
1238	Office Staff	f
1242	Delivery Rider	f
1251	Regional Sales Manager	f
1254	Cluster Business Development Manager	f
1255	Senior Human Resource Manager	f
1259	Marketing Manager	f
1265	Trade Marketing Manager	f
1269	Supply Chain Manager	f
1270	Vietnamese CSR	f
1273	Skin Care Advisor 	f
1274	Driver	f
1281	Receiptionist/Cashier 	f
1288	Driver 	f
1301	IT Quality Consultant	f
1302	POS Support	f
1305	IT Openings	f
1306	Registrar Associate	f
1307	Network Architect	f
1310	Japanese Analyst	f
1311	AX Developer	f
1314	Technical Support Engineer	f
1315	Cisco Routing and Switching	f
1323	SI Project Manager	f
1325	SAP	f
1326	Network Engineer	f
1329	Sales Distributor Specialist	f
1340	Network Architecture	f
\.


--
-- Data for Name: job_positions_logs; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY job_positions_logs (position_pk, type, details, created_by, date_created) FROM stdin;
742	Logs	None was changed from Accenture-Mandarin to Accentures-Mandarin	0	2016-02-19 16:38:37.430763+08
742	Remarks	Test	28	2016-02-19 16:38:37.430763+08
618	Logs	PROFILE was changed from Accountant (Non CPA) to Accountant (Non CPA)...	0	2016-02-19 16:39:52.512803+08
618	Remarks	This is a test	28	2016-02-19 16:39:52.512803+08
1344	Logs	None was changed from Enabled to Disabled	0	2016-02-19 18:06:44.08766+08
1344	Remarks		28	2016-02-19 18:06:44.08766+08
1344	Logs	STATUS was changed from Disabled to Enabled	0	2016-02-19 18:13:58.27511+08
1344	Logs	STATUS was changed from Enabled to Disabled	0	2016-02-19 18:14:14.374079+08
1344	Remarks		28	2016-02-19 18:14:14.374079+08
1344	Logs	STATUS was changed from Disabled to Enabled	0	2016-02-19 18:15:17.918499+08
1344	Logs	STATUS was changed from Enabled to Disabled	0	2016-02-19 18:15:41.019975+08
1344	Remarks		28	2016-02-19 18:15:41.019975+08
1344	Logs	STATUS was changed from Disabled to Enabled	0	2016-02-19 18:17:04.805115+08
1344	Logs	STATUS was changed from Enabled to Disabled	0	2016-02-19 18:17:17.714902+08
1344	Remarks		28	2016-02-19 18:17:17.714902+08
1344	Logs	STATUS was changed from Disabled to Enabled	0	2016-02-19 18:18:24.431736+08
1344	Logs	STATUS was changed from Enabled to Disabled	0	2016-02-19 18:19:05.722895+08
1344	Remarks	undefined	28	2016-02-19 18:19:05.722895+08
1344	Logs	STATUS was changed from Disabled to Enabled	0	2016-02-19 18:19:24.174755+08
1344	Logs	STATUS was changed from Enabled to Disabled	0	2016-02-19 18:19:37.465755+08
1344	Remarks	undefined	28	2016-02-19 18:19:37.465755+08
1344	Logs	STATUS was changed from Disabled to Enabled	0	2016-02-19 18:22:30.770841+08
1344	Logs	STATUS was changed from Enabled to Disabled	0	2016-02-19 18:22:46.641312+08
1344	Remarks	sssss	28	2016-02-19 18:22:46.641312+08
\.


--
-- Name: job_positions_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('job_positions_pk_seq', 1344, true);


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY notifications (employees_pk, notification, type, table_pk, date_created, read, pk) FROM stdin;
33	A new requisition has been submitted by Lita Elejido	requisitions	3	2016-02-24 16:24:37.375463+08	t	4
33	A new requisition has been submitted by Lita Elejido	requisitions	2	2016-02-24 15:38:58.285852+08	t	3
18	A new candidate has been added.	applicants	48	2016-02-15 13:30:13.584056+08	t	1
33	A new requisition has been submitted by Lita Elejido	requisitions	5	2016-02-26 12:45:55.054737+08	f	6
33	A new requisition has been submitted by Lita Elejido	requisitions	6	2016-02-26 12:54:18.288141+08	f	7
33	A new requisition has been submitted by Lita Elejido	requisitions	7	2016-02-26 12:54:40.703392+08	f	8
33	A new requisition has been submitted by Lita Elejido	requisitions	8	2016-02-26 14:45:50.268809+08	f	9
28	A new candidate has been added.	applicants	51	2016-02-15 14:14:22.354009+08	t	2
10	A new candidate has been added.	applicants	55	2016-03-19 11:31:39.587352+08	f	11
12	A new candidate has been added.	applicants	56	2016-04-01 13:42:44.91917+08	f	12
33	A new requisition has been submitted by Lita Elejido	requisitions	4	2016-02-26 12:45:05.525392+08	t	5
28	Requisition  has been modified.	requisition	5	2016-03-03 12:27:24.63421+08	t	10
13	Requisition 1602-0002 has been modified.	requisition	6	2016-04-05 14:41:44.67211+08	f	13
12	A new candidate has been added.	applicants	57	2016-05-15 17:05:57.799348+08	f	14
12	A new candidate has been added.	applicants	58	2016-06-01 17:27:59.612882+08	f	15
12	A new candidate has been added.	applicants	59	2016-06-03 13:05:50.57265+08	f	16
\.


--
-- Name: notifications_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('notifications_pk_seq', 16, true);


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY permissions (pk, parent, item, archived) FROM stdin;
2	Reports	Candidates	f
3	Admin	Permission	f
1	Tracker	New Candidate Form	f
\.


--
-- Name: permissions_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('permissions_pk_seq', 3, true);


--
-- Data for Name: reminders; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY reminders (pk, message, remind_on, date_created, created_by) FROM stdin;
\.


--
-- Name: reminders_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('reminders_pk_seq', 1, false);


--
-- Data for Name: requisitions; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY requisitions (pk, job_positions_pk, total, created_by, date_created, archived, end_date, requisition_id, alternate_title) FROM stdin;
7	598	242	13	2016-02-26 12:54:40.703392+08	f	2016-03-31 18:00:00+08	1602-0003	\N
8	589	123	13	2016-02-26 14:45:50.268809+08	f	2016-03-15 18:00:00+08	1602-0004	\N
5	598	100	13	2016-02-26 12:45:55.054737+08	f	2016-03-27 15:00:00+08	1602-0001	\N
9	742	3	28	2016-03-19 09:23:02.397458+08	f	2016-03-31 06:00:00+08	1603-0005	
11	1106	3	28	2016-03-19 09:32:56.458028+08	f	2016-03-30 06:00:00+08	1603-0007	l;dfa;lsdf
10	742	3	28	2016-03-19 09:24:29.846417+08	f	2016-03-30 06:00:00+08	1603-0006	aaaaaaaaaaaaaaab
12	992	12	12	2016-04-01 12:09:47.839684+08	f	2016-04-30 18:00:00+08	1604-0008	Team Ken
6	619	234	13	2016-02-26 12:54:18.288141+08	f	2016-02-29 18:00:00+08	1602-0002	\N
13	821	12	28	2016-05-15 16:21:18.144922+08	f	2016-05-31 18:00:00+08	1605-0009	
14	742	12	28	2016-06-01 17:27:04.577969+08	f	2016-06-09 17:25:00+08	1606-0010	sdlkdjfskdafjalksdjf
\.


--
-- Data for Name: requisitions_logs; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY requisitions_logs (requisitions_pk, type, details, created_by, date_created) FROM stdin;
5	Remarks	Test	13	2016-02-26 12:45:55.054737+08
6	Remarks	sdkfjasdklf	13	2016-02-26 12:54:18.288141+08
7	Remarks	lsdkjflksad	13	2016-02-26 12:54:40.703392+08
8	Remarks	Test	13	2016-02-26 14:45:50.268809+08
5	Remarks	ddd	13	2016-02-26 17:45:46.012357+08
5	Remarks	we need 100	13	2016-02-26 17:59:50.243486+08
5	Remarks	hurry up guys...	13	2016-02-26 18:00:04.90393+08
5	Remarks	aaaa	13	2016-02-26 18:02:04.526651+08
5	Remarks	test	28	2016-03-03 11:00:26.647327+08
5	Remarks	test	28	2016-03-03 11:22:14.398339+08
5	Remarks	d	28	2016-03-03 11:23:21.464776+08
5	Remarks	d	28	2016-03-03 11:28:02.718923+08
5	Remarks	dd	28	2016-03-03 11:34:24.780809+08
5	Remarks	ssd	28	2016-03-03 11:36:13.040201+08
5	Remarks	ddd	28	2016-03-03 11:37:10.641112+08
5	Remarks	dfdf	28	2016-03-03 11:49:27.284141+08
5	Remarks	sldkj	13	2016-03-03 12:20:24.334088+08
5	Remarks	ksjflasd	13	2016-03-03 12:25:05.827608+08
5	Remarks	asdfasdf	13	2016-03-03 12:27:24.63421+08
9	Remarks	kdslf	28	2016-03-19 09:23:02.397458+08
10	Remarks	sdfsd	28	2016-03-19 09:24:29.846417+08
11	Remarks	fsd	28	2016-03-19 09:32:56.458028+08
10	Remarks	s	28	2016-03-19 10:05:05.220507+08
12	Remarks	a	12	2016-04-01 12:09:47.839684+08
6	Remarks	sdfs	28	2016-04-05 14:41:44.67211+08
13	Remarks	This is for ilocos	28	2016-05-15 16:21:18.144922+08
14	Remarks	sdsd	28	2016-06-01 17:27:04.577969+08
\.


--
-- Name: requisitions_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('requisitions_pk_seq', 14, true);


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY roles (pk, role, archived, r_order) FROM stdin;
1	Administrator	f	1
2	Director	f	2
3	Manager	f	3
4	Team Leader	f	4
5	Talent Acquisition	f	5
6	Sourcer	f	6
\.


--
-- Name: roles_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('roles_pk_seq', 6, true);


--
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY sources (pk, source, archived) FROM stdin;
1	PostingJob	f
2	Avaya Voice Network	f
3	BestJobs	f
4	CebuJobs	f
5	Central Mailbox	f
6	ConnectTalentnow	f
7	Endorsed	f
8	Facebook	f
9	Job Posting	f
10	From Bilingual email	f
11	GigaJobs	f
12	GMail	f
13	Greatjobs	f
14	Indeed	f
15	Jobs Cloud	f
16	Jobvertise	f
17	LinkedIn	f
18	MBClassified	f
19	PinoyJobs	f
20	Post Job Free	f
21	Referral	f
22	Textblast 	f
23	Trovit.Ph	f
24	Others	f
25	JobStreet	f
\.


--
-- Data for Name: sources_logs; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY sources_logs (source_pk, type, details, created_by, date_created) FROM stdin;
25	Logs	SOURCE was changed from Jobstreet to Jobstreet	0	2016-02-22 12:38:09.299369+08
25	Remarks	Split	28	2016-02-22 12:38:09.299369+08
25	Logs	SOURCE was changed from Job Street to JobStreet	0	2016-02-22 12:40:38.631546+08
25	Remarks	Join	28	2016-02-22 12:40:38.631546+08
\.


--
-- Name: sources_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('sources_pk_seq', 25, true);


--
-- Data for Name: statuses; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY statuses (pk, status, archived) FROM stdin;
1	Failed CHRS Screening	f
2	No answer	f
3	Endorsed to Acquire	f
4	CNR	f
1554	For Processing	f
8	No answer/SMS Sent	f
17	Not interested in Acquire/for demand science pooling	f
20	Endorsed to TP EDSA	f
23	For Callback	f
25	Candidate not available	f
29	No Answer	f
30	Not Qualified	f
31	CNI	f
36	endorsed to IBEX Davao	f
40	Already Applied In UHG	f
43	For Pooling	f
48	Forwarded to Accenture for validation	f
53	Endorsed to IBEX Hanston	f
56	Endorsed to TP - Pasay	f
57	For CB	f
60	Encoded to in Taleo	f
62	No Answer/for CB	f
65	Endorsed to IBEX Davao	f
76	Currently enrolled / Interested in in Part-time jobs only	f
82	Endorsed to IBEX PQ	f
84	For CB on Monday	f
87	NI	f
89	Endorsed to TP - Alphaland	f
93	Endorsed to Cebu IT Park	f
97	For email invite, TP-EDSA	f
99	Endorsed to TP-Cebu IT Park	f
104	Endorsed to Ibex tomorrow	f
109	Not willing to relocate	f
227	Didn't meet salary expectation	f
233	For CB tomorrow morning	f
238	Endorsed to TP-IT Park	f
249	Failed TP/Undergrad	f
260	Failed Screening	f
261	For Accenture Validation	f
262	Failed TP Cebu	f
267	Sms sent for accenture interview	f
268	CNR / for callback	f
269	endorsed to TP Sucat 08-oct-2015	f
274	Invited for interview and coaching session tomorrow 9:00AM	f
275	Requested for Callback	f
277	Endorsed to TP Edsa	f
278	endorsed to tp It park	f
281	NO Answer / For callback	f
282	Failed screening	f
283	Endorsed to TP-Pasay	f
284	Lookinf for part time only	f
285	For accenture validation	f
290	Number unavailable	f
292	For CB 4pm	f
293	Valid for accenture	f
294	failed	f
299	Encoded in Taleo  - Sept 7	f
302	Not Valid	f
306	Encoded in Taleo  - Sept 12	f
307	Endorsed to IBEX PQ - October 8	f
308	NQ	f
311	Endorsed to IBEX Davao - October 13	f
315	For Validation	f
319	Valid for Accenture	f
328	Invited for on site coaching	f
329	Endorsed to  DavaoTP / NI	f
333	for reprofiling/ for cv	f
339	Invited for coaching / for endorsement to tp-edsa	f
342	Invited for on-site coaching	f
343	No ANswer o both numbers / SMS sent	f
345	Request Call back after 1 hr	f
348	No Answer / SMS sent	f
349	Endorsed to TP-Cebu	f
351	Validated by Accenture - For Toolkit	f
352	Already sourced by another vendor	f
353	On-hold (No demand) - Accenture	f
359	Accenture - Valid	f
362	Not Available	f
364	Requested Callback	f
365	Poor Connection	f
371	Endorsed to Acquire tommorow	f
373	Accenture - For Validation	f
375	Endorsed to TP CEbu IT Park tom	f
384	Already scheduled for interview	f
388	Endorsed to IBEX davao - CSR	f
391	Requested Callback 3pm	f
393	No answer/SMS sent	f
394	Already processed application at TP / Will reprofile to Ibex	f
396	Endorsed to TP - Cebu IT Park CSR tomorrow	f
397	Endorsed to TP - Cebu IT Park tomorrow	f
398	Endorsed to TP Pasay tomorrow 10AM	f
400	Endorsed to TP-Pasay CSR / tomorrow 10AM	f
401	Endorsed to EXL	f
402	Accenture - Invalid	f
404	BPOI - Paper Screening	f
409	Paperscreening - BPOI	f
417	No answer for Callback	f
420	No answer /  for Accenture validation 	f
422	Candidate not available for Callback	f
424	Failed	f
426	Failed Tp Exam / for accenture validation	f
428	Invited for coaching session	f
429	Was already endorsed to Ibex	f
431	Endorsed to Acquire shaw on Monday 9:00 AM	f
434	Endorsed to TP Edsa 	f
435	No answer / SMS sent	f
437	Valid - Provide toolkit	f
439	endorsed to TP - Cebu it park 17-Oct-2015 	f
443	Candidate not available 	f
448	Invited for Coaching /Sitel 	f
451	Poor Connection / For Callback	f
452	For validation CSR / ACCENTURE	f
454	Endorsed to IGT	f
455	Valid - Accenture	f
456	Endorsed to TP Cebu IT Park tomorrow 10AM CSR Pilot Class	f
457	Endorsed to TP Baguio	f
458	Called 2x/No asnwer 	f
459	For callback on Monday 10-12 AM	f
461	Endorsed to TP Sucat	f
463	For Callback on Monday	f
464	N0 answer	f
465	For callback	f
468	Endorsed to TP-Cebu IT Park / CSR	f
469	No answer /sms sent	f
473	was already scheduled for tomorrow by a different vendor.	f
474	CNR for CB	f
477	No anwer SMS sent	f
478	Endorsed to TP - IT Park / CSR - TRAVEL	f
479	No answer sms sent	f
486	Endorsed to TP Davao	f
490	Endorsed to TP Cebu	f
491	No answer/ sms sent	f
495	For endorsement to IGT will wait for date confirmation from the candidate	f
496	Endorsed to WCC - IGT 22-OCT-2015 CSR-Travel	f
500	Endorsed to TP-IT Park tomorrow 10AM	f
502	Endorsed to TP-Aura tomorrow	f
509	Endorsed to TP-Cebu IT Park friday 10AM / CSR	f
515	Accenture - Provide Toolkit	f
517	Poor reception / SMS sent for callback	f
518	Endorsed to IGT- WCC 24-Oct-2015 10AM	f
526	No  Answer/ For Callback	f
527	No Answer / for callback	f
530	NI / receptionist job	f
536	Endorsed to IBEX global Davao 26-Oct-2015	f
538	Accenture - Provide toolkit	f
543	Endorsed to TP Cebu IT Park Monday	f
545	Endorsed to PC	f
546	BPOI - PaperScreening	f
551	For endorsement to ACQUIRE	f
555	Endorsed to TP - IT Park 10AM 27-Oct	f
558	Endorsed to TP Sucat - Oct 26 10AM CSR	f
559	Endorsed to TP Cebu IT Park Oct. 26 10 AM	f
560	Endorsed to IGT tomorrow 10AM	f
562	Endorsed to TP Cebu IT Park Nov. 4 10 AM CSR	f
565	No Answer / sms sent	f
567	Endorsed to TP Bacolod Oct-29-15 10AM CSR	f
570	Endorsed to IGT WCC November 9- 15 10AM CSR-Travel	f
572	Endorsed to TP EDSA Nov.2,15 CSR Dayshift	f
573	Endorsed to Acquire Shaw November 3 10AM	f
575	Endorsed to TP-Cebu IT park tomorrow 10AM	f
578	Endorsed to tp baguio tomorrow 10AM	f
580	No Answer/SMS sent	f
581	For CB 5PM	f
586	Endorsed to TP Cebu IT Park Oct. 29 10AM	f
587	Endorsed to TP - Baguio tomorrow 10AM	f
589	Endorsed to TP Baguio Tomorrow 10 AM CSR	f
592	Endorsed to TP Cebu IT Park Nov.2 10AM CSR	f
593	Endorsed to TP Cebu IT Park Nov. 4 10AM CSR	f
594	Endorsed to TP Cebu IT Park Oct.28 1PM CSR	f
596	CNR/SMS sent	f
597	No Answer/ SMS sent	f
599	Already hired by TP last month but was not able to comply with the requirements	f
605	For OJT Application	f
610	Endorsed to it park tp - 02-Nov 10AM CSR-Banking	f
611	Endorsed to IGT WCC / Tomorrow 10AM	f
612	Poor connection / For callback	f
614	Endorsed to TP Davao Oct.30 10AM	f
618	Encoded to Taleo	f
620	CNR /For Callback	f
622	ENdorsed to TP Davao tomorrow 10AM CSR	f
624	Endorsed to TP Cebu IT Park tomorrow 10AM CSR - Banking	f
626	Endorsed to TP Fairview November 2, 2015 10 AM CSR	f
630	Endorsed to TP EDSA Greenfield tomorrow 1PM CSR	f
632	Endorsed to IGT McKinley Nov.4, 15 10AM	f
635	Accenture - Reallocate / Re-endorse	f
637	No answer / sms sent	f
641	Endorsed to TP Cebu IT Park Nov 4, 2015 10AM CSR - Bankin	f
645	Endorsed to TP Fairview November 3,, 2015 10AM CSR	f
653	KSI - For Validation	f
656	Will be available next year	f
657	EXL - For Validation	f
658	PC Paper Screening	f
668	Endorsed to TP	f
672	For Validation for NNIT	f
674	For Validation for Accenture	f
676	For Paperscreening	f
682	Invalid	f
685	No Contact	f
690	Show-up Nov.9	f
699	Endorsed to KSI	f
706	Waiting for the result of Validation	f
708	For Paper Screening	f
717	Endorsed to CSS Corp	f
718	For Callback by 5:30 PM	f
725	Over age, expected salary is 50K	f
726	Invalid already sourced by other vendor	f
732	For Screening Interview	f
735	Invalid already sourced 	f
736	Waiting for the result of validation	f
738	Endorsed to client / TP Rockwell	f
739	Endorsed to client	f
756	No Valid Phil No.	f
757	CB	f
762	already Endorsed to Accenture	f
767	Proximity issue	f
770	Not Interested	f
774	expected salary is 80K	f
777	Wrong num / email sent	f
778	No answer, For CB	f
779	Invalid for NNIT	f
781	For Reprofiling	f
782	Endorsed to IGT WCC	f
785	Endorsed to TP Cebu IT Park	f
788	Endorsed to TP Cebu 	f
791	Failed Phone Screening	f
799	Endorsed to TP MOA	f
800	No contact number provide	f
802	Endorsed to TP IT Park Cebu	f
808	Endorsed TO Cebu IT Park	f
810	Endorsed to TP PQ	f
811	For callback/ for accenture validation	f
812	Candidate is not interested	f
813	Endorsed to TP Rockwell Ortigas for TSR IT Helpdesk	f
815	Wrong Number	f
816	For callback 	f
823	Endorsed to IBEX	f
826	Invalid / With existing record in UHG	f
831	Endorsed/Validation to Accenture	f
834	Valid - For F2F interview 11/24/2015	f
835	Endorsed to Accenture/Sent toolkit	f
840	Endorsed to TP - EDSA	f
841	Former TP Employee	f
850	Endorsed to TP Fairview	f
854	Endorsed to IBEX Paranaque	f
884	No Answer/SMS Sent	f
887	Waiting for Validation result from TP	f
892	Waiting for Validation result from Accenture	f
904	For callback, not available for phone interview	f
909	Encoded to taleo	f
921	Endorsed to Acquire Shaw	f
927	Endorse to Accenture for validation 	f
931	Valid to Accenture	f
932	Endorsed to TP ALPHALAND	f
936	Ringing No Answer	f
940	For Callback Tomorrow	f
943	Endorsed To IBEX Tiendesitas	f
944	No Answer / SMS Sent	f
947	Endorsed to UHG	f
948	Interested in Part time only	f
957	For Validation/sent to accenture	f
959	For NNIT Project Manager	f
960	For NNIT Senior IT Project Manager	f
962	For CGI Validation for M3 Consultant	f
963	For CGI Validation	f
966	Unreachable	f
968	Endorsed to IBEX Silver City	f
969	Endorsed to TP Pasay	f
973	Employed not Interested	f
979	Endorsed to TP Rockwell Ortigas	f
982	Already Employed	f
984	Endorsed To ACQUIRE EASTWOOD	f
985	Endorsed to TP CEBU IT PARK	f
992	Will relocate to Cebu by January	f
1000	Cannot be reached	f
1003	Endorsed to CEBU IT PARK	f
1024	Endorsed to TP McKinley	f
1037	For Validation TP	f
1038	For Validation TP/Accenture	f
1039	For Validation Accenture 	f
1041	Endorsed to TP Paranaque	f
1054	Employed	f
1059	For F2f interview	f
1069	Endorsed to CSS Corp Taguig	f
1073	Endorsed to Accenture	f
1096	Valid to Accenture 	f
1097	F2F Interview 	f
1098	Already Applied to TP	f
1100	Candidate already on database of UHG	f
1101	Endorsed to IBEX SILVER CITY	f
1102	Position Closed for review for different position	f
1103	No Contact 	f
1108	Endorsed to NNIT	f
1112	Already in UHG Database	f
1115	Endorsed	f
1127	Endorsed to CSS Corp.	f
1136	Endorsed to TP-Edsa	f
1138	Poor Reception / For CB	f
1140	Endorsed to TP Aura	f
1142	Failed PreScreening	f
1144	No Valid Philippine Number	f
1146	For Validation NNIT	f
1161	Failed 	f
1165	Invalid Number	f
1166	Invalid 	f
1169	Already processed by other Head hunter	f
1171	Unavailable	f
1176	Unattended	f
1187	No Valid Philippine No	f
1189	For Accenture Validation- POS Support Engineer	f
1197	Lacks Qualification	f
1205	Not Amenable to Work in Ilocos	f
1207	For CB- Not From Ilocos	f
1210	For CB- For Workstation Manager	f
1211	No Valid Phil. No.	f
1214	For CB- Workstation Engineer	f
1217	Endorsed to Amikat	f
1218	Endorsed to Comodo	f
1228	Endorsed to Sitel Baguio	f
1238	Endorsed to TP Cebu Insular	f
1242	Invalid with existing record in UHG	f
1244	Not Qualified/ No IT Experience	f
1247	Invited to F2F Interview and coaching / TP EDSA	f
1249	No Answer SMS Sent	f
1266	Endorsed to IBEX Tiendesitas	f
1269	Endorsed to AMIKAT	f
1272	Endorsement to TP Cebu Insular	f
1279	Already failed TP and SITEL Baguio	f
1280	For CB 2:40 PM	f
1282	Endorsed to EXL Alabang	f
1283	No Valid Philippine No.	f
1297	For pooling already applied to TP	f
1309	No Answer 	f
1311	CNR / Sms Sent	f
1317	Applied to TP Last week	f
1323	Low signal reception / Sms Sent	f
1327	Already applied to IBEX and TP	f
1336	No Answer / Sms Sent	f
1340	Endorsed to TP Ayala	f
1343	Already applied to TP	f
1351	Failed for Accenture - only amenable in Metro Manila	f
1353	No Valid Philippine ID	f
1360	Currently Employed with Accenture	f
1365	For Clearing	f
1371	CNR / SMS Sent	f
1383	Profiled for IGT/Amikat	f
1384	Medical Issue/Sick	f
1402	for Validation	f
1423	for f2f Interview	f
1452	for f2f Interview 1-11-2016	f
1457	For f2f interview	f
1463	Endorsed to WNS	f
1466	Endorsed to YSA	f
1474	Endorsed to HGS	f
1477	For PAper Screening	f
1484	f2f interview 	f
1510	Endorse to GPC for f2f interview	f
1511	Endorsed to YSA 	f
1513	Endorsed to GPC	f
1517	Endorsed to Accenture Bilingual Hiring Event	f
1519	For pooling	f
1521	Call back at 12nn 20-Jan-2016	f
1527	not qualified	f
1528	Callback/Busy/Ringing Only	f
1529	for Accenture Validation	f
1532	For f2f interview 1/25/2016	f
1541	Invalid for Accenture	f
\.


--
-- Name: statuses_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: cats
--

SELECT pg_catalog.setval('statuses_pk_seq', 1554, true);


--
-- Data for Name: talent_acquisition_group; Type: TABLE DATA; Schema: public; Owner: cats
--

COPY talent_acquisition_group (employees_pk, supervisor_pk) FROM stdin;
27	12
33	19
\.


--
-- Name: applicants_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY applicants
    ADD CONSTRAINT applicants_pkey PRIMARY KEY (pk);


--
-- Name: clients_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (pk);


--
-- Name: external_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY external_statuses
    ADD CONSTRAINT external_statuses_pkey PRIMARY KEY (pk);


--
-- Name: job_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY job_positions
    ADD CONSTRAINT job_positions_pkey PRIMARY KEY (pk);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (pk);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (pk);


--
-- Name: reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (pk);


--
-- Name: requisitions_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY requisitions
    ADD CONSTRAINT requisitions_pkey PRIMARY KEY (pk);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (pk);


--
-- Name: sources_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (pk);


--
-- Name: statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: cats; Tablespace: 
--

ALTER TABLE ONLY statuses
    ADD CONSTRAINT statuses_pkey PRIMARY KEY (pk);


--
-- Name: applicant_id_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX applicant_id_idx ON applicants USING btree (applicant_id);


--
-- Name: applicants_pk_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX applicants_pk_idx ON applicants_tags USING btree (applicants_pk);


--
-- Name: client_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX client_idx ON clients USING btree (code, client);


--
-- Name: employees_id_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX employees_id_idx ON employees_permission USING btree (employee_id);


--
-- Name: employees_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX employees_idx ON talent_acquisition_group USING btree (employees_pk, supervisor_pk);


--
-- Name: employees_pk_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX employees_pk_idx ON employees_permission USING btree (employees_pk);


--
-- Name: position_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX position_idx ON job_positions USING btree ("position");


--
-- Name: role_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX role_idx ON roles USING btree (role);


--
-- Name: seq_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX seq_idx ON external_statuses USING btree (seq);


--
-- Name: source_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX source_idx ON sources USING btree (source);


--
-- Name: status_idx; Type: INDEX; Schema: public; Owner: cats; Tablespace: 
--

CREATE UNIQUE INDEX status_idx ON statuses USING btree (status);


--
-- Name: insertlogs; Type: TRIGGER; Schema: public; Owner: cats
--

CREATE TRIGGER insertlogs BEFORE UPDATE ON applicants FOR EACH ROW EXECUTE PROCEDURE insertlogs();


--
-- Name: insertlogs; Type: TRIGGER; Schema: public; Owner: cats
--

CREATE TRIGGER insertlogs BEFORE UPDATE ON applicants_tags FOR EACH ROW EXECUTE PROCEDURE insertlogs();


--
-- Name: insertlogs; Type: TRIGGER; Schema: public; Owner: cats
--

CREATE TRIGGER insertlogs BEFORE UPDATE ON job_positions FOR EACH ROW EXECUTE PROCEDURE insertlogs();


--
-- Name: insertlogs; Type: TRIGGER; Schema: public; Owner: cats
--

CREATE TRIGGER insertlogs BEFORE UPDATE ON clients FOR EACH ROW EXECUTE PROCEDURE insertlogs();


--
-- Name: insertlogs; Type: TRIGGER; Schema: public; Owner: cats
--

CREATE TRIGGER insertlogs BEFORE UPDATE ON sources FOR EACH ROW EXECUTE PROCEDURE insertlogs();


--
-- Name: applicants_appointer_applicants_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_appointer
    ADD CONSTRAINT applicants_appointer_applicants_pk_fkey FOREIGN KEY (applicants_pk) REFERENCES applicants(pk);


--
-- Name: applicants_appointer_employees_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_appointer
    ADD CONSTRAINT applicants_appointer_employees_pk_fkey FOREIGN KEY (employees_pk) REFERENCES employees_permission(employees_pk);


--
-- Name: applicants_client_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants
    ADD CONSTRAINT applicants_client_fkey FOREIGN KEY (clients_pk) REFERENCES clients(pk);


--
-- Name: applicants_endorser_applicants_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_endorser
    ADD CONSTRAINT applicants_endorser_applicants_pk_fkey FOREIGN KEY (applicants_pk) REFERENCES applicants(pk);


--
-- Name: applicants_endorser_employees_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_endorser
    ADD CONSTRAINT applicants_endorser_employees_pk_fkey FOREIGN KEY (employees_pk) REFERENCES employees_permission(employees_pk);


--
-- Name: applicants_external_status_applicants_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_external_status
    ADD CONSTRAINT applicants_external_status_applicants_pk_fkey FOREIGN KEY (applicants_pk) REFERENCES applicants(pk);


--
-- Name: applicants_external_status_external_statuses_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_external_status
    ADD CONSTRAINT applicants_external_status_external_statuses_pk_fkey FOREIGN KEY (external_statuses_pk) REFERENCES external_statuses(pk);


--
-- Name: applicants_logs_applicants_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_logs
    ADD CONSTRAINT applicants_logs_applicants_pk_fkey FOREIGN KEY (applicants_pk) REFERENCES applicants(pk);


--
-- Name: applicants_profiled_for_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants
    ADD CONSTRAINT applicants_profiled_for_fkey FOREIGN KEY (job_positions_pk) REFERENCES job_positions(pk);


--
-- Name: applicants_remarks_applicants_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_remarks
    ADD CONSTRAINT applicants_remarks_applicants_pk_fkey FOREIGN KEY (applicants_pk) REFERENCES applicants(pk);


--
-- Name: applicants_requisitions_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants
    ADD CONSTRAINT applicants_requisitions_pk_fkey FOREIGN KEY (requisitions_pk) REFERENCES requisitions(pk);


--
-- Name: applicants_status_applicants_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_status
    ADD CONSTRAINT applicants_status_applicants_pk_fkey FOREIGN KEY (applicants_pk) REFERENCES applicants(pk);


--
-- Name: applicants_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants
    ADD CONSTRAINT applicants_status_fkey FOREIGN KEY (statuses_pk) REFERENCES statuses(pk);


--
-- Name: applicants_tags_applicants_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_tags
    ADD CONSTRAINT applicants_tags_applicants_pk_fkey FOREIGN KEY (applicants_pk) REFERENCES applicants(pk);


--
-- Name: applicants_talent_acquisition_applicants_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_talent_acquisition
    ADD CONSTRAINT applicants_talent_acquisition_applicants_pk_fkey FOREIGN KEY (applicants_pk) REFERENCES applicants(pk);


--
-- Name: applicants_talent_acquisition_employees_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY applicants_talent_acquisition
    ADD CONSTRAINT applicants_talent_acquisition_employees_pk_fkey FOREIGN KEY (employees_pk) REFERENCES employees_permission(employees_pk);


--
-- Name: clients_logs_client_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY clients_logs
    ADD CONSTRAINT clients_logs_client_pk_fkey FOREIGN KEY (client_pk) REFERENCES clients(pk);


--
-- Name: employees_permission_logs_employees_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY employees_permission_logs
    ADD CONSTRAINT employees_permission_logs_employees_pk_fkey FOREIGN KEY (employees_pk) REFERENCES employees_permission(employees_pk);


--
-- Name: employees_permission_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY employees_permission
    ADD CONSTRAINT employees_permission_role_fkey FOREIGN KEY (roles_pk) REFERENCES roles(pk);


--
-- Name: job_positions_logs_position_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY job_positions_logs
    ADD CONSTRAINT job_positions_logs_position_pk_fkey FOREIGN KEY (position_pk) REFERENCES job_positions(pk);


--
-- Name: reminders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY reminders
    ADD CONSTRAINT reminders_created_by_fkey FOREIGN KEY (created_by) REFERENCES employees_permission(employees_pk);


--
-- Name: requisitions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY requisitions
    ADD CONSTRAINT requisitions_created_by_fkey FOREIGN KEY (created_by) REFERENCES employees_permission(employees_pk);


--
-- Name: requisitions_logs_requisitions_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY requisitions_logs
    ADD CONSTRAINT requisitions_logs_requisitions_pk_fkey FOREIGN KEY (requisitions_pk) REFERENCES requisitions(pk);


--
-- Name: requisitions_profile_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY requisitions
    ADD CONSTRAINT requisitions_profile_fkey FOREIGN KEY (job_positions_pk) REFERENCES job_positions(pk);


--
-- Name: sources_logs_source_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cats
--

ALTER TABLE ONLY sources_logs
    ADD CONSTRAINT sources_logs_source_pk_fkey FOREIGN KEY (source_pk) REFERENCES sources(pk);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

