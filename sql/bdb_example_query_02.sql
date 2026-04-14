SELECT cms.cpt_id,cms.cpt_description,umls.name 
FROM cms_cpt cms JOIN umls_cpt umls ON umls.cpt_id = cms.cpt_id 
WHERE umls.name IS NOT NULL ORDER BY name ;