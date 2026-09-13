Create database toxic_youtube_comments;

use toxic_youtube_comments;

drop table toxicity_data;

CREATE TABLE toxicity_data (
    comment_id INTEGER PRIMARY KEY,
    target FLOAT,
    comment_text TEXT,
    severe_toxicity FLOAT,
    obscene FLOAT,
    identity_attack FLOAT,
    insult FLOAT,
    threat FLOAT,
    -- Identity attributes
    asian FLOAT,
    atheist FLOAT,
    bisexual FLOAT,
    black FLOAT,
    buddhist FLOAT,
    christian FLOAT,
    female FLOAT,
    heterosexual FLOAT,
    hindu FLOAT,
    homosexual_gay_or_lesbian FLOAT,
    intellectual_or_learning_disability FLOAT,
    jewish FLOAT,
    latino FLOAT,
    male FLOAT,
    muslim FLOAT,
    other_disability FLOAT,
    other_gender FLOAT,
    other_race_or_ethnicity FLOAT,
    other_religion FLOAT,
    other_sexual_orientation FLOAT,
    physical_disability FLOAT,
    psychiatric_or_mental_illness FLOAT,
    transgender FLOAT,
    white FLOAT,
    -- Metadata
    created_date TIMESTAMP,
    publication_id INTEGER,
    parent_id INTEGER, -- Can be NULL
    article_id INTEGER,
    rating VARCHAR(20),
    -- Reactions and Counts
    funny INTEGER,
    wow INTEGER,
    sad INTEGER,
    likes INTEGER,
    disagree INTEGER,
    sexual_explicit FLOAT,
    identity_annotator_count INTEGER,
    toxicity_annotator_count INTEGER
);

select * from toxicity_data;	


LOAD DATA LOCAL INFILE 'C:/Users/snach/Documents/DataAnalytics/SQL/data.csv' 
INTO TABLE toxicity_data 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';


SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/snach/Documents/DataAnalytics/SQL/data.csv' 
INTO TABLE toxicity_data 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- total count of rows
select count(*) from toxicity_data;

select count(distinct comment_id) as count_of_unique_ids from toxicity_data;

select * from toxicity_data
limit 10;

-- no toxic comments
select * from toxicity_data
where target = 0
limit 10;

-- toxic comments vs non toxic comments
select
count(case when target = 0 then comment_id else null end ) as Total_non_toxic_comment,
count(case when target <> 0 then comment_id else null end ) as Total__toxic_comment
from toxicity_data;

select
(count(case when target = 0 then comment_id else null end ) / count(*) )as Total_non_toxic_comment_percent,
(count(case when target <> 0 then comment_id else null end ) / count(*) ) as Total__toxic_comment_percent
from toxicity_data;

-- non toxic comment analysis
SELECT count(*)
FROM toxicity_data
WHERE target = 0;

SELECT count(*)
FROM toxicity_data
WHERE target = 0;


-- data glance
select * from toxicity_data
limit 5;

-- avg toxicity observed in entire data
select ROUND(avg(target),2)
from toxicity_data;

-- number of comments with high toxicity as defined by 
select count(comment_id)
from toxicity_data
where target > 0.9;

-- summarisation of different level of toxicity
select 
Count(case when target > 0.9 then comment_id else null end) as Extreme_Toxicity_9,
Count(case when target > 0.8  then comment_id else null end) as Very_High_Toxicity_8, -- also include 0.9 aswell
Count(case when target > 0.7 then comment_id else null end) as High_Toxicity_7  -- also include 0.8 and 0.7 aswell
from toxicity_data;

-- data sample record date 
select min(created_date), max(created_date)
from toxicity_data;

-- categorical analysis
select round(avg(obscene),2), round(avg(identity_attack),2),round(avg(insult),2), round(avg(threat),2)
from toxicity_data;


select 
count(*),
Count(case when obscene > 0 then comment_id else null end) as Obscene_comment,
Count(case when identity_attack > 0  then comment_id else null end) as Hate_speech, -- 
Count(case when insult > 0 then comment_id else null end) as Verbal_abuse,
Count(case when threat > 0 then comment_id else null end) as Threat
from toxicity_data
where target > 0;


select 
count(*),
Count(case when obscene > 0 then comment_id else null end)/count(*) as Obscene_comment,
Count(case when identity_attack > 0  then comment_id else null end)/count(*) as Hate_speech, -- 
Count(case when insult > 0 then comment_id else null end)/count(*) as Verbal_abuse,
Count(case when threat > 0 then comment_id else null end)/count(*) as Threat
from toxicity_data
where target > 0;


-- obscene analysis



-- annotator analysis
select max(identity_annotator_count),max(toxicity_annotator_count)
from toxicity_data;

