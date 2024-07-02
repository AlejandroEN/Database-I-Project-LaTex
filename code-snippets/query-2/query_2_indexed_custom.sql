SET enable_mergejoin TO ON;
SET enable_hashjoin TO ON;
SET enable_bitmapscan TO ON;
SET enable_sort TO ON;
SET enable_nestloop TO ON;
SET enable_indexscan TO ON;
SET enable_indexonlyscan TO ON;

VACUUM FULL colaborador;
VACUUM FULL persona;
VACUUM FULL profesor_sede;
VACUUM FULL sede;

CREATE INDEX IF NOT EXISTS idx_persona_nacimiento_fecha ON persona (nacimiento_fecha);
