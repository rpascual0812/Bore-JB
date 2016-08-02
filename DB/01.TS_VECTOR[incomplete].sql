begin;

ALTER TABLE profiles ADD COLUMN tsv tsvector;
CREATE INDEX tsv_idx ON profiles USING gin(tsv);

--UPDATE profiles SET tsv = setweight(to_tsvector(coalesce(profile->>'skills','')), 'A') || setweight(to_tsvector(coalesce(pin,'')), 'D');

-- UPDATE profiles SET tsv = setweight(to_tsvector(coalesce(profile->>'skills','')), 'A') || setweight(to_tsvector(coalesce(pin,'')), 'B') || setweight(to_tsvector(coalesce(profile->>'personal','')), 'C');

-- UPDATE profiles SET tsv = setweight(to_tsvector(coalesce(profile->>'personal','')), 'A') || setweight(to_tsvector(coalesce(pin,'')), 'B') || setweight(to_tsvector(coalesce(profile->>'personal','')), 'C');

DROP FUNCTION profiles_search_trigger() cascade;
CREATE FUNCTION profiles_search_trigger() RETURNS trigger AS $$
begin
  	new.tsv :=
    	setweight(to_tsvector(coalesce(new.profile->>'skills','')), 'A') || setweight(to_tsvector(coalesce(pin,'')), 'B') || setweight(to_tsvector(coalesce(new.profile->>'status','')), 'C')  || setweight(to_tsvector(coalesce(new.profile->'personal'->>'city','')), 'D');
  	return new;
end
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_tsvectorupdate AFTER INSERT OR UPDATE
ON profiles FOR EACH ROW EXECUTE PROCEDURE profiles_search_trigger();

/* SAMPLE SELECT QUERY
SELECT pin, profiles, tsv FROM (
  	SELECT pin, profiles, tsv
  	FROM profiles, plainto_tsquery('SAMPLE KEYWORDS') AS q
  	WHERE (tsv @@ q)
) AS t1 ORDER BY ts_rank_cd(t1.tsv, plainto_tsquery('SAMPLE KEYWORDS')) DESC LIMIT 5;
*/

--update objects set body=jsonb_set(body, '{name}', '"Mary"', true) where id=1;
commit;

SELECT pin, profiles, tsv FROM (
  	SELECT pin, profiles, tsv
  	FROM profiles, plainto_tsquery('jquery') AS q
  	WHERE (tsv @@ q)
) AS t1 ORDER BY ts_rank_cd(t1.tsv, plainto_tsquery('jquery')) DESC LIMIT 5;

--update profiles set profile=jsonb_set(profile, '{statuses_pk}', '3', true) where pin in ('1234-JJ','1235-JJ');


UPDATE profiles SET tsv = setweight(to_tsvector(coalesce(profile->>'skills','')), 'A') || setweight(to_tsvector(coalesce(pin,'')), 'B') || setweight(to_tsvector(coalesce(profile->>'status','')), 'C')  || setweight(to_tsvector(coalesce(profile->'personal'->>'city','')), 'D');

update profiles set profile=jsonb_set(profile, '{personal}', '{"first_name" : "Rafael", "last_name" : "Pascual", "city" : "Pasig City"}', true) where pin in ('1235-JJ');