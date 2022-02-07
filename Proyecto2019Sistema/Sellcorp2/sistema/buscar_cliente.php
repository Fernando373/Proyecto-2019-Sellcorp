<?php

session_start();
include "../conexion.php";

?>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
<?php include "includes/scripts.php"; ?>
		<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, minimum-scale=1.0">
		<link rel="stylesheet"  href="css/bootstrap.min.css">
	<title>Lista de Clientes</title>
</head>
<body>
<?php include "includes/header.php"; ?>
	<section id="container">
		<?php
			$busqueda = strtolower($_REQUEST['busqueda']);
			if(empty($busqueda)){
				header ("location: lista_clientes.php");
				mysqli_close($conection);
			}
		?>
		<h1>Lista de clientes</h1>
		<a href="registro_cliente.php" class="btn_new">Nuevo cliente</a>

		<?php //BUSCADOR// ?>
		<form action="buscar_cliente.php" method="get" class="form_search"> 
				<input type="text" name="busqueda" id="busqueda" placeholder="Buscar" value="<?php echo $busqueda; ?>">
				<input type="submit" value="Buscar" class="btn_search">

		</form>

		<table>
			<tr>
				<th>N°</th>
				<th>NIT</th>
				<th>Nombre</th>
				<th>Telefono</th>
				<th>Direccion</th>
				<th>Acciones</th>
			
			</tr>
			<?php
			//Paginador
			 $sql_register=mysqli_query($conection,"SELECT Count(*) as total_registro FROM cliente WHERE ( idcliente LIKE '%$busqueda%' OR 																nit LIKE '%$busqueda%' OR
			 	nombre LIKE '%$busqueda%' OR
				telefono LIKE '%$busqueda%' OR
				direccion LIKE '%$busqueda%' )
				 AND estatus = 1");
			 $result_register =mysqli_fetch_array($sql_register);
			 $total_registro = $result_register['total_registro'];

			 $por_pagina = 8;
			 if(empty($_GET['pagina'])){
				 $pagina = 1;
			 } else{
				 $pagina = $_GET['pagina'];
			 }
				 $desde = ($pagina-1) * $por_pagina;
				 $total_paginas = ceil($total_registro / $por_pagina);


			 
				$query = mysqli_query($conection,"SELECT *
				FROM cliente
				WHERE ( idcliente LIKE '%$busqueda%' OR
						nit LIKE '%$busqueda%' OR
						nombre LIKE '%$busqueda%' OR	
						direccion LIKE '%$busqueda%' OR
						telefono LIKE '%$busqueda%')  AND estatus = 1
				ORDER BY idcliente ASC
				LIMIT $desde,$por_pagina");

				mysqli_close($conection);
				$result = mysqli_num_rows($query);
				if($result>0){
					while($data = mysqli_fetch_array($query)){	
					if ($data["nit"] == 0) {
										$nit= 'C/F';
									}else{
										$nit = $data["nit"];
									}			
			?>
			<tr>
					<td> <?php echo $data["idcliente"];?></td>
					<td> <?php echo $data["nit"];?></td>
					<td> <?php echo $data["nombre"];?></td>
					<td> <?php echo $data["telefono"];?></td>
					<td> <?php echo $data['direccion'] ?></td>
				  	<td>
					<a class="btn_edit" href="editar_cliente.php?id=<?php echo $data["idcliente"];?>">Editar</a>
					<?php if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2) { ?>
					<a class="btn_delete" href="eliminar_confirmar_cliente.php?id=<?php echo $data["idcliente"];?>">Eliminar</a><?php } ?>
					</td>
				</tr>
		<?php			
				}
			} 
		?>
		</table>
		<?php
		if($total_registro !=0)
		{
		?>
		<div class="paginador">
			<ul> <?php
			if($pagina !=1){
				?>
				<li><a href="?pagina = <?php echo 1; ?>&busqueda=<?php echo $busqueda; ?>">|<</a></li>
				<li><a href="?pagina = <?php echo $pagina-1; ?>&busqueda=<?php echo $busqueda; ?>"><<</a></li>
				<?php
			}
				for ($i=1; $i <= $total_paginas; $i++){
					if ($i == $pagina){
						echo '<li class="pageSelected">'.$i.'</li>';
					} else {
					echo '<li><a href="?pagina='.$i.'&busqueda='.$busqueda.'">'.$i.'</a></li>';
				} 
			}
			if ($pagina !=$total_paginas){
				?>

				<li><a href="?pagina=<?php echo $pagina + 1; ?>&busqueda=<?php echo $busqueda; ?>">>></a></li>
				<li><a href="?pagina=<?php echo $total_paginas; ?>&busqueda=<?php echo $busqueda; ?>">>|</a></li>
			<?php } ?>
			</ul>
		</div>
			<?php } 
			else {
				echo '<center> NO EXISTEN REGISTROS </center>';
			}?>
	</section>
	<?php include "includes/footer.php"; ?>
			<script type="js/jquery.js"></script>
			<script type="js/bootstrap.min.js"></script>
</body>
</html>-