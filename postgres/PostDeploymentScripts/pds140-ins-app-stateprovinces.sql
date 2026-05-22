\echo 'Inserting Application.StateProvinces'

DO $$
DECLARE
  v_country_id_us INT;
BEGIN
  SELECT CountryID INTO v_country_id_us
  FROM application.countries
  WHERE CountryName = 'United States';

  INSERT INTO application.state_provinces
    (StateProvinceID, StateProvinceCode, StateProvinceName, CountryID, SalesTerritory, Border, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo)
  VALUES
    (1,  'AL', 'Alabama',                      v_country_id_us, 'Southeast',     NULL, 4833722,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (2,  'AK', 'Alaska',                       v_country_id_us, 'Far West',      NULL, 735132,   1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (3,  'AZ', 'Arizona',                      v_country_id_us, 'Southwest',     NULL, 6626624,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (4,  'AR', 'Arkansas',                     v_country_id_us, 'Southeast',     NULL, 2959373,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (5,  'CA', 'California',                   v_country_id_us, 'Far West',      NULL, 38332521, 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (6,  'CO', 'Colorado',                     v_country_id_us, 'Rocky Mountain',NULL, 5268367,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (7,  'CT', 'Connecticut',                  v_country_id_us, 'New England',   NULL, 3596080,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (8,  'DE', 'Delaware',                     v_country_id_us, 'Mideast',       NULL, 925749,   1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (9,  'DC', 'District of Columbia',         v_country_id_us, 'Mideast',       NULL, 658893,   1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (10, 'FL', 'Florida',                      v_country_id_us, 'Southeast',     NULL, 19552860, 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (11, 'GA', 'Georgia',                      v_country_id_us, 'Southeast',     NULL, 9992167,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (12, 'HI', 'Hawaii',                       v_country_id_us, 'Far West',      NULL, 1404054,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (13, 'ID', 'Idaho',                        v_country_id_us, 'Rocky Mountain',NULL, 1612136,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (14, 'IL', 'Illinois',                     v_country_id_us, 'Great Lakes',   NULL, 12882135, 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (15, 'IN', 'Indiana',                      v_country_id_us, 'Great Lakes',   NULL, 6570902,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (16, 'IA', 'Iowa',                         v_country_id_us, 'Plains',        NULL, 3090416,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (17, 'KS', 'Kansas',                       v_country_id_us, 'Plains',        NULL, 2893957,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (18, 'KY', 'Kentucky',                     v_country_id_us, 'Southeast',     NULL, 4395295,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (19, 'LA', 'Louisiana',                    v_country_id_us, 'Southeast',     NULL, 4625470,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (20, 'ME', 'Maine',                        v_country_id_us, 'New England',   NULL, 1328302,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (21, 'MD', 'Maryland',                     v_country_id_us, 'Mideast',       NULL, 5928814,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (22, 'MA', 'Massachusetts[E]',             v_country_id_us, 'New England',   NULL, 6692824,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (23, 'MI', 'Michigan',                     v_country_id_us, 'Great Lakes',   NULL, 9895622,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (24, 'MN', 'Minnesota',                    v_country_id_us, 'Plains',        NULL, 5420380,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (25, 'MS', 'Mississippi',                  v_country_id_us, 'Southeast',     NULL, 2991207,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (26, 'MO', 'Missouri',                     v_country_id_us, 'Plains',        NULL, 6021988,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (27, 'MT', 'Montana',                      v_country_id_us, 'Rocky Mountain',NULL, 1015165,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (28, 'NE', 'Nebraska',                     v_country_id_us, 'Plains',        NULL, 1868516,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (29, 'NV', 'Nevada',                       v_country_id_us, 'Far West',      NULL, 2790136,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (30, 'NH', 'New Hampshire',                v_country_id_us, 'New England',   NULL, 1323459,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (31, 'NJ', 'New Jersey',                   v_country_id_us, 'Mideast',       NULL, 8899339,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (32, 'NM', 'New Mexico',                   v_country_id_us, 'Southwest',     NULL, 2085287,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (33, 'NY', 'New York',                     v_country_id_us, 'Mideast',       NULL, 19651127, 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (34, 'NC', 'North Carolina',               v_country_id_us, 'Southeast',     NULL, 9848060,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (35, 'ND', 'North Dakota',                 v_country_id_us, 'Plains',        NULL, 723393,   1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (36, 'OH', 'Ohio',                         v_country_id_us, 'Great Lakes',   NULL, 11570808, 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (37, 'OK', 'Oklahoma',                     v_country_id_us, 'Southwest',     NULL, 3850568,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (38, 'OR', 'Oregon',                       v_country_id_us, 'Far West',      NULL, 3930065,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (39, 'PA', 'Pennsylvania',                 v_country_id_us, 'Mideast',       NULL, 12773801, 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (40, 'PR', 'Puerto Rico (US Territory)',   v_country_id_us, 'External',      NULL, 3474182,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (41, 'RI', 'Rhode Island',                 v_country_id_us, 'New England',   NULL, 1051511,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (42, 'SC', 'South Carolina',               v_country_id_us, 'Southeast',     NULL, 4774839,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (43, 'SD', 'South Dakota',                 v_country_id_us, 'Plains',        NULL, 844877,   1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (44, 'TN', 'Tennessee',                    v_country_id_us, 'Southeast',     NULL, 6495978,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (45, 'TX', 'Texas',                        v_country_id_us, 'Southwest',     NULL, 26448193, 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (46, 'UT', 'Utah',                         v_country_id_us, 'Rocky Mountain',NULL, 2900872,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (47, 'VT', 'Vermont',                      v_country_id_us, 'New England',   NULL, 626630,   1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (48, 'VI', 'Virgin Islands (US Territory)',v_country_id_us, 'External',      NULL, 104737,   1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (49, 'VA', 'Virginia',                     v_country_id_us, 'Southeast',     NULL, 8260405,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (50, 'WA', 'Washington',                   v_country_id_us, 'Far West',      NULL, 6971406,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (51, 'WV', 'West Virginia',                v_country_id_us, 'Southeast',     NULL, 1854304,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (52, 'WI', 'Wisconsin',                    v_country_id_us, 'Great Lakes',   NULL, 5742713,  1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
  , (53, 'WY', 'Wyoming',                      v_country_id_us, 'Rocky Mountain',NULL, 582658,   1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6));
END;
$$;
