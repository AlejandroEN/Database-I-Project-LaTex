SET enable_mergejoin TO ON;
SET enable_hashjoin TO ON;
SET enable_bitmapscan TO ON;
SET enable_sort TO ON;
SET enable_nestloop TO ON;
SET enable_indexscan TO ON;
SET enable_indexonlyscan TO ON;

VACUUM FULL persona;
VACUUM FULL colaborador;
VACUUM FULL director;
VACUUM FULL sede;
VACUUM FULL profesor_sede;
VACUUM FULL alumno;
