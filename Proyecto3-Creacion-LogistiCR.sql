-- =============================================================================
-- UNIVERSIDAD ESTATAL A DISTANCIA (UNED)
-- 00826 - Base de Datos - III Cuatrimestre 2026
-- PROYECTO No. 3 - Procedimientos almacenados y funciones (SQL avanzado)
-- Base de datos: LogistiCR
-- Elaborado por: Gabriel Quiros
-- =============================================================================
-- SCRIPT DE CREACION: crea los 3 procedimientos y las 3 funciones.
-- Se ejecuta UNA vez (si se vuelve a ejecutar no hay problema: cada objeto
-- empieza con DROP ... IF EXISTS, que lo borra y lo vuelve a crear).
--
-- GUIA RAPIDA DE LECTURA (comparacion con Java):
--   PROCEDIMIENTO = receta guardada en la base de datos que HACE cosas
--                   (como un metodo void). Se llama con CALL.
--   FUNCION       = receta guardada que DEVUELVE un valor (como un metodo con
--                   return). Se usa dentro de un SELECT.
--   SIGNAL        = lanzar un error a proposito (como un throw en Java).
--   IN / OUT      = datos que ENTRAN a la receta / datos que SALEN de ella.
-- =============================================================================

USE `LogistiCR`;

-- DELIMITER cambia el simbolo que marca "aqui termina la sentencia".
-- Hace falta porque adentro de cada receta hay muchos ; y MySQL pensaria que
-- la receta termino en el primero. Mientras el delimitador sea $$, el ; normal
-- queda libre para usarse adentro. Al final se devuelve a ;
DELIMITER $$


-- =============================================================================
-- REQUERIMIENTO 1: sp_RegistrarCliente
-- Registra un cliente nuevo, validando que la provincia exista y que la cedula
-- no este repetida. Si algo falla, cancela con un error controlado.
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_RegistrarCliente$$

CREATE PROCEDURE sp_RegistrarCliente(
    IN p_cedula        VARCHAR(30),   -- IN = dato que entra a la receta
    IN p_nombre        VARCHAR(100),  -- (el prefijo p_ evita confundirlo con la columna)
    IN p_apellidos     VARCHAR(150),
    IN p_telefono      VARCHAR(30),
    IN p_correo        VARCHAR(150),
    IN p_direccion     VARCHAR(255),
    IN p_id_provincia  INT
)
BEGIN
    -- Validacion 1: "si NO existe una provincia con ese id, lanza un error"
    IF NOT EXISTS (SELECT 1 FROM Provincia WHERE id_provincia = p_id_provincia) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: la provincia indicada no existe.';
    END IF;

    -- Validacion 2: "si YA existe un cliente con esa cedula, lanza un error"
    IF EXISTS (SELECT 1 FROM Cliente WHERE cedula_identificacion = p_cedula) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: ya existe un cliente registrado con esa cedula.';
    END IF;

    -- Si llegamos aqui, las dos validaciones pasaron: se inserta el cliente.
    -- (id_cliente no se escribe: lo genera solo la base de datos, AUTO_INCREMENT)
    INSERT INTO Cliente
        (cedula_identificacion, nombre, apellidos, telefono, correo, direccion_habitual, id_provincia)
    VALUES
        (p_cedula, p_nombre, p_apellidos, p_telefono, p_correo, p_direccion, p_id_provincia);

    -- Muestra el id que se le asigno al cliente nuevo (para ver que funciono)
    SELECT LAST_INSERT_ID() AS id_cliente_registrado;
END$$


-- =============================================================================
-- REQUERIMIENTO 2: fn_NombreCompletoCliente
-- Recibe un id_cliente y devuelve "nombre apellidos" como un solo texto.
-- =============================================================================
DROP FUNCTION IF EXISTS fn_NombreCompletoCliente$$

