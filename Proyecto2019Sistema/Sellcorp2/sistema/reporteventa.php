<?php
		session_start();
		include "../conexion.php";
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
<?php include "includes/scripts.php"; ?>
	<title>Lista de Ventas</title>
</head>
<body>
<?php include "includes/header.php"; ?>
	<section id="container">

		<h1><i class="far fa-newspaper"></i> Venta Diaria</h1>
		<a href="nueva_venta.php" class="btn_new"><i class="fas fa-plus"></i> Nueva Venta</a>

		<?php //BUSCADOR// ?>
		<form action="buscar_venta.php" method="get" class="form_search"> 
				<input type="text" name="busqueda" id="busqueda" placeholder="No. Factura">
				<input type="submit" value="Buscar" class="btn_search">

		</form>
		<div>
			<h5>Fecha a ver</h5>
			<form action="buscar_venta.php" method="get" class="form_search_date">
				<label>De:</label>
				<input type="date" name="fecha_de" id="fecha_de" required>
			
				<button type="submit" class="btn_view"><i class="fas fa-search"></i></button>
			</form>
		</div>

		<table>	
			<?php
			/*Paginador
			 $sql_register=mysqli_query($conection,"SELECT Count(*) as total_registro FROM factura WHERE estatus != 10");
			 $result_register =mysqli_fetch_array($sql_register);
			 $total_registro = $result_register['total_registro'];

			 $por_pagina = 10;
			 if(empty($_GET['pagina'])){
				 $pagina = 1;
			 } else{
				 $pagina = $_GET['pagina'];
			 }
				 $desde = ($pagina-1) * $por_pagina;
				 $total_paginas = ceil($total_registro / $por_pagina); */


			 
				$query = mysqli_query($conection,"SELECT SUM(f.totalfactura) as total
				FROM factura f 
			    WHERE f.estatus != 10
				ORDER BY f.fecha DESC");
				
				

				$result = mysqli_num_rows($query);
				if($result>0){
					while($data = mysqli_fetch_array($query)){
						
			?>
			<!-- <tr id="row_<?php echo $data["nofactura"];?>"> -->
						<tr>
				TOTAL DE MOVIMIENTO DIARIO BS. <?php echo $data["total"];?></tr> 
					<tr>
				<th>TOTAL DE PRODUCTOS VENDIDOS</th>
			</tr>
			<tr>
				<th>TOTAL DE CLIENTES </th>
			</tr>
			<tr>
				<th>TOTAL DE VENTAS </th>
			</tr>
			<tr>
				<th>TOTAL DE MOVIMIENTO </th>
			</tr>
			<tr>
				<th>TOTAL DE DESCUENTOS </th>
			</tr>
			<!--<td> <?php echo $data["fecha"];?></td>
					<td> <?php echo $data["cliente"];?></td>
					<td> <?php echo $data["vendedor"];?></td>
					<td class="estado"> <?php echo $estado;?></td>
					<td class="textright totalfactura"><span>Bs.</span><?php echo $data['totalfactura']; ?></td>
				  	<td>
				  		
					<div class="div_acciones">
						<div>
							<button class="btn_view view_factura" type="button" cl="<?php echo $data["codcliente"]; ?>" f="<?php echo $data['nofactura']; ?>"><i class="fas fa-eye"></i></button>
						</div>
					
					<?php if ($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2) {
						if ($data["estatus"] == 1) { ?>
							<div class="div_factura">
								<button class="btn_anular anular_factura" fac="<?php echo $data["nofactura"]; ?>"><i class="fas fa-ban"></i></button>
							</div>
						<?php }else{ ?> 
							<div class="div_factura">
								<button type="button" class="btn_anular inactive"><i class="fas-fa-ban"></i></button>
							</div>
					<?php } 
					} ?>
					
					</td>	
				</tr> -->
		<?php			
				}
			} 
		?> </div>
		</table>
		<table><tr>
		<th> TOTAL DE MOVIMIENTO DIARIO BS.  </th></tr></table>
	</section>
	<?php include "includes/footer.php"; ?>
</body>
</html>