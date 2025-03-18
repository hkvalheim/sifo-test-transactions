-- SIFO Kategorier initialiseringsscript
-- Dette skriptet setter opp hovedkategorier og underkategorier basert på SIFO-standarden

-- Tøm eksisterende data (hvis nødvendig)
TRUNCATE category_keywords CASCADE;
TRUNCATE categories CASCADE;
-- Reset serienumre
ALTER SEQUENCE categories_id_seq RESTART WITH 1;
ALTER SEQUENCE category_keywords_id_seq RESTART WITH 1;

-- Hovedkategorier
INSERT INTO categories (name, sifo_code, description, parent_id) VALUES
('Bolig', 'SIFO-B', 'Utgifter knyttet til bolig', NULL),
('Mat og drikke', 'SIFO-MD', 'Utgifter til mat og drikke', NULL),
('Transport', 'SIFO-T', 'Utgifter til transport', NULL),
('Klær og sko', 'SIFO-KS', 'Utgifter til klær og sko', NULL),
('Personlig pleie', 'SIFO-PP', 'Utgifter til personlig pleie', NULL),
('Fritid og kultur', 'SIFO-FK', 'Utgifter til fritidsaktiviteter og kultur', NULL),
('Sparing og investering', 'SIFO-SI', 'Penger satt av til sparing og investering', NULL),
('Andre utgifter', 'SIFO-A', 'Diverse andre utgifter', NULL);

-- Underkategorier for Bolig
INSERT INTO categories (name, sifo_code, description, parent_id) VALUES
('Husleie', 'SIFO-B-HL', 'Månedlig husleie', 1),
('Strøm', 'SIFO-B-ST', 'Utgifter til strøm', 1),
('Kommunale avgifter', 'SIFO-B-KA', 'Kommunale avgifter', 1),
('Forsikring bolig', 'SIFO-B-FB', 'Boligforsikring', 1),
('Vedlikehold', 'SIFO-B-VL', 'Vedlikehold av bolig', 1),
('Internett og TV', 'SIFO-B-ITV', 'Utgifter til internett og TV', 1),
('Møbler og interiør', 'SIFO-B-MI', 'Utgifter til møbler og interiør', 1);

-- Underkategorier for Mat og drikke
INSERT INTO categories (name, sifo_code, description, parent_id) VALUES
('Dagligvarer', 'SIFO-MD-DV', 'Matvarer fra dagligvarebutikker', 2),
('Restaurant og kafé', 'SIFO-MD-RK', 'Bespisning ute', 2),
('Takeaway', 'SIFO-MD-TA', 'Henting av mat', 2),
('Alkohol', 'SIFO-MD-AL', 'Alkoholholdige drikkevarer', 2);

-- Underkategorier for Transport
INSERT INTO categories (name, sifo_code, description, parent_id) VALUES
('Kollektivtransport', 'SIFO-T-KT', 'Utgifter til kollektivtransport', 3),
('Drivstoff', 'SIFO-T-DS', 'Utgifter til drivstoff', 3),
('Bilhold', 'SIFO-T-BH', 'Faste utgifter til bil', 3),
('Vedlikehold kjøretøy', 'SIFO-T-VK', 'Vedlikehold og reparasjoner av kjøretøy', 3),
('Forsikring kjøretøy', 'SIFO-T-FK', 'Forsikring av kjøretøy', 3),
('Parkering', 'SIFO-T-PA', 'Parkeringsutgifter', 3),
('Bompenger', 'SIFO-T-BP', 'Utgifter til bompenger', 3);

-- Underkategorier for Klær og sko
INSERT INTO categories (name, sifo_code, description, parent_id) VALUES
('Klær', 'SIFO-KS-KL', 'Utgifter til klær', 4),
('Sko', 'SIFO-KS-SK', 'Utgifter til sko', 4),
('Tilbehør', 'SIFO-KS-TB', 'Tilbehør til klær og sko', 4);

-- Underkategorier for Personlig pleie
INSERT INTO categories (name, sifo_code, description, parent_id) VALUES
('Hygiene', 'SIFO-PP-HY', 'Hygieneartikler', 5),
('Frisør', 'SIFO-PP-FR', 'Frisørtjenester', 5),
('Helse', 'SIFO-PP-HL', 'Helsetjenester og -produkter', 5),
('Medisiner', 'SIFO-PP-MD', 'Utgifter til medisiner', 5),
('Treningsmedlemskap', 'SIFO-PP-TM', 'Medlemskap på treningssenter', 5);