CREATE FUNCTION fn_NombreCompletoCliente(p_id_cliente INT)
RETURNS VARCHAR(255)       -- RETURNS = el tipo de dato que entrega la funcion
DETERMINISTIC              -- con los mismos datos, siempre da el mismo resultado
READS SQL DATA             -- solo LEE de las tablas, no las modifica
BEGIN
    DECLARE v_nombre_completo VARCHAR(255);  -- caja temporal para guardar el resultado

    -- "toma nombre + espacio + apellidos de ese cliente y guardalo en la caja"
    SELECT CONCAT(nombre, ' ', apellidos)
      INTO v_nombre_completo
      FROM Cliente
     WHERE id_cliente = p_id_cliente;

    -- Entrega el resultado. Si el cliente no existe, la caja queda vacia (NULL)
    RETURN v_nombre_completo;
END$$


-- =============================================================================
-- REQUERIMIENTO 3: sp_RegistrarEnvio
-- Crea un envio nuevo en estado 'Registrado' con costo 0.00 y genera su codigo
-- de rastreo. Devuelve el id del envio y el codigo mediante parametros OUT.
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_RegistrarEnvio$$

CREATE PROCEDURE sp_RegistrarEnvio(
    IN  p_id_remitente         INT,
    IN  p_id_destinatario      INT,
    IN  p_id_sucursal_origen   INT,
    IN  p_id_sucursal_destino  INT,
    IN  p_fecha_estimada       DATE,
    OUT p_id_envio             INT,          -- OUT = dato que SALE de la receta
    OUT p_codigo_rastreo       VARCHAR(30)   -- (el que llama lo recibe en una variable)
)
BEGIN
    -- Caja temporal para el codigo (los DECLARE siempre van primero)
    DECLARE v_codigo VARCHAR(30);

    -- Validaciones: cada una lanza su propio error con un mensaje claro
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente = p_id_remitente) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: el cliente remitente no existe.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id_cliente = p_id_destinatario) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: el cliente destinatario no existe.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Sucursal WHERE id_sucursal = p_id_sucursal_origen) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: la sucursal de origen no existe.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Sucursal WHERE id_sucursal = p_id_sucursal_destino) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: la sucursal de destino no existe.';
    END IF;

    -- Genera el codigo con el formato pedido: CR-2026- + 6 digitos al azar
    -- (RAND da un numero al azar; LPAD lo rellena con ceros a la izquierda
    -- hasta completar 6 caracteres)
    SET v_codigo = CONCAT('CR-2026-', LPAD(FLOOR(RAND() * 899999 + 100000), 6, '0'));

    -- El codigo debe ser unico: "mientras ya exista ese codigo, genera otro"
    WHILE EXISTS (SELECT 1 FROM Envio WHERE codigo_rastreo = v_codigo) DO
        SET v_codigo = CONCAT('CR-2026-', LPAD(FLOOR(RAND() * 899999 + 100000), 6, '0'));
    END WHILE;

    -- Inserta el envio: estado 'Registrado' y costo inicial 0.00
    INSERT INTO Envio
        (codigo_rastreo, id_cliente_remitente, id_cliente_destinatario,
         id_sucursal_origen, id_sucursal_destino, fecha_estimada_entrega,
         estado, costo_total)
    VALUES
        (v_codigo, p_id_remitente, p_id_destinatario,
         p_id_sucursal_origen, p_id_sucursal_destino, p_fecha_estimada,
         'Registrado', 0.00);

    -- Llena los dos parametros de salida (lo que "devuelve" la receta)
    SET p_id_envio = LAST_INSERT_ID();   -- el id que la base de datos le asigno
    SET p_codigo_rastreo = v_codigo;
END$$


-- =============================================================================
-- REQUERIMIENTO 4: fn_ObtenerEstadoEnvio
-- Recibe un id_envio y devuelve su estado actual. Si no existe: 'NO ENCONTRADO'.
-- =============================================================================
DROP FUNCTION IF EXISTS fn_ObtenerEstadoEnvio$$

CREATE FUNCTION fn_ObtenerEstadoEnvio(p_id_envio INT)
RETURNS VARCHAR(30)
READS SQL DATA
BEGIN
    DECLARE v_estado VARCHAR(30);

    -- "busca el estado de ese envio y guardalo en la caja"
    SELECT estado INTO v_estado FROM Envio WHERE id_envio = p_id_envio;

    -- Si la caja quedo vacia, el envio no existe
    IF v_estado IS NULL THEN
        RETURN 'NO ENCONTRADO';
    END IF;

    RETURN v_estado;
