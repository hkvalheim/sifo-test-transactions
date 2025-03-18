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
BEGIN
  -- Tøm eksisterende transaksjoner hvis ønskelig
  -- TRUNCATE transactions CASCADE;
  -- ALTER SEQUENCE transactions_id_seq RESTART WITH 1;
  
  -- Generer for hver kategori
  FOR cat IN SELECT id, name, parent_id FROM categories WHERE id > 8 ORDER BY id LOOP
    RAISE NOTICE 'Genererer data for kategori %: %', cat.id, cat.name;
    
    -- Sett kategori-spesifikke innstillinger
    CASE 
      -- BOLIG
      WHEN cat.id = 9 THEN -- Husleie
        receivers := ARRAY['Oslo Boligutleie AS', 'Utleier Hansen'];
        frequency := 12; -- Månedlig
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -12500;
        max_amount := -12500;
        transaction_title := 'Husleie';
        payment_type := 'Betaling';
      WHEN cat.id = 10 THEN -- Strøm
        receivers := ARRAY['Elvia AS', 'Fjordkraft', 'Tibber Norge'];
        frequency := 12; -- Månedlig
        monthly_pattern := TRUE;
        seasonal_variation := TRUE;
        min_amount := -700;
        max_amount := -2200;
        transaction_title := 'Strømregning';
        payment_type := 'Betaling';
      WHEN cat.id = 11 THEN -- Kommunale avgifter
        receivers := ARRAY['Oslo Kommune', 'Kommunale avgifter'];
        frequency := 4; -- Kvartalsvis
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -3500;
        max_amount := -4000;
        transaction_title := 'Kommunale avgifter';
        payment_type := 'Betaling';
      WHEN cat.id = 12 THEN -- Forsikring bolig
        receivers := ARRAY['Gjensidige Forsikring', 'IF Forsikring', 'Tryg Forsikring'];
        frequency := 4; -- Kvartalsvis
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -1400;
        max_amount := -1600;
        transaction_title := 'Boligforsikring';
        payment_type := 'Betaling';
      WHEN cat.id = 13 THEN -- Vedlikehold
        receivers := ARRAY['Jernia AS', 'Clas Ohlson', 'Biltema', 'Byggmax', 'Maxbo', 'Montér'];
        frequency := 5; -- Sporadisk
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -1000;
        max_amount := -5000;
        transaction_title := 'Vedlikehold bolig';
        payment_type := 'Visa';
      WHEN cat.id = 14 THEN -- Internett og TV
        receivers := ARRAY['Telenor Norge AS', 'Telia', 'Get', 'Altibox'];
        frequency := 12; -- Månedlig
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -899;
        max_amount := -1099;
        transaction_title := 'Internett og TV';
        payment_type := 'Betaling';
      WHEN cat.id = 15 THEN -- Møbler og interiør
        receivers := ARRAY['IKEA AS', 'Skeidar', 'Jysk', 'Bohus', 'Kid Interiør', 'Elkjøp', 'Nille', 'Princess'];
        frequency := 6; -- Sporadisk
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -800;
        max_amount := -5000;
        transaction_title := 'Møbler og interiør';
        payment_type := 'Visa';
        
      -- MAT OG DRIKKE
      WHEN cat.id = 16 THEN -- Dagligvarer
        receivers := ARRAY['Rema 1000', 'Kiwi', 'Meny', 'Coop Extra', 'Bunnpris', 'Joker', 'Spar'];
        frequency := 300; -- Høyfrekvent
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -180;
        max_amount := -1000;
        transaction_title := 'Dagligvarer';
        payment_type := 'Visa';
      WHEN cat.id = 17 THEN -- Restaurant og kafé
        receivers := ARRAY['Espresso House', 'Kaffebrenneriet', 'Starbucks', 'Baker Hansen', 
                           'Olivia Restaurant', 'Peppes Pizza', 'Lofoten Fiskerestaurant', 'Aften Restaurant', 
                           'Delicatessen', 'Den Glade Gris', 'Egon Restaurant', 'Krishnas Cuisine'];
        frequency := 100; -- Moderat høy
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -80;
        max_amount := -1600;
        transaction_title := 'Restaurant/Kafé';
        payment_type := 'Visa';
      WHEN cat.id = 18 THEN -- Takeaway
        receivers := ARRAY['Foodora', 'Wolt', 'Just Eat', 'Dominos Pizza', 'Pizzabakeren', 'McDonalds', 'Burger King'];
        frequency := 72; -- 6 per måned
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -200;
        max_amount := -450;
        transaction_title := 'Takeaway';
        payment_type := 'Visa';
      WHEN cat.id = 19 THEN -- Alkohol
        receivers := ARRAY['Vinmonopolet'];
        frequency := 30; -- 2-3 ganger per måned
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -400;
        max_amount := -1000;
        transaction_title := 'Vinmonopolet';
        payment_type := 'Visa';
        
      -- TRANSPORT
      WHEN cat.id = 20 THEN -- Kollektivtransport
        receivers := ARRAY['Ruter AS', 'Vy', 'Entur', 'Flytoget'];
        frequency := 45; -- Fast månedlig + ekstra billetter
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -39;
        max_amount := -814;
        transaction_title := 'Kollektivtransport';
        payment_type := 'Visa';
      WHEN cat.id = 21 THEN -- Drivstoff
        receivers := ARRAY['Circle K', 'Esso', 'Shell', 'Uno-X', 'YX'];
        frequency := 24; -- 2 ganger per måned
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -600;
        max_amount := -1000;
        transaction_title := 'Drivstoff';
        payment_type := 'Visa';
      WHEN cat.id = 22 THEN -- Bilhold
        receivers := ARRAY['Statens Vegvesen', 'Skatteetaten', 'NAF'];
        frequency := 1; -- Årlig
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -5800;
        max_amount := -6000;
        transaction_title := 'Årsavgift bil';
        payment_type := 'Betaling';
      WHEN cat.id = 23 THEN -- Vedlikehold kjøretøy
        receivers := ARRAY['Mekonomen Verksted', 'Dekk1', 'Vianor', 'Bilia', 'Møller Auto'];
        frequency := 4; -- Sporadisk
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -2000;
        max_amount := -5000;
        transaction_title := 'Vedlikehold bil';
        payment_type := 'Visa';
      WHEN cat.id = 24 THEN -- Forsikring kjøretøy
        receivers := ARRAY['Gjensidige Forsikring', 'IF Forsikring', 'Tryg Forsikring', 'Fremtind'];
        frequency := 4; -- Kvartalsvis
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -2900;
        max_amount := -3100;
        transaction_title := 'Bilforsikring';
        payment_type := 'Betaling';
      WHEN cat.id = 25 THEN -- Parkering
        receivers := ARRAY['EuroPark AS', 'Q-Park', 'Aimo Park', 'Oslo Kommune Parkering'];
        frequency := 60; -- 5 ganger per måned
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -35;
        max_amount := -100;
        transaction_title := 'Parkering';
        payment_type := 'Visa';
      WHEN cat.id = 26 THEN -- Bompenger
        receivers := ARRAY['Fjellinjen AS', 'AutoPASS', 'Bomringen'];
        frequency := 12; -- Månedlig
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -400;
        max_amount := -700;
        transaction_title := 'Bompenger';
        payment_type := 'Betaling';
      
      -- KLÆR OG SKO
      WHEN cat.id = 27 THEN -- Klær
        receivers := ARRAY['H&M', 'Zara', 'Cubus', 'Dressmann', 'Carlings', 'Lindex', 'Jack & Jones', 
                           'Volt', 'Urban', 'Weekday', 'Monki', 'BikBok', 'Zalando', 'Boozt', 'ASOS'];
        frequency := 32; -- Varierer gjennom året
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -400;
        max_amount := -2000;
        transaction_title := 'Klær';
        payment_type := 'Visa';
      WHEN cat.id = 28 THEN -- Sko
        receivers := ARRAY['Eurosko', 'Skoringen', 'Din Sko', 'Footlocker', 'Shoe Gallery', 'Ecco', 'Skomaker Dagestad', 'Nilson Shoes'];
        frequency := 9; -- Få, men større kjøp
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -600;
        max_amount := -2200;
        transaction_title := 'Sko';
        payment_type := 'Visa';
      WHEN cat.id = 29 THEN -- Tilbehør
        receivers := ARRAY['Glitter', 'Accessorize', 'H&M', 'Cubus', 'Ur & Penn', 'Vita', 'Kicks', 'Claire''s', 'Tilbehørsbutikken'];
        frequency := 10; -- Sporadisk
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -250;
        max_amount := -4000;
        transaction_title := 'Tilbehør';
        payment_type := 'Visa';
        
      -- PERSONLIG PLEIE
      WHEN cat.id = 30 THEN -- Hygiene
        receivers := ARRAY['Apotek 1', 'Boots Apotek', 'Vitus Apotek', 'Normal', 'H&M', 'Vita', 'Kicks'];
        frequency := 40; -- 3-4 per måned
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -300;
        max_amount := -900;
        transaction_title := 'Hygieneprodukter';
        payment_type := 'Visa';
      WHEN cat.id = 31 THEN -- Frisør
        receivers := ARRAY['Frisør Adam og Eva', 'Nikita Hair', 'Cutters', 'HEAD Frisør', 'Salong Cut', 'SAYSO Hair', 'Frisør Sara'];
        frequency := 9; -- Hver 6-8 uke
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -500;
        max_amount := -2000;
        transaction_title := 'Frisør';
        payment_type := 'Visa';
      WHEN cat.id = 32 THEN -- Helse
        receivers := ARRAY['Legesenter', 'Tannlege', 'Kiropraktor', 'Fysioterapeut', 'Hudlege', 'Volvat Medisinske Senter'];
        frequency := 6; -- Sporadisk
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -300;
        max_amount := -3500;
        transaction_title := 'Helsetjenester';
        payment_type := 'Visa';
      WHEN cat.id = 33 THEN -- Medisiner
        receivers := ARRAY['Apotek 1', 'Boots Apotek', 'Vitus Apotek', 'Ditt Apotek'];
        frequency := 17; -- Regelmessig
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -150;
        max_amount := -600;
        transaction_title := 'Medisiner';
        payment_type := 'Visa';
      WHEN cat.id = 34 THEN -- Treningsmedlemskap
        receivers := ARRAY['SATS Norge', 'Elixia', 'Evo Fitness', 'Fresh Fitness', 'XXL Sport', 'Intersport'];
        frequency := 21; -- Månedlig abonnement + utstyr
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -549;
        max_amount := -1500;
        transaction_title := 'Trening';
        payment_type := 'Visa';
        
      -- FRITID OG KULTUR
      WHEN cat.id = 35 THEN -- Underholdning
        receivers := ARRAY['Filmweb', 'Odeon Kino', 'Colosseum Kino', 'Ticketmaster', 'Oslo Konserthus'];
        frequency := 24; -- 2 per måned
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -200;
        max_amount := -800;
        transaction_title := 'Underholdning';
        payment_type := 'Visa';
      WHEN cat.id = 36 THEN -- Hobby
        receivers := ARRAY['Hobbyland', 'Clas Ohlson', 'Panduro Hobby', 'Jernia', 'XXL Sport'];
        frequency := 15; -- Jevnlig
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -300;
        max_amount := -1500;
        transaction_title := 'Hobbyartikler';
        payment_type := 'Visa';
      WHEN cat.id = 37 THEN -- Ferier
        receivers := ARRAY['SAS', 'Norwegian', 'Booking.com', 'Hotels.com', 'Ving', 'TUI'];
        frequency := 5; -- Få, men store kjøp
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -2000;
        max_amount := -12000;
        transaction_title := 'Feriereise';
        payment_type := 'Visa';
      WHEN cat.id = 38 THEN -- Kultur
        receivers := ARRAY['Nasjonalgalleriet', 'Astrup Fearnley Museet', 'Den Norske Opera', 'Nationaltheatret'];
        frequency := 12; -- Månedlig
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -200;
        max_amount := -600;
        transaction_title := 'Kulturarrangement';
        payment_type := 'Visa';
      WHEN cat.id = 39 THEN -- Gaver
        receivers := ARRAY['Tilbehørsbutikken', 'Jernia', 'IKEA', 'Kicks', 'Vinmonopolet', 'Nille'];
        frequency := 15; -- Sporadisk
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -300;
        max_amount := -1000;
        transaction_title := 'Gave';
        payment_type := 'Visa';
      WHEN cat.id = 40 THEN -- Abonnementer
        receivers := ARRAY['Netflix', 'HBO Max', 'Spotify', 'Disney+', 'Amazon Prime', 'Storytel', 'Apple'];
        frequency := 50; -- Flere månedlige abonnementer
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -89;
        max_amount := -199;
        transaction_title := 'Abonnement';
        payment_type := 'Visa';

      -- SPARING OG INVESTERING
      WHEN cat.id = 41 THEN -- Sparing
        receivers := ARRAY['Egen sparekonto', 'Sparekonto', 'BSU-konto'];
        frequency := 12; -- Månedlig
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -3000;
        max_amount := -5000;
        transaction_title := 'Overføring til sparing';
        payment_type := 'Overføring';
      WHEN cat.id = 42 THEN -- Aksjefond
        receivers := ARRAY['DNB Asset Management', 'Nordnet', 'KLP', 'ODIN Forvaltning'];
        frequency := 12; -- Månedlig
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -2000;
        max_amount := -2000;
        transaction_title := 'Fondssparing';
        payment_type := 'Overføring';
      WHEN cat.id = 43 THEN -- Enkeltaksjer
        receivers := ARRAY['Nordnet', 'DNB Markets', 'Saxo Bank'];
        frequency := 6; -- Sporadisk
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -5000;
        max_amount := -15000;
        transaction_title := 'Aksjekjøp';
        payment_type := 'Overføring';

      -- ANDRE UTGIFTER
      WHEN cat.id = 46 THEN -- Forsikringer
        receivers := ARRAY['Gjensidige Forsikring', 'IF Forsikring', 'Tryg Forsikring', 'DNB Forsikring'];
        frequency := 4; -- Kvartalsvis
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -1200;
        max_amount := -1500;
        transaction_title := 'Innboforsikring/Reiseforsikring';
        payment_type := 'Betaling';
      WHEN cat.id = 47 THEN -- Utdanning
        receivers := ARRAY['Bokhandel', 'Akademika', 'Kompetanse Norge', 'Kursagenten'];
        frequency := 4; -- Sporadisk
        monthly_pattern := FALSE;
        seasonal_variation := TRUE;
        min_amount := -500;
        max_amount := -3000;
        transaction_title := 'Utdanning/Kurs';
        payment_type := 'Visa';
      WHEN cat.id = 49 THEN -- Lån og renter
        receivers := ARRAY['DNB', 'Nordea', 'Danske Bank', 'OBOS-banken'];
        frequency := 12; -- Månedlig
        monthly_pattern := TRUE;
        seasonal_variation := FALSE;
        min_amount := -6500;
        max_amount := -6500;
        transaction_title := 'Nedbetaling lån';
        payment_type := 'Betaling';
        
      -- Standardverdier for kategorier som ikke har spesifikke innstillinger
      ELSE 
        receivers := ARRAY['Diverse', 'Ukjent', 'Nettbutikk'];
        frequency := 10; -- Få transaksjoner
        monthly_pattern := FALSE;
        seasonal_variation := FALSE;
        min_amount := -500;
        max_amount := -1500;
        transaction_title := cat.name;
        payment_type := 'Visa';
    END CASE;
    
    -- Generer transaksjoner for denne kategorien
    FOR i IN 1..frequency LOOP
      -- Bestem dato basert på månedsmønster
      IF monthly_pattern AND i <= 12 THEN
        -- For månedlige betalinger, bruk en fast dag i måneden
        transaction_date := make_date(2024, i, CASE WHEN cat.id = 9 THEN 1 ELSE 5 + (cat.id % 20) END);
      ELSE
        -- For andre, bruk tilfeldige datoer fordelt over året
        transaction_date := make_date(2024, 1 + floor(random() * 12)::integer, 1 + floor(random() * 28)::integer);
      END IF;
      
      -- Bestem beløp, med sesongvariasjon hvis relevant
      IF seasonal_variation THEN
        -- Strøm har høyere kostnader om vinteren
        IF cat.id = 10 THEN -- Strøm
          CASE EXTRACT(MONTH FROM transaction_date)
            WHEN 12, 1, 2 THEN transaction_amount := -1800 - (random() * 400); -- Vinter (høy)
            WHEN 3, 4, 5, 9, 10, 11 THEN transaction_amount := -1200 - (random() * 300); -- Vår/høst (medium)
            ELSE transaction_amount := -700 - (random() * 200); -- Sommer (lav)
          END CASE;
        -- Dagligvarer har høyere kostnader rundt jul
        ELSIF cat.id = 16 AND EXTRACT(MONTH FROM transaction_date) = 12 AND EXTRACT(DAY FROM transaction_date) > 15 THEN
          transaction_amount := -800 - (random() * 700); -- Julevarer
        -- Klær har sesongvariasjoner
        ELSIF cat.id = 27 THEN
          CASE EXTRACT(MONTH FROM transaction_date)
            WHEN 12 THEN transaction_amount := -800 - (random() * 1200); -- Julegaver, festklær
            WHEN 7 THEN transaction_amount := -400 - (random() * 500); -- Sommersalg
            WHEN 9, 10 THEN transaction_amount := -750 - (random() * 850); -- Høstkolleksjoner
            ELSE transaction_amount := -500 - (random() * 700); -- Standard
          END CASE;
        ELSE
          -- Andre sesongvariasjoner
          transaction_amount := min_amount - (random() * (max_amount - min_amount));
        END IF;
      ELSE
        -- Ingen sesongvariasjon, bare tilfeldig beløp innen spekteret
        transaction_amount := min_amount - (random() * (max_amount - min_amount));
      END IF;
      
      -- For faste beløp som husleie
      IF cat.id = 9 OR (cat.id = 14) OR (cat.id = 34 AND i <= 12) THEN -- Husleie, TV/Internett eller treningsmedlemskap
        transaction_amount := min_amount;
      END IF;
      
      -- Velg en tilfeldig mottaker fra listen
      receiver := receivers[1 + floor(random() * array_length(receivers, 1))];
      
      -- Sett spesifikke transaksjontitler for visse kategorier og sesonger
      IF cat.id = 10 THEN -- Strøm
        transaction_title := 'Strømregning ' || TO_CHAR(transaction_date, 'YYYY-MM');
      ELSIF cat.id = 11 OR cat.id = 12 THEN -- Kvartalsvise regninger
        transaction_title := transaction_title || ' ' || TO_CHAR(transaction_date, 'YYYY-Q') || '. kvartal';
      ELSIF cat.id = 27 THEN -- Klær
        -- Sesongvariasjoner i beskrivelsen
        CASE EXTRACT(MONTH FROM transaction_date)
          WHEN 12 THEN 
            IF random() < 0.4 THEN transaction_title := 'Festklær';
            ELSIF random() < 0.7 THEN transaction_title := 'Julegaver - klær';
            ELSE transaction_title := 'Vinterklær'; END IF;
          WHEN 1, 2 THEN
            IF random() < 0.5 THEN transaction_title := 'Vinterklær';
            ELSE transaction_title := 'Klær'; END IF;
          WHEN 3, 4, 5 THEN
            IF random() < 0.6 THEN transaction_title := 'Vårklær';
            ELSE transaction_title := 'Klær'; END IF;
          WHEN 6, 7, 8 THEN
            IF random() < 0.7 THEN transaction_title := 'Sommerklær';
            ELSE transaction_title := 'Klær'; END IF;
          WHEN 9, 10, 11 THEN
            IF random() < 0.6 THEN transaction_title := 'Høstklær';
            ELSE transaction_title := 'Klær'; END IF;
        END CASE;
      END IF;
      
      -- Sett inn transaksjonen
      INSERT INTO transactions (
        booking_date, 
        amount, 
        sender, 
        receiver, 
        name, 
        title, 
        currency, 
        payment_type, 
        category_id
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
  
  -- Legg til noen inntekter/lønn
  FOR i IN 1..12 LOOP
    INSERT INTO transactions (
      booking_date, 
      amount, 
      sender, 
      receiver, 
      name, 
      title, 
      currency, 
      payment_type, 
      category_id
    ) VALUES (
      make_date(2024, i, 15), -- Lønnsutbetaling 15. hver måned
      38500, -- Fast lønn
      'Arbeidsgiver AS',
      'Privatkonto',
      'Arbeidsgiver AS',
      'Lønnsutbetaling',
      'NOK',
      'Overføring',
      NULL -- Ingen kategori for lønn ennå
    );
  END LOOP;
  
  -- Bekreftelse
  RAISE NOTICE 'Generering fullført, totalt % transaksjoner generert', 
    (SELECT COUNT(*) FROM transactions WHERE booking_date >= '2024-01-01');
END;
$$ LANGUAGE plpgsql;

-- Kjør funksjonen for å generere alt på én gang
SELECT generate_testdata_2024();

-- Verifiser resultatet
SELECT c.name as kategori, COUNT(*) as antall, SUM(t.amount) as sum_beløp
FROM transactions t
JOIN categories c ON t.category_id = c.id
WHERE t.booking_date >= '2024-01-01'
GROUP BY c.name
ORDER BY c.name;