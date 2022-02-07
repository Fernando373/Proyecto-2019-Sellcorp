<?php
		session_start();
		include "../conexion.php";
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
<?php include "includes/scripts.php"; ?>
	<title>Lista de Ventas en linea</title>
</head>
<body>
<?php include "includes/header.php"; ?>
	<section id="container">

		<h1><i class="far fa-newspaper"></i> Lista de Ventas en linea</h1>

		<?php //BUSCADOR// ?>
		<form action="buscar_vental.php" method="get" class="form_search"> 
				<input type="text" name="busqueda" id="busqueda" placeholder="No. Pedido">
				<input type="submit" value="Buscar" class="btn_search">

		</form>
		<div>
			<h5>Buscar por fechas</h5>
			<form action="buscar_vental.php" method="get" class="form_search_date">
				<label>De:</label>
				<input type="date" name="fecha_de" id="fecha_de" required>
				<label>Hasta</label>
				<input type="date" name="fecha_a" id="fecha_a" required>
				<button type="submit" class="btn_view"><i class="fas fa-search"></i></button>
			</form>
		</div>

		<table>
			<tr>
				<th>N° Pedido</th>
				<th>Fecha</th>
				<th>Cliente</th>
				<th>Estado</th>
				<th class="text-center"> Total Factura</th>
				<th class="textright"> Acciones</th>
				
				
			</tr>
			<?php
			//Paginador
			 $sql_register=mysqli_query($conection,"SELECT Count(*) as total_registro FROM tblventas WHERE estado != 10");
			 $result_register =mysqli_fetch_array($sql_register);
			 $total_registro = $result_register['total_registro'];

			 $por_pagina = 10;
			 if(empty($_GET['pagina'])){
				 $pagina = 1;
			 } else{
				 $pagina = $_GET['pagina'];
			 }
				 $desde = ($pagina-1) * $por_pagina;
				 $total_paginas = ceil($total_registro / $por_pagina);


			 
				$query = mysqli_query($conection,"SELECT tbl.ID, tbl.Fecha,tbl.Correo,tbl.Total,tbl.estado,tbl.status
				FROM tblventas tbl 
			    WHERE tbl.estado != 10
				ORDER BY tbl.Fecha DESC
				LIMIT $desde,$por_pagina");
				
				mysqli_close($conection);

				$result = mysqli_num_rows($query);
				if($result>0){
					while($data = mysqli_fetch_array($query)){
						if ($data["estado"] == 1 ) {
							$estado = '<span class="pagada">Aun no entregada</span>';
						}else{
							$estado = '<span class="anulada">Entregado</span>';
						}
			?>
			<tr id="row_<?php echo $data["ID"];?>">
					 <td> <?php echo $data["ID"];?></td> 
					<td> <?php echo $data["Fecha"];?></td>
					<td> <?php echo $data["Correo"];?></td>
					<td class="estado"> <?php echo $estado;?></td>
					<td class="textright totalfactura"><span>Bs.</span><?php echo $data['Total']; ?></td>
				  	<td>
				  		
					<div class="div_acciones">
						
					
					<?php if ($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2) {
						if ($data["estado"] == 1) { ?>
							<div class="div_factura" >
								<button class="btn_anular anular_factura" fac="<?php echo $data["ID"]; ?>">Entregar</button>
							</div>
						<?php }else{ ?> 
							<div class="div_factura">
								<button type="button" class="btn_anular inactive"><i class="fas-fa-ban"></i></button>
							</div>
					<?php } 
					} ?>
					
					</td>	
				</tr>
		<?php			
				}
			} 
		?> </div>
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