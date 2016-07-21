begin;

ALTER TABLE profiles ADD COLUMN tsv tsvector;
CREATE INDEX tsv_idx ON profiles USING gin(tsv);

--UPDATE profiles SET tsv = setweight(to_tsvector(coalesce(profiles->>'skills','')), 'A') || setweight(to_tsvector(coalesce(text,'')), 'D');

UPDATE profiles SET tsv = setweight(to_tsvector(coalesce(profile->>'skills','')), 'A');

DROP FUNCTION profiles_search_trigger() cascade;
CREATE FUNCTION profiles_search_trigger() RETURNS trigger AS $$
begin
  	new.tsv :=
    	setweight(to_tsvector(coalesce(new.profile->>'skills','')), 'A');
  	return new;
end
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_tsvectorupdate BEFORE INSERT OR UPDATE
ON profiles FOR EACH ROW EXECUTE PROCEDURE profiles_search_trigger();

/* SAMPLE SELECT QUERY
SELECT pin, profiles, tsv FROM (
  	SELECT pin, profiles, tsv
  	FROM profiles, plainto_tsquery('SAMPLE KEYWORDS') AS q
  	WHERE (tsv @@ q)
) AS t1 ORDER BY ts_rank_cd(t1.tsv, plainto_tsquery('SAMPLE KEYWORDS')) DESC LIMIT 5;
*/
commit;