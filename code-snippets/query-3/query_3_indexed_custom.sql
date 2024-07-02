SET enable_mergejoin TO ON;
SET enable_hashjoin TO ON;
SET enable_bitmapscan TO ON;
SET enable_sort TO ON;
SET enable_nestloop TO ON;
SET enable_indexscan TO ON;
SET enable_indexonlyscan TO ON;

VACUUM FULL colaborador;
VACUUM FULL apoderado;
VACUUM FULL alumno;
VACUUM FULL matricula;
VACUUM FULL persona;

CREATE INDEX IF NOT EXISTS idx_horas_semanales_trabajo ON colaborador (horas_semanales_trabajo);
