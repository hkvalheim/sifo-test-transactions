-- Først oppretter vi hjelpefunksjonen for tilfeldige datoer
CREATE OR REPLACE FUNCTION random_date_in_month(year INT, month INT) RETURNS DATE AS $$
DECLARE
  start_date DATE;
  days_in_month INT;
  random_day INT;
BEGIN
  start_date := make_date(year, month, 1);
  days_in_month := (DATE_TRUNC('MONTH', start_date) + INTERVAL '1 MONTH - 1 day')::DATE - DATE_TRUNC('MONTH', start_date)::DATE + 1;
  random_day := floor(random() * days_in_month) + 1;
  RETURN make_date(year, month, random_day);
END;
$$ LANGUAGE plpgsql;

-- Først oppretter vi en funksjon for å generere beløp med variasjon
CREATE OR REPLACE FUNCTION generate_amount_with_variation(base_amount NUMERIC, variation_percent INT DEFAULT 10) 
RETURNS NUMERIC AS $$
BEGIN
    RETURN base_amount * (1 + (random() * variation_percent/100 - variation_percent/200));
END;
$$ LANGUAGE plpgsql;

-- Så oppretter vi hovedfunksjonen for å generere testdata
CREATE OR REPLACE FUNCTION generate_testdata_2024() RETURNS VOID AS $$
DECLARE
  cat RECORD;
  transaction_date DATE;
  transaction_amount NUMERIC;
  transaction_title TEXT;
  receiver TEXT;
  payment_type TEXT;
  frequency INT;
  i INT;
  monthly_pattern BOOLEAN;
  seasonal_variation BOOLEAN;
  min_amount NUMERIC;
  max_amount NUMERIC;
  receivers TEXT[];
  -- SIFO referanseverdier for familie (2 voksne, 1 tennåring, 2 barn)
  base_amounts RECORD;
