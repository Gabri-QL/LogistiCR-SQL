-- =============================================================================
-- UNIVERSIDAD ESTATAL A DISTANCIA (UNED)
-- 00826 - Base de Datos - III Cuatrimestre 2026
-- PROYECTO No. 2 - Comandos SQL (DML y DQL)
-- Base de datos: LogistiCR (creada en el Proyecto 1)
-- Elaborado por: Gabriel Quiros
-- =============================================================================

USE `LogistiCR`;

-- =============================================================================
-- REQUERIMIENTO 1: Poblamiento y carga de datos de prueba (DML)
-- =============================================================================

-- ------------------------------------------------------------------
-- 1.1 BLOQUE DE LIMPIEZA
-- Se desactivan temporalmente las llaves foraneas para poder vaciar
-- las tablas sin que el orden de las relaciones genere error, y se
-- reactivan justo despues. Asi el script se puede volver a ejecutar
-- las veces que haga falta durante la revision.
-- ------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE `AuditoriaEnvio`;
TRUNCATE TABLE `SeguimientoEnvio`;
TRUNCATE TABLE `AsignacionRuta`;
TRUNCATE TABLE `DetallePaquete`;
TRUNCATE TABLE `Envio`;
TRUNCATE TABLE `Empleado`;
TRUNCATE TABLE `Cliente`;
TRUNCATE TABLE `Vehiculo`;
TRUNCATE TABLE `TipoPaquete`;
TRUNCATE TABLE `Sucursal`;
TRUNCATE TABLE `Provincia`;

SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------------
-- 1.2 Provincia: las 7 provincias oficiales de Costa Rica
-- ------------------------------------------------------------------
INSERT INTO `Provincia` (`nombre`) VALUES
('San José'),       -- id_provincia 1
('Alajuela'),        -- id_provincia 2
('Cartago'),         -- id_provincia 3
('Heredia'),         -- id_provincia 4
('Guanacaste'),      -- id_provincia 5
('Puntarenas'),      -- id_provincia 6
('Limón');           -- id_provincia 7

-- ------------------------------------------------------------------
-- 1.3 Sucursal: 5 sucursales en provincias distintas
-- ------------------------------------------------------------------
INSERT INTO `Sucursal` (`nombre`, `id_provincia`, `direccion`, `telefono`, `capacidad_m3`) VALUES
('Sucursal Central San José',      1, 'Avenida Central, San José centro',                   '2222-1000', 250.00),
('Sucursal Alajuela Aeropuerto',   2, 'Costado norte Aeropuerto Juan Santamaría, Alajuela',  '2222-2000', 180.00),
('Sucursal Heredia Central',       4, 'Barrio Fátima, Heredia centro',                       '2222-3000', 150.00),
('Sucursal Cartago Oriental',      3, 'Costado este de la Basílica, Cartago',                '2222-4000', 120.00),
('Sucursal Puntarenas Puerto',     6, 'Paseo de los Turistas, Puntarenas centro',            '2222-5000', 140.00);
-- id_sucursal: 1 San José, 2 Alajuela, 3 Heredia, 4 Cartago, 5 Puntarenas

-- ------------------------------------------------------------------
-- 1.4 TipoPaquete: 3 modalidades tarifarias
-- ------------------------------------------------------------------
INSERT INTO `TipoPaquete` (`nombre`, `descripcion`, `tarifa_base_kg`) VALUES
('Estándar',     'Entrega en 3 a 5 días hábiles',       850.00),
('Express',      'Entrega en 24 a 48 horas',           1500.00),
('Carga Pesada', 'Paquetes de gran volumen o peso',    2200.00);
-- id_tipo_paquete: 1 Estándar, 2 Express, 3 Carga Pesada

