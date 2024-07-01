------------------------------TABLAS-------------------------------

CREATE TABLE institucion
(
    ruc             CHAR(11) PRIMARY KEY,
    descripcion     VARCHAR(1000)       NOT NULL,
    fundador        VARCHAR(100)        NOT NULL,
    fundacion_fecha DATE                NOT NULL,
    banner_url      VARCHAR(255)        NOT NULL,
    nombre          VARCHAR(150) UNIQUE NOT NULL,
    CHECK (ruc NOT LIKE '%[^0-9]%'),
    CHECK (banner_url LIKE 'https://%'),
    CHECK (fundacion_fecha <= CURRENT_DATE)
);

CREATE TABLE persona
(
    dni              CHAR(8) PRIMARY KEY,
    nombres          VARCHAR(100)        NOT NULL,
    primer_apellido  VARCHAR(50)         NOT NULL,
    segundo_apellido VARCHAR(50)         NOT NULL,
    nacimiento_fecha DATE                NOT NULL,
    sexo             CHAR(1)             NOT NULL,
    email            VARCHAR(100) UNIQUE NOT NULL,
    CHECK (dni NOT LIKE '%[^0-9]%'),
    CHECK (sexo IN ('M', 'F')),
    CHECK (email LIKE '%_@__%.__%'),
    CHECK (nacimiento_fecha <= CURRENT_DATE)
);

CREATE TABLE colaborador
(
    dni                     CHAR(8) PRIMARY KEY REFERENCES persona (dni),
    sueldo_hora             FLOAT       NOT NULL,
    cci                     CHAR(20)    NOT NULL,
    numero_celular          VARCHAR(15) NOT NULL,
    horas_semanales_trabajo INT         NOT NULL,
    esta_activo             BOOLEAN     NOT NULL,
    CHECK (sueldo_hora > 0.0),
    CHECK (cci NOT LIKE '%[^0-9]%'),
    CHECK (numero_celular LIKE '+%[0-9 ]%' OR numero_celular NOT LIKE '%[^0-9 ]%'),
    CHECK (horas_semanales_trabajo BETWEEN 1 AND 60)
);

CREATE TABLE sede
(
    id                  SERIAL PRIMARY KEY,
    coordenada_longitud DOUBLE PRECISION NOT NULL,
    coordenada_latitud  DOUBLE PRECISION NOT NULL,
    direccion           VARCHAR(255)     NOT NULL,
    construccion_fecha  DATE             NOT NULL,
    institucion_ruc     CHAR(11) REFERENCES institucion (ruc) NOT NULL,
    CHECK (coordenada_longitud BETWEEN -180 AND 180),
    CHECK (coordenada_latitud BETWEEN -90 AND 90),
    CHECK (construccion_fecha <= CURRENT_DATE)
);

CREATE TABLE director
(
    dni     CHAR(8) PRIMARY KEY REFERENCES colaborador (dni),
    sede_id INT REFERENCES sede (id) UNIQUE NOT NULL
);

CREATE TABLE consejero
(
    dni     CHAR(8) PRIMARY KEY REFERENCES colaborador (dni),
    sede_id INT REFERENCES sede (id) NOT NULL
);

CREATE TABLE secretario
(
    dni     CHAR(8) PRIMARY KEY REFERENCES colaborador (dni),
    sede_id INT REFERENCES sede (id) NOT NULL
);

CREATE TABLE profesor
(
    dni CHAR(8) PRIMARY KEY REFERENCES colaborador (dni)
);

CREATE TABLE grado
(
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE curso
(
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE salon
(
    aforo          INT                       NOT NULL,
    nombre_seccion VARCHAR(50)               NOT NULL,
    grado_id       INT REFERENCES grado (id) NOT NULL,
    sede_id        INT REFERENCES sede (id)  NOT NULL,
    PRIMARY KEY (nombre_seccion, sede_id),
    CHECK (aforo >= 5 AND aforo <= 40)
);

CREATE TABLE tutor
(
    dni                  CHAR(8) PRIMARY KEY REFERENCES colaborador (dni),
    salon_nombre_seccion VARCHAR(50) NOT NULL,
    sede_id              INT         NOT NULL,
    FOREIGN KEY (salon_nombre_seccion, sede_id) REFERENCES salon (nombre_seccion, sede_id),
    UNIQUE (salon_nombre_seccion, sede_id)
);

CREATE TABLE apoderado
(
    dni            CHAR(8) PRIMARY KEY REFERENCES persona (dni),
    numero_celular VARCHAR(15) NOT NULL,
    CHECK (numero_celular LIKE '+%[0-9 ]%' OR numero_celular NOT LIKE '%[^0-9 ]%')
);

CREATE TABLE alumno
(
    dni                  CHAR(8) PRIMARY KEY REFERENCES persona (dni),
    salon_nombre_seccion VARCHAR(50)                        NOT NULL,
    salon_sede_id        INT                                NOT NULL,
    apoderado_dni        CHAR(8) REFERENCES apoderado (dni) NOT NULL,
    FOREIGN KEY (salon_nombre_seccion, salon_sede_id) REFERENCES salon (nombre_seccion, sede_id)
);

CREATE TABLE profesor_sede
(
    profesor_dni CHAR(8) REFERENCES profesor (dni),
    sede_id      INT REFERENCES sede (id) NOT NULL,
    PRIMARY KEY (profesor_dni, sede_id)
);

CREATE TABLE profesor_curso_grado
(
    curso_id          INT REFERENCES curso (id),
    grado_id          INT REFERENCES grado (id),
    profesor_dni      CHAR(8) REFERENCES profesor (dni),
    periodo_academico INT NOT NULL,
    PRIMARY KEY (curso_id, grado_id, profesor_dni),
    CHECK (periodo_academico <= EXTRACT(YEAR FROM CURRENT_DATE))
);

CREATE TABLE matricula
(
    year           INT                                 NOT NULL,
    alumno_dni     CHAR(8) REFERENCES alumno (dni),
    sede_id        INT REFERENCES sede (id),
    grado_id       INT REFERENCES grado (id)           NOT NULL,
    secretario_dni CHAR(8) REFERENCES secretario (dni) NOT NULL,
    PRIMARY KEY (year, alumno_dni, sede_id),
    CHECK (year <= EXTRACT(YEAR FROM CURRENT_DATE))
);
