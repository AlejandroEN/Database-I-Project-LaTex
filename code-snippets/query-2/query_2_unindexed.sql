SET enable_mergejoin TO OFF;
SET enable_hashjoin TO OFF;
SET enable_bitmapscan TO OFF;
SET enable_sort TO OFF;
SET enable_nestloop TO OFF;
SET enable_indexscan TO OFF;
SET enable_indexonlyscan TO OFF;

DROP INDEX IF EXISTS idx_persona_nacimiento_fecha;

VACUUM FULL colaborador;
VACUUM FULL persona;
VACUUM FULL profesor_sede;
VACUUM FULL sede;