-- ------------------------------------------------------------------
-- 1.5 Vehiculo: 5 vehículos con estados y capacidades distintas
-- (usado tambien para el Requerimiento 5: UPDATE)
-- ------------------------------------------------------------------
INSERT INTO `Vehiculo` (`numero_placa`, `marca`, `modelo`, `capacidad_peso_kg`, `estado_operativo`) VALUES
('SJB-1234',   'Hyundai',    'Porter',  1200.00, 'Disponible'),         -- id 1: Disponible pero capacidad < 1500 -> NO cambia
('CL-456789',  'Isuzu',      'NPR',     3500.00, 'En Ruta'),            -- id 2: no esta Disponible -> NO cambia
('AL-998877',  'Toyota',     'Hilux',   1800.00, 'Disponible'),         -- id 3: Disponible y capacidad >= 1500 -> SI cambia
('HER-334455', 'Mitsubishi', 'Canter',  2500.00, 'Fuera de Servicio'),  -- id 4: no esta Disponible -> NO cambia
('PTA-556677', 'Daihatsu',   'Hijet',   2000.00, 'Disponible');         -- id 5: Disponible y capacidad >= 1500 -> SI cambia

-- ------------------------------------------------------------------
-- 1.6 Cliente: 4 clientes, cada uno con su provincia
-- ------------------------------------------------------------------
INSERT INTO `Cliente` (`cedula_identificacion`, `nombre`, `apellidos`, `telefono`, `correo`, `direccion_habitual`, `id_provincia`) VALUES
('1-1111-1111', 'María',    'Rojas Vargas',      '8888-1111', 'maria.rojas@gmail.com',      '100 m norte del parque, San José', 1),
('2-2222-2222', 'Carlos',   'Fernández Solís',   '8888-2222', 'carlos.fernandez@hotmail.com','Residencial Los Álamos, Alajuela', 2),
('3-3333-3333', 'Laura',    'Jiménez Castro',    '8888-3333', 'laura.jimenez@gmail.com',     'Frente a la iglesia, Heredia',     4),
('4-4444-4444', 'Esteban',  'Vargas Mora',       '8888-4444', 'esteban.vargas@yahoo.com',    'Barrio El Carmen, Cartago',        3);
-- id_cliente: 1 María (gmail), 2 Carlos (hotmail), 3 Laura (gmail), 4 Esteban (yahoo)

-- ------------------------------------------------------------------
-- 1.7 Empleado: 5 colaboradores (conductores, operador, supervisor, administrador)
-- ------------------------------------------------------------------
INSERT INTO `Empleado` (`cedula`, `nombre`, `apellidos`, `puesto`, `id_sucursal`, `licencia_conducir`, `telefono`) VALUES
('9-1111-0001', 'José',      'Hernández Pérez',   'Conductor',     1, 'B2-554433', '7000-1111'),
('9-1111-0002', 'Ana',       'López Chaves',      'Conductor',     2, 'B2-778899', '7000-2222'),
('9-1111-0003', 'Marco',     'Solano Rodríguez',  'Operador',      1, NULL,        '7000-3333'),
('9-1111-0004', 'Gabriela',  'Araya Méndez',      'Supervisor',    3, NULL,        '7000-4444'),
('9-1111-0005', 'Ricardo',   'Mora Salas',        'Administrador', 1, NULL,        '7000-5555');
-- id_empleado: 1 y 2 conductores, 3 operador, 4 supervisor, 5 administrador

-- ------------------------------------------------------------------
-- 1.8 Envio: 5 envios en distintos estados operativos
-- ------------------------------------------------------------------
INSERT INTO `Envio` (`codigo_rastreo`, `id_cliente_remitente`, `id_cliente_destinatario`, `id_sucursal_origen`, `id_sucursal_destino`, `fecha_registro`, `fecha_estimada_entrega`, `estado`, `costo_total`) VALUES
('LCR-0001-2026', 1, 2, 1, 2, '2026-09-01 08:30:00', '2026-09-10', 'Entregado',    9500.00),
('LCR-0002-2026', 2, 1, 2, 1, '2026-09-05 10:15:00', '2026-09-12', 'En Tránsito',  7100.00),
('LCR-0003-2026', 3, 4, 3, 4, '2026-09-08 09:00:00', '2026-09-15', 'En Reparto',   4900.00),
('LCR-0004-2026', 4, 3, 4, 3, '2026-09-10 14:20:00', '2026-09-20', 'Registrado',   6300.00),
('LCR-0005-2026', 1, 3, 1, 4, '2026-08-20 11:00:00', '2026-08-28', 'Devuelto',     3200.00);
-- id_envio: 1 al 5, con los 5 estados posibles representados

