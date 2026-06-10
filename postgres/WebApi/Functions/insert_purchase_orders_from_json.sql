CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_purchase_orders_from_json(
    p_purchase_orders text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO purchasing.purchaseorders (
        SupplierID, OrderDate, DeliveryMethodID, ContactPersonID,
        ExpectedDeliveryDate, SupplierReference, IsOrderFinalized, Comments,
        InternalComments, LastEditedBy
    )
    SELECT
        x."SupplierID", x."OrderDate", x."DeliveryMethodID", x."ContactPersonID",
        x."ExpectedDeliveryDate", x."SupplierReference", x."IsOrderFinalized",
        x."Comments", x."InternalComments", p_user_id
    FROM jsonb_to_recordset(
        CASE WHEN jsonb_typeof(p_purchase_orders::jsonb) = 'array'
             THEN p_purchase_orders::jsonb
             ELSE jsonb_build_array(p_purchase_orders::jsonb) END
    ) AS x(
        "SupplierID"           integer,
        "OrderDate"            date,
        "DeliveryMethodID"     integer,
        "ContactPersonID"      integer,
        "ExpectedDeliveryDate" date,
        "SupplierReference"    varchar(20),
        "IsOrderFinalized"     boolean,
        "Comments"             text,
        "InternalComments"     text
    );
END;
$$ LANGUAGE plpgsql;
