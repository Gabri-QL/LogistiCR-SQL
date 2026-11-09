-- =============================================================================
-- UNIVERSIDAD ESTATAL A DISTANCIA (UNED)
-- 00826 - Base de Datos - III Cuatrimestre 2026
-- PROYECTO No. 3 - Script de PRUEBAS de procedimientos y funciones
-- Base de datos: LogistiCR
-- Elaborado por: Gabriel Quiros
-- =============================================================================
-- ANTES DE EJECUTAR:
--   1. Ya debe estar ejecutado el script de creacion (Proyecto3-Creacion).
--   2. Deben estar cargados los datos de prueba del Proyecto 2 (Requerimiento 1):
--      clientes 1 a 4, sucursales 1 a 5, tipos de paquete 1 a 3, envios 1 a 5.
--
-- COMO EJECUTAR:
--   Ejecuta UNA prueba a la vez (selecciona solo esas lineas y presiona Run).
--   Las pruebas marcadas "ERROR ESPERADO" fallan a proposito: en el panel Output
--   debe aparecer el mensaje de error controlado (SQLSTATE 45000). Si las
--   corrieras todas juntas, el script se detendria en el primer error.
-- =============================================================================

USE `LogistiCR`;

-- =============================================================================
-- REQUERIMIENTO 1: sp_RegistrarCliente
-- =============================================================================

-- 1.1 Caso correcto: registra un cliente nuevo
-- (si lo ejecutas dos veces, la segunda dara error de cedula duplicada: es normal)
CALL sp_RegistrarCliente('5-5555-5555', 'Pedro', 'Soto Quesada', '8888-5555',
                         'pedro.soto@gmail.com', 'Barrio Escalante, San José', 1);

-- 1.2 Evidencia: el nuevo registro quedo en la tabla Cliente
SELECT * FROM Cliente WHERE cedula_identificacion = '5-5555-5555';

-- 1.3 ERROR ESPERADO: la provincia 99 no existe
CALL sp_RegistrarCliente('6-6666-6666', 'Sofía', 'Mora Ruiz', '8888-6666',
                         'sofia.mora@gmail.com', 'Liberia, Guanacaste', 99);

-- 1.4 ERROR ESPERADO: la cedula 1-1111-1111 ya pertenece a otro cliente
CALL sp_RegistrarCliente('1-1111-1111', 'Otro', 'Cliente Repetido', '8888-0000',
                         'repetido@gmail.com', 'San José', 1);


-- =============================================================================
-- REQUERIMIENTO 2: fn_NombreCompletoCliente
-- =============================================================================

-- 2.1 Cliente existente (id 1 = María Rojas Vargas)
SELECT fn_NombreCompletoCliente(1) AS Nombre_Completo;

-- 2.2 Otro cliente existente (id 3)
SELECT fn_NombreCompletoCliente(3) AS Nombre_Completo;

-- 2.3 Cliente que no existe: devuelve NULL (vacio)
SELECT fn_NombreCompletoCliente(999) AS Nombre_Completo;


-- =============================================================================
-- REQUERIMIENTO 3: sp_RegistrarEnvio
-- =============================================================================

-- 3.1 Caso correcto: @id_envio y @codigo reciben los valores de salida (OUT)
CALL sp_RegistrarEnvio(1, 3, 1, 4, '2026-12-01', @id_envio, @codigo);

-- 3.2 Muestra lo que devolvio el procedimiento
SELECT @id_envio AS ID_Envio_Generado, @codigo AS Codigo_Rastreo_Asignado;

-- 3.3 Evidencia: el nuevo envio quedo en la tabla Envio (estado Registrado, costo 0.00)
SELECT * FROM Envio WHERE id_envio = @id_envio;

-- 3.4 ERROR ESPERADO: el remitente 99 no existe
CALL sp_RegistrarEnvio(99, 3, 1, 4, '2026-12-01', @id_x, @codigo_x);

-- 3.5 ERROR ESPERADO: la sucursal de destino 99 no existe
CALL sp_RegistrarEnvio(1, 3, 1, 99, '2026-12-01', @id_x, @codigo_x);


-- =============================================================================
-- REQUERIMIENTO 4: fn_ObtenerEstadoEnvio
-- =============================================================================

-- 4.1 Envio existente (id 1 = Entregado)
SELECT fn_ObtenerEstadoEnvio(1) AS Estado_Envio;

-- 4.2 Envio existente (id 2 = En Tránsito)
SELECT fn_ObtenerEstadoEnvio(2) AS Estado_Envio;

-- 4.3 El envio recien creado en la prueba 3.1 (debe ser Registrado)
SELECT fn_ObtenerEstadoEnvio(@id_envio) AS Estado_Envio;

-- 4.4 Envio que no existe: devuelve 'NO ENCONTRADO'
SELECT fn_ObtenerEstadoEnvio(999) AS Estado_Envio;


-- =============================================================================
-- REQUERIMIENTO 5: sp_RegistrarDetallePaquete
-- (usa el envio creado en la prueba 3.1, que tiene costo_total = 0.00)
-- =============================================================================

-- 5.1 ANTES: costo del envio antes de agregar el paquete
SELECT id_envio, codigo_rastreo, costo_total FROM Envio WHERE id_envio = @id_envio;

-- 5.2 Caso correcto: tipo 2 (Express, tarifa 1500.00/kg) x 2.50 kg = 3750.00
CALL sp_RegistrarDetallePaquete(@id_envio, 2, 'Equipo electrónico', 2.50, 15.00, 15.00, 25.00);

-- 5.3 Evidencia: el paquete quedo en DetallePaquete con su subtotal calculado
SELECT * FROM DetallePaquete WHERE id_envio = @id_envio;

-- 5.4 DESPUES: el costo_total del envio ahora incluye el subtotal (3750.00)
SELECT id_envio, codigo_rastreo, costo_total FROM Envio WHERE id_envio = @id_envio;

-- 5.5 ERROR ESPERADO: el envio 999 no existe
CALL sp_RegistrarDetallePaquete(999, 2, 'Caja', 1.00, 10.00, 10.00, 10.00);

-- 5.6 ERROR ESPERADO: el tipo de paquete 99 no existe
CALL sp_RegistrarDetallePaquete(@id_envio, 99, 'Caja', 1.00, 10.00, 10.00, 10.00);

-- 5.7 ERROR ESPERADO: peso en cero
CALL sp_RegistrarDetallePaquete(@id_envio, 2, 'Caja', 0.00, 10.00, 10.00, 10.00);


-- =============================================================================
-- REQUERIMIENTO 6: fn_TotalEnviosEntregadosConductor
-- =============================================================================

-- 6.1 Conductor 1 (José): tiene asignado el envio 1, que esta Entregado -> 1
SELECT fn_TotalEnviosEntregadosConductor(1) AS Envios_Entregados;

-- 6.2 Conductor 2 (Ana): tiene asignado el envio 2, que esta En Tránsito -> 0
SELECT fn_TotalEnviosEntregadosConductor(2) AS Envios_Entregados;

-- 6.3 Empleado sin asignaciones (id 3, Operador) -> 0
SELECT fn_TotalEnviosEntregadosConductor(3) AS Envios_Entregados;

-- =============================================================================
-- FIN DEL SCRIPT DE PRUEBAS - PROYECTO 3
-- =============================================================================