-- ------------------------------------------------------------------
-- 1.9 DetallePaquete: 5 paquetes asociados a los envios
-- ------------------------------------------------------------------
INSERT INTO `DetallePaquete` (`id_envio`, `id_tipo_paquete`, `descripcion_contenido`, `peso_kg`, `alto_cm`, `ancho_cm`, `largo_cm`, `subtotal`) VALUES
(1, 1, 'Caja con ropa y calzado',     5.50,  30.00, 25.00, 20.00, 4675.00),
(1, 2, 'Documentos urgentes',        1.20,  10.00, 20.00, 30.00, 1800.00),
(2, 3, 'Repuestos industriales',    15.00,  40.00, 35.00, 50.00, 7100.00),
(3, 1, 'Artículos de oficina',       3.00,  20.00, 20.00, 20.00, 2550.00),
(4, 2, 'Equipo electrónico',         2.50,  15.00, 15.00, 25.00, 3750.00);

-- ------------------------------------------------------------------
-- 1.10 AsignacionRuta: 3 asignaciones de conductor y vehiculo
-- ------------------------------------------------------------------
INSERT INTO `AsignacionRuta` (`id_envio`, `id_empleado_conductor`, `id_vehiculo`, `fecha_asignacion`, `fecha_finalizacion`) VALUES
(1, 1, 1, '2026-09-01 09:00:00', '2026-09-10 16:00:00'),
(2, 2, 3, '2026-09-05 11:00:00', NULL),
(3, 1, 2, '2026-09-08 09:30:00', NULL);

-- ------------------------------------------------------------------
-- 1.11 SeguimientoEnvio: 6 eventos de trazabilidad (minimo 4)
-- ------------------------------------------------------------------
INSERT INTO `SeguimientoEnvio` (`id_envio`, `fecha_hora`, `id_sucursal_actual`, `estado_reportado`, `observaciones`, `id_empleado_registro`) VALUES
(1, '2026-09-01 08:30:00', 1, 'Registrado',   'Envío ingresado al sistema en sucursal origen',       3),
(1, '2026-09-10 16:00:00', 2, 'Entregado',    'Paquete entregado al destinatario en sucursal Alajuela', 2),
(2, '2026-09-05 10:15:00', 2, 'Registrado',   'Envío ingresado al sistema en sucursal origen',       3),
(2, '2026-09-07 13:00:00', 1, 'En Tránsito',  'Envío en camino hacia sucursal destino',               2),
(3, '2026-09-08 09:00:00', 3, 'Registrado',   'Envío ingresado al sistema en sucursal origen',       4),
(3, '2026-09-09 15:30:00', 4, 'En Reparto',   'Paquete en ruta de reparto final',                     1);


-- =============================================================================
-- REQUERIMIENTO 2: Reporte consolidado de envios (DQL - multiples INNER JOIN)
-- Las relaciones dobles (remitente/destinatario y origen/destino) se
-- resuelven dandole a la tabla Cliente y a la tabla Sucursal un alias
-- distinto cada vez que se usan.
-- =============================================================================
SELECT
    e.id_envio                                    AS ID_Envio,
    e.codigo_rastreo                               AS Codigo_Rastreo,
    DATE_FORMAT(e.fecha_registro, '%d/%m/%Y')      AS Fecha_Registro,
    CONCAT(cr.nombre, ' ', cr.apellidos)           AS Cliente_Remitente,
    pr.nombre                                      AS Provincia_Remitente,
    CONCAT(cd.nombre, ' ', cd.apellidos)           AS Cliente_Destinatario,
    pd.nombre                                      AS Provincia_Destinatario,
    so.nombre                                      AS Sucursal_Origen,
    sd.nombre                                      AS Sucursal_Destino,
    e.estado                                       AS Estado_Envio,
    e.costo_total                                  AS Monto_Total
