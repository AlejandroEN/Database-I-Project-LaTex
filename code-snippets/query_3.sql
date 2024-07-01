SELECT persona.nombres,
       persona.primer_apellido,
       persona.segundo_apellido,
       persona.sexo,
       persona.email
FROM persona
WHERE persona.dni 
    IN (SELECT alumno.dni
        FROM alumno
        WHERE alumno.dni 
            IN (SELECT matricula.alumno_dni
                FROM matricula
                WHERE matricula.year <= EXTRACT(YEAR FROM CURRENT_DATE) - 2)
                AND alumno.apoderado_dni 
                    IN (SELECT apoderado.dni
                        FROM apoderado
                        WHERE apoderado.dni 
                            IN (SELECT colaborador.dni 
                                FROM colaborador
                                WHERE colaborador.esta_activo = TRUE
                                AND colaborador.horas_semanales_trabajo > 48
                                AND colaborador.sueldo_hora * colaborador.horas_semanales_trabajo * 4 < 2000)))
    AND persona.nacimiento_fecha > CURRENT_DATE - INTERVAL '18 years';