select count(comment_id),rating
from toxicity_data
where target = 0 and
toxicity_annotator_count > 40
group by 2;  -- only 1 comment ID has tac of greater than 4 but still it is considered non toxic and it is also in rejected rating

-- calculated the annotator and toxicity comparion where around 55% of comments has toxicicty annotator count of greater than 30
WITH toxic_comment_with_annotatory_greater30 AS (
    SELECT COUNT(*) AS toxic_comment30
    FROM toxicity_data
    WHERE toxicity_annotator_count > 30
),
total_count AS (
    SELECT COUNT(*) AS total_cnt
    FROM toxicity_data
    where target > 0
)

SELECT 
    toxic_comment30 * 1.0 / total_cnt AS ratio
FROM toxic_comment_with_annotatory_greater30, total_count;


-- calculated the identity_annotator and toxicity comparion where around very minimal of '0.00024'has grater than 30 identity annotatrs
WITH toxic_comment_with_annotatory_greater30 AS (
    SELECT COUNT(*) AS toxic_comment30
    FROM toxicity_data
    WHERE identity_annotator_count > 30
),
total_count AS (
    SELECT COUNT(*) AS total_cnt
    FROM toxicity_data
    where target > 0
)

SELECT 
    toxic_comment30 * 1.0 / total_cnt AS ratio
FROM toxic_comment_with_annotatory_greater30, total_count;


--  publications
WITH publication_toxic_comments AS (
    SELECT COUNT(DISTINCT publication_id) AS pub_toxic
    FROM toxicity_data
    WHERE target > 0.7
)
SELECT 
    -- Multiply by 1.0 to force decimal division
    max(p.pub_toxic * 1.0) / COUNT(DISTINCT t.publication_id) AS pub_toxic_ratio
FROM publication_toxic_comments p
CROSS JOIN toxicity_data t;

-- articles analysis

select count(distinct article_id)
from toxicity_data;

select article_id,count(article_id)
from toxicity_data
where target > 0
group by 1
having count(article_id) > 1
order by 2 desc;

WITH article_toxic_comments AS (
    SELECT COUNT(DISTINCT article_id) AS art_toxic
    FROM toxicity_data
    WHERE target > 0
)
SELECT 
    -- Multiply by 1.0 to force decimal division
    max(p.art_toxic * 1.0) / COUNT(DISTINCT t.article_id) AS art_toxic_ratio
FROM article_toxic_comments p
CROSS JOIN toxicity_data t;


-- Publication article ratio
WITH pub_art_related AS (
    SELECT 
        publication_id,
        COUNT(DISTINCT article_id) AS articles
    FROM toxicity_data
    WHERE target > 0
    GROUP BY publication_id
    -- Removed the ORDER BY here; it causes errors in CTEs
    HAVING COUNT(DISTINCT article_id) > 500
),
total AS (
    SELECT 
        COUNT(DISTINCT publication_id) AS total_pubs,
        COUNT(DISTINCT article_id) AS total_articles
    FROM toxicity_data
    WHERE target > 0
),
selected_articles AS (
    SELECT COUNT(DISTINCT article_id) AS selected_articles
    FROM toxicity_data
    WHERE target > 0
    AND publication_id IN (SELECT publication_id FROM pub_art_related)
)
SELECT 
    COUNT(DISTINCT p.publication_id) * 1.0 / MAX(t.total_pubs) AS pub_ratio,
    MAX(s.selected_articles) * 1.0 / MAX(t.total_articles) AS article_ratio
FROM pub_art_related p
CROSS JOIN total t
CROSS JOIN selected_articles s;

drop temporary table avg_toxicity;
-- which article has the most toxic comments

create temporary table avg_toxicity as
SELECT article_id as article, count(comment_id) as c, round(avg(target),2) as toxicity,round(avg(obscene),2) as vulgar , round(avg(identity_attack),2) as hatespeech,
round(avg(insult),2) as abuse, round(avg(threat),2) as threat
from toxicity_data
where target > 0
group by 1
order by 2 desc;

select * from avg_toxicity;

select 
count(distinct article),
count( case when toxicity > 0.7 then article else null end) as no_of_art_with_hightoxicity,
count( case when vulgar > 0.7 then article else null end) as no_of_art_with_highvulgar,
count( case when hatespeech > 0.7 then article else null end) as no_of_art_with_highhatespeech,
count( case when abuse > 0.7 then article else null end) as no_of_art_with_verbalabuse,
count( case when threat > 0.7 then article else null end) as no_of_art_with_threat
from avg_toxicity;