END$$


-- =============================================================================
-- REQUERIMIENTO 5: sp_RegistrarDetallePaquete
-- Agrega un paquete a un envio: calcula el subtotal (peso x tarifa del tipo de
-- paquete), guarda el detalle y suma ese subtotal al costo_total del envio.
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_RegistrarDetallePaquete$$

CREATE PROCEDURE sp_RegistrarDetallePaquete(
    IN p_id_envio         INT,
    IN p_id_tipo_paquete  INT,
    IN p_descripcion      VARCHAR(250),
    IN p_peso_kg          DECIMAL(8,2),
    IN p_alto_cm          DECIMAL(8,2),
    IN p_ancho_cm         DECIMAL(8,2),
    IN p_largo_cm         DECIMAL(8,2)
)
BEGIN
    DECLARE v_tarifa    DECIMAL(10,2);   -- tarifa por kg del tipo de paquete
    DECLARE v_subtotal  DECIMAL(10,2);   -- peso * tarifa

    -- Validacion 1: el envio debe existir
    IF NOT EXISTS (SELECT 1 FROM Envio WHERE id_envio = p_id_envio) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: el envio indicado no existe.';
    END IF;

    -- Validacion 2: el tipo de paquete debe existir
    IF NOT EXISTS (SELECT 1 FROM TipoPaquete WHERE id_tipo_paquete = p_id_tipo_paquete) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: el tipo de paquete indicado no existe.';
    END IF;

    -- Validacion 3: peso y dimensiones deben ser mayores que cero
    IF p_peso_kg <= 0 OR p_alto_cm <= 0 OR p_ancho_cm <= 0 OR p_largo_cm <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: el peso y las dimensiones deben ser mayores que cero.';
    END IF;

    -- Busca la tarifa por kg de ese tipo de paquete (viene del catalogo TipoPaquete)
    SELECT tarifa_base_kg INTO v_tarifa
      FROM TipoPaquete
     WHERE id_tipo_paquete = p_id_tipo_paquete;

    -- Calcula el subtotal: peso x tarifa
    SET v_subtotal = p_peso_kg * v_tarifa;

    -- Guarda el paquete en DetallePaquete
    INSERT INTO DetallePaquete
        (id_envio, id_tipo_paquete, descripcion_contenido,
         peso_kg, alto_cm, ancho_cm, largo_cm, subtotal)
    VALUES
        (p_id_envio, p_id_tipo_paquete, p_descripcion,
         p_peso_kg, p_alto_cm, p_ancho_cm, p_largo_cm, v_subtotal);

    -- Actualiza el costo total del envio: "lo que ya tenia + este subtotal"
    UPDATE Envio
       SET costo_total = costo_total + v_subtotal
     WHERE id_envio = p_id_envio;
END$$


-- =============================================================================
-- REQUERIMIENTO 6: fn_TotalEnviosEntregadosConductor
-- Recibe el id de un empleado conductor y devuelve cuantos envios 'Entregado'
-- le fueron asignados en AsignacionRuta.
-- =============================================================================
DROP FUNCTION IF EXISTS fn_TotalEnviosEntregadosConductor$$

CREATE FUNCTION fn_TotalEnviosEntregadosConductor(p_id_empleado INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total INT;

    -- Cuenta los envios entregados que tiene asignados ese conductor.
    -- DISTINCT evita contar dos veces el mismo envio si estuviera asignado
    -- mas de una vez al mismo conductor.
    SELECT COUNT(DISTINCT e.id_envio)
      INTO v_total
      FROM AsignacionRuta ar
     INNER JOIN Envio e ON ar.id_envio = e.id_envio
     WHERE ar.id_empleado_conductor = p_id_empleado
       AND e.estado = 'Entregado';

    RETURN v_total;
END$$


-- Se devuelve el delimitador normal
DELIMITER ;

-- =============================================================================
-- FIN DEL SCRIPT DE CREACION - PROYECTO 3
-- =============================================================================