-- Underkategorier for Fritid og kultur
INSERT INTO categories (name, sifo_code, description, parent_id) VALUES
('Underholdning', 'SIFO-FK-UH', 'Utgifter til underholdning', 6),
('Hobby', 'SIFO-FK-HB', 'Hobbyrelaterte utgifter', 6),
('Ferier', 'SIFO-FK-FR', 'Utgifter til ferier', 6),
('Kultur', 'SIFO-FK-KU', 'Kulturarrangementer', 6),
('Gaver', 'SIFO-FK-GA', 'Gaver til andre', 6),
('Abonnementer', 'SIFO-FK-AB', 'Abonnementer på magasiner, strømmetjenester, etc.', 6);

-- Underkategorier for Sparing og investering
INSERT INTO categories (name, sifo_code, description, parent_id) VALUES
('Sparing', 'SIFO-SI-SP', 'Generell sparing', 7),
('Aksjefond', 'SIFO-SI-AF', 'Investeringer i aksjefond', 7),
('Enkeltaksjer', 'SIFO-SI-EA', 'Investeringer i enkeltaksjer', 7),
('Pensjonssparing', 'SIFO-SI-PS', 'Sparing til pensjon', 7),
('Kryptovaluta', 'SIFO-SI-KV', 'Investering i kryptovaluta', 7);

-- Underkategorier for Andre utgifter
INSERT INTO categories (name, sifo_code, description, parent_id) VALUES
('Forsikringer', 'SIFO-A-FS', 'Andre forsikringer', 8),
('Utdanning', 'SIFO-A-UD', 'Utgifter til utdanning', 8),
('Veldedighet', 'SIFO-A-VD', 'Donasjoner til veldedige formål', 8),
('Lån og renter', 'SIFO-A-LR', 'Avdrag og renter på lån', 8),
('Diverse utgifter', 'SIFO-A-DU', 'Diverse uklassifiserte utgifter', 8);

-- Legg til nøkkelord for automatisk kategorisering
-- Bolig - Husleie
INSERT INTO category_keywords (category_id, keyword, weight) VALUES
(9, 'husleie', 1.0),
(9, 'leie', 0.8),
(9, 'hybel', 0.7),
(9, 'leilighet', 0.7);

-- Bolig - Strøm
INSERT INTO category_keywords (category_id, keyword, weight) VALUES
(10, 'strøm', 1.0),
(10, 'elektrisitet', 0.9),
(10, 'kraft', 0.8),
(10, 'fjernvarme', 0.8);

-- Mat og drikke - Dagligvarer
INSERT INTO category_keywords (category_id, keyword, weight) VALUES
(16, 'rema', 1.0),
(16, 'kiwi', 1.0),
(16, 'meny', 1.0),
(16, 'coop', 1.0),
(16, 'bunnpris', 1.0),
(16, 'dagligvare', 0.9),
(16, 'matbutikk', 0.9);

-- Mat og drikke - Restaurant
INSERT INTO category_keywords (category_id, keyword, weight) VALUES
(17, 'restaurant', 1.0),
(17, 'kafé', 1.0),
(17, 'cafe', 1.0),
(17, 'spiseri', 0.9),
(17, 'kafe', 0.9);

-- Transport - Kollektiv
INSERT INTO category_keywords (category_id, keyword, weight) VALUES
(20, 'buss', 1.0),
(20, 'tog', 1.0),
(20, 'trikk', 1.0),
(20, 'ruter', 1.0),
(20, 'vy', 1.0),
(20, 'at', 0.8),
(20, 'entur', 0.8);

-- Transport - Drivstoff
INSERT INTO category_keywords (category_id, keyword, weight) VALUES
(21, 'bensin', 1.0),
(21, 'diesel', 1.0),
(21, 'drivstoff', 1.0),
(21, 'esso', 0.9),
(21, 'shell', 0.9),
(21, 'circle k', 0.9),
(21, 'statoil', 0.8),
(21, 'uno-x', 0.9);

-- Tilpass flere nøkkelord etter behov

-- Bekreft antall kategorier
SELECT COUNT(*) FROM categories;

-- Bekreft antall nøkkelord
SELECT COUNT(*) FROM category_keywords;

-- Vis hierarkiet av kategorier
WITH RECURSIVE category_tree AS (
  SELECT id, name, parent_id, 0 AS level
  FROM categories
  WHERE parent_id IS NULL
  
  UNION ALL
  
  SELECT c.id, c.name, c.parent_id, ct.level + 1
  FROM categories c
  JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT 
  REPEAT('    ', level) || name AS category_hierarchy,
  id,
  parent_id
FROM category_tree
ORDER BY 
  CASE WHEN parent_id IS NULL THEN id ELSE parent_id END,
  level,
  name;