select 
count(distinct article),
count( case when toxicity > 0.7 then article else null end)/count(distinct article) as Toxicity_percent,
count( case when vulgar > 0.7 then article else null end)/count(distinct article) as vulgar_percent,
count( case when hatespeech > 0.7 then article else null end)/count(distinct article) as hatespeech_percent,
count( case when abuse > 0.7 then article else null end)/count(distinct article) as verbal_abuse_percent,
count( case when threat > 0.7 then article else null end)/count(distinct article) as threat_percent
from avg_toxicity;\


-- parent Id and replies

select parent_id, count(comment_id),round(avg(target),2) as toxicity,round(avg(obscene),2) as vulgar , round(avg(identity_attack),2) as hatespeech,
round(avg(insult),2) as abuse, round(avg(threat),2) as threat
from toxicity_data
where target > 0 and parent_id > 0
group by 1
order by 2 desc;

select count(distinct parent_id)/count(distinct comment_id)
from toxicity_data
where target > 0;

-- categorical distribution - Moderation analysis

SELECT 
    rating, 
    COUNT(*) AS total_comments,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM toxicity_data), 2) AS percentage
FROM toxicity_data
where target > 0 and toxicity_annotator_count > 30
GROUP BY rating
ORDER BY total_comments DESC;



SELECT 
    rating, 
    COUNT(*) AS total_comments,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM toxicity_data), 2) AS percentage
FROM toxicity_data
where target > 0.7 and toxicity_annotator_count > 30
GROUP BY rating
ORDER BY total_comments DESC;

SELECT 
    rating, 
    COUNT(*) AS total_comments,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM toxicity_data), 2) AS percentage
FROM toxicity_data
where target = 0
GROUP BY rating
ORDER BY total_comments DESC;

SELECT 
    CASE 
        WHEN target > 0.7 THEN 'High Risk'
        WHEN target BETWEEN 0.3 AND 0.7 THEN 'Medium Risk'
        WHEN target BETWEEN 0 and 0.3 then 'Low Risk'
        ELSE 'Non toxic Comments'
    END AS risk_level,
    rating,
    COUNT(*) AS total_comments,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM toxicity_data), 2) AS pct_of_total
FROM toxicity_data
GROUP BY risk_level, rating
ORDER BY risk_level DESC, pct_of_total DESC;



select round(avg(target),2) as toxicity,round(avg(obscene),2) as vulgar , round(avg(identity_attack),2) as hatespeech,
round(avg(insult),2) as abuse, round(avg(threat),2) as threat
from toxicity_data
where target > 0 
and rating = 'approved';


-- commente reaction - Engagaement analysis

select 
count(case when funny <> 0 then comment_id else null end) as funny_reaction,
count(case when wow <> 0 then comment_id else null end) as wow_reaction,
count(case when sad <> 0 then comment_id else null end) as sad_reaction,
count(case when likes <> 0 then comment_id else null end) as likes_reaction,
count(case when disagree <> 0 then comment_id else null end)  disagree_reaction
from toxicity_data
where target > 0.7
and 
toxicity_annotator_count > 30  ;



select 
count(case when funny <> 0 then comment_id else null end)/count(distinct comment_id) as funny_reaction,
count(case when wow <> 0 then comment_id else null end) /count(distinct comment_id)as wow_reaction,
count(case when sad <> 0 then comment_id else null end)/count(distinct comment_id) as sad_reaction,
count(case when likes <> 0 then comment_id else null end) /count(distinct comment_id)as likes_reaction,
count(case when disagree <> 0 then comment_id else null end) /count(distinct comment_id)as disagree_reaction
from toxicity_data
where target > 0.7
and 
toxicity_annotator_count > 30  ;

select count(comment_id) from toxicity_data where target > 0.7
and toxicity_annotator_count > 30;


select rating,count(case when disagree <> 0 then comment_id else null end) as disagree_reaction,
count(case when disagree <> 0 then comment_id else null end) /(select count(comment_id) from toxicity_data where target > 0.7
and toxicity_annotator_count > 30)  as  disagree_reaction_pct
from toxicity_data
where target > 0.7
and 
toxicity_annotator_count > 30 
group by 1;



select target,rating,toxicity_annotator_count,disagree
from
toxicity_data
where disagree in 
(select max(disagree)
from toxicity_data);

-- positive engagement to toxic commments (likes, wow, funny)
select rating,
count(case when funny <> 0 then comment_id else null end)/count(distinct comment_id) as funny_reaction,
count(case when wow <> 0 then comment_id else null end) /count(distinct comment_id)as wow_reaction,
count(case when likes <> 0 then comment_id else null end) /count(distinct comment_id)as likes_reaction
from toxicity_data
where target > 0.7
and 
toxicity_annotator_count > 30
group by 1  ;
