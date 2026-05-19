-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomBuyingGroupNotInUse.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_buying_group_not_in_use(
) RETURNS TABLE(
    city_id            integer,
    city_name          varchar(50),
    state_province_code varchar(5),
    state_province_name varchar(50),
    area_code          varchar(4),
    buying_group_id    integer,
    buying_group_name  varchar(50),
    web_domain         varchar(256),
    email_domain       varchar(256),
    customer_name      varchar(100)
) AS $$
DECLARE
    v_city_id            integer;
    v_city_name          varchar(50);
    v_state_province_code varchar(5);
    v_state_province_name varchar(50);
    v_area_code          varchar(4);
    v_buying_group_id    integer;
    v_buying_group_name  varchar(50);
    v_web_domain         varchar(256);
    v_email_domain       varchar(256);
    v_customer_name      varchar(100);
    v_in_use_counter     integer;
BEGIN
    v_in_use_counter := 1;
    WHILE v_in_use_counter > 0 LOOP
        SELECT r.city_id, r.city_name, r.state_province_code, r.state_province_name, r.area_code
        INTO v_city_id, v_city_name, v_state_province_code, v_state_province_name, v_area_code
        FROM dataloadsimulation.get_random_city() r;

        SELECT r.buying_group_id, r.buying_group_name
        INTO v_buying_group_id, v_buying_group_name
        FROM dataloadsimulation.get_random_buying_group() r;

        v_in_use_counter := dataloadsimulation.get_customer_count(
            v_buying_group_name || ' (' || v_city_name || ', ' || v_state_province_code || ')'
        );
    END LOOP;

    SELECT r.web_domain, r.email_domain
    INTO v_web_domain, v_email_domain
    FROM dataloadsimulation.get_buying_group_domain(v_buying_group_name) r;

    v_customer_name := v_buying_group_name || ' (' || v_city_name || ', ' || v_state_province_code || ')';

    city_id            := v_city_id;
    city_name          := v_city_name;
    state_province_code := v_state_province_code;
    state_province_name := v_state_province_name;
    area_code          := v_area_code;
    buying_group_id    := v_buying_group_id;
    buying_group_name  := v_buying_group_name;
    web_domain         := v_web_domain;
    email_domain       := v_email_domain;
    customer_name      := v_customer_name;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;
