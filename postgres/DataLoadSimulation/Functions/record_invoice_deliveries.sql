-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/RecordInvoiceDeliveries.sql
-- Note: geography .Lat/.Long → ST_Y/ST_X(geom::geometry); JSON_MODIFY → jsonb_set.
-- Requires: CREATE EXTENSION IF NOT EXISTS postgis;
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.record_invoice_deliveries(
    p_current_date_time timestamp,
    p_starting_when     timestamp,
    p_end_of_time       timestamp,
    p_is_silent_mode    boolean
) RETURNS void AS $$
DECLARE
    v_delivery_driver_person_id integer;
    v_returned_delivery_data    jsonb;
    v_invoice_id                integer;
    v_customer_name             varchar(100);
    v_primary_contact_full_name varchar(50);
    v_latitude                  numeric(18,7);
    v_longitude                 numeric(18,7);
    v_delivery_attempt_when     timestamp;
    v_counter                   integer := 0;
    v_delivery_event            jsonb;
    v_is_delivered              boolean;
    rec                         record;
BEGIN
    v_delivery_driver_person_id := dataloadsimulation.get_random_employee_person();

    FOR rec IN
        SELECT i."InvoiceID", i."ReturnedDeliveryData"::jsonb, c."CustomerName",
               p."FullName",
               ST_Y(ct."Location"::geometry) AS latitude,
               ST_X(ct."Location"::geometry) AS longitude
        FROM sales.invoices AS i
        INNER JOIN sales.customers AS c         ON i."CustomerID" = c."CustomerID"
        INNER JOIN application.cities AS ct     ON c."DeliveryCityID" = ct."CityID"
        INNER JOIN application.people AS p      ON c."PrimaryContactPersonID" = p."PersonID"
        WHERE i."ConfirmedDeliveryTime" IS NULL
          AND i."InvoiceDate" < CAST(p_starting_when AS date)
        ORDER BY i."InvoiceID"
    LOOP
        v_invoice_id                := rec."InvoiceID";
        v_returned_delivery_data    := rec."ReturnedDeliveryData";
        v_customer_name             := rec."CustomerName";
        v_primary_contact_full_name := rec."FullName";
        v_latitude                  := rec.latitude;
        v_longitude                 := rec.longitude;

        v_counter               := v_counter + 1;
        v_delivery_attempt_when := p_starting_when + (v_counter * 5 * interval '1 minute');

        v_delivery_event := '{}'::jsonb;
        v_delivery_event := jsonb_set(v_delivery_event, '{Event}',     '"DeliveryAttempt"');
        v_delivery_event := jsonb_set(v_delivery_event, '{EventTime}', to_json(to_char(v_delivery_attempt_when, 'YYYY-MM-DD"T"HH24:MI:SS'))::jsonb);
        v_delivery_event := jsonb_set(v_delivery_event, '{ConNote}',   to_json('EAN-125-' || (v_invoice_id + 1050)::varchar)::jsonb);
        v_delivery_event := jsonb_set(v_delivery_event, '{DriverID}',  to_json(v_delivery_driver_person_id)::jsonb);
        v_delivery_event := jsonb_set(v_delivery_event, '{Latitude}',  to_json(v_latitude)::jsonb);
        v_delivery_event := jsonb_set(v_delivery_event, '{Longitude}', to_json(v_longitude)::jsonb);

        v_is_delivered := false;

        IF random() < 0.1 THEN
            v_delivery_event := jsonb_set(v_delivery_event, '{Comment}', '"Receiver not present"');
        ELSE
            v_delivery_event := jsonb_set(v_delivery_event, '{Status}', '"Delivered"');
            v_is_delivered   := true;
        END IF;

        v_returned_delivery_data := jsonb_set(
            v_returned_delivery_data, '{Events}',
            (v_returned_delivery_data->'Events') || jsonb_build_array(v_delivery_event)
        );
        v_returned_delivery_data := jsonb_set(
            v_returned_delivery_data, '{DeliveredWhen}',
            to_json(to_char(v_delivery_attempt_when, 'YYYY-MM-DD"T"HH24:MI:SS'))::jsonb
        );
        v_returned_delivery_data := jsonb_set(
            v_returned_delivery_data, '{ReceivedBy}',
            to_json(v_primary_contact_full_name)::jsonb
        );

        UPDATE sales.invoices
        SET "ReturnedDeliveryData" = v_returned_delivery_data::text,
            "LastEditedBy"         = v_delivery_driver_person_id,
            "LastEditedWhen"       = p_starting_when
        WHERE "InvoiceID" = v_invoice_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
