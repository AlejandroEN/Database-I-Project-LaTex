CREATE OR REPLACE FUNCTION function_check_alumno_overlapping_colaborador_apoderado() RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS (SELECT 1 FROM colaborador WHERE dni = new.dni) OR
       EXISTS (SELECT 1 FROM apoderado WHERE dni = new.dni) THEN
        RAISE EXCEPTION 'La persona con DNI % ya existe en las tablas Colaborador o Apoderado.', new.dni;
    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_alumno_overlapping
    BEFORE INSERT
    ON alumno
    FOR EACH ROW
EXECUTE FUNCTION function_check_alumno_overlapping_colaborador_apoderado();

CREATE OR REPLACE FUNCTION function_check_colaborador_sueldo_mensual() RETURNS TRIGGER AS
$$
DECLARE
    sueldo_mensual INT;
BEGIN
    sueldo_mensual = new.sueldo_hora * new.horas_semanales_trabajo * 4;

    IF sueldo_mensual < 1025 THEN
        RAISE EXCEPTION 'El sueldo mensual debe ser % mayor al sueldo minimo de 1025.', sueldo_mensual;
    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_colaborador_sueldo_mensual
    BEFORE INSERT OR UPDATE
    ON colaborador
    FOR EACH ROW
EXECUTE FUNCTION function_check_colaborador_sueldo_mensual();

----

CREATE OR REPLACE FUNCTION function_check_colaborador_overlapping() RETURNS TRIGGER AS
$$
BEGIN
    IF (EXISTS (SELECT 1 FROM profesor WHERE dni = new.dni)) OR
       (EXISTS (SELECT 1 FROM consejero WHERE dni = new.dni)) OR
       (EXISTS (SELECT 1 FROM secretario WHERE dni = new.dni)) OR
       (EXISTS (SELECT 1 FROM director WHERE dni = new.dni)) OR
       (EXISTS (SELECT 1 FROM tutor WHERE dni = new.dni)) THEN
        RAISE EXCEPTION 'El colaborador con DNI % ya existe en otra tabla hija.', new.dni;
    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_profesor_overlapping
    BEFORE INSERT
    ON profesor
    FOR EACH ROW
EXECUTE FUNCTION function_check_colaborador_overlapping();

CREATE TRIGGER trigger_check_consejero_overlapping
    BEFORE INSERT
    ON consejero
    FOR EACH ROW
EXECUTE FUNCTION function_check_colaborador_overlapping();

CREATE TRIGGER trigger_check_secretario_overlapping
    BEFORE INSERT
    ON secretario
    FOR EACH ROW
EXECUTE FUNCTION function_check_colaborador_overlapping();

CREATE TRIGGER trigger_check_director_overlapping
    BEFORE INSERT
    ON director
    FOR EACH ROW
EXECUTE FUNCTION function_check_colaborador_overlapping();

CREATE TRIGGER trigger_check_tutor_overlapping
    BEFORE INSERT
    ON tutor
    FOR EACH ROW
EXECUTE FUNCTION function_check_colaborador_overlapping();

----

CREATE OR REPLACE FUNCTION function_check_colaborador_apoderado_overlapping_alumno() RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS (SELECT 1 FROM alumno WHERE dni = new.dni) THEN
        RAISE EXCEPTION 'La persona con DNI % ya existe en la tabla Alumno.', new.dni;
    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_colaborador_overlapping
    BEFORE INSERT
    ON colaborador
    FOR EACH ROW
EXECUTE FUNCTION function_check_colaborador_apoderado_overlapping_alumno();

CREATE TRIGGER trigger_check_apoderado_overlapping
    BEFORE INSERT
    ON apoderado
    FOR EACH ROW
EXECUTE FUNCTION function_check_colaborador_apoderado_overlapping_alumno();

----

CREATE OR REPLACE FUNCTION function_check_colaborador_esta_activo() RETURNS TRIGGER AS
$$
DECLARE
    esta_activo BOOLEAN;
BEGIN
    SELECT esta_activo
    INTO esta_activo
    FROM colaborador
    WHERE new.dni = dni;

    IF NOT esta_activo THEN
        RAISE EXCEPTION 'El colaborador que se intenta insertar no esta activo.';
    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_profesor_esta_activo
    BEFORE INSERT OR UPDATE
    ON persona
    FOR EACH ROW
EXECUTE FUNCTION function_check_colaborador_esta_activo();

----

