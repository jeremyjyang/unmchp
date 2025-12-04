-- Find table duplicates.
SELECT
        u.cpt_id,
        u.name,
        u.provenance
FROM
        umls_cpt u
WHERE
        u.cpt_id IN (SELECT cpt_id FROM umls_cpt GROUP BY cpt_id HAVING COUNT(cpt_id) > 1)
ORDER BY
        u.cpt_id, provenance
        ;
