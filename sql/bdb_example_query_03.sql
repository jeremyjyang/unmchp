SELECT cc.document_number,cc.test_system_id,cd.test_system_name,cd.analyte_name,cd.complexity,cd.date_effective 
FROM clia_cdc cc JOIN clia_detail cd ON cd.document_number = cc.document_number
WHERE cd.analyte_name ILIKE 'Creatinine%' OR cd.analyte_name ILIKE 'Creatine%' ;