BEGIN
  -- Definerer basis månedsbeløp basert på SIFO
  SELECT 
    16440 as mat_drikke,        -- (4220*2 + 3890 + 2340*2)
    8970 as klar_sko,           -- (2190*2 + 2390 + 1100*2)
    4290 as personlig_pleie,    -- (850*2 + 990 + 800*2)
    9280 as fritid_kultur,      -- (2320*2 + 2440 + 1100*2)
    11910 as transport,         -- (2970*2 + 3090 + 1440*2)
    4680 as diverse            -- (1170*2 + 1140 + 600*2)
  INTO base_amounts;

  -- Tøm eksisterende transaksjoner for 2024
  DELETE FROM transactions WHERE EXTRACT(YEAR FROM booking_date) = 2024;
  
  -- Generer for hver kategori
  FOR cat IN SELECT id, name, parent_id FROM categories WHERE parent_id IS NOT NULL ORDER BY id LOOP
    RAISE NOTICE 'Genererer data for kategori %: %', cat.id, cat.name;
    
    -- Sett kategori-spesifikke innstillinger
    CASE 
      -- BOLIG
      WHEN cat.id = 9 THEN -- Husleie
        receivers := ARRAY['Oslo Boligutleie AS', 'Utleier Hansen'];
        frequency := 12;
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -15000;
        max_amount := -15000;
        transaction_title := 'Husleie';
        payment_type := 'Betaling';
      WHEN cat.id = 10 THEN -- Strøm
        receivers := ARRAY['Elvia AS', 'Fjordkraft', 'Tibber Norge'];
        frequency := 12;
        monthly_pattern := TRUE;
        seasonal_variation := TRUE;
        min_amount := -1200;
        max_amount := -3500;
        transaction_title := 'Strømregning';
        payment_type := 'Betaling';

      -- MAT OG DRIKKE
      WHEN cat.parent_id = 2 THEN
        receivers := ARRAY['Rema 1000', 'Kiwi', 'Meny', 'Coop Mega', 'Joker'];
        frequency := 45; -- Omtrent hver andre dag
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -base_amounts.mat_drikke/30;  -- Daglig basis
        max_amount := -base_amounts.mat_drikke/15;  -- Større handletur
        transaction_title := 'Dagligvarer';
        payment_type := 'Visa';

      -- TRANSPORT
      WHEN cat.id = 20 THEN -- Kollektivtransport
        receivers := ARRAY['Ruter', 'Vy', 'Entur'];
        frequency := 24; -- Månedskort + ekstra billetter
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -base_amounts.transport/4;
        max_amount := -base_amounts.transport/3;
        transaction_title := 'Kollektivtransport';
        payment_type := 'Visa';

      -- KLÆR OG SKO
      WHEN cat.parent_id = 4 THEN
        receivers := ARRAY['H&M', 'Zara', 'Cubus', 'XXL', 'Stadium'];
        frequency := 24; -- To ganger i måneden i snitt
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -base_amounts.klar_sko/8;
        max_amount := -base_amounts.klar_sko/4;
        transaction_title := 'Klær og sko';
        payment_type := 'Visa';

      -- FRITID OG KULTUR
      WHEN cat.parent_id = 6 THEN
        receivers := ARRAY['Kulturhuset', 'Kino', 'Teater', 'Museum', 'Konserthuset'];
        frequency := 30; -- Jevnlige aktiviteter
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -base_amounts.fritid_kultur/10;
        max_amount := -base_amounts.fritid_kultur/5;
        transaction_title := cat.name;
        payment_type := 'Visa';

      -- Standardverdier for andre kategorier
      ELSE 
        receivers := ARRAY['Diverse', 'Ukjent', 'Nettbutikk'];
        frequency := 12;
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -500;
        max_amount := -1500;
        transaction_title := cat.name;
        payment_type := 'Visa';
    END CASE;

    -- Generer transaksjoner
    FOR i IN 1..frequency LOOP
      -- Bestem dato
      IF monthly_pattern THEN
        transaction_date := make_date(2024, 1 + ((i-1) % 12), 
            CASE WHEN cat.id = 9 THEN 1 ELSE 5 + (cat.id % 20) END);
      ELSE
        transaction_date := random_date_in_month(2024, 1 + floor(random() * 12)::integer);
      END IF;

      -- Beregn beløp med sesongvariasjon
      IF seasonal_variation THEN
        CASE EXTRACT(MONTH FROM transaction_date)
          WHEN 1, 2, 12 THEN -- Vinter
            transaction_amount := min_amount * 1.3;
          WHEN 6, 7, 8 THEN  -- Sommer
            transaction_amount := min_amount * 0.8;
          ELSE               -- Vår/Høst
            transaction_amount := min_amount;
        END CASE;
      ELSE
        transaction_amount := min_amount + (random() * (min_amount - max_amount));
      END IF;

      -- Velg tilfeldig mottaker
      receiver := receivers[1 + floor(random() * array_length(receivers, 1))::integer];

      -- Sett inn transaksjon
      INSERT INTO transactions (
        booking_date, amount, sender, receiver, name, title, 
        currency, payment_type, category_id
      ) VALUES (
        transaction_date,
        ROUND(transaction_amount::numeric, 2),
        'Privatkonto',
        receiver,
        receiver,
        transaction_title,
        'NOK',
        payment_type,
        cat.id
      );
    END LOOP;
  END LOOP;

  -- Legg til inntekter (lønn for to voksne)
  FOR i IN 1..12 LOOP
    -- Hovedinntekt
    INSERT INTO transactions (
      booking_date, amount, sender, receiver, name, title, 
      currency, payment_type, category_id
    ) VALUES (
      make_date(2024, i, 15),
      45000,
      'Arbeidsgiver AS',
      'Privatkonto',
      'Arbeidsgiver AS',
      'Lønn hovedinntekt',
      'NOK',
      'Lønn',
      NULL
    );
    
    -- Partner inntekt
    INSERT INTO transactions (
      booking_date, amount, sender, receiver, name, title, 
      currency, payment_type, category_id
    ) VALUES (
      make_date(2024, i, 12),
      38000,
      'Bedrift AS',
      'Privatkonto',
      'Bedrift AS',
      'Lønn partner',
      'NOK',
      'Lønn',
      NULL
    );
  END LOOP;

  -- Bekreftelse
  RAISE NOTICE 'Generering fullført, totalt % transaksjoner generert', 
    (SELECT COUNT(*) FROM transactions WHERE EXTRACT(YEAR FROM booking_date) = 2024);
END;
$$ LANGUAGE plpgsql;

-- Kjør funksjonen
SELECT generate_testdata_2024();

-- Verifiser resultatet
SELECT c.name as kategori, COUNT(*) as antall, 
    ROUND(ABS(SUM(t.amount))::numeric, 2) as sum_beløp,
    ROUND(ABS(AVG(t.amount))::numeric, 2) as snitt_beløp
FROM transactions t
JOIN categories c ON t.category_id = c.id
WHERE EXTRACT(YEAR FROM t.booking_date) = 2024
GROUP BY c.name
ORDER BY c.name;