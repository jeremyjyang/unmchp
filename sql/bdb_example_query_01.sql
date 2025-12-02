SELECT
        lod.cpt_id,
        lod.cpt_description,
        umls.name
FROM
        lod_42_cpt lod
JOIN
        umls_cpt umls ON umls.cpt_id = lod.cpt_id
WHERE
        umls.name LIKE '%breast%cancer%'
        ;