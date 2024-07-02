SELECT CONCAT(persona.nombres, ' ', persona.primer_apellido, ' ', persona.segundo_apellido) AS nombre_completo,
       colaborador.cci,
       persona.email,
       CASE
           WHEN profesor.dni IS NOT NULL THEN
               colaborador.sueldo_hora * colaborador.horas_semanales_trabajo * 4 * 0.05 *
               (SELECT COUNT(id)
                FROM sede
                         JOIN profesor_sede ON sede.id = profesor_sede.sede_id
                WHERE profesor_sede.profesor_dni = profesor.dni
                  AND (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM sede.construccion_fecha)) % 10 = 0
                  AND (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM sede.construccion_fecha)) > 0)
           ELSE
               colaborador.sueldo_hora * colaborador.horas_semanales_trabajo * 4 * 0.05 *
               (CASE
                    WHEN (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM 
                    (SELECT MIN(sede.construccion_fecha) 
                    FROM sede JOIN colaborador AS c ON c.dni = colaborador.dni 
                    WHERE c.dni = colaborador.dni 
                    AND (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM sede.construccion_fecha)) % 10 = 0 
                    AND (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM sede.construccion_fecha)) > 0))) >= 10 THEN 1 ELSE 0 END)
                    END AS bonificacion
FROM colaborador
         JOIN persona ON colaborador.dni = persona.dni
         LEFT JOIN profesor ON colaborador.dni = profesor.dni
WHERE colaborador.esta_activo = TRUE
  AND persona.nacimiento_fecha BETWEEN '1960-01-01' AND '1980-12-31'
  AND EXISTS (SELECT 1
              FROM sede JOIN colaborador AS c ON c.dni = colaborador.dni
              WHERE c.dni = colaborador.dni
                AND (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM sede.construccion_fecha)) % 10 = 0
                AND (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM sede.construccion_fecha)) > 0);