FROM `Envio` e
INNER JOIN `Cliente`   cr ON e.id_cliente_remitente    = cr.id_cliente
INNER JOIN `Provincia` pr ON cr.id_provincia           = pr.id_provincia
INNER JOIN `Cliente`   cd ON e.id_cliente_destinatario = cd.id_cliente
INNER JOIN `Provincia` pd ON cd.id_provincia           = pd.id_provincia
INNER JOIN `Sucursal`  so ON e.id_sucursal_origen      = so.id_sucursal
INNER JOIN `Sucursal`  sd ON e.id_sucursal_destino     = sd.id_sucursal
ORDER BY e.id_envio;


-- =============================================================================
-- REQUERIMIENTO 3: Agregacion gerencial por sucursal y estado (GROUP BY / HAVING)
-- =============================================================================
SELECT
    so.nombre              AS Sucursal_Origen,
    e.estado                AS Estado_Envio,
    COUNT(*)                 AS Total_Envios,
    SUM(e.costo_total)       AS Total_Recaudado,
    AVG(e.costo_total)       AS Promedio_Costo
FROM `Envio` e
INNER JOIN `Sucursal` so ON e.id_sucursal_origen = so.id_sucursal
GROUP BY so.nombre, e.estado
HAVING SUM(e.costo_total) >= 5000.00
ORDER BY Total_Recaudado DESC;


-- =============================================================================
-- REQUERIMIENTO 4: Auditoria de envios pendientes de entrega
-- Filtro adicional: solo clientes destinatarios con correo @gmail.com
-- =============================================================================
SELECT
    e.codigo_rastreo                                   AS Codigo_Rastreo,
    DATE_FORMAT(e.fecha_estimada_entrega, '%d/%m/%Y')  AS Fecha_Estimada_Entrega,
    sd.nombre                                           AS Sucursal_Destino,
    CONCAT(cd.nombre, ' ', cd.apellidos)                AS Cliente_Destinatario,
    cd.telefono                                         AS Telefono_Destinatario,
    e.estado                                            AS Estado_Envio
FROM `Envio` e
INNER JOIN `Sucursal` sd ON e.id_sucursal_destino      = sd.id_sucursal
INNER JOIN `Cliente`  cd ON e.id_cliente_destinatario  = cd.id_cliente
WHERE e.estado IN ('Registrado', 'En Tránsito', 'En Reparto')
  AND cd.correo LIKE '%@gmail.com'
ORDER BY e.fecha_estimada_entrega ASC;


-- =============================================================================
-- REQUERIMIENTO 5: Actualizacion de estado operativo de la flota (UPDATE)
-- =============================================================================

-- 5.1 VERIFICACION PREVIA: filas que seran afectadas por el UPDATE
SELECT
    id_vehiculo,
    numero_placa,
    capacidad_peso_kg,
    estado_operativo
FROM `Vehiculo`
WHERE estado_operativo = 'Disponible'
  AND capacidad_peso_kg >= 1500.00;

-- 5.2 ACTUALIZACION: se marcan "En Mantenimiento" los vehiculos
-- disponibles con capacidad de carga igual o mayor a 1500 kg
UPDATE `Vehiculo`
SET estado_operativo = 'En Mantenimiento'
WHERE estado_operativo = 'Disponible'
  AND capacidad_peso_kg >= 1500.00;

-- 5.3 VERIFICACION POSTERIOR: confirma que las filas quedaron actualizadas
SELECT
    id_vehiculo,
    numero_placa,
    capacidad_peso_kg,
    estado_operativo
FROM `Vehiculo`
WHERE estado_operativo = 'En Mantenimiento'
  AND capacidad_peso_kg >= 1500.00;

-- =============================================================================
-- FIN DEL SCRIPT - PROYECTO 2
-- =============================================================================
