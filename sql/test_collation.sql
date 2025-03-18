-- Opprett en midlertidig testtabell
CREATE TEMPORARY TABLE norsk_test (
    ord TEXT
);

-- Sett inn noen norske ord
INSERT INTO norsk_test (ord) VALUES 
    ('å'),
    ('æ'),
    ('ø'),
    ('a'),
    ('b'),
    ('aa');

-- Test sortering
SELECT ord 
FROM norsk_test 
ORDER BY ord;

-- Test case-insensitive sortering
SELECT ord 
FROM norsk_test 
ORDER BY ord COLLATE "C";

-- Vis tilgjengelige collasjoner
SELECT * FROM pg_collation;