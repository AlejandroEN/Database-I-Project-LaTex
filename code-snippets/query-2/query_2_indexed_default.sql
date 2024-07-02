SET enable_mergejoin TO ON;
SET enable_hashjoin TO ON;
SET enable_bitmapscan TO ON;
SET enable_sort TO ON;
SET enable_nestloop TO ON;
SET enable_indexscan TO ON;
SET enable_indexonlyscan TO ON;

DROP INDEX IF EXISTS idx_persona_nacimiento_fecha;

VACUUM FULL colaborador;
VACUUM FULL persona;
VACUUM FULL profesor_sede;
VACUUM FULL sede;