CREATE OR REPLACE FUNCTION gestionar_director_reasignacion() RETURNS TRIGGER AS
$$
BEGIN
    IF (SELECT COUNT(*) FROM director WHERE sede_id = old.sede_id AND dni != old.dni) = 0 THEN
        RAISE EXCEPTION 'No se puede reasignar el director sin reemplazo en la sede %', old.sedeid;
    END IF;

    DELETE FROM director WHERE dni = old.dni;

    UPDATE colaborador SET esta_activo = FALSE WHERE dni = old.dni;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_gestionar_director_reasignacion
    AFTER UPDATE
    ON director
    FOR EACH ROW
    WHEN (old.dni IS DISTINCT FROM new.dni)
EXECUTE FUNCTION gestionar_director_reasignacion();

----

CREATE OR REPLACE FUNCTION function_check_matricula_year() RETURNS TRIGGER AS
$$
BEGIN
    IF new.year <= (SELECT EXTRACT(YEAR FROM construccion_fecha) FROM sede WHERE id = new.sede_id) THEN
        RAISE EXCEPTION 'El anho de matricula debe ser mayor que el anho de construccion de la sede.';
    END IF;
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_matricula_year
    BEFORE INSERT OR UPDATE
    ON matricula
    FOR EACH ROW
EXECUTE FUNCTION function_check_matricula_year();

----

CREATE OR REPLACE FUNCTION function_check_salon_aforo_on_alumno()
    RETURNS TRIGGER AS
$$
DECLARE
    salon_aforo      INT;
    alumnos_cantidad INT;
BEGIN
    SELECT aforo
    INTO salon_aforo
    FROM salon
    WHERE nombre_seccion = new.nombre_seccion
      AND sede_id = new.sede_id;

    SELECT COUNT(dni) + 1
    INTO alumnos_cantidad
    FROM alumno
    WHERE salon_nombre_seccion = new.salon_nombre_seccion
      AND salon_sede_id = new.salon_sede_id;

    IF alumnos_cantidad > salon_aforo THEN
        RAISE EXCEPTION 'El aforo del salon ha sido excedido. Aforo maximo: %, Numero de alumnos: %', salon_aforo, alumnos_cantidad;
    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_salon_aforo_on_alumno
    BEFORE INSERT
    ON alumno
    FOR EACH ROW
EXECUTE FUNCTION function_check_salon_aforo_on_alumno();

----

CREATE OR REPLACE FUNCTION function_check_salon_aforo_on_matricula()
    RETURNS TRIGGER AS
$$
DECLARE
    salon_aforo          INT;
    alumnos_cantidad     INT;
    salon_nombre_seccion VARCHAR(50);
    salon_sede_id        INT;
BEGIN
    SELECT salon_nombre_seccion, salon_sede_id
    INTO salon_nombre_seccion, salon_sede_id
    FROM alumno
    WHERE dni = new.alumno_dni;

    SELECT aforo
    INTO salon_aforo
    FROM salon
    WHERE salon_nombre_seccion = new.nombre_seccion
      AND salon_sede_id = new.sede_id;

    SELECT COUNT(dni) + 1
    INTO alumnos_cantidad
    FROM alumno
    WHERE salon_nombre_seccion = new.nombre_seccion
      AND salon_sede_id = new.sede_id;

    IF alumnos_cantidad > salon_aforo THEN
        RAISE EXCEPTION 'El aforo del salon ha sido excedido. Aforo maximo: %, Numero de alumnos: %', salon_aforo, alumnos_cantidad + 1;
    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_salon_aforo_on_matricula
    BEFORE INSERT
    ON matricula
    FOR EACH ROW
EXECUTE FUNCTION function_check_salon_aforo_on_matricula();

----

CREATE OR REPLACE FUNCTION gestionar_tutor_reasignacion()
    RETURNS TRIGGER AS
$$
BEGIN
    IF (SELECT COUNT(*)
        FROM tutor
        WHERE salon_nombre_seccion = old.salon_nombre_seccion
          AND sede_id = old.sede_id
          AND dni != old.dni) = 0 THEN
        RAISE EXCEPTION 'No se puede reasignar el tutor sin reemplazo en el salon % de la sede %', old.salon_nombre_seccion, old.sede_id;
    END IF;

    DELETE FROM tutor WHERE dni = old.dni AND salon_nombre_seccion = old.salon_nombre_seccion AND sede_id = old.sede_id;

    UPDATE colaborador SET esta_activo = FALSE WHERE dni = old.dni;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_gestionar_tutor_reasignacion
    AFTER UPDATE
    ON tutor
    FOR EACH ROW
    WHEN (old.dni IS DISTINCT FROM new.dni OR old.salon_nombre_seccion IS DISTINCT FROM new.salon_nombre_seccion OR
          old.sede_id IS DISTINCT FROM new.sede_id)
EXECUTE FUNCTION gestionar_tutor_reasignacion();
