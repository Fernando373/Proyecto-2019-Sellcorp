-- phpMyAdmin SQL Dump
-- version 4.3.11
-- http://www.phpmyadmin.net
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 19-04-2018 a las 09:11:20
-- Versión del servidor: 5.6.24
-- Versión de PHP: 5.6.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `tutoriales_estadistica`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE IF NOT EXISTS `productos` (
  `id_prod` int(11) NOT NULL,
  `nomb_prod` varchar(100) NOT NULL,
  `tipo_prod` varchar(50) NOT NULL,
  `precio_unit` float NOT NULL,
  `precio_dist` float NOT NULL,
  `fecha_reg` date NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id_prod`, `nomb_prod`, `tipo_prod`, `precio_unit`, `precio_dist`, `fecha_reg`) VALUES
(21, 'Aceite Capri', 'enlatados', 18, 7, '2014-12-08'),
(23, 'Mayonesa Hellmans', 'otros', 5, 4, '2014-11-11'),
(24, 'Gaseosa KR', 'otros', 5, 4, '2014-09-30'),
(25, 'Mantequilla Laive', 'otros', 6, 5, '2014-09-03'),
(26, 'Galletas Margaritas', 'otros', 2, 1, '2014-08-15'),
(27, 'Arroz la Paisana', 'otros', 6, 3, '2015-02-04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE IF NOT EXISTS `ventas` (
  `id_venta` int(11) NOT NULL,
  `fecha_venta` date NOT NULL,
  `monto_venta` decimal(10,2) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`id_venta`, `fecha_venta`, `monto_venta`) VALUES
(1, '2014-01-15', '3623.00'),
(2, '2014-02-13', '2011.30'),
(3, '2014-03-11', '1550.55'),
(4, '2014-04-22', '3655.50'),
(5, '2014-05-22', '4211.20'),
(6, '2014-06-14', '2854.20'),
(7, '2014-07-30', '3114.20'),
(8, '2014-08-16', '2600.20'),
(9, '2014-09-23', '3010.90'),
(10, '2014-10-02', '1411.10'),
(11, '2014-11-20', '6633.00'),
(12, '2014-12-12', '5442.20'),
(13, '2015-01-20', '3522.40'),
(14, '2015-02-22', '6748.20'),
(15, '2015-03-11', '7000.00');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id_prod`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`id_venta`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id_prod` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=28;
--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id_venta` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=16;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
