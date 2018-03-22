/*
 * This SQL script is a template for the SQL that is to be run
 * in order to generate the ACEF files (e.g. AcceptedSpecies.txt,
 * AcceptedInfraspecificTaxa.txt, etc.). It is meant to be run
 * by the make-acef.sh script, which uses sed to replace
 * __OUTPUT_DIR__ and __DATABASE_ID__ with proper values.
 */

/* 
 * AcceptedSpecies.txt
 */
SELECT 
'AcceptedTaxonID','Kingdom','Phylum', 'Class', 'Order', 'Superfamily', 'Family', 'Genus', 'SubGenusName', 
'SpeciesEpithet', 'AuthorString', 'GSDNameStatus', 'Sp2000NameStatus', 'IsExtinct', 'HasPreHolocene',
'HasModern', 'LifeZone', 'AdditionalData', 'LTSSpecialist', 'LTSDate','SpeciesURL', 'GSDTaxonGUID', 'GSDNameGUID'
UNION
SELECT sn.name_code							AS AcceptedTaxonID
,	IFNULL(fam.kingdom,'')					AS Kingdom
,	IFNULL(fam.phylum,'')					AS Phylum
,	IFNULL(fam.class,'')					AS Class
,	IFNULL(fam.`order`,'')					AS `Order`
,	IFNULL(fam.superfamily,'')				AS Superfamily
,	IFNULL(fam.family,'')					AS Family
,	IFNULL(sn.genus,'')						AS Genus
,	IFNULL(sn.subgenus,'')					AS SubGenusName
,	IFNULL(sn.species,'')					AS SpeciesEpithet
,	REPLACE(REPLACE(REPLACE(REPLACE(IFNULL(sn.author, ''), '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS AuthorString
,	''										AS GSDNameStatus /* ??? */
,	IFNULL(nomstatus.sp2000_status,'')		AS Sp2000NameStatus
,	IFNULL(sn.is_extinct,'')				AS IsExtinct
,	IFNULL(sn.has_preholocene,'')			AS HasPreHolocene
,	IFNULL(sn.has_modern,'')				AS HasModern
,	IFNULL(lz.lifezones,'')					AS LifeZone
,	REPLACE(REPLACE(REPLACE(REPLACE(IFNULL(sn.comment, ''), '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS AdditionalData
,	IFNULL(sp.specialist_name,'')			AS LTSSpecialist
,	IFNULL(sn.scrutiny_date,'')				AS LTSDate
,	IFNULL(sn.web_site,'')					AS SpeciesURL
,	IFNULL(sn.GSDTaxonGUID,'')				AS GSDTaxonGUID
,	IFNULL(sn.GSDNameGUID,'')				AS GSDNameGUID
INTO OUTFILE '__OUTPUT_DIR__/AcceptedSpecies.txt'
CHARACTER SET UTF8
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\n'
FROM scientific_names AS sn
LEFT JOIN families AS fam ON (sn.family_code = fam.family_code OR sn.family_id = fam.record_id)
LEFT JOIN sp2000_statuses AS nomstatus ON (sn.sp2000_status_id = nomstatus.record_id)
LEFT JOIN lifezones_per_name lz ON (sn.record_id = lz.scientific_name_id)
LEFT JOIN specialists AS sp ON (sn.specialist_id = sp.record_id)
WHERE (sn.infraspecies_marker IS NULL OR infraspecies_marker = '')
AND sn.is_accepted_name != 0 /* both 1 and 5 are accepted names; 5 likely data corruption */
AND sn.database_id=__DATABASE_ID__;


/* 
 * AcceptedInfraspecificTaxa.txt
 */
SELECT 'AcceptedTaxonID','parentID','InfraSpeciesEpithet','InfraSpeciesMarker','InfraSpeciesAuthorString',
 'GSDNameStatus','Sp2000NameStatus','IsExtinct','HasPreHolocene','HasModern','LifeZone','AdditionalData',
 'LTSSpecialist','LTSDate','InfraSpeciesURL','GSDTaxonGUID','GSDNameGUID'
UNION
SELECT sn.name_code							AS AcceptedTaxonID
,	IFNULL(sn.infraspecies_parent_name_code,'') AS parentID
,	IFNULL(sn.infraspecies,'')				AS InfraSpeciesEpithet
,	IFNULL(sn.infraspecies_marker,'')		AS InfraSpeciesMarker
,	IFNULL(sn.author,'')					AS InfraSpeciesAuthorString
,	''										AS GSDNameStatus /* ??? */
,	IFNULL(nomstatus.sp2000_status,'')		AS Sp2000NameStatus
,	IFNULL(sn.is_extinct,'')				AS IsExtinct
,	IFNULL(sn.has_preholocene,'')			AS HasPreHolocene
,	IFNULL(sn.has_modern,'')				AS HasModern
,	REPLACE(REPLACE(REPLACE(REPLACE(IFNULL(lz.lifezones, ''), '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS LifeZone
,	REPLACE(REPLACE(REPLACE(REPLACE(IFNULL(sn.comment, ''), '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS AdditionalData
,	IFNULL(sp.specialist_name,'')			AS LTSSpecialist
,	IFNULL(sn.scrutiny_date,'')				AS LTSDate
,	IFNULL(sn.web_site,'')					AS InfraSpeciesURL
,	IFNULL(sn.GSDTaxonGUID,'')				AS GSDTaxonGUID
,	IFNULL(sn.GSDNameGUID,'')				AS GSDNameGUID
INTO OUTFILE '__OUTPUT_DIR__/AcceptedInfraspecificTaxa.txt'
CHARACTER SET UTF8
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\n'
FROM scientific_names AS sn
LEFT JOIN sp2000_statuses AS nomstatus ON (sn.sp2000_status_id = nomstatus.record_id)
LEFT JOIN lifezones_per_name lz ON (sn.record_id = lz.scientific_name_id)
LEFT JOIN specialists AS sp ON (sn.specialist_id = sp.record_id)
WHERE (sn.infraspecies_marker IS NOT NULL AND infraspecies_marker != '')
AND sn.is_accepted_name != 0
AND sn.database_id=__DATABASE_ID__;


/* 
 * Synonyms.txt
 */
SELECT 'ID','AcceptedTaxonID','Genus','SubGenusName','SpeciesEpithet','AuthorString','InfraSpeciesEpithet',
'InfraSpeciesMarker','InfraSpeciesAuthorString','GSDNameStatus','Sp2000NameStatus','GSDNameGUID'
UNION
SELECT sn.name_code							AS ID
,	sn.accepted_name_code					AS AcceptedTaxonID
,	IFNULL(sn.genus,'')						AS Genus
,	IFNULL(sn.subgenus,'')					AS SubGenusName
,	IFNULL(sn.species,'')					AS SpeciesEpithet
,	IFNULL(sn.author,'')					AS AuthorString
,	IFNULL(sn.infraspecies,'')				AS InfraSpeciesEpithet
,	IFNULL(sn.infraspecies_marker,'')		AS InfraSpeciesMarker
,	''										AS InfraSpeciesAuthorString /* ??? */
,	''										AS GSDNameStatus /* ??? */
,	IFNULL(nomstatus.sp2000_status,'')		AS Sp2000NameStatus
,	IFNULL(sn.GSDNameGUID,'')				AS GSDNameGUID
INTO OUTFILE '__OUTPUT_DIR__/Synonyms.txt'
CHARACTER SET UTF8
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\n'
FROM scientific_names AS sn
LEFT JOIN sp2000_statuses AS nomstatus ON (sn.sp2000_status_id = nomstatus.record_id)
WHERE sn.is_accepted_name = 0
AND sn.database_id=__DATABASE_ID__;


/*
 * CommonNames.txt
 */
SELECT 'AcceptedTaxonID','CommonName','TransliteratedNames','Language','Country','Area','ReferenceID'
UNION
SELECT cn.name_code							AS AcceptedTaxonID
,	REPLACE(REPLACE(REPLACE(REPLACE(cn.common_name, '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS CommonName
,	IFNULL(cn.transliteration,'')			AS TransliteratedNames
,	IFNULL(cn.language,'')					AS Language
,	IFNULL(cn.country,'')					AS Country
,	REPLACE(REPLACE(REPLACE(REPLACE(cn.area, '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS Area
,	IFNULL(cn.reference_code,'')			AS ReferenceID
INTO OUTFILE '__OUTPUT_DIR__/CommonNames.txt'
CHARACTER SET UTF8
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\n'
FROM common_names AS cn
LEFT JOIN scientific_names sn ON (cn.name_code = sn.name_code)
WHERE cn.database_id=__DATABASE_ID__;


/*
 * Distribution.txt
 */
SELECT 'AcceptedTaxonID','DistributionElement','StandardInUse','DistributionStatus'
UNION
SELECT d.name_code							AS AcceptedTaxonID
,	REPLACE(REPLACE(REPLACE(REPLACE(IFNULL(distribution, ''), '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS DistributionElement
,	IFNULL(d.StandardInUse,'')				AS StandardInUse
,	IFNULL(d.DistributionStatus,'')			AS DistributionStatus
INTO OUTFILE '__OUTPUT_DIR__/Distribution.txt'
CHARACTER SET UTF8
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\n'
FROM distribution AS d
WHERE d.database_id=__DATABASE_ID__;


/*
 * References.txt
 */
SELECT 'ReferenceID','Authors','Year','Title','Details'
UNION
SELECT r.reference_code						AS ReferenceID
,	REPLACE(REPLACE(REPLACE(REPLACE(IFNULL(r.author, ''), '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS Authors
,	IFNULL(r.year,'')						AS Year
,	REPLACE(REPLACE(REPLACE(REPLACE(IFNULL(r.title, ''), '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS Title
,	REPLACE(REPLACE(REPLACE(REPLACE(IFNULL(r.source, ''), '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS Details
INTO OUTFILE '__OUTPUT_DIR__/References.txt'
CHARACTER SET UTF8
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\n'
FROM `references` AS r
WHERE r.database_id=__DATABASE_ID__;



/*
 * NameReferences.txt
 */
SELECT 'ID','ReferenceType','ReferenceID'
UNION
SELECT snr.name_code						AS ID
,	IFNULL(snr.reference_type,'')			AS ReferenceType
,	IFNULL(snr.reference_code,'')			AS ReferenceID
INTO OUTFILE '__OUTPUT_DIR__/NameReferences.txt'
CHARACTER SET UTF8
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\n'
FROM scientific_name_references AS snr
WHERE snr.database_id=__DATABASE_ID__;


/*
 * SourceDatabase.txt
 */
SELECT 'DatabaseFullName','DatabaseName','DatabaseVersion','ReleaseDate','AuthorsEditors','TaxonomicCoverage',
'GroupNameInEnglish','Abstract','Organization','HomeURL','Coverage','Completeness','Confidence',
'LogoFileName','ContactPerson'
UNION
SELECT db.database_full_name				AS DatabaseFullName
,	IFNULL(db.database_name,'')				AS DatabaseName
,	IFNULL(db.version,'')					AS DatabaseVersion
,	IFNULL(db.release_date,'')				AS ReleaseDate
,	IFNULL(db.authors_editors,'')			AS AuthorsEditors
,	REPLACE(REPLACE(REPLACE(REPLACE(IFNULL(db.taxonomic_coverage, ''), '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS TaxonomicCoverage
,	''										AS GroupNameInEnglish /* ??? */
,	REPLACE(REPLACE(REPLACE(REPLACE(IFNULL(db.abstract, ''), '\r\n', ' '), '\n', ' '), '\r', ' '), '\t', ' ') AS Abstract
,	IFNULL(db.organization,'')				AS Organization
,	IFNULL(db.web_site,'')					AS HomeURL
,	IFNULL(db.coverage,'')					AS Coverage
,	IFNULL(db.completeness,'')				AS Completeness
,	IFNULL(db.confidence,'')				AS Confidence
,	''										AS LogoFileName
,	IFNULL(db.contact_person,'')			AS ContactPerson
INTO OUTFILE '__OUTPUT_DIR__/SourceDatabase.txt'
CHARACTER SET UTF8
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\n'
FROM `databases` AS db
WHERE db.record_id=__DATABASE_ID__;

