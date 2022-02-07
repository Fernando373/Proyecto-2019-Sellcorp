<?php
		session_start();
		include "../conexion.php";
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
<?php include "includes/scripts.php"; ?>
	<title>Historial de Productos</title>
</head>
<body>
<?php include "includes/header.php"; ?>
	<section id="container">

		<h1><i class="fas fa-cube"></i>Historial de productos</h1>
		<a href="registro_producto.php" class="btn_new"><i class="fas fa-plus"></i> Nuevo Producto</a>

		<table>
			<tr>
				<th>Codigo</th>
				<th>Nombre del Producto</th>
				<th>Fecha</th>
				<th>Cantidad</th>
				<th>Precio</th>
				<th><?php
                   $query_proveedor = mysqli_query($conection,"SELECT idusuario, nombre FROM usuario WHERE estatus = 1 ORDER BY idusuario ASC");
                   $result_proveedor = mysqli_num_rows($query_proveedor);
                   ?>
                   <select name="proveedor" id="search_usuario" >
                   	<option value="" selected>Usuario</option>
                    <?php 
                      if ($result_proveedor > 0) {
                        while ($usuario = mysqli_fetch_array($query_proveedor)) {
                          ?> 
                          <option value="<?php echo $usuario["idusuario" ]; ?>"><?php echo $usuario["nombre"]; ?></option>

                          <?php
                        }
                      }
                    ?>
                    
                   </select></th>
			</tr>
			<?php
			//Paginador
			 $sql_register=mysqli_query($conection,"SELECT Count(*) as total_registro FROM entradas");
			 $result_register =mysqli_fetch_array($sql_register);
			 $total_registro = $result_register['total_registro'];

			 $por_pagina = 9;
			 if(empty($_GET['pagina'])){
				 $pagina = 1;
			 } else{
				 $pagina = $_GET['pagina'];
			 }
				 $desde = ($pagina-1) * $por_pagina;
				 $total_paginas = ceil($total_registro / $por_pagina);


			 
				$query = mysqli_query($conection,"SELECT e.codproducto, e.fecha, e.cantidad, e.precio, e.usuario_id, u.nombre, p.descripcion
				FROM entradas e
				INNER JOIN usuario u
				ON e.usuario_id = u.idusuario 
				INNER JOIN producto p
				ON e.codproducto = p.codproducto
				ORDER BY e.correlativo DESC
				LIMIT $desde,$por_pagina");
				
				mysqli_close($conection);

				$result = mysqli_num_rows($query);
				if($result>0){
					while($data = mysqli_fetch_array($query)){
						
			?>
			<tr class="row<?php echo $data["codproducto"];?>">
					<td> <?php echo $data["codproducto"];?></td>
					<td> <?php echo $data["descripcion"]; ?></td>
					<td> <?php  echo $data["fecha"]; ?></td>
					<td class="celPrecio"> <?php echo $data["cantidad"]; ?></td>
					<td class="celExistencia"> <?php echo $data["precio"]; ?></td>
					<td> <?php echo $data["nombre"]; ?></td>
					
				
					<?php if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2) { ?>
		<td>
		<a class="link_add add_product" product="<?php echo $data["codproducto"]; ?>" href="#"><i class="fas fa-plus"></i> Agregar</a>
					
				
					</td>
					<?php } ?>	
				</tr>
		<?php			
				}
			} 
		?>
		</table>
		<div class="paginador">
			<ul> <?php
			if($pagina !=1){
				?>
				<li><a href="?pagina = <?php echo 1; ?>"><i class="fas fa-step-backward"></i></a></li>
				<li><a href="?pagina = <?php echo $pagina-1; ?>"><i class="fas fa-backward"></i></a></li>
				<?php
			}
				for ($i=1; $i <= $total_paginas; $i++){
					if ($i == $pagina){
						echo '<li class="pageSelected">'.$i.'</li>';
					} else {
					echo '<li><a href="?pagina='.$i.'">'.$i.'</a></li>';
				} 
			}
			if ($pagina !=$total_paginas){
				?>

				<li><a href="?pagina=<?php echo $pagina + 1; ?>"><i class="fas fa-forward"></i></a></li>
				<li><a href="?pagina=<?php echo $total_paginas; ?>"><i class="fas fa-step-forward"></i></a></li>
			<?php } ?>
			</ul>
		</div>
	</section>
	<?php include "includes/footer.php"; ?>
</body>
</html>	