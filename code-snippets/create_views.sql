CREATE VIEW vista_colaborador_sueldo_mensual AS
SELECT
    p.dni,
    p.email,
    c.cci,
    c.esta_activo,
    (c.horas_semanales_trabajo * c.sueldo_hora * 4) AS sueldo_mensual
FROM
    colaborador c
        JOIN
    persona p ON c.dni = p.dni;

----

CREATE VIEW vista_profesor_curso_grado AS
SELECT
    c.nombre AS curso_nombre,
    g.nombre AS grado_nombre,
    p.nombres AS profesor_nombres,
    p.primer_apellido AS profesor_primer_apellido,
    p.segundo_apellido AS profesor_segundo_apellido,
    pcg.periodo_academico
FROM
    curso c
        JOIN
    profesor_curso_grado pcg ON c.id = pcg.curso_id
        JOIN
    grado g ON pcg.grado_id = g.id
        JOIN
    profesor pr ON pcg.profesor_dni = pr.dni
        JOIN
    persona p ON pr.dni = p.dni;

----

CREATE VIEW vista_total_alumnos_grado_sede AS
SELECT
    s.direccion AS sede_direccion,
    g.nombre AS grado_nombre,
    COUNT(a.dni) AS total_alumnos
FROM
    alumno a
        JOIN
    salon sa ON a.salon_nombre_seccion = sa.nombre_seccion AND a.salon_sede_id = sa.sede_id
        JOIN
    grado g ON sa.grado_id = g.id
        JOIN
    sede s ON sa.sede_id = s.id
GROUP BY
    g.id, g.nombre, s.id;

----

CREATE VIEW vista_hijos_por_apoderado_sede AS
SELECT
    ap.dni,
    ap.numero_celular AS apoderado_numero_celular,
    s.id AS sede_id,
    COUNT(a.dni) AS total_hijos_en_sede
FROM
    alumno a
        JOIN
    matricula m ON a.dni = m.alumno_dni
        JOIN
    apoderado ap ON a.apoderado_dni = ap.dni
        JOIN
    sede s ON m.sede_id = s.id
GROUP BY
    ap.dni, ap.numero_celular, s.id;
