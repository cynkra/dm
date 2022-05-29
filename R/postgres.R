# From \d+ information_schema.constraint_column_usage, adapted to include colnum
postgres_column_constraints <- "SELECT current_database()::information_schema.sql_identifier AS table_catalog,
    x.tblschema::information_schema.sql_identifier AS table_schema,
    x.tblname::information_schema.sql_identifier AS table_name,
    x.colname::information_schema.sql_identifier AS column_name,
    current_database()::information_schema.sql_identifier AS constraint_catalog,
    x.cstrschema::information_schema.sql_identifier AS constraint_schema,
    x.cstrname::information_schema.sql_identifier AS constraint_name,
    x.colnum::information_schema.cardinal_number AS ordinal_position

   FROM ( SELECT DISTINCT nr.nspname,
            r.relname,
            r.relowner,
            a.attname,
            NULL::smallint AS attnum,
            nc.nspname,
            c.conname
           FROM pg_namespace nr,
            pg_class r,
            pg_attribute a,
            pg_depend d,
            pg_namespace nc,
            pg_constraint c
          WHERE nr.oid = r.relnamespace AND r.oid = a.attrelid AND d.refclassid = 'pg_class'::regclass::oid AND d.refobjid = r.oid AND d.refobjsubid = a.attnum AND d.classid = 'pg_constraint'::regclass::oid AND d.objid = c.oid AND c.connamespace = nc.oid AND c.contype = 'c'::\"char\" AND (r.relkind = ANY (ARRAY['r'::\"char\", 'p'::\"char\"])) AND NOT a.attisdropped
        UNION ALL
         SELECT nr.nspname,
            r.relname,
            r.relowner,
            a.attname,
            a.attnum,
            nc.nspname,
            c.conname
           FROM pg_namespace nr,
            pg_class r,
            pg_attribute a,
            pg_namespace nc,
            pg_constraint c
          WHERE nr.oid = r.relnamespace AND r.oid = a.attrelid AND nc.oid = c.connamespace AND r.oid =
                CASE c.contype
                    WHEN 'f'::\"char\" THEN c.confrelid
                    ELSE c.conrelid
                END AND (a.attnum = ANY (
                CASE c.contype
                    WHEN 'f'::\"char\" THEN c.confkey
                    ELSE c.conkey
                END)) AND NOT a.attisdropped AND (c.contype = ANY (ARRAY['f'::\"char\"])) AND (r.relkind = ANY (ARRAY['r'::\"char\", 'p'::\"char\"]))) x(tblschema, tblname, tblowner, colname, colnum, cstrschema, cstrname)
  WHERE pg_has_role(x.tblowner, 'USAGE'::text)"
