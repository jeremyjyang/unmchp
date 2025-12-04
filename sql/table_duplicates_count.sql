-- Count table duplicates.
SELECT 
        COUNT(t.cpt_id) duplicate_cpt_id_count
FROM
        (SELECT cpt_id FROM umls_cpt GROUP BY cpt_id HAVING COUNT(cpt_id) > 1) t
        ;