CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.supplier_transactions AS
SELECT
    st.SupplierTransactionID,
    st.TransactionDate,
    st.AmountExcludingTax,
    st.TaxAmount,
    st.TransactionAmount,
    st.OutstandingBalance,
    st.FinalizationDate,
    st.IsFinalized,
    s.SupplierName,
    tt.TransactionTypeName,
    pm.PaymentMethodName,
    st.SupplierID,
    st.TransactionTypeID,
    st.PurchaseOrderID,
    st.PaymentMethodID,
    po.OrderDate,
    po.IsOrderFinalized,
    po.ExpectedDeliveryDate,
    po.SupplierReference
FROM purchasing.suppliertransactions AS st
LEFT JOIN purchasing.purchaseorders AS po ON st.PurchaseOrderID = po.PurchaseOrderID
LEFT JOIN application.transaction_types AS tt ON st.TransactionTypeID = tt.TransactionTypeID
LEFT JOIN purchasing.suppliers AS s ON st.SupplierID = s.SupplierID
LEFT JOIN application.payment_methods AS pm ON st.PaymentMethodID = pm.PaymentMethodID;
