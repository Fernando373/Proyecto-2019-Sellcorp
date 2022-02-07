	<?php

	session_start();
	include "../conexion.php";
	//echo md5($_SESSION['idUser']);
	?>

	<!DOCTYPE html>
	<html lang="en">
	<head>
		 <script>
   function solonumeros(e){
   key=e.keyCode || e.which;
   teclado= String.fromCharCode(key).toLowerCase();
   letras="1234567890"
   especiales = "8-37-38-46-164";
   teclado_especial=false;
   for (var i  in especiales) {

    if (key==especiales[i]) {
      teclado_especial=true;break;
    }
  }
  if (letras.indexOf(teclado)==-1 && !teclado_especial) {
    return false;


  }
}   
</script>
 <script>
   function sololetras(e){
   key=e.keyCode || e.which;
   teclado= String.fromCharCode(key).toLowerCase();
   letras="abcdefghijklmnopqerstuvwxyz "
   especiales = "8-37-38-46-164";
   teclado_especial=false;
   for (var i  in especiales) {

    if (key==especiales[i]) {
      teclado_especial=true;break;
    }
  }
  if (letras.indexOf(teclado)==-1 && !teclado_especial) {
    return false;


  }
}   
</script>
		<meta charset="UTF-8">
	<?php include "includes/scripts.php"; ?>
			<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, minimum-scale=1.0">
		<title>Nueva Venta</title>
	</head>
	<body>		
		<?php include "includes/header.php"; ?>
		<section id="container">
			<div class="title_page">
				<h1><i class="fas fa-cube"></i> Nueva Venta</h1>
			</div>
			<div class="datos_cliente">
				<div class="action_cliente">
					<h4>Datos del cliente</h4>
					<a href="#" class="btn_new btn_new_cliente"><i class="fas fa-plus"></i> Nuevo cliente</a>
				</div>
				<form name="form_new_cliente_venta" id="form_new_cliente_venta" class="datos">
					<input type="hidden" name="action" value="addCliente">
					<input type="hidden" id="idcliente" name="idcliente" value="" required>
					<div class="wd30">
						<label>NIT</label>
						<input type="text" name="nit_cliente" id="nit_cliente" onkeypress="return solonumeros(event)" onpaste="return false">
					</div>
					<div class="wd30">
						<label>Nombre</label>
						<input type="text" name="nom_cliente" id="nom_cliente" onkeypress="return sololetras(event)" onpaste="return false" disabled required>
					</div>
					<div class="wd30">
						<label>Telefono</label>
						<input type="number" name="tel_cliente" id="tel_cliente" onkeypress="return solonumeros(event)" onpaste="return false" disabled required>
					</div>
					<div class="wd30">
						<label>Direccion</label>
						<input type="text" name="dir_cliente" id="dir_cliente" disabled required>
					</div>
					<div id="div_registro_cliente" class="wd100">
						<button type="submit" class="btn_save"><i class="far fa-save fa-lg"></i> Guardar</button>
					</div>
				</form>
			</div>
			<div class="datos_venta">
				<h4>Datos de venta</h4>
				<div class="datos">
					<div class="wd50">
						<label>Vendedor</label>
						<p><?php echo $_SESSION['nombre'];?></p>
					</div>
					<div class="wd50">
						<label>Acciones</label>
						<div id="acciones_venta">
							<a href="#" class="btn_ok textcenter" id="btn_anular_venta"><i class="fas fa-ban"></i> Anular</a>
							<a href="#" class="btn_new textcenter" id="btn_facturar_venta" style="display: none;"><i class="fas fa-edit"></i> Procesar</a>
						</div>
					</div>
				</div>
			</div>
			<table class="tbl_venta">
				<thead>
					<tr>
						<th width="100px">Codigo</th>
						<th>Descripcion</th>
						<th>Existencia</th>
						<th width="100px">Cantidad</th>
						<th class="textright">Precio</th>
						<th class="textright">Precio Total</th>
						<th class="100px">Descuento</th>
						<th> Accion</th>
						
					</tr>
					<tr>
						<td><input type="number" name="txt_cod_producto" id="txt_cod_producto" onkeypress="return solonumeros(event)" onpaste="return false"></td>
						<td id="txt_descripcion">-</td>
						<td id="txt_existencia">-</td>
						<td><input type="text" name="txt_cant_producto" id="txt_cant_producto" value="0" min="1" disabled></td>
						<td id="txt_precio" class="textright">0.00</td>
						<td id="txt_precio_total" class="textright">0.00</td>
						<td><button id=btn> <a href="#" id="add_product_venta" class="link_add"><i class="fas fa-plus"></i> Agregar</a></button></td>
						
						
					</tr>
					<tr>
						<th>Çodigo</th>
						<th colspan="2">Descripcion</th>
						<th> Cantidad </th>
						<th class="textright">Precio</th>
						<th class="textright"> Precio Total </th>
						<th> Descuento </th>
						<th> Accion </th>
						<div id=error1></div>
					</tr>
				</thead>
				<tbody id="detalle_venta">
					<!-- CONTENIDO EN AJAX.PHP --> 

				</tbody>
				<tfoot id="detalle_totales">
					<!--- CONTENIDO AJAX -->
					
				</tfoot>
			</table>
		</section>
		<?php include "includes/footer.php"; ?>

		<script type="text/javascript">
			$(document).ready(function(){
				var usuarioid = '<?php echo $_SESSION['idUser']?>';
				serchForDetalle(usuarioid);
			});
		</script>
		<script type="text/javascript">
					window.onload = function(){
						Push.Permission.request();
					}
					document.getElementById('btn').onclick = function(){
						Push.create('Producto bajo en stock',{
							body : 'No quedan muchos productos',
							icon: 'img/img_producto.png',
							timeout: 10000,
							vibrate: [100,100,100],
							onClick: function(){
						window.location="lista_productos.php";
						this.close();
					}
						});
					}
					</script>
		<?php
  $query = mysqli_query($conection,"SELECT p.codproducto, p.descripcion, p.foto, p.existencia
				FROM producto p 
			    WHERE p.existencia < 6 ");
				$result = mysqli_num_rows($query);
				if($result>0){
					while($data = mysqli_fetch_array($query)){
				echo '<script>
					Push.create("El producto tiene un stock bajo",{
					data: "No hay productos>",
					icon: "img/img_producto.png",
					timeout: 10000,
					onClick: function(){
						window.location="lista_productos.php";
						this.close();
					}
					});
					</script> ';
		
				}
			} 
    ?>
	</body>
	</html>
