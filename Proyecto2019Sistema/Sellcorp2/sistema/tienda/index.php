<?php
include 'global/config.php';
include 'global/conexion.php';
include 'carrito.php';
include 'templates/cabecera.php' 
?>
<?php if($mensaje!=""){?>
		<br> <div class="alert alert-success">
			<?php echo $mensaje; ?>
			<a href="mostrarCarrito.php" class="badge-success">Ver carrito</a>
			</div>
<?php } ?> <br>
<br>
			<div class="row">
				<?php // QUERY PARA CONSEGUIR TODO LO DE LOS PRODUCTOS
				//include "../img/uploads";
				$sentencia=$pdo->prepare("SELECT * FROM producto WHERE estatus ='1' ");
				$sentencia->execute();
				$listaProductos=$sentencia->fetchAll(PDO::FETCH_ASSOC);
				
				//print_r($listaProductos);
				?> 
				<?php //AGREGAMOS EL VALOR A LOS CAMPOS
				foreach($listaProductos as $producto){ ?>
					<div class="col-3">
					<div class="card">
						<img 
						title="<?php echo $producto['descripcion'];?>" alt="<?php echo $producto['descripcion'];?>"
						 class="card-img-top" 
						src="<?php echo $producto['foto']; ?>"
						data-toggle="popover"
						data-trigger="hover"
						data-content="<?php echo $producto['descripcion'];?>"			
						height="300px"			>
						
						<div class="card-body">
						<span><?php echo $producto['descripcion'];?> </span>	
							<h5 class="card-title">Bs.<?php echo $producto['precio'];?></h5>
							<!-- <p class="card-text"><?php echo $producto['codproducto'];?></p> -->

							<form action="" method="post">
								<!-- BOTON PARA ENVIAR LA INFORMACION -->
								<input type="hidden" name="id" id="id" value="<?php echo  openssl_encrypt($producto['codproducto'],COD,KEY);?>">
								<input type="hidden" name="descripcion" id="descripcion" value="<?php echo openssl_encrypt($producto['descripcion'],COD,KEY); ?>">
								<input type="hidden" name="precio" id="precio" value="<?php echo openssl_encrypt($producto['precio'],COD,KEY); ?>">
								<input type="hidden" name="cantidad" id="cantidad" value="<?php echo openssl_encrypt(1,COD,KEY);; ?>">
							<button class="btn btn-primary" name="btnAccion" value="Agregar" type="submit">Agregar al carrito</button>
							</form>

							</div>
					</div>

				</div>
 				<?php }		?>
				
			</div>
	</div>
	<script>
		$(function(){
				$('[data-toggle="popover"]').popover()
		});

		</script>

<?php include 'templates/pie.php'; ?> 
