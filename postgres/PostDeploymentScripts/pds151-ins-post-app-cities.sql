/* Post insert A-Z Code*/
\echo 'Executing Post Inserting application.cities Code'
;
DELETE FROM application.cities AS c
WHERE EXISTS (SELECT 1 FROM application.cities AS cd
                       WHERE cd.CityName = c.CityName
					   AND cd.StateProvinceID = c.StateProvinceID
					   AND cd.CityID < c.CityID);

DELETE FROM application.cities_archive AS ca
WHERE NOT EXISTS (SELECT 1 FROM application.cities AS c
                           WHERE ca.CityID = c.CityID);
;
