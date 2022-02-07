<?php 
//Incluímos inicialmente la conexión a la base de datos
require "../conexion.php";

Class Consultas
{
	//Implementamos nuestro constructor
	public function __construct()
	{

	}

	
	public function Productos()
	{
		$sql="SELECT p.descripcion as nombre, SUM(d.precio_venta) as total
        FROM producto p 
        INNER JOIN detallefactura d ON d.codproducto = p.codproducto
        GROUP BY p.codproducto
				
              limit 0,20";
		return $sql;
	}




}

?>