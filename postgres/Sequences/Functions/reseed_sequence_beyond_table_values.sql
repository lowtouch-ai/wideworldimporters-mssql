-- Converted from: wwi-ssdt/wwi-ssdt/Sequences/Stored Procedures/ReseedSequenceBeyondTableValues.sql
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE OR REPLACE FUNCTION sequences.reseed_sequence_beyond_table_values(
    p_sequence_name text,
    p_schema_name   text,
    p_table_name    text,
    p_column_name   text
) RETURNS void AS $$
DECLARE
    v_current_table_max bigint;
    v_current_seq_max   bigint;
    v_new_seq_value     bigint;
BEGIN
    -- pg_sequences.last_value is NULL before first use; fall back to start_value
    SELECT COALESCE(last_value, start_value)
      INTO v_current_seq_max
      FROM pg_sequences
     WHERE schemaname  = 'sequences'
       AND sequencename = p_sequence_name;

    -- Dynamic column/table reference — %I quotes identifiers safely (replaces QUOTENAME)
    EXECUTE format(
        'SELECT COALESCE(MAX(%I), 0) FROM %I.%I',
        p_column_name, p_schema_name, p_table_name
    ) INTO v_current_table_max;

    IF v_current_table_max >= COALESCE(v_current_seq_max, 0) THEN
        v_new_seq_value := v_current_table_max + 1;
        EXECUTE format(
            'ALTER SEQUENCE sequences.%I RESTART WITH %s',
            p_sequence_name, v_new_seq_value
        );
    END IF;
END;
$$ LANGUAGE plpgsql;
