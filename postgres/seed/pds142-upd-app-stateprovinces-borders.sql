-- StateProvinces Border column is geography (PostGIS) -- setting to NULL as PostGIS is not installed.
UPDATE application.stateprovinces SET border = NULL;
