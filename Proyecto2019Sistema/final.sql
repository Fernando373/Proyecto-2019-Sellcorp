-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 18-06-2019 a las 22:42:04
-- Versión del servidor: 10.1.38-MariaDB
-- Versión de PHP: 7.3.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `final`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_precio_producto` (`n_cantidad` INT, `n_precio` DECIMAL(10,2), `codigo` INT)  BEGIN
    	DECLARE nueva_existencia int;
        DECLARE nuevo_total  decimal(10,2);
        DECLARE nuevo_precio decimal(10,2);
        
        DECLARE cant_actual int;
        DECLARE pre_actual decimal(10,2);
        
        DECLARE actual_existencia int;
        DECLARE actual_precio decimal(10,2);
                
        SELECT precio,existencia INTO actual_precio,actual_existencia FROM producto WHERE codproducto = codigo;
        SET nueva_existencia = actual_existencia + n_cantidad;
        SET nuevo_total = (actual_existencia * actual_precio) + (n_cantidad * n_precio);
        SET nuevo_precio = nuevo_total / nueva_existencia;
        
        UPDATE producto SET existencia = nueva_existencia, precio = nuevo_precio WHERE codproducto = codigo;
        
        SELECT nueva_existencia,nuevo_precio;
        
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_detalle_temp` (`codigo` INT, `cantidad` INT, `token_user` VARCHAR(50))  BEGIN
DECLARE precio_actual decimal(10,2);
SELECT precio INTO precio_actual FROM producto WHERE codproducto = codigo;
INSERT INTO detalle_temp(token_user, codproducto,cantidad,precio_venta) VALUES (token_user, codigo, cantidad,precio_actual);
SELECT tmp.correlativo, tmp.codproducto,p.descripcion,tmp.cantidad,tmp.precio_venta FROM detalle_temp tmp
INNER JOIN producto p 
ON tmp.codproducto = p.codproducto
WHERE tmp.token_user = token_user;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `anular_factura` (`no_factura` INT)  BEGIN 
    	DECLARE existe_factura int;
        DECLARE registros int;
        DECLARE a int;
        
        DECLARE cod_producto int;
        DECLARE cant_producto int;
        DECLARE existencia_actual int;
        DECLARE nueva_existencia int;
        
        SET existe_factura = (SELECT COUNT(*) FROM factura WHERE nofactura = no_factura and estatus = 1);
        
        IF existe_factura > 0 THEN
        	CREATE TEMPORARY TABLE tbl_tmp (
                id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                cod_prod BIGINT,
                cant_prod int);
                
                SET a = 1;
                
                SET registros = (SELECT COUNT(*) FROM detallefactura WHERE nofactura = no_factura);
                
                IF registros > 0 THEN
                 	
                    INSERT INTO tbl_tmp(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detallefactura WHERE nofactura = no_factura;
                    
                    WHILE a<= registros DO
                    	SELECT cod_prod,cant_prod INTO cod_producto,cant_producto FROM tbl_tmp WHERE id = a;
                        SELECT existencia INTO existencia_actual  FROM producto WHERE codproducto = cod_producto;
                        SET nueva_existencia = existencia_actual + cant_producto;
                        UPDATE producto SET existencia = nueva_existencia WHERE codproducto = cod_producto;
                        
                        SET a=a+1;
                    END WHILE;
                    
                    UPDATE factura SET estatus = 2 WHERE nofactura = no_factura;
                    DROP TABLE tbl_tmp;
                    SELECT * FROM factura WHERE nofactura = no_factura;
                
                END IF;
        ELSE
        	SELECT 0 factura;
        END IF;
    
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `dataDashboard` ()  BEGIN
    	DECLARE usuarios int;
        DECLARE clientes int;
        DECLARE proveedores int;
        DECLARE productos int;
        DECLARE ventas int;
        DECLARE totalventas int;
        DECLARE internet int;
        DECLARE totinte int;
        
        
        SELECT COUNT(*) INTO usuarios FROM usuario WHERE estatus !=10;
        SELECT COUNT(*) INTO clientes FROM cliente WHERE estatus !=10;
        SELECT COUNT(*) INTO proveedores FROM proveedor WHERE estatus !=10;
        SELECT COUNT(*) INTO productos FROM producto WHERE estatus !=10;
        SELECT COUNT(*) INTO ventas FROM factura WHERE fecha > CURDATE() AND estatus !=10;
        SELECT SUM(totalfactura) INTO totalventas FROM factura WHERE fecha > CURDATE() AND estatus !=10;
        SELECT COUNT(Total) INTO internet FROM tblventas WHERE Fecha > CURDATE() AND estado !=10;
        SELECT SUM(Total) INTO totinte FROM tblventas WHERE Fecha > CURDATE() AND estado !=10;
        
        SELECT usuarios,clientes,proveedores,productos,ventas,totalventas,internet,totinte;
        
    
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `del_detalle_temp` (`id_detalle` INT, `token` VARCHAR(50))  BEGIN
DELETE FROM detalle_temp WHERE correlativo = id_detalle;
SELECT tmp.correlativo, tmp.codproducto,p.descripcion,tmp.cantidad,tmp.precio_venta FROM detalle_temp tmp
INNER JOIN producto p 
ON tmp.codproducto = p.codproducto
WHERE tmp.token_user = token;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `procesar_venta` (IN `cod_usuario` INT, IN `cod_cliente` INT, IN `token` VARCHAR(50))  BEGIN
        	DECLARE factura INT;
            
            DECLARE registros INT;
            DECLARE total DECIMAL(10,2);
            
            DECLARE nueva_existencia int;
            DECLARE existencia_actual int;
            
            DECLARE tmp_cod_producto int;
            DECLARE tmp_cant_producto int;
            DECLARE a INT;
            SET a = 1;
            
            CREATE TEMPORARY TABLE tbl_tmp_tokenuser(
                id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                cod_prod BIGINT,
                cant_prod int);
            SET registros = (SELECT COUNT(*) FROM detalle_temp WHERE token_user = token);
            
            IF registros > 0 THEN
            	INSERT INTO tbl_tmp_tokenuser(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detalle_temp WHERE token_user = token;
                INSERT INTO factura(usuario,codcliente) VALUES(cod_usuario,cod_cliente);
                SET factura = LAST_INSERT_ID();
                
                INSERT INTO detallefactura(nofactura,codproducto,cantidad,precio_venta) SELECT (factura) as nofactura, codproducto,cantidad,precio_venta FROM detalle_temp WHERE token_user = token;
                
                WHILE a <= registros DO
                	SELECT cod_prod,cant_prod INTO tmp_cod_producto,tmp_cant_producto FROM tbl_tmp_tokenuser WHERE id = a;
                    SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = tmp_cod_producto;
                    
                    SET nueva_existencia = existencia_actual - tmp_cant_producto;
                    UPDATE producto SET existencia = nueva_existencia WHERE codproducto = tmp_cod_producto;
                    
                    SET a=a+1;
                END WHILE;
                
                SET total = (SELECT SUM(cantidad * precio_venta) FROM detalle_temp WHERE token_user = token);
                UPDATE factura SET totalfactura = total WHERE nofactura = factura;
                DELETE FROM detalle_temp WHERE token_user = token;
                TRUNCATE TABLE tbl_tmp_tokenuser;
                SELECT * FROM factura WHERE nofactura = factura;
                
            ELSE
            	SELECT 0;
            END IF;
        END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `administradores`
--

CREATE TABLE `administradores` (
  `id` int(11) NOT NULL,
  `nombre` text COLLATE utf8_spanish_ci NOT NULL,
  `email` text COLLATE utf8_spanish_ci NOT NULL,
  `foto` text COLLATE utf8_spanish_ci NOT NULL,
  `password` text COLLATE utf8_spanish_ci NOT NULL,
  `perfil` text COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `administradores`
--

INSERT INTO `administradores` (`id`, `nombre`, `email`, `foto`, `password`, `perfil`, `estado`, `fecha`) VALUES
(1, 'David Pinto', 'david@david.com', 'vistas/img/perfiles/343.jpg', '$2a$07$asxx54ahjppf45sd87a5auY00k1u8xuSPBVWyPyNbI1/Yjo0Ydzra', 'administrador', 1, '2019-06-18 13:37:07'),
(2, 'Fernando Murguia', 'fer@fer.com', 'vistas/img/perfiles/667.jpg', '$2a$07$asxx54ahjppf45sd87a5autmgqGyHHXH8y0sPvyUw9l5uJdWGEKiO', 'administrador', 1, '2019-06-18 13:37:33');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `banner`
--

CREATE TABLE `banner` (
  `id` int(11) NOT NULL,
  `ruta` text COLLATE utf8_spanish_ci NOT NULL,
  `tipo` text COLLATE utf8_spanish_ci NOT NULL,
  `img` text COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cabeceras`
--

CREATE TABLE `cabeceras` (
  `id` int(11) NOT NULL,
  `ruta` text COLLATE utf8_spanish_ci NOT NULL,
  `titulo` text COLLATE utf8_spanish_ci NOT NULL,
  `descripcion` text COLLATE utf8_spanish_ci NOT NULL,
  `palabrasClaves` text COLLATE utf8_spanish_ci NOT NULL,
  `portada` text COLLATE utf8_spanish_ci NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `cabeceras`
--

INSERT INTO `cabeceras` (`id`, `ruta`, `titulo`, `descripcion`, `palabrasClaves`, `portada`, `fecha`) VALUES
(1, 'inicio', 'Tienda Virtual', 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quisquam accusantium enim esse eos officiis sit officia', 'Lorem ipsum, dolor sit amet, consectetur, adipisicing, elit, Quisquam, accusantium, enim, esse', 'vistas/img/cabeceras/default.jpg', '2017-11-17 14:58:16'),
(2, 'desarrollo-web', 'Desarrollo Web', 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quisquam accusantium enim esse eos officiis sit officia', 'Lorem ipsum, dolor sit amet, consectetur, adipisicing, elit, Quisquam, accusantium, enim, esse', 'vistas/img/cabeceras/web.jpg', '2017-11-17 14:59:28'),
(3, 'autos', 'Autos', 'autos de juguetes', 'lorem,ipsum,sit', 'vistas/img/cabeceras/autos.jpg', '2019-06-18 13:58:29'),
(4, 'woody', 'Woody', 'woody de toy story', 'woody', 'vistas/img/cabeceras/woody.png', '2019-06-18 06:25:02'),
(5, 'juguetes-de-hule', 'Juguetes de hule', 'juguetes de hule', 'hule', 'vistas/img/cabeceras/juguetes-de-hule.jpg', '2019-06-18 14:01:25'),
(6, 'peluches-de-1-a-5-anos', 'peluches de 1 a 5 años', 'peluches para niños de 1 a 5 años', 'niños ', 'vistas/img/cabeceras/peluches-de-1-a-5-anos.jpg', '2019-06-18 14:03:49'),
(7, 'autos-a-control-remoto', 'autos a control remoto', 'autos a control remoto', 'autos', 'vistas/img/cabeceras/autos-a-control-remoto.jpg', '2019-06-18 14:04:40'),
(8, 'rayo-mcqueen', 'Rayo Mcqueen', 'autos de cars', 'auto', 'vistas/img/cabeceras/rayo-mcqueen.jpg', '2019-06-18 15:06:37'),
(9, 'sticj', 'Sticj', 'stich', 'sticj', 'vistas/img/cabeceras/sticj.jpg', '2019-06-18 15:07:44'),
(10, 'patito-de-hule', 'Patito de hule', 'juguetes de hule', 'juguetes ', 'vistas/img/cabeceras/patito-de-hule.jpg', '2019-06-18 15:08:50'),
(11, 'pistolas-de-juguete', 'pistolas de juguete', 'pistola de juguete', 'pistola', 'vistas/img/cabeceras/pistolas-de-juguete.jpg', '2019-06-18 19:51:22'),
(12, 'pato-de-hule', 'pato de hule', 'pato de hule', 'pato', 'vistas/img/cabeceras/pato-de-hule.jpg', '2019-06-18 19:52:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id` int(11) NOT NULL,
  `categoria` text COLLATE utf8_spanish_ci NOT NULL,
  `ruta` text COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL,
  `oferta` int(11) NOT NULL,
  `precioOferta` float NOT NULL,
  `descuentoOferta` int(11) NOT NULL,
  `imgOferta` text COLLATE utf8_spanish_ci NOT NULL,
  `finOferta` datetime NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id`, `categoria`, `ruta`, `estado`, `oferta`, `precioOferta`, `descuentoOferta`, `imgOferta`, `finOferta`, `fecha`) VALUES
(4, 'PELUCHES', 'peluches', 1, 0, 0, 0, '', '0000-00-00 00:00:00', '2019-06-18 14:00:41'),
(5, 'PISTOLAS', 'pistolas', 1, 0, 0, 0, '', '0000-00-00 00:00:00', '2019-06-18 13:59:13'),
(6, 'AUTOS', 'autos', 1, 0, 0, 0, '', '0000-00-00 00:00:00', '2019-06-18 13:58:29'),
(7, 'JUGUETES DE HULE', 'juguetes-de-hule', 1, 0, 0, 0, '', '0000-00-00 00:00:00', '2019-06-18 14:01:25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `idcliente` int(11) NOT NULL,
  `nit` int(11) DEFAULT NULL,
  `nombre` varchar(80) DEFAULT NULL,
  `telefono` int(11) DEFAULT NULL,
  `direccion` text,
  `dateadd` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_id` int(11) NOT NULL,
  `estatus` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`idcliente`, `nit`, `nombre`, `telefono`, `direccion`, `dateadd`, `usuario_id`, `estatus`) VALUES
(1, 0, 'SIN NOMBRE', NULL, '', '2019-04-17 23:19:42', 2, 1),
(2, 985262, 'David Saavedra', 456465612, 'El alto xdxd', '2019-04-17 23:23:18', 2, 1),
(3, 9873282, 'Cristhian Boyan', 12313213, 'Miraflores', '2019-04-17 23:26:37', 2, 1),
(4, 123154, 'David Saavedra', 456465612, 'El alto xdxd', '2019-04-24 21:40:01', 2, 1),
(5, 78956, 'David Saavedra', 456465612, 'El alto xdxd', '2019-04-24 21:41:58', 2, 1),
(6, 2823789, 'Fernando Murguia', 76587841, 'Avenida las Americas', '2019-04-24 21:52:56', 2, 1),
(9, 2147483647, 'Elver Galarga', 78956222, 'Obrajes ', '2019-05-03 11:07:18', 2, 1),
(10, 98732822, 'Esteffi Fierrote', 78552133, 'llojeta', '2019-05-03 11:07:19', 2, 1),
(11, 987312300, 'Mariano Flores', 75251113, 'Los Pinos', '2019-05-03 11:08:39', 2, 1),
(12, 9873123, 'Juan Carlos Guerro', 87897542, 'no se we', '2019-05-03 11:09:26', 2, 1),
(13, 123456789, 'Julio Pineda', 789456123, 'Calacoto ', '2019-05-03 11:15:58', 2, 1),
(14, 468517, 'FabiolaPerez', 72008114, 'cruce villa copacabana', '2019-05-06 16:19:33', 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comentarios`
--

CREATE TABLE `comentarios` (
  `id` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `calificacion` float NOT NULL,
  `comentario` text COLLATE utf8_spanish_ci NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `comentarios`
--

INSERT INTO `comentarios` (`id`, `id_usuario`, `id_producto`, `calificacion`, `comentario`, `fecha`) VALUES
(1, 86, 496, 3.5, 'Lo mejor de PHP', '2018-02-13 16:39:25'),
(2, 86, 464, 4.5, 'Excelente', '2018-02-13 15:55:14'),
(3, 87, 496, 4, 'El curso es muy bueno, pero puede ser mejor.', '2018-02-13 16:10:50'),
(4, 88, 496, 4.5, 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod\r\n		tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,\r\n		quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo\r\n		consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse\r\n		cillum dolore eu fugiat nulla pariatur', '2018-02-13 17:17:48'),
(6, 5, 496, 2, 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod\r\n		tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,\r\n		quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo\r\n		consequat. ', '2018-02-13 17:21:30'),
(7, 12, 500, 0, '', '2018-03-27 23:19:33');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comercio`
--

CREATE TABLE `comercio` (
  `id` int(11) NOT NULL,
  `impuesto` float NOT NULL,
  `envioNacional` float NOT NULL,
  `envioInternacional` float NOT NULL,
  `tasaMinimaNal` float NOT NULL,
  `tasaMinimaInt` float NOT NULL,
  `pais` text COLLATE utf8_spanish_ci NOT NULL,
  `modoPaypal` text COLLATE utf8_spanish_ci NOT NULL,
  `clienteIdPaypal` text COLLATE utf8_spanish_ci NOT NULL,
  `llaveSecretaPaypal` text COLLATE utf8_spanish_ci NOT NULL,
  `modoPayu` text COLLATE utf8_spanish_ci NOT NULL,
  `merchantIdPayu` int(11) NOT NULL,
  `accountIdPayu` int(11) NOT NULL,
  `apiKeyPayu` text COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `comercio`
--

INSERT INTO `comercio` (`id`, `impuesto`, `envioNacional`, `envioInternacional`, `tasaMinimaNal`, `tasaMinimaInt`, `pais`, `modoPaypal`, `clienteIdPaypal`, `llaveSecretaPaypal`, `modoPayu`, `merchantIdPayu`, `accountIdPayu`, `apiKeyPayu`) VALUES
(1, 13, 1, 2, 10, 15, 'BO', 'sandbox', 'AU1ynU1bfKi2FYoSDZuOT7VDRZ3rOm-Su3Mcs8CCw36V1HdXCTyvGiVCyqCSuJ7jgNIwn04nd3wN2L_d', 'EDw1Z75iQzIh9YuxIE5v9HndtFtS7kdxuBm4AdnOrWU6-UuGrJ_8QBoEsXQpAIeEZIxMyJCjIu5ZtRzi', 'undefined', 0, 0, 'undefined');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `id` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `envio` int(11) NOT NULL,
  `metodo` text COLLATE utf8_spanish_ci NOT NULL,
  `email` text COLLATE utf8_spanish_ci NOT NULL,
  `direccion` text COLLATE utf8_spanish_ci NOT NULL,
  `pais` text COLLATE utf8_spanish_ci NOT NULL,
  `cantidad` int(11) NOT NULL,
  `detalle` text COLLATE utf8_spanish_ci,
  `pago` text COLLATE utf8_spanish_ci NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `compras`
--

INSERT INTO `compras` (`id`, `id_usuario`, `id_producto`, `envio`, `metodo`, `email`, `direccion`, `pais`, `cantidad`, `detalle`, `pago`, `fecha`) VALUES
(1, 1, 2, 0, 'paypal', '', 'barranca', 'pe', 5, NULL, '50', '2019-06-18 19:53:46'),
(2, 12, 2, 2, 'paypal', '', 'barranca', 'pe', 2, NULL, '40', '2019-06-18 19:53:48'),
(3, 13, 2, 0, 'paypal', '', 'urb 17 de mayo mz a lt 1-2', 'pe', 1, NULL, '70', '2019-06-18 19:53:50'),
(12, 8, 3, 0, 'paypal', 'tutorialesatualcance-buyer@hotmail.com', '1 Main St, San Jose, CA, 95131', 'US', 9, NULL, '10', '2019-06-18 19:53:54'),
(13, 8, 3, 2, 'paypal', 'tutorialesatualcance-buyer@hotmail.com', '1 Main St, San Jose, CA, 95131', 'US', 4, NULL, '10', '2019-06-18 19:53:58'),
(14, 8, 4, 0, 'paypal', 'tutorialesatualcance-buyer@hotmail.com', '1 Main St, San Jose, CA, 95131', 'US', 8, NULL, '10', '2019-06-18 19:54:00'),
(15, 8, 4, 0, 'paypal', 'correo@test.com', '', 'BO', 1, NULL, '20', '2019-06-18 19:54:04'),
(16, 8, 4, 2, 'paypal', 'correo@test.com', '', 'BO', 2, NULL, '20', '2019-06-18 19:54:06'),
(17, 8, 2, 0, 'paypal', 'ejemplo@test.com', '', 'BO', 7, NULL, '10', '2019-06-18 19:54:11'),
(18, 8, 2, 0, 'paypal', 'pepe@gmail.com', '', 'US', 4, NULL, '11', '2019-06-18 19:54:38'),
(19, 13, 2, 0, 'paypal', 'pepe@gmail.com', '', 'BO', 6, NULL, '5', '2019-06-18 19:54:41'),
(20, 7, 2, 0, 'paypal', 'pepe@gmail.com', '', 'BO', 3, NULL, '8', '2019-06-18 19:54:44'),
(21, 12, 4, 0, 'paypal', 'pepe@gmail.com', '', 'US', 6, NULL, '20', '2019-06-18 19:54:47'),
(22, 12, 3, 2, 'paypal', 'tutorialesatualcance-buyer@hotmail.com', '1 Main St, San Jose, CA, 95131', 'US', 1, NULL, '9.99', '2019-06-18 19:54:28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--

CREATE TABLE `configuracion` (
  `id` bigint(20) NOT NULL,
  `nit` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `razon_social` varchar(100) NOT NULL,
  `telefono` bigint(20) NOT NULL,
  `email` varchar(200) NOT NULL,
  `direccion` text NOT NULL,
  `iva` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `configuracion`
--

INSERT INTO `configuracion` (`id`, `nit`, `nombre`, `razon_social`, `telefono`, `email`, `direccion`, `iva`) VALUES
(1, '9873282', 'SELLCORP S.R.L', '', 76587841, 'sellcorp@gmail.com', 'calle 21 San Miguel', '13.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `deseos`
--

CREATE TABLE `deseos` (
  `id` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `deseos`
--

INSERT INTO `deseos` (`id`, `id_usuario`, `id_producto`, `fecha`) VALUES
(1, 9, 469, '2018-03-26 22:03:34'),
(2, 9, 469, '2018-03-26 22:03:35'),
(3, 9, 467, '2018-03-26 22:03:39'),
(4, 9, 3, '2018-03-26 22:03:43'),
(5, 9, 469, '2018-03-26 22:03:54'),
(6, 9, 470, '2018-03-26 22:03:57'),
(7, 9, 467, '2018-03-26 22:04:00'),
(8, 9, 4, '2018-03-26 22:04:37');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefactura`
--

CREATE TABLE `detallefactura` (
  `correlativo` bigint(11) NOT NULL,
  `nofactura` bigint(11) DEFAULT NULL,
  `codproducto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio_venta` decimal(10,2) DEFAULT NULL,
  `descuento` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detallefactura`
--

INSERT INTO `detallefactura` (`correlativo`, `nofactura`, `codproducto`, `cantidad`, `precio_venta`, `descuento`) VALUES
(1, 1, 1, 3, '1800.00', 0),
(2, 2, 1, 3, '1800.00', 0),
(3, 3, 1, 3, '1800.00', 0),
(4, 4, 1, 3, '1800.00', 0),
(5, 4, 10, 5, '55.00', 0),
(7, 5, 1, 3, '1800.00', 0),
(8, 6, 1, 3, '1800.00', 0),
(9, 7, 1, 3, '1800.00', 0),
(10, 8, 1, 3, '1800.00', 0),
(11, 8, 5, 10, '74.61', 0),
(12, 8, 7, 11, '106.81', 0),
(13, 9, 1, 2, '1800.00', 0),
(14, 9, 5, 2, '74.61', 0),
(16, 10, 8, 40, '139.44', 0),
(17, 10, 11, 15, '93.81', 0),
(19, 11, 10, 5, '55.00', 0),
(20, 11, 5, 8, '74.61', 0),
(22, 12, 10, 15, '55.00', 0),
(23, 13, 9, 1, '19.80', 0),
(24, 14, 3, 10, '106.67', 0),
(25, 15, 9, 1, '19.80', 0),
(26, 16, 5, 10, '74.61', 0),
(27, 17, 10, 2, '55.00', 0),
(28, 17, 11, 5, '93.81', 0),
(30, 18, 9, 1, '19.80', 0),
(31, 18, 2, 5, '150.00', 0),
(33, 19, 8, 50, '139.44', 0),
(34, 20, 8, 50, '139.44', 0),
(35, 21, 8, 1000, '139.44', 0),
(36, 22, 11, 12, '9.17', 0),
(37, 22, 8, 2, '139.44', 0),
(38, 23, 1, 1, '1800.00', 0),
(39, 23, 8, 10, '139.44', 0),
(40, 23, 8, 10, '139.44', 0),
(41, 23, 9, 3, '19.80', 0),
(42, 23, 10, 3, '55.00', 0),
(43, 23, 11, 90, '9.17', 0),
(44, 23, 5, 5, '74.61', 0),
(45, 23, 6, 5, '1.00', 0),
(46, 23, 7, 100, '106.81', 0),
(47, 23, 3, 10, '106.67', 0),
(48, 23, 4, 10, '158.42', 0),
(49, 23, 5, 10, '74.61', 0),
(50, 23, 1, 2, '1800.00', 0),
(51, 24, 10, 5, '55.00', 0),
(52, 24, 1, 1, '666.67', 0),
(53, 25, 1, 3, '651.67', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_temp`
--

CREATE TABLE `detalle_temp` (
  `correlativo` int(11) NOT NULL,
  `token_user` varchar(50) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detalle_temp`
--

INSERT INTO `detalle_temp` (`correlativo`, `token_user`, `codproducto`, `cantidad`, `precio_venta`) VALUES
(17, 'c4ca4238a0b923820dcc509a6f75849b', 2, 2, '135.00'),
(18, 'c4ca4238a0b923820dcc509a6f75849b', 1, 1, '651.67');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas`
--

CREATE TABLE `entradas` (
  `correlativo` int(11) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cantidad` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `entradas`
--

INSERT INTO `entradas` (`correlativo`, `codproducto`, `fecha`, `cantidad`, `precio`, `usuario_id`) VALUES
(1, 3, '2019-04-18 11:48:43', 100, '110.00', 2),
(2, 4, '2019-04-18 16:10:41', 1, '0.20', 1),
(3, 5, '2019-04-19 10:50:20', 500, '50.00', 2),
(4, 6, '2019-04-19 10:52:10', 500, '50.00', 2),
(5, 7, '2019-04-19 10:56:06', 999, '5.00', 2),
(6, 8, '2019-04-25 10:52:51', 10000, '100.00', 2),
(7, 4, '2019-04-25 13:41:57', 100, '160.00', 2),
(8, 5, '2019-04-25 13:50:02', 10, '51.00', 2),
(9, 3, '2019-04-25 13:51:59', 50, '100.00', 2),
(10, 8, '2019-04-25 14:23:03', 20, '10001.00', 2),
(11, 8, '2019-04-25 14:23:06', 20, '10001.00', 2),
(12, 7, '2019-04-25 14:25:18', 10, '200.00', 2),
(13, 6, '2019-04-25 20:06:55', 10, '55.00', 2),
(14, 6, '2019-04-25 20:12:41', 10, '50.00', 2),
(15, 9, '2019-04-25 20:17:37', 100, '10.00', 2),
(16, 10, '2019-04-25 20:18:48', 100, '10.00', 2),
(17, 11, '2019-04-25 20:20:27', 10, '100.00', 2),
(18, 11, '2019-04-25 20:21:28', 100, '100.00', 2),
(19, 10, '2019-04-25 20:22:12', 100, '100.00', 2),
(20, 9, '2019-04-25 20:22:48', 1, '1000.00', 2),
(21, 11, '2019-04-25 20:25:48', 10, '100.00', 2),
(22, 11, '2019-04-25 20:28:06', 10, '100.00', 2),
(23, 11, '2019-04-25 20:28:52', 10, '100.00', 2),
(24, 11, '2019-04-25 20:29:17', 10, '100.00', 2),
(25, 10, '2019-04-25 20:34:31', 10, '55.00', 2),
(26, 10, '2019-04-25 20:34:54', 10, '55.00', 2),
(27, 7, '2019-04-25 20:45:40', 1, '1000.00', 2),
(28, 7, '2019-04-25 20:48:02', 1, '100000.00', 2),
(29, 12, '2019-04-25 21:21:33', 0, '19.80', 2),
(30, 12, '2019-04-26 11:25:18', 10, '20.00', 2),
(31, 11, '2019-04-29 16:31:14', 10, '1.00', 2),
(32, 11, '2019-05-06 16:26:45', 1450, '1.00', 2),
(33, 1, '2019-05-27 15:19:40', 10, '100.00', 2),
(34, 13, '2019-06-17 12:59:01', 100, '10.00', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--

CREATE TABLE `factura` (
  `nofactura` bigint(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario` int(11) DEFAULT NULL,
  `codcliente` int(11) DEFAULT NULL,
  `totalfactura` decimal(10,2) DEFAULT NULL,
  `estatus` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `factura`
--

INSERT INTO `factura` (`nofactura`, `fecha`, `usuario`, `codcliente`, `totalfactura`, `estatus`) VALUES
(1, '2019-05-05 22:54:21', 1, 1, NULL, 2),
(2, '2019-05-05 22:54:28', 1, 1, '100.00', 1),
(3, '2019-05-05 22:55:13', 1, 1, '100.00', 1),
(4, '2019-05-05 22:55:31', 1, 1, '100.00', 1),
(5, '2019-05-05 22:56:19', 2, 1, '100.00', 1),
(6, '2019-05-06 09:06:12', 2, 2, '100.00', 1),
(7, '2019-05-06 09:31:31', 2, 3, '100.00', 1),
(8, '2019-05-06 10:11:03', 2, 5, '7321.01', 1),
(9, '2019-05-06 10:31:07', 2, 3, '3749.22', 1),
(10, '2019-05-06 10:33:41', 2, 1, '6984.75', 1),
(11, '2019-05-06 11:14:08', 2, 3, '871.88', 1),
(12, '2019-05-06 11:21:09', 2, 3, '825.00', 1),
(13, '2019-05-06 11:22:30', 2, 6, '19.80', 1),
(14, '2019-05-06 11:24:03', 2, 6, '1066.70', 1),
(15, '2019-05-06 11:27:35', 2, 6, '19.80', 1),
(16, '2019-05-06 13:45:15', 2, 1, '746.10', 1),
(17, '2019-05-06 14:34:28', 2, 3, '579.05', 1),
(18, '2019-05-06 14:47:13', 2, 3, '769.80', 1),
(19, '2019-05-06 14:47:55', 2, 3, '6972.00', 1),
(20, '2019-05-06 16:20:41', 2, 1, '6972.00', 1),
(21, '2019-05-06 16:22:16', 2, 1, '139440.00', 2),
(22, '2019-05-07 21:43:46', 2, 1, '388.92', 2),
(23, '2019-05-23 15:06:27', 2, 1, '23694.55', 1),
(24, '2019-06-16 08:43:25', 2, 1, '941.67', 1),
(25, '2019-06-17 21:41:11', 2, 1, '1955.01', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificaciones`
--

CREATE TABLE `notificaciones` (
  `id` int(11) NOT NULL,
  `nuevosUsuarios` int(11) NOT NULL,
  `nuevasVentas` int(11) NOT NULL,
  `nuevasVisitas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `notificaciones`
--

INSERT INTO `notificaciones` (`id`, `nuevosUsuarios`, `nuevasVentas`, `nuevasVisitas`) VALUES
(1, 1, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `plantilla`
--

CREATE TABLE `plantilla` (
  `id` int(11) NOT NULL,
  `barraSuperior` text COLLATE utf8_spanish_ci NOT NULL,
  `textoSuperior` text COLLATE utf8_spanish_ci NOT NULL,
  `colorFondo` text COLLATE utf8_spanish_ci NOT NULL,
  `colorTexto` text COLLATE utf8_spanish_ci NOT NULL,
  `logo` text COLLATE utf8_spanish_ci NOT NULL,
  `icono` text COLLATE utf8_spanish_ci NOT NULL,
  `redesSociales` text COLLATE utf8_spanish_ci NOT NULL,
  `apiFacebook` text COLLATE utf8_spanish_ci NOT NULL,
  `pixelFacebook` text COLLATE utf8_spanish_ci NOT NULL,
  `googleAnalytics` text COLLATE utf8_spanish_ci NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `plantilla`
--

INSERT INTO `plantilla` (`id`, `barraSuperior`, `textoSuperior`, `colorFondo`, `colorTexto`, `logo`, `icono`, `redesSociales`, `apiFacebook`, `pixelFacebook`, `googleAnalytics`, `fecha`) VALUES
(1, '#000000', '#ffffff', '#47bac1', '#ffffff', 'vistas/img/plantilla/logo.jpg', 'vistas/img/plantilla/icono.jpg', '[{\"red\":\"fa-facebook\",\"estilo\":\"facebookBlanco\",\"url\":\"http://facebook.com/\",\"activo\":1},{\"red\":\"fa-youtube\",\"estilo\":\"youtubeBlanco\",\"url\":\"http://youtube.com/\",\"activo\":1},{\"red\":\"fa-twitter\",\"estilo\":\"twitterBlanco\",\"url\":\"http://twitter.com/\",\"activo\":1},{\"red\":\"fa-google-plus\",\"estilo\":\"google-plusBlanco\",\"url\":\"http://google.com/\",\"activo\":1},{\"red\":\"fa-instagram\",\"estilo\":\"instagramBlanco\",\"url\":\"http://instagram.com/\",\"activo\":1}]', '\r\n      		<script>   window.fbAsyncInit = function() {     FB.init({       appId      : \'131737410786111\',       cookie     : true,       xfbml      : true,       version    : \'v2.10\'     });            FB.AppEvents.logPageView();             };    (function(d, s, id){      var js, fjs = d.getElementsByTagName(s)[0];      if (d.getElementById(id)) {return;}      js = d.createElement(s); js.id = id;      js.src = \"https://connect.facebook.net/en_US/sdk.js\";      fjs.parentNode.insertBefore(js, fjs);    }(document, \'script\', \'facebook-jssdk\'));  </script>\r\n      		', '\r\n  			<!-- Facebook Pixel Code --> 	<script> 	  !function(f,b,e,v,n,t,s) 	  {if(f.fbq)return;n=f.fbq=function(){n.callMethod? 	  n.callMethod.apply(n,arguments):n.queue.push(arguments)}; 	  if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version=\'2.0\'; 	  n.queue=[];t=b.createElement(e);t.async=!0; 	  t.src=v;s=b.getElementsByTagName(e)[0]; 	  s.parentNode.insertBefore(t,s)}(window, document,\'script\', 	  \'https://connect.facebook.net/en_US/fbevents.js\'); 	  fbq(\'init\', \'131737410786111\'); 	  fbq(\'track\', \'PageView\'); 	</script> 	<noscript><img height=\"1\" width=\"1\" style=\"display:none\" 	  src=\"https://www.facebook.com/tr?id=149877372404434&ev=PageView&noscript=1\" 	/></noscript> <!-- End Facebook Pixel Code -->    \r\n  			', '  \r\n  				<!-- Global site tag (gtag.js) - Google Analytics --> 	<script async src=\"https://www.googletagmanager.com/gtag/js?id=UA-999999-1\"></script> 	<script> 	  window.dataLayer = window.dataLayer || []; 	  function gtag(){dataLayer.push(arguments);} 	  gtag(\'js\', new Date());  	  gtag(\'config\', \'UA-9999999-1\'); 	</script>      \r\n            \r\n            \r\n            \r\n      ', '2019-06-18 13:54:43');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `codproducto` int(11) NOT NULL,
  `Nombre` varchar(255) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `proveedor` int(11) DEFAULT NULL,
  `producto` varchar(100) NOT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `existencia` int(11) DEFAULT NULL,
  `categoria` varchar(50) NOT NULL,
  `foto` text,
  `date_add` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_id` int(11) NOT NULL,
  `estatus` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`codproducto`, `Nombre`, `descripcion`, `proveedor`, `producto`, `precio`, `existencia`, `categoria`, `foto`, `date_add`, `usuario_id`, `estatus`) VALUES
(1, '', 'Tennis', 5, 'Scootyer', '651.67', 11, 'MODA', 'https://images-na.ssl-images-amazon.com/images/I/81ApJFGzgkL._SX425_.jpg', '2019-04-18 11:34:02', 0, 1),
(2, '', 'Tennis 2 ruedas', 5, 'Tennis 2 ruedas', '135.00', 45, 'TENNIS 2 RUEDAS', 'img_producto.png', '2019-04-18 11:34:02', 0, 1),
(3, '', 'Wody Original', 12, '', '91.67', 130, '', 'img_producto.png', '2019-04-18 11:48:43', 2, 1),
(4, '', 'David carma', 2, 'David', '143.42', 91, '', 'img_producto.png', '2019-04-18 16:10:41', 1, 1),
(5, '', '  Buzzeees', 13, '', '59.61', 565, '', 'img_ed586f342bfd9730513d0cad389773f9.jpg', '2019-04-19 10:50:20', 2, 1),
(6, '', '  Milhouse', 13, '', '1.00', 515, '', 'img_producto.png', '2019-04-19 10:52:10', 2, 1),
(7, '', 'Wody de Toy Story', 13, '', '91.81', 900, '', 'img_producto.png', '2019-04-19 10:56:06', 2, 1),
(8, '', 'Iron Man', 13, '', '124.44', 4, '', 'img_863ece53d58a594e860ae4de9c92dbed.jpg', '2019-04-25 10:52:51', 2, 1),
(9, '', 'Martillo de Thor', 13, '', '19.80', 95, '', 'img_2cd5fa85bfed1d462743ac1dd2ab5c87.jpg', '2019-04-25 20:17:37', 2, 1),
(10, '', 'Thanos', 13, '', '40.00', 190, '', 'img_producto.png', '2019-04-25 20:18:48', 2, 1),
(11, '', 'BLACKWIDOW', 13, '', '9.17', 1500, '', 'img_producto.png', '2019-04-25 20:20:27', 2, 1),
(12, '', ' Martillo de Thor 2.0', 9, '', '15.00', 5, '', 'img_6f92c9c5323eb5378081a1db52346860.jpg', '2019-04-25 21:21:33', 2, 1),
(13, '', 'cjcjgkc', 7, '', '10.00', 100, '', 'img_producto.png', '2019-06-17 12:59:01', 2, 1);

--
-- Disparadores `producto`
--
DELIMITER $$
CREATE TRIGGER `entradas_A_I` AFTER INSERT ON `producto` FOR EACH ROW BEGIN
INSERT INTO entradas(codproducto, cantidad, precio , usuario_id)
VALUES(new.codproducto, new.existencia, new.precio, new.usuario_id);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id` int(11) NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `id_subcategoria` int(11) NOT NULL,
  `tipo` text COLLATE utf8_spanish_ci NOT NULL,
  `ruta` text COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL,
  `titulo` text COLLATE utf8_spanish_ci NOT NULL,
  `titular` text COLLATE utf8_spanish_ci NOT NULL,
  `descripcion` text COLLATE utf8_spanish_ci NOT NULL,
  `multimedia` text COLLATE utf8_spanish_ci NOT NULL,
  `detalles` text COLLATE utf8_spanish_ci NOT NULL,
  `precio` float NOT NULL,
  `portada` text COLLATE utf8_spanish_ci NOT NULL,
  `vistas` int(11) NOT NULL,
  `ventas` int(11) NOT NULL,
  `vistasGratis` int(11) NOT NULL,
  `ventasGratis` int(11) NOT NULL,
  `ofertadoPorCategoria` int(11) NOT NULL,
  `ofertadoPorSubCategoria` int(11) NOT NULL,
  `oferta` int(11) NOT NULL,
  `precioOferta` float NOT NULL,
  `descuentoOferta` int(11) NOT NULL,
  `imgOferta` text COLLATE utf8_spanish_ci NOT NULL,
  `finOferta` datetime NOT NULL,
  `peso` float NOT NULL,
  `entrega` float NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `id_categoria`, `id_subcategoria`, `tipo`, `ruta`, `estado`, `titulo`, `titular`, `descripcion`, `multimedia`, `detalles`, `precio`, `portada`, `vistas`, `ventas`, `vistasGratis`, `ventasGratis`, `ofertadoPorCategoria`, `ofertadoPorSubCategoria`, `oferta`, `precioOferta`, `descuentoOferta`, `imgOferta`, `finOferta`, `peso`, `entrega`, `fecha`) VALUES
(2, 6, 2, 'fisico', 'woody', 1, 'Woody', 'woody de toy story...', 'woody de toy story', '[{\"foto\":\"vistas/img/multimedia/woody/Woody_4.png\"}]', '{\"Talla\":[],\"Color\":[],\"Marca\":[\"Hasbro\"]}', 20, 'vistas/img/productos/woody.png', 1, 5, 0, 0, 0, 0, 0, 0, 0, '', '0000-00-00 00:00:00', 0, 10, '2019-06-18 15:27:23'),
(3, 6, 2, 'fisico', 'rayo-mcqueen', 1, 'Rayo Mcqueen', 'autos de cars...', 'autos de cars', '[{\"foto\":\"vistas/img/multimedia/rayo-mcqueen/00102716511957____1__640x640.jpg\"}]', '{\"Talla\":[],\"Color\":[],\"Marca\":[\"Hasbro\"]}', 25, 'vistas/img/productos/rayo-mcqueen.jpg', 20, 10, 0, 0, 0, 0, 0, 0, 0, '', '0000-00-00 00:00:00', 0, 15, '2019-06-18 15:09:56'),
(4, 4, 1, 'fisico', 'sticj', 1, 'Sticj', 'stich...', 'stich', '[{\"foto\":\"vistas/img/multimedia/sticj/stich.jpg\"}]', '{\"Talla\":[],\"Color\":[],\"Marca\":[\"Hasbro\"]}', 15, 'vistas/img/productos/sticj.jpg', 100, 50, 0, 0, 0, 0, 0, 0, 0, '', '0000-00-00 00:00:00', 0, 20, '2019-06-18 15:10:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `codproveedor` int(11) NOT NULL,
  `proveedor` varchar(100) DEFAULT NULL,
  `contacto` varchar(100) DEFAULT NULL,
  `telefono` bigint(11) DEFAULT NULL,
  `direccion` text,
  `date_add` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_id` int(11) NOT NULL,
  `estatus` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`codproveedor`, `proveedor`, `contacto`, `telefono`, `direccion`, `date_add`, `usuario_id`, `estatus`) VALUES
(1, 'BIC', 'Claudia Rosales', 78987788, 'Avenida las Americas', '2019-04-18 10:23:25', 1, 1),
(2, 'CASIO', 'Jorge Herrera', 565656565656, 'Calzada Las Flores', '2019-04-18 10:23:25', 2, 1),
(3, 'Omega', 'Julio Estrada', 982877489, 'Avenida Elena Zona 4, Guatemala', '2019-04-18 10:23:25', 2, 1),
(4, 'Dell Compani', 'Roberto Estrada', 2147483647, 'Guatemala, Guatemala', '2019-04-18 10:23:25', 1, 1),
(5, 'Olimpia S.A', 'Elena Franco Morales', 564535676, '5ta. Avenida Zona 4 Ciudad', '2019-04-18 10:23:25', 2, 1),
(6, 'Oster', 'Fernando Guerra', 78987678, 'Calzada La Paz, Guatemala', '2019-04-18 10:23:25', 2, 1),
(7, 'ACELTECSA S.A', 'Ruben PÃ©rez', 789879889, 'Colonia las Victorias', '2019-04-18 10:23:25', 2, 1),
(8, 'Sony', 'Julieta Contreras', 89476787, 'Antigua Guatemala', '2019-04-18 10:23:25', 2, 1),
(9, 'VAIO', 'Felix Arnoldo Rojas', 476378276, 'Avenida las Americas Zona 13', '2019-04-18 10:23:25', 2, 1),
(10, 'SUMAR', 'Oscar Maldonado', 788376787, 'Colonia San Jose, Zona 5 Guatemala', '2019-04-18 10:23:25', 2, 1),
(11, 'HP', 'Angel Cardona', 2147483647, '5ta. calle zona 4 Guatemala', '2019-04-18 10:23:25', 2, 1),
(12, 'Coca Cola', 'Fernando Murguia', 76587841, 'mi casa a lado de mi vecino', '2019-04-18 10:24:34', 2, 1),
(13, 'ToyHouse', 'Fernando Murguia', 745645645, 'el prado', '2019-04-19 10:27:57', 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `idrol` int(11) NOT NULL,
  `rol` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`idrol`, `rol`) VALUES
(1, 'Administrador'),
(2, 'Supervisor'),
(3, 'Vendedor');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `slide`
--

CREATE TABLE `slide` (
  `id` int(11) NOT NULL,
  `nombre` text COLLATE utf8_spanish_ci NOT NULL,
  `imgFondo` text COLLATE utf8_spanish_ci NOT NULL,
  `tipoSlide` text COLLATE utf8_spanish_ci NOT NULL,
  `imgProducto` text COLLATE utf8_spanish_ci NOT NULL,
  `estiloImgProducto` text COLLATE utf8_spanish_ci NOT NULL,
  `estiloTextoSlide` text COLLATE utf8_spanish_ci NOT NULL,
  `titulo1` text COLLATE utf8_spanish_ci NOT NULL,
  `titulo2` text COLLATE utf8_spanish_ci NOT NULL,
  `titulo3` text COLLATE utf8_spanish_ci NOT NULL,
  `boton` text COLLATE utf8_spanish_ci NOT NULL,
  `url` text COLLATE utf8_spanish_ci NOT NULL,
  `orden` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `slide`
--

INSERT INTO `slide` (`id`, `nombre`, `imgFondo`, `tipoSlide`, `imgProducto`, `estiloImgProducto`, `estiloTextoSlide`, `titulo1`, `titulo2`, `titulo3`, `boton`, `url`, `orden`, `fecha`) VALUES
(1, 'AUTO', 'vistas/img/slide/default/back_default.jpg', 'slideOpcion2', 'vistas/img/slide/slide1/producto.jpg', '{\"top\":\"5\",\"right\":\"\",\"left\":\"20\",\"width\":\"30\"}', '{\"top\":\"20\",\"right\":\"10\",\"left\":\"\",\"width\":\"40\"}', '{\"texto\":\"AUTO\",\"color\":\"#333\"}', '{\"texto\":\"CARS\",\"color\":\"#777\"}', '{\"texto\":\"Rayo mcquin\",\"color\":\"#888\"}', 'VER PRODUCTO', '#', 1, '2019-06-18 13:56:37'),
(5, 'WOODY', 'vistas/img/slide/default/fondo.jpg', 'slideOpcion1', 'vistas/img/slide/slide5/producto.png', '{\"top\":\"5\",\"right\":\"15\",\"left\":\"\",\"width\":\"20\"}', '{\"top\":\"20\",\"right\":\"\",\"left\":\"15\",\"width\":\"40\"}', '{\"texto\":\"Juguete\",\"color\":\"#333\"}', '{\"texto\":\"Toy Story\",\"color\":\"#777\"}', '{\"texto\":\"Woody\",\"color\":\"#888\"}', 'VER PRODUCTO', '#', 2, '2019-06-18 13:57:32');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subcategorias`
--

CREATE TABLE `subcategorias` (
  `id` int(11) NOT NULL,
  `subcategoria` text COLLATE utf8_spanish_ci NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `ruta` text COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL,
  `ofertadoPorCategoria` int(11) NOT NULL,
  `oferta` int(11) NOT NULL,
  `precioOferta` float NOT NULL,
  `descuentoOferta` int(11) NOT NULL,
  `imgOferta` text COLLATE utf8_spanish_ci NOT NULL,
  `finOferta` datetime NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `subcategorias`
--

INSERT INTO `subcategorias` (`id`, `subcategoria`, `id_categoria`, `ruta`, `estado`, `ofertadoPorCategoria`, `oferta`, `precioOferta`, `descuentoOferta`, `imgOferta`, `finOferta`, `fecha`) VALUES
(1, 'peluches de 1 a 5 años', 4, 'peluches-de-1-a-5-anos', 1, 0, 0, 0, 0, '', '0000-00-00 00:00:00', '2019-06-18 14:03:49'),
(2, 'autos a control remoto', 6, 'autos-a-control-remoto', 1, 0, 0, 0, 0, '', '0000-00-00 00:00:00', '2019-06-18 14:04:40'),
(3, 'pistolas de juguete', 5, 'pistolas-de-juguete', 1, 0, 0, 0, 0, '', '0000-00-00 00:00:00', '2019-06-18 19:51:22'),
(4, 'pato de hule', 7, 'pato-de-hule', 1, 0, 0, 0, 0, '', '0000-00-00 00:00:00', '2019-06-18 19:52:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbldetalleventa`
--

CREATE TABLE `tbldetalleventa` (
  `ID` int(11) NOT NULL,
  `IDVENTA` int(11) NOT NULL,
  `IDPRODUCTO` int(11) NOT NULL,
  `PRECIOUNITARIO` decimal(20,2) NOT NULL,
  `CANTIDAD` int(11) NOT NULL,
  `DESCARGADO` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tbldetalleventa`
--

INSERT INTO `tbldetalleventa` (`ID`, `IDVENTA`, `IDPRODUCTO`, `PRECIOUNITARIO`, `CANTIDAD`, `DESCARGADO`) VALUES
(1, 1, 2, '1000.00', 1, 0),
(2, 4, 2, '135.00', 1, 0),
(3, 4, 4, '143.42', 1, 0),
(4, 4, 1, '651.67', 1, 0),
(5, 5, 2, '135.00', 1, 0),
(6, 5, 4, '143.42', 1, 0),
(7, 5, 1, '651.67', 1, 0),
(8, 6, 2, '135.00', 1, 0),
(9, 6, 4, '143.42', 1, 0),
(10, 6, 1, '651.67', 1, 0),
(11, 7, 2, '135.00', 1, 0),
(12, 7, 4, '143.42', 1, 0),
(13, 7, 1, '651.67', 1, 0),
(14, 8, 2, '135.00', 1, 0),
(15, 8, 4, '143.42', 1, 0),
(16, 8, 1, '651.67', 1, 0),
(17, 9, 2, '135.00', 1, 0),
(18, 10, 2, '135.00', 1, 0),
(19, 11, 2, '135.00', 1, 0),
(20, 12, 1, '651.67', 1, 0),
(21, 13, 1, '651.67', 1, 0),
(22, 14, 1, '651.67', 1, 0),
(23, 15, 2, '135.00', 1, 0),
(24, 16, 2, '135.00', 1, 0),
(25, 17, 1, '651.67', 1, 0),
(26, 18, 1, '651.67', 1, 0),
(27, 19, 1, '651.67', 1, 0),
(28, 20, 2, '135.00', 1, 0),
(29, 21, 2, '135.00', 1, 0),
(30, 22, 2, '135.00', 1, 0),
(31, 23, 2, '135.00', 1, 0),
(32, 24, 2, '135.00', 1, 0),
(33, 25, 2, '135.00', 1, 0),
(34, 26, 2, '135.00', 1, 0),
(35, 27, 2, '135.00', 1, 0),
(36, 28, 2, '135.00', 1, 0),
(37, 29, 2, '135.00', 1, 0),
(38, 30, 2, '135.00', 1, 0),
(39, 31, 2, '135.00', 1, 0),
(40, 32, 2, '135.00', 1, 0),
(41, 33, 2, '135.00', 1, 0),
(42, 34, 2, '135.00', 1, 0),
(43, 35, 2, '135.00', 1, 0),
(44, 36, 7, '91.81', 1, 0),
(45, 37, 7, '91.81', 1, 0),
(46, 38, 7, '91.81', 1, 0),
(47, 39, 7, '91.81', 1, 0),
(48, 40, 7, '91.81', 1, 0),
(49, 41, 7, '91.81', 1, 0),
(50, 42, 7, '91.81', 1, 0),
(51, 43, 7, '91.81', 1, 0),
(52, 44, 7, '91.81', 1, 0),
(53, 45, 7, '91.81', 1, 0),
(54, 46, 7, '91.81', 1, 0),
(55, 47, 7, '91.81', 1, 0),
(56, 48, 7, '91.81', 1, 0),
(57, 49, 7, '91.81', 1, 0),
(58, 50, 7, '91.81', 1, 0),
(59, 51, 7, '91.81', 1, 0),
(60, 52, 7, '91.81', 1, 0),
(61, 53, 7, '91.81', 1, 0),
(62, 54, 7, '91.81', 1, 0),
(63, 55, 7, '91.81', 1, 0),
(64, 56, 7, '91.81', 1, 0),
(65, 57, 7, '91.81', 1, 0),
(66, 58, 7, '91.81', 1, 0),
(67, 59, 7, '91.81', 1, 0),
(68, 60, 7, '91.81', 1, 0),
(69, 61, 7, '91.81', 1, 0),
(70, 62, 7, '91.81', 1, 0),
(71, 63, 7, '91.81', 1, 0),
(72, 64, 7, '91.81', 1, 0),
(73, 65, 7, '91.81', 1, 0),
(74, 66, 7, '91.81', 1, 0),
(75, 67, 7, '91.81', 1, 0),
(76, 68, 7, '91.81', 1, 0),
(77, 69, 7, '91.81', 1, 0),
(78, 70, 7, '91.81', 1, 0),
(79, 71, 7, '91.81', 1, 0),
(80, 72, 7, '91.81', 1, 0),
(81, 73, 7, '91.81', 1, 0),
(82, 74, 7, '91.81', 1, 0),
(83, 75, 7, '91.81', 1, 0),
(84, 76, 7, '91.81', 1, 0),
(85, 77, 7, '91.81', 1, 0),
(86, 78, 7, '91.81', 1, 0),
(87, 79, 7, '91.81', 1, 0),
(88, 80, 7, '91.81', 1, 0),
(89, 81, 7, '91.81', 1, 0),
(90, 82, 7, '91.81', 1, 0),
(91, 83, 7, '91.81', 1, 0),
(92, 84, 7, '91.81', 1, 0),
(93, 85, 7, '91.81', 1, 0),
(94, 86, 7, '91.81', 1, 0),
(95, 87, 7, '91.81', 1, 0),
(96, 88, 7, '91.81', 1, 0),
(97, 89, 7, '91.81', 1, 0),
(98, 90, 7, '91.81', 1, 0),
(99, 91, 7, '91.81', 1, 0),
(100, 92, 7, '91.81', 1, 0),
(101, 93, 7, '91.81', 1, 0),
(102, 94, 7, '91.81', 1, 0),
(103, 95, 7, '91.81', 1, 0),
(104, 96, 7, '91.81', 1, 0),
(105, 97, 7, '91.81', 1, 0),
(106, 98, 7, '91.81', 1, 0),
(107, 99, 7, '91.81', 1, 0),
(108, 100, 7, '91.81', 1, 0),
(109, 101, 7, '91.81', 1, 0),
(110, 102, 7, '91.81', 1, 0),
(111, 103, 7, '91.81', 1, 0),
(112, 104, 7, '91.81', 1, 0),
(113, 105, 7, '91.81', 1, 0),
(114, 106, 7, '91.81', 1, 0),
(115, 107, 7, '91.81', 1, 0),
(116, 108, 7, '91.81', 1, 0),
(117, 109, 7, '91.81', 1, 0),
(118, 110, 7, '91.81', 1, 0),
(119, 111, 1, '651.67', 1, 0),
(120, 112, 1, '651.67', 1, 0),
(121, 113, 7, '91.81', 1, 0),
(122, 114, 7, '91.81', 1, 0),
(123, 115, 7, '91.81', 1, 0),
(124, 116, 1, '651.67', 1, 0),
(125, 117, 1, '651.67', 1, 0),
(126, 118, 1, '651.67', 1, 0),
(127, 119, 1, '651.67', 1, 0),
(128, 120, 1, '651.67', 1, 0),
(129, 121, 1, '651.67', 1, 0),
(130, 122, 7, '91.81', 1, 0),
(131, 123, 1, '651.67', 1, 0),
(132, 124, 1, '651.67', 1, 0),
(133, 125, 1, '651.67', 1, 0),
(134, 126, 1, '651.67', 1, 0),
(135, 127, 1, '651.67', 1, 0),
(136, 128, 1, '651.67', 1, 0),
(137, 129, 1, '651.67', 1, 0),
(138, 130, 1, '651.67', 1, 0),
(139, 131, 1, '651.67', 1, 0),
(140, 132, 1, '651.67', 1, 0),
(141, 133, 1, '651.67', 1, 0),
(142, 134, 1, '651.67', 1, 0),
(143, 135, 1, '651.67', 1, 0),
(144, 136, 1, '651.67', 1, 0),
(145, 137, 1, '651.67', 1, 0),
(146, 138, 1, '651.67', 1, 0),
(147, 139, 1, '651.67', 1, 0),
(148, 140, 1, '651.67', 1, 0),
(149, 141, 1, '651.67', 1, 0),
(150, 142, 1, '651.67', 1, 0),
(151, 143, 1, '651.67', 1, 0),
(152, 144, 1, '651.67', 1, 0),
(153, 145, 1, '651.67', 1, 0),
(154, 145, 2, '135.00', 1, 0),
(155, 146, 1, '651.67', 1, 0),
(156, 146, 2, '135.00', 1, 0),
(157, 147, 1, '651.67', 1, 0),
(158, 147, 2, '135.00', 1, 0),
(159, 148, 1, '651.67', 1, 0),
(160, 148, 2, '135.00', 1, 0),
(161, 148, 3, '91.67', 1, 0),
(162, 149, 1, '651.67', 1, 0),
(163, 149, 2, '135.00', 1, 0),
(164, 149, 3, '91.67', 1, 0),
(165, 150, 1, '651.67', 1, 0),
(166, 150, 2, '135.00', 1, 0),
(167, 150, 3, '91.67', 1, 0),
(168, 150, 8, '124.44', 1, 0),
(169, 151, 8, '124.44', 1, 1),
(170, 152, 8, '124.44', 1, 0),
(171, 153, 1, '651.67', 1, 1),
(172, 154, 1, '651.67', 1, 0),
(173, 154, 2, '135.00', 1, 0),
(174, 155, 1, '651.67', 1, 0),
(175, 156, 1, '651.67', 1, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblventas`
--

CREATE TABLE `tblventas` (
  `ID` int(11) NOT NULL,
  `ClaveTransaccion` varchar(250) NOT NULL,
  `PaypalDatos` text NOT NULL,
  `Fecha` datetime NOT NULL,
  `Correo` varchar(5000) NOT NULL,
  `Total` decimal(60,2) NOT NULL,
  `status` varchar(200) NOT NULL,
  `estado` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tblventas`
--

INSERT INTO `tblventas` (`ID`, `ClaveTransaccion`, `PaypalDatos`, `Fecha`, `Correo`, `Total`, `status`, `estado`) VALUES
(1, '123', '', '2019-06-13 23:21:16', 'fmurguia12@gmail.com', '700.00', 'pendiente', 1),
(2, '123', '', '2019-06-13 23:23:58', 'fmurguia12@gmail.com', '700.00', 'pendiente', 1),
(3, 'q10sjjdrqal9usmh57umr0l3o3', '', '2019-06-13 23:33:49', 'fmurguia12@gmail.com', '930.09', 'pendiente', 1),
(4, 'q10sjjdrqal9usmh57umr0l3o3', '', '2019-06-13 23:57:34', 'jcarlos.ad7@gmail.com', '930.09', 'pendiente', 1),
(5, 'q10sjjdrqal9usmh57umr0l3o3', '', '2019-06-14 00:05:02', 'david@david.com', '930.09', 'pendiente', 1),
(6, 'q10sjjdrqal9usmh57umr0l3o3', '', '2019-06-14 00:05:19', 'david@david.com', '930.09', 'pendiente', 1),
(7, 'q10sjjdrqal9usmh57umr0l3o3', '', '2019-06-14 00:05:35', 'david@david.com', '930.09', 'pendiente', 1),
(8, 'q10sjjdrqal9usmh57umr0l3o3', '', '2019-06-14 00:06:21', 'david@david.com', '930.09', 'pendiente', 1),
(9, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 10:44:04', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(10, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 10:45:12', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(11, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 10:55:37', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(12, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-14 10:56:05', 'mariano@gmail.com', '651.67', 'pendiente', 1),
(13, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-14 11:07:01', 'mariano@gmail.com', '651.67', 'pendiente', 1),
(14, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-14 11:07:09', 'mariano@gmail.com', '651.67', 'pendiente', 1),
(15, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:14:45', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(16, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:14:52', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(17, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-14 11:36:20', 'nakjsdnv@sgad.com', '651.67', 'pendiente', 1),
(18, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-14 11:37:09', 'nakjsdnv@sgad.com', '651.67', 'pendiente', 1),
(19, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-14 11:37:36', 'nakjsdnv@sgad.com', '651.67', 'pendiente', 1),
(20, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:37:45', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(21, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:37:47', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(22, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:40', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(23, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:41', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(24, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:42', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(25, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:42', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(26, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:43', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(27, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:43', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(28, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:43', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(29, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:43', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(30, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:43', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(31, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:44', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(32, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:44', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(33, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:44', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(34, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:44', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(35, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:38:44', 'jcarlos.ad7@gmail.com', '135.00', 'pendiente', 1),
(36, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:39:01', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(37, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:39:15', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(38, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:39:17', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(39, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:39:18', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(40, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:39:33', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(41, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:39:34', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(42, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:08', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(43, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:09', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(44, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:10', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(45, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:11', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(46, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:11', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(47, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:12', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(48, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:12', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(49, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:13', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(50, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:13', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(51, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:13', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(52, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:13', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(53, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:13', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(54, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:14', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(55, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:14', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(56, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:14', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(57, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:14', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(58, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:15', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(59, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:15', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(60, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:30', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(61, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:32', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(62, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:43', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(63, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:44', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(64, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:44', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(65, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:45', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(66, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:45', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(67, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:45', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(68, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:45', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(69, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:45', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(70, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:45', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(71, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:46', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(72, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:46', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(73, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:46', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(74, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:46', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(75, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:47', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(76, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:47', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(77, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:47', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(78, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:47', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(79, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:47', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(80, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:47', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(81, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:47', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(82, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:48', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(83, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:48', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(84, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:48', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(85, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:48', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(86, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:48', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(87, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:49', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(88, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:49', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(89, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:49', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(90, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:49', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(91, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:49', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(92, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:49', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(93, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:50', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(94, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:50', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(95, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:50', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(96, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:50', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(97, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:50', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(98, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:51', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(99, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:51', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(100, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:51', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(101, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:52', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(102, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:52', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(103, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:52', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(104, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:41:52', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(105, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:43:30', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(106, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:43:31', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(107, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:43:32', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(108, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:43:32', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(109, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:43:32', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(110, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:43:32', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(111, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-14 11:43:41', 'nakjsdnv@sgad.com', '651.67', 'pendiente', 1),
(112, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-14 11:44:00', 'nakjsdnv@sgad.com', '651.67', 'pendiente', 1),
(113, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-14 11:49:03', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(114, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-15 13:03:25', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(115, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-15 13:10:17', 'fdavid@gmail.com', '91.81', 'pendiente', 1),
(116, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-15 13:11:40', 'murguia12@gmail.com', '651.67', 'pendiente', 1),
(117, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-15 13:13:28', 'fmurguia12@gmail.com', '651.67', 'pendiente', 1),
(118, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-15 13:14:58', 'fmurguia12-facilitator@gmail.com', '651.67', 'pendiente', 1),
(119, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-15 13:16:13', 'fmurguia12-facilitator@gmail.com', '651.67', 'pendiente', 1),
(120, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-15 13:20:42', 'fmurguia12-facilitator@gmail.com', '651.67', 'pendiente', 1),
(121, 'ulh1osip3e9vgtqoft2k0795in', '', '2019-06-15 13:24:35', 'fmurguia12@gmail.com', '651.67', 'pendiente', 1),
(122, '23v4cq08nj8n239gt713g3cnrf', '', '2019-06-15 13:25:19', 'fmurguia12@gmail.com', '91.81', 'pendiente', 1),
(123, 'ogghocoggbbd71uboltujslh4s', '', '2019-06-16 11:30:08', 'jcarlos.ad7@gmail.com', '651.67', 'completo', 1),
(124, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:30:54', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(125, 'u6ns70gp5jrobn5k56gkfmq6jp', '', '2019-06-16 11:31:29', 'fmurguia12@gmail.com', '651.67', 'pendiente', 1),
(126, 'u6ns70gp5jrobn5k56gkfmq6jp', '', '2019-06-16 11:31:49', 'fmurguia12@gmail.com', '651.67', 'pendiente', 1),
(127, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:33:11', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(128, 'ogghocoggbbd71uboltujslh4s', '', '2019-06-16 11:34:33', 'jcarlos.ad7@gmail.com', '651.67', 'completo', 1),
(129, 'ogghocoggbbd71uboltujslh4s', '', '2019-06-16 11:34:55', 'jcarlos.ad7@gmail.com', '651.67', 'completo', 1),
(130, 'ogghocoggbbd71uboltujslh4s', '', '2019-06-16 11:36:56', 'jcarlos.ad7@gmail.com', '651.67', 'completo', 1),
(131, 'ogghocoggbbd71uboltujslh4s', '', '2019-06-16 11:37:17', 'jcarlos.ad7@gmail.com', '651.67', 'completo', 1),
(132, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:37:54', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(133, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:38:55', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(134, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:39:16', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(135, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:45:23', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(136, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:52:22', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(137, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:53:37', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(138, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:54:29', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(139, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:54:45', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(140, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:54:59', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(141, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 11:57:23', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(142, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 12:01:36', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(143, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 12:23:31', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(144, 'ogghocoggbbd71uboltujslh4s', '', '2019-06-16 12:26:39', 'jcarlos.ad7@gmail.com', '651.67', 'completo', 1),
(145, 'ogghocoggbbd71uboltujslh4s', '{\"id\":\"PAYID-LUDG4FI6AN0248426750580T\",\"intent\":\"sale\",\"state\":\"approved\",\"cart\":\"9XN79016FM6156900\",\"payer\":{\"payment_method\":\"paypal\",\"status\":\"VERIFIED\",\"payer_info\":{\"email\":\"fmurguia12-buyer@gmail.com\",\"first_name\":\"test\",\"last_name\":\"buyer\",\"payer_id\":\"3LFWWNJWXQ4G8\",\"shipping_address\":{\"recipient_name\":\"test buyer\",\"line1\":\"calle Vilamarï¿½ 76993- 17469\",\"city\":\"Albacete\",\"state\":\"Albacete\",\"postal_code\":\"02001\",\"country_code\":\"ES\"},\"phone\":\"9062611439\",\"country_code\":\"ES\"}},\"transactions\":[{\"amount\":{\"total\":\"786.67\",\"currency\":\"MXN\",\"details\":{\"subtotal\":\"786.67\",\"shipping\":\"0.00\",\"insurance\":\"0.00\",\"handling_fee\":\"0.00\",\"shipping_discount\":\"0.00\"}},\"payee\":{\"merchant_id\":\"4AQ2CKAHC39L6\",\"email\":\"fmurguia12-facilitator@gmail.com\"},\"description\":\"Compra de productos a Sellcorp:Bs786.67\",\"custom\":\"ogghocoggbbd71uboltujslh4s#09YG+xUp9AQWJ4hX92F7+w==\",\"item_list\":{\"shipping_address\":{\"recipient_name\":\"test buyer\",\"line1\":\"calle Vilamarï¿½ 76993- 17469\",\"city\":\"Albacete\",\"state\":\"Albacete\",\"postal_code\":\"02001\",\"country_code\":\"ES\"}},\"related_resources\":[{\"sale\":{\"id\":\"40L40065F1729630R\",\"state\":\"pending\",\"amount\":{\"total\":\"786.67\",\"currency\":\"MXN\",\"details\":{\"subtotal\":\"786.67\",\"shipping\":\"0.00\",\"insurance\":\"0.00\",\"handling_fee\":\"0.00\",\"shipping_discount\":\"0.00\"}},\"payment_mode\":\"INSTANT_TRANSFER\",\"reason_code\":\"RECEIVING_PREFERENCE_MANDATES_MANUAL_ACTION\",\"protection_eligibility\":\"ELIGIBLE\",\"protection_eligibility_type\":\"ITEM_NOT_RECEIVED_ELIGIBLE,UNAUTHORIZED_PAYMENT_ELIGIBLE\",\"receivable_amount\":{\"value\":\"786.67\",\"currency\":\"MXN\"},\"exchange_rate\":\"21.30602113214266\",\"parent_payment\":\"PAYID-LUDG4FI6AN0248426750580T\",\"create_time\":\"2019-06-16T16:29:14Z\",\"update_time\":\"2019-06-16T16:29:14Z\",\"links\":[{\"href\":\"https://api.sandbox.paypal.com/v1/payments/sale/40L40065F1729630R\",\"rel\":\"self\",\"method\":\"GET\"},{\"href\":\"https://api.sandbox.paypal.com/v1/payments/sale/40L40065F1729630R/refund\",\"rel\":\"refund\",\"method\":\"POST\"},{\"href\":\"https://api.sandbox.paypal.com/v1/payments/payment/PAYID-LUDG4FI6AN0248426750580T\",\"rel\":\"parent_payment\",\"method\":\"GET\"}]}}]}],\"create_time\":\"2019-06-16T16:28:05Z\",\"update_time\":\"2019-06-16T16:29:14Z\",\"links\":[{\"href\":\"https://api.sandbox.paypal.com/v1/payments/payment/PAYID-LUDG4FI6AN0248426750580T\",\"rel\":\"self\",\"method\":\"GET\"}]}', '2019-06-16 12:26:54', 'david@david.com', '786.67', 'completo', 1),
(146, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 12:34:45', 'sellcorp@gmail.com', '786.67', 'completo', 1),
(147, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 13:13:14', 'omo@gmail.com', '786.67', 'completo', 1),
(148, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 13:14:21', 'anuel@gmail.com', '878.34', 'completo', 1),
(149, '4hqekjhh5tssdfduipm4vqqdnp', '', '2019-06-16 13:14:56', 'anuel@gmail.com', '878.34', 'completo', 1),
(150, '4hqekjhh5tssdfduipm4vqqdnp', '{\"id\":\"PAYID-LUDHTVA2L583805VK084552M\",\"intent\":\"sale\",\"state\":\"approved\",\"cart\":\"5B301762JJ5093709\",\"payer\":{\"payment_method\":\"paypal\",\"status\":\"VERIFIED\",\"payer_info\":{\"email\":\"fmurguia12-buyer@gmail.com\",\"first_name\":\"test\",\"last_name\":\"buyer\",\"payer_id\":\"3LFWWNJWXQ4G8\",\"shipping_address\":{\"recipient_name\":\"test buyer\",\"line1\":\"calle Vilamarï¿½ 76993- 17469\",\"city\":\"Albacete\",\"state\":\"Albacete\",\"postal_code\":\"02001\",\"country_code\":\"ES\"},\"phone\":\"9062611439\",\"country_code\":\"ES\"}},\"transactions\":[{\"amount\":{\"total\":\"1002.78\",\"currency\":\"MXN\",\"details\":{\"subtotal\":\"1002.78\",\"shipping\":\"0.00\",\"insurance\":\"0.00\",\"handling_fee\":\"0.00\",\"shipping_discount\":\"0.00\"}},\"payee\":{\"merchant_id\":\"4AQ2CKAHC39L6\",\"email\":\"fmurguia12-facilitator@gmail.com\"},\"description\":\"Compra de productos a Sellcorp:Bs1,002.78\",\"custom\":\"4hqekjhh5tssdfduipm4vqqdnp#o2QLtvmsDEHUVEaTjx7txA==\",\"item_list\":{\"shipping_address\":{\"recipient_name\":\"test buyer\",\"line1\":\"calle Vilamarï¿½ 76993- 17469\",\"city\":\"Albacete\",\"state\":\"Albacete\",\"postal_code\":\"02001\",\"country_code\":\"ES\"}},\"related_resources\":[{\"sale\":{\"id\":\"86H5474393852931S\",\"state\":\"pending\",\"amount\":{\"total\":\"1002.78\",\"currency\":\"MXN\",\"details\":{\"subtotal\":\"1002.78\",\"shipping\":\"0.00\",\"insurance\":\"0.00\",\"handling_fee\":\"0.00\",\"shipping_discount\":\"0.00\"}},\"payment_mode\":\"INSTANT_TRANSFER\",\"reason_code\":\"RECEIVING_PREFERENCE_MANDATES_MANUAL_ACTION\",\"protection_eligibility\":\"ELIGIBLE\",\"protection_eligibility_type\":\"ITEM_NOT_RECEIVED_ELIGIBLE,UNAUTHORIZED_PAYMENT_ELIGIBLE\",\"receivable_amount\":{\"value\":\"1002.78\",\"currency\":\"MXN\"},\"exchange_rate\":\"21.30602113214266\",\"parent_payment\":\"PAYID-LUDHTVA2L583805VK084552M\",\"create_time\":\"2019-06-16T17:19:24Z\",\"update_time\":\"2019-06-16T17:19:24Z\",\"links\":[{\"href\":\"https://api.sandbox.paypal.com/v1/payments/sale/86H5474393852931S\",\"rel\":\"self\",\"method\":\"GET\"},{\"href\":\"https://api.sandbox.paypal.com/v1/payments/sale/86H5474393852931S/refund\",\"rel\":\"refund\",\"method\":\"POST\"},{\"href\":\"https://api.sandbox.paypal.com/v1/payments/payment/PAYID-LUDHTVA2L583805VK084552M\",\"rel\":\"parent_payment\",\"method\":\"GET\"}]}}]}],\"create_time\":\"2019-06-16T17:18:12Z\",\"update_time\":\"2019-06-16T17:19:24Z\",\"links\":[{\"href\":\"https://api.sandbox.paypal.com/v1/payments/payment/PAYID-LUDHTVA2L583805VK084552M\",\"rel\":\"self\",\"method\":\"GET\"}]}', '2019-06-16 13:16:57', 'sellcorp@gmail.com', '1002.78', 'completo', 1),
(151, 'rbd3clnre0raln8vqmrp16g3i7', '{\"id\":\"PAYID-LUDZMLA1YN4079299798342G\",\"intent\":\"sale\",\"state\":\"approved\",\"cart\":\"9VE82744TS2253107\",\"payer\":{\"payment_method\":\"paypal\",\"status\":\"VERIFIED\",\"payer_info\":{\"email\":\"fmurguia12-buyer@gmail.com\",\"first_name\":\"test\",\"last_name\":\"buyer\",\"payer_id\":\"3LFWWNJWXQ4G8\",\"shipping_address\":{\"recipient_name\":\"test buyer\",\"line1\":\"calle Vilamarï¿½ 76993- 17469\",\"city\":\"Albacete\",\"state\":\"Albacete\",\"postal_code\":\"02001\",\"country_code\":\"ES\"},\"phone\":\"9062611439\",\"country_code\":\"ES\"}},\"transactions\":[{\"amount\":{\"total\":\"124.44\",\"currency\":\"MXN\",\"details\":{\"subtotal\":\"124.44\",\"shipping\":\"0.00\",\"insurance\":\"0.00\",\"handling_fee\":\"0.00\",\"shipping_discount\":\"0.00\"}},\"payee\":{\"merchant_id\":\"4AQ2CKAHC39L6\",\"email\":\"fmurguia12-facilitator@gmail.com\"},\"description\":\"Compra de productos a Sellcorp:Bs124.44\",\"custom\":\"rbd3clnre0raln8vqmrp16g3i7#JcSpaOqEwPPVRndmnfCOCw==\",\"item_list\":{\"shipping_address\":{\"recipient_name\":\"test buyer\",\"line1\":\"calle Vilamarï¿½ 76993- 17469\",\"city\":\"Albacete\",\"state\":\"Albacete\",\"postal_code\":\"02001\",\"country_code\":\"ES\"}},\"related_resources\":[{\"sale\":{\"id\":\"38D833612D962233Y\",\"state\":\"pending\",\"amount\":{\"total\":\"124.44\",\"currency\":\"MXN\",\"details\":{\"subtotal\":\"124.44\",\"shipping\":\"0.00\",\"insurance\":\"0.00\",\"handling_fee\":\"0.00\",\"shipping_discount\":\"0.00\"}},\"payment_mode\":\"INSTANT_TRANSFER\",\"reason_code\":\"RECEIVING_PREFERENCE_MANDATES_MANUAL_ACTION\",\"protection_eligibility\":\"ELIGIBLE\",\"protection_eligibility_type\":\"ITEM_NOT_RECEIVED_ELIGIBLE,UNAUTHORIZED_PAYMENT_ELIGIBLE\",\"receivable_amount\":{\"value\":\"124.44\",\"currency\":\"MXN\"},\"exchange_rate\":\"21.30602113214266\",\"parent_payment\":\"PAYID-LUDZMLA1YN4079299798342G\",\"create_time\":\"2019-06-17T13:32:00Z\",\"update_time\":\"2019-06-17T13:32:00Z\",\"links\":[{\"href\":\"https://api.sandbox.paypal.com/v1/payments/sale/38D833612D962233Y\",\"rel\":\"self\",\"method\":\"GET\"},{\"href\":\"https://api.sandbox.paypal.com/v1/payments/sale/38D833612D962233Y/refund\",\"rel\":\"refund\",\"method\":\"POST\"},{\"href\":\"https://api.sandbox.paypal.com/v1/payments/payment/PAYID-LUDZMLA1YN4079299798342G\",\"rel\":\"parent_payment\",\"method\":\"GET\"}]}}]}],\"create_time\":\"2019-06-17T13:31:24Z\",\"update_time\":\"2019-06-17T13:32:00Z\",\"links\":[{\"href\":\"https://api.sandbox.paypal.com/v1/payments/payment/PAYID-LUDZMLA1YN4079299798342G\",\"rel\":\"self\",\"method\":\"GET\"}]}', '2019-06-17 09:29:58', 'fmurguia12@gmail.com', '124.44', 'completo', 1),
(152, 'gfa3dnnvv6bmdc7dn8s4m213kk', '{\"id\":\"PAYID-LUDZY2A7JW65579LM534511V\",\"intent\":\"sale\",\"state\":\"approved\",\"cart\":\"5BW93119WD027022S\",\"payer\":{\"payment_method\":\"paypal\",\"status\":\"VERIFIED\",\"payer_info\":{\"email\":\"fmurguia12-buyer@gmail.com\",\"first_name\":\"test\",\"last_name\":\"buyer\",\"payer_id\":\"3LFWWNJWXQ4G8\",\"shipping_address\":{\"recipient_name\":\"test buyer\",\"line1\":\"calle Vilamarï¿½ 76993- 17469\",\"city\":\"Albacete\",\"state\":\"Albacete\",\"postal_code\":\"02001\",\"country_code\":\"ES\"},\"phone\":\"9062611439\",\"country_code\":\"ES\"}},\"transactions\":[{\"amount\":{\"total\":\"124.44\",\"currency\":\"MXN\",\"details\":{\"subtotal\":\"124.44\",\"shipping\":\"0.00\",\"insurance\":\"0.00\",\"handling_fee\":\"0.00\",\"shipping_discount\":\"0.00\"}},\"payee\":{\"merchant_id\":\"4AQ2CKAHC39L6\",\"email\":\"fmurguia12-facilitator@gmail.com\"},\"description\":\"Compra de productos a Sellcorp:Bs124.44\",\"custom\":\"gfa3dnnvv6bmdc7dn8s4m213kk#IkpM7e/J0Mgck53/TOJRLQ==\",\"item_list\":{\"shipping_address\":{\"recipient_name\":\"test buyer\",\"line1\":\"calle Vilamarï¿½ 76993- 17469\",\"city\":\"Albacete\",\"state\":\"Albacete\",\"postal_code\":\"02001\",\"country_code\":\"ES\"}},\"related_resources\":[{\"sale\":{\"id\":\"1YC881565K3718131\",\"state\":\"pending\",\"amount\":{\"total\":\"124.44\",\"currency\":\"MXN\",\"details\":{\"subtotal\":\"124.44\",\"shipping\":\"0.00\",\"insurance\":\"0.00\",\"handling_fee\":\"0.00\",\"shipping_discount\":\"0.00\"}},\"payment_mode\":\"INSTANT_TRANSFER\",\"reason_code\":\"RECEIVING_PREFERENCE_MANDATES_MANUAL_ACTION\",\"protection_eligibility\":\"ELIGIBLE\",\"protection_eligibility_type\":\"ITEM_NOT_RECEIVED_ELIGIBLE,UNAUTHORIZED_PAYMENT_ELIGIBLE\",\"receivable_amount\":{\"value\":\"124.44\",\"currency\":\"MXN\"},\"exchange_rate\":\"21.30602113214266\",\"parent_payment\":\"PAYID-LUDZY2A7JW65579LM534511V\",\"create_time\":\"2019-06-17T13:58:48Z\",\"update_time\":\"2019-06-17T13:58:48Z\",\"links\":[{\"href\":\"https://api.sandbox.paypal.com/v1/payments/sale/1YC881565K3718131\",\"rel\":\"self\",\"method\":\"GET\"},{\"href\":\"https://api.sandbox.paypal.com/v1/payments/sale/1YC881565K3718131/refund\",\"rel\":\"refund\",\"method\":\"POST\"},{\"href\":\"https://api.sandbox.paypal.com/v1/payments/payment/PAYID-LUDZY2A7JW65579LM534511V\",\"rel\":\"parent_payment\",\"method\":\"GET\"}]}}]}],\"create_time\":\"2019-06-17T13:58:00Z\",\"update_time\":\"2019-06-17T13:58:48Z\",\"links\":[{\"href\":\"https://api.sandbox.paypal.com/v1/payments/payment/PAYID-LUDZY2A7JW65579LM534511V\",\"rel\":\"self\",\"method\":\"GET\"}]}', '2019-06-17 09:56:47', 'sellcorp@gmail.com', '124.44', 'completo', 1),
(153, 'h0npnsids17faphdfd5hhrq10s', '{\"id\":\"PAYID-LUD2H4I2L6045808M6923036\",\"intent\":\"sale\",\"state\":\"approved\",\"cart\":\"5E250516AT849622W\",\"payer\":{\"payment_method\":\"paypal\",\"status\":\"VERIFIED\",\"payer_info\":{\"email\":\"fmurguia12-buyer@gmail.com\",\"first_name\":\"test\",\"last_name\":\"buyer\",\"payer_id\":\"3LFWWNJWXQ4G8\",\"shipping_address\":{\"recipient_name\":\"test buyer\",\"line1\":\"calle Vilamarï¿½ 76993- 17469\",\"city\":\"Albacete\",\"state\":\"Albacete\",\"postal_code\":\"02001\",\"country_code\":\"ES\"},\"phone\":\"9062611439\",\"country_code\":\"ES\"}},\"transactions\":[{\"amount\":{\"total\":\"651.67\",\"currency\":\"MXN\",\"details\":{\"subtotal\":\"651.67\",\"shipping\":\"0.00\",\"insurance\":\"0.00\",\"handling_fee\":\"0.00\",\"shipping_discount\":\"0.00\"}},\"payee\":{\"merchant_id\":\"4AQ2CKAHC39L6\",\"email\":\"fmurguia12-facilitator@gmail.com\"},\"description\":\"Compra de productos a Sellcorp:Bs651.67\",\"custom\":\"h0npnsids17faphdfd5hhrq10s#ERmBkfsT+HFphSvoQMoc6g==\",\"item_list\":{\"shipping_address\":{\"recipient_name\":\"test buyer\",\"line1\":\"calle Vilamarï¿½ 76993- 17469\",\"city\":\"Albacete\",\"state\":\"Albacete\",\"postal_code\":\"02001\",\"country_code\":\"ES\"}},\"related_resources\":[{\"sale\":{\"id\":\"17391674ND6897027\",\"state\":\"pending\",\"amount\":{\"total\":\"651.67\",\"currency\":\"MXN\",\"details\":{\"subtotal\":\"651.67\",\"shipping\":\"0.00\",\"insurance\":\"0.00\",\"handling_fee\":\"0.00\",\"shipping_discount\":\"0.00\"}},\"payment_mode\":\"INSTANT_TRANSFER\",\"reason_code\":\"RECEIVING_PREFERENCE_MANDATES_MANUAL_ACTION\",\"protection_eligibility\":\"ELIGIBLE\",\"protection_eligibility_type\":\"ITEM_NOT_RECEIVED_ELIGIBLE,UNAUTHORIZED_PAYMENT_ELIGIBLE\",\"receivable_amount\":{\"value\":\"651.67\",\"currency\":\"MXN\"},\"exchange_rate\":\"21.30602113214266\",\"parent_payment\":\"PAYID-LUD2H4I2L6045808M6923036\",\"create_time\":\"2019-06-17T14:31:16Z\",\"update_time\":\"2019-06-17T14:31:16Z\",\"links\":[{\"href\":\"https://api.sandbox.paypal.com/v1/payments/sale/17391674ND6897027\",\"rel\":\"self\",\"method\":\"GET\"},{\"href\":\"https://api.sandbox.paypal.com/v1/payments/sale/17391674ND6897027/refund\",\"rel\":\"refund\",\"method\":\"POST\"},{\"href\":\"https://api.sandbox.paypal.com/v1/payments/payment/PAYID-LUD2H4I2L6045808M6923036\",\"rel\":\"parent_payment\",\"method\":\"GET\"}]}}]}],\"create_time\":\"2019-06-17T14:30:09Z\",\"update_time\":\"2019-06-17T14:31:16Z\",\"links\":[{\"href\":\"https://api.sandbox.paypal.com/v1/payments/payment/PAYID-LUD2H4I2L6045808M6923036\",\"rel\":\"self\",\"method\":\"GET\"}]}', '2019-06-17 10:28:55', 'sellcorp@gmail.com', '651.67', 'completo', 1),
(154, 'h0npnsids17faphdfd5hhrq10s', '', '2019-06-17 12:48:45', 'yadfaf@fjghcg.com', '786.67', 'pendiente', 1),
(155, 'rbd3clnre0raln8vqmrp16g3i7', '', '2019-06-17 13:49:28', 'jcarlos.ad7@gmail.com', '651.67', 'pendiente', 1),
(156, 'rbd3clnre0raln8vqmrp16g3i7', '', '2019-06-17 13:58:08', 'jcarlos.ad7@gmail.com', '651.67', 'pendiente', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_categorias`
--

CREATE TABLE `tbl_categorias` (
  `id_cat` int(11) NOT NULL,
  `nom_cat` varchar(100) NOT NULL,
  `img_cat` varchar(200) NOT NULL,
  `st_cat` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tbl_categorias`
--

INSERT INTO `tbl_categorias` (`id_cat`, `nom_cat`, `img_cat`, `st_cat`) VALUES
(1, 'Juguetes para bebe', '', 1),
(2, 'Peluches', '', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_publico`
--

CREATE TABLE `user_publico` (
  `id` int(10) NOT NULL,
  `clave` varchar(100) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `foto` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `user_publico`
--

INSERT INTO `user_publico` (`id`, `clave`, `nombre`, `correo`, `foto`) VALUES
(1, 'e02b5e50ee3d07f2fb68c0b4857418495f7d5206', 'David Pinto Saavedra', 'davico_2999@hotmail.com', 'https://graph.facebook.com/1936559513120717/picture&oe='),
(2, '3587e04f34e392b57b50e880e077bae2b116d5ed', 'David Alejandro Pinto Saavedra', 'aledavid54321@gmail.com', 'https://lh6.googleusercontent.com/-deRwNwzJfEk/AAAAAAAAAAI/AAAAAAAAADc/WsI9zN7Yjc8/photo.jpg');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idusuario` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `usuario` varchar(15) DEFAULT NULL,
  `clave` varchar(100) DEFAULT NULL,
  `rol` int(11) DEFAULT NULL,
  `fotografia_usuario` varchar(500) NOT NULL,
  `estatus` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idusuario`, `nombre`, `correo`, `usuario`, `clave`, `rol`, `fotografia_usuario`, `estatus`) VALUES
(1, 'David', 'david@david.com', 'David', '123', 2, 'https://scontent.flpb3-1.fna.fbcdn.net/v/t1.0-9/33127449_1522333847876621_7942514296997543936_n.jpg?_nc_cat=102&_nc_ht=scontent.flpb3-1.fna&oh=cd5c7b7b4c2713637beb30ab3cad18cf&oe=5D3BEC7F', 1),
(2, 'Fernando', 'fernando@fernando.com', 'Fernando1', '456', 1, '', 1),
(6, 'Cristhian', 'cristhian@cristhian.com', 'Cristhian', '456', 1, '', 1),
(7, 'Mariano Pinto', 'mariano@gmail.com', 'Mariano', '123', 1, '', 1),
(8, 'Maria Pinto', 'maria@gmail.com', 'maria', 'maria', 3, '', 1),
(9, 'Alejandro Pinto', 'ale@gmail.com', 'Ale', 'ale', 3, '', 1),
(10, 'Ivan Pinto', 'ivan@gmail.com', 'ivan', 'ivan', 3, '', 1),
(11, 'Juan Pinto', 'juanito@gmail.com', 'juan', 'juan', 3, '', 1),
(12, 'Pinto Pinto', 'pinto@gmail.com', 'pinto', 'pinto', 3, '', 1),
(13, 'Mariana Pinto', 'mariana@hotmail.com', 'mariana', 'mariana', 3, '', 1),
(14, 'Michelle Pinto', 'Michelle@gmail.com', 'michelle', 'michelle', 1, '', 1),
(15, 'Cualquiera20', 'cualquiera@hotmail.com', 'Alguien', 'cualquiera', 1, '', 1),
(16, 'David', 'david@gmail.com', '123', '123', 1, '', 1),
(17, 'asd', 'asd@gmail.com', 'asd', 'asd', 1, '', 1),
(18, 'asdasd', 'asd@asd.com', 'asd1', '123', 1, '', 1),
(19, 'Ingeniera Moller', 'moller@gmail.com', 'Moller', 'Moller', 1, '', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombre` text COLLATE utf8_spanish_ci NOT NULL,
  `password` text COLLATE utf8_spanish_ci NOT NULL,
  `email` text COLLATE utf8_spanish_ci NOT NULL,
  `modo` text COLLATE utf8_spanish_ci NOT NULL,
  `foto` text COLLATE utf8_spanish_ci NOT NULL,
  `verificacion` int(11) NOT NULL,
  `emailEncriptado` text COLLATE utf8_spanish_ci NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `password`, `email`, `modo`, `foto`, `verificacion`, `emailEncriptado`, `fecha`) VALUES
(2, 'Francisco gomez', '$2a$07$asxx54ahjppf45sd87a5auxq/SS293XhTEeizKWMnfhnpfay0AALe', 'pepe@gmail.com', 'directo', '', 0, '6b0becddecd5a06042b3f8078c97f2e0', '2018-03-27 15:55:09'),
(3, 'Juan Fernando Urrego Alvarez', 'null', 'juanustudio@hotmail.com', 'facebook', 'http://graph.facebook.com/10215085853809464/picture?type=large', 0, 'null', '2017-10-27 15:55:12'),
(5, 'Juan Fernando Urrego Alvarez', 'null', 'contacto@juanfernandourrego.com', 'google', 'https://lh4.googleusercontent.com/-2UURMoPtS5Q/AAAAAAAAAAI/AAAAAAAAAAA/AFiYof1_ZJSXsDExO9Jd1-5p1-4rjp2x4w/s96-c/photo.jpg', 0, 'null', '2017-12-13 16:53:03'),
(6, 'Juan Fernando Urrego Alvarez', 'null', 'juanu@misena.edu.co', 'google', 'https://lh6.googleusercontent.com/-WRzOjXfAxp4/AAAAAAAAAAI/AAAAAAAAAAA/AFiYof31C6gB0EtqvVjoLv7yszCM_j2Udg/s96-c/photo.jpg', 0, 'null', '2017-12-13 16:54:00'),
(12, 'juanito perez', '$2a$07$asxx54ahjppf45sd87a5auptO89Bfb9XuXeaqzpkZhWf7pRyzngoO', 'juanito@gmail.com', 'directo', '', 0, 'c19e7e7da901025911234b21b7002143', '2018-03-27 23:08:38'),
(13, 'david pinto', '$2a$07$asxx54ahjppf45sd87a5auY00k1u8xuSPBVWyPyNbI1/Yjo0Ydzra', 'david@gmail.com', 'directo', '', 0, 'f3c52e5ef3d2b471d0ef51c66c21d10c', '2019-06-18 06:00:17');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `visitaspaises`
--

CREATE TABLE `visitaspaises` (
  `id` int(11) NOT NULL,
  `pais` text COLLATE utf8_spanish_ci NOT NULL,
  `codigo` text COLLATE utf8_spanish_ci NOT NULL,
  `cantidad` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `visitaspaises`
--

INSERT INTO `visitaspaises` (`id`, `pais`, `codigo`, `cantidad`, `fecha`) VALUES
(1, 'United States', 'US', 2, '2017-12-05 21:02:46'),
(2, 'Japan', 'JP', 65, '2018-03-27 13:26:30'),
(3, 'Spain', 'ES', 10, '2017-12-05 21:02:53'),
(4, 'Colombia', 'CO', 5, '2017-12-05 21:02:55'),
(5, 'China', 'CN', 3, '2017-12-05 21:04:32'),
(6, 'Germany', 'DE', 34, '2017-12-05 21:04:39'),
(7, 'Mexico', 'MX', 8, '2017-12-05 21:04:41');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `visitaspersonas`
--

CREATE TABLE `visitaspersonas` (
  `id` int(11) NOT NULL,
  `ip` text COLLATE utf8_spanish_ci NOT NULL,
  `pais` text COLLATE utf8_spanish_ci NOT NULL,
  `visitas` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `visitaspersonas`
--

INSERT INTO `visitaspersonas` (`id`, `ip`, `pais`, `visitas`, `fecha`) VALUES
(1, '153.202.197.216', 'Japan', 1, '2017-11-08 18:37:07'),
(3, '249.170.168.184', 'Spain', 1, '2017-11-28 19:16:16'),
(5, '249.170.168.184', 'Spain', 1, '2017-11-28 19:16:19'),
(6, '234.13.198.119', 'Colombia', 1, '2017-11-28 19:16:03'),
(7, '141.46.61.241', 'Germany', 1, '2017-11-28 19:13:45'),
(8, '40.179.75.60', 'United States', 1, '2017-11-28 19:14:05'),
(9, '153.205.198.22', 'Japan', 1, '2017-11-01 19:14:18'),
(10, '148.21.177.158', 'United States', 1, '2017-10-28 19:14:34'),
(11, '40.224.125.226', 'United States', 1, '2017-11-28 19:14:56'),
(12, '10.98.135.68', 'China', 1, '2017-11-28 19:15:57'),
(13, '23.121.157.131', 'United States', 1, '2017-11-28 19:15:37'),
(17, '8.12.238.123', 'United States', 1, '2017-11-28 19:28:27'),
(18, '148.21.177.158', 'United States', 1, '2017-11-28 19:33:05'),
(19, '153.202.197.216', 'Japan', 1, '2017-11-28 19:33:50'),
(27, '153.205.198.22', 'Japan', 1, '2017-10-28 20:05:19'),
(31, '153.205.198.22', 'Japan', 1, '2017-11-28 20:09:49'),
(32, '153.205.198.22', 'Japan', 1, '2017-11-29 19:23:07'),
(33, '153.205.198.22', 'Japan', 1, '2017-11-30 23:01:27'),
(34, '153.205.198.22', 'Japan', 1, '2017-12-04 14:55:27'),
(35, '153.205.198.22', 'Japan', 1, '2017-12-05 20:58:04'),
(36, '153.205.198.22', 'Japan', 1, '2017-12-06 21:11:13'),
(37, '153.205.198.22', 'Japan', 1, '2017-12-07 22:32:13'),
(38, '153.205.198.22', 'Japan', 1, '2017-12-11 15:32:10'),
(39, '153.205.198.22', 'Japan', 1, '2017-12-13 15:45:58'),
(40, '153.205.198.22', 'Japan', 1, '2017-12-19 02:37:45'),
(41, '153.205.198.22', 'Japan', 1, '2017-12-19 12:54:21'),
(42, '153.205.198.22', 'Unknown', 1, '2017-12-30 15:41:47'),
(43, '153.205.198.22', 'Japan', 1, '2018-01-02 15:46:52'),
(44, '153.205.198.22', 'Japan', 1, '2018-01-03 13:54:29'),
(45, '153.205.198.22', 'Japan', 1, '2018-01-04 16:54:03'),
(46, '153.205.198.22', 'Japan', 1, '2018-01-05 17:17:05'),
(47, '153.205.198.22', 'Japan', 1, '2018-01-08 13:57:21'),
(48, '153.205.198.22', 'Japan', 1, '2018-01-09 15:46:40'),
(49, '153.205.198.22', 'Japan', 1, '2018-01-10 20:34:12'),
(50, '153.205.198.22', 'Japan', 1, '2018-01-11 14:08:56'),
(51, '153.205.198.22', 'Japan', 1, '2018-01-15 18:10:09'),
(52, '153.205.198.22', 'Japan', 1, '2018-01-16 16:15:33'),
(53, '153.205.198.22', 'Japan', 1, '2018-01-17 21:39:17'),
(54, '153.205.198.22', 'Japan', 1, '2018-01-18 20:16:09'),
(55, '153.205.198.22', 'Japan', 1, '2018-01-19 15:05:32'),
(56, '153.205.198.22', 'Japan', 1, '2018-01-22 14:38:48'),
(57, '153.205.198.22', 'Japan', 1, '2018-01-25 15:44:30'),
(58, '153.205.198.22', 'Japan', 1, '2018-01-26 21:24:38'),
(59, '153.205.198.22', 'Japan', 1, '2018-01-29 20:45:50'),
(60, '153.205.198.22', 'Japan', 1, '2018-01-30 22:32:35'),
(61, '153.205.198.22', 'Japan', 1, '2018-01-31 18:35:33'),
(62, '153.205.198.22', 'Japan', 1, '2018-02-07 17:37:45'),
(63, '153.205.198.22', 'Japan', 1, '2018-02-13 16:52:37'),
(64, '153.205.198.22', 'Japan', 1, '2018-02-14 13:33:04'),
(65, '153.205.198.22', 'Japan', 1, '2018-02-16 13:50:44'),
(66, '153.205.198.22', 'Japan', 1, '2018-02-23 17:06:23'),
(67, '153.205.198.22', 'Japan', 1, '2018-03-02 17:25:19'),
(68, '153.205.198.22', 'Japan', 1, '2018-03-03 12:06:54'),
(69, '153.205.198.22', 'Japan', 1, '2018-03-05 16:27:57'),
(70, '153.205.198.22', 'Japan', 1, '2018-03-06 17:59:36'),
(71, '153.205.198.22', 'Japan', 1, '2018-03-08 14:56:34'),
(72, '153.205.198.22', 'Japan', 1, '2018-03-08 14:56:34'),
(73, '153.205.198.22', 'Japan', 1, '2018-03-12 19:38:37'),
(74, '153.205.198.22', 'Japan', 1, '2018-03-13 20:35:47'),
(75, '153.205.198.22', 'Japan', 1, '2018-03-14 19:41:17'),
(76, '153.205.198.22', 'Japan', 1, '2018-03-15 16:41:11'),
(77, '153.205.198.22', 'Japan', 1, '2018-03-16 19:21:45'),
(78, '153.205.198.22', 'Japan', 1, '2018-03-17 12:23:58'),
(79, '153.205.198.22', 'Japan', 1, '2018-03-19 00:38:47'),
(80, '153.205.198.22', 'Japan', 1, '2018-03-19 12:57:20'),
(81, '153.205.198.22', 'Japan', 1, '2018-03-20 20:33:33'),
(82, '153.205.198.22', 'Japan', 1, '2018-03-21 19:30:58'),
(83, '153.205.198.22', 'Japan', 1, '2018-03-23 19:41:03'),
(84, '153.205.198.22', 'Japan', 1, '2018-03-26 12:42:06'),
(85, '153.205.198.22', 'Japan', 1, '2018-03-27 13:26:30'),
(86, '163.172.160.190', 'France', 1, '2018-03-27 23:23:14');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `administradores`
--
ALTER TABLE `administradores`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `banner`
--
ALTER TABLE `banner`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `cabeceras`
--
ALTER TABLE `cabeceras`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idcliente`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `comentarios`
--
ALTER TABLE `comentarios`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `comercio`
--
ALTER TABLE `comercio`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `deseos`
--
ALTER TABLE `deseos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `detallefactura`
--
ALTER TABLE `detallefactura`
  ADD PRIMARY KEY (`correlativo`),
  ADD KEY `codproducto` (`codproducto`),
  ADD KEY `nofactura` (`nofactura`);

--
-- Indices de la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  ADD PRIMARY KEY (`correlativo`),
  ADD KEY `nofactura` (`token_user`),
  ADD KEY `codproducto` (`codproducto`);

--
-- Indices de la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD PRIMARY KEY (`correlativo`),
  ADD KEY `codproducto` (`codproducto`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`nofactura`),
  ADD KEY `usuario` (`usuario`),
  ADD KEY `codcliente` (`codcliente`),
  ADD KEY `codcliente_2` (`codcliente`),
  ADD KEY `codcliente_3` (`codcliente`),
  ADD KEY `usuario_2` (`usuario`);

--
-- Indices de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `plantilla`
--
ALTER TABLE `plantilla`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`codproducto`),
  ADD KEY `proveedor` (`proveedor`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`codproveedor`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`idrol`);

--
-- Indices de la tabla `slide`
--
ALTER TABLE `slide`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `subcategorias`
--
ALTER TABLE `subcategorias`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `tbldetalleventa`
--
ALTER TABLE `tbldetalleventa`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `IDVENTA` (`IDVENTA`),
  ADD KEY `IDPRODUCTO` (`IDPRODUCTO`);

--
-- Indices de la tabla `tblventas`
--
ALTER TABLE `tblventas`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `tbl_categorias`
--
ALTER TABLE `tbl_categorias`
  ADD PRIMARY KEY (`id_cat`);

--
-- Indices de la tabla `user_publico`
--
ALTER TABLE `user_publico`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idusuario`),
  ADD KEY `rol` (`rol`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `visitaspaises`
--
ALTER TABLE `visitaspaises`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `visitaspersonas`
--
ALTER TABLE `visitaspersonas`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `administradores`
--
ALTER TABLE `administradores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `banner`
--
ALTER TABLE `banner`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `cabeceras`
--
ALTER TABLE `cabeceras`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idcliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `comentarios`
--
ALTER TABLE `comentarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `comercio`
--
ALTER TABLE `comercio`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `deseos`
--
ALTER TABLE `deseos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `detallefactura`
--
ALTER TABLE `detallefactura`
  MODIFY `correlativo` bigint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT de la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de la tabla `entradas`
--
ALTER TABLE `entradas`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT de la tabla `factura`
--
ALTER TABLE `factura`
  MODIFY `nofactura` bigint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `plantilla`
--
ALTER TABLE `plantilla`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `codproducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `codproveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `idrol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `slide`
--
ALTER TABLE `slide`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `subcategorias`
--
ALTER TABLE `subcategorias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tbldetalleventa`
--
ALTER TABLE `tbldetalleventa`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=176;

--
-- AUTO_INCREMENT de la tabla `tblventas`
--
ALTER TABLE `tblventas`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=157;

--
-- AUTO_INCREMENT de la tabla `tbl_categorias`
--
ALTER TABLE `tbl_categorias`
  MODIFY `id_cat` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `user_publico`
--
ALTER TABLE `user_publico`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idusuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `visitaspaises`
--
ALTER TABLE `visitaspaises`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `visitaspersonas`
--
ALTER TABLE `visitaspersonas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=87;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detallefactura`
--
ALTER TABLE `detallefactura`
  ADD CONSTRAINT `detallefactura_ibfk_1` FOREIGN KEY (`nofactura`) REFERENCES `factura` (`nofactura`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detallefactura_ibfk_2` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  ADD CONSTRAINT `detalle_temp_ibfk_2` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD CONSTRAINT `entradas_ibfk_1` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `factura`
--
ALTER TABLE `factura`
  ADD CONSTRAINT `factura_ibfk_1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `factura_ibfk_2` FOREIGN KEY (`codcliente`) REFERENCES `cliente` (`idcliente`);

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`proveedor`) REFERENCES `proveedor` (`codproveedor`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `tbldetalleventa`
--
ALTER TABLE `tbldetalleventa`
  ADD CONSTRAINT `tbldetalleventa_ibfk_1` FOREIGN KEY (`IDPRODUCTO`) REFERENCES `producto` (`codproducto`),
  ADD CONSTRAINT `tbldetalleventa_ibfk_2` FOREIGN KEY (`IDVENTA`) REFERENCES `tblventas` (`ID`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`rol`) REFERENCES `rol` (`idrol`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
