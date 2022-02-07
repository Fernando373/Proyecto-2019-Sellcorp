		<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
			<div class="collapse navbar-collapse" id="navbarSupportedContent">
			 <ul class="navbar-nav mr-auto">
				<li><a href="index.php"><i class="fas fa-home"></i> Inicio</a></li>
			<?php 
				if($_SESSION['rol'] == 1){
			 ?>
				<li class="principal">

					<a href="#"><i class="fas fa-users"></i> Usuarios</a>
					<ul class="navbar-nav mr-auto">
						<li><a href="registro_usuario.php"><i class="fas fa-user-plus"></i> Nuevo Usuario</a></li>
						<li><a href="lista_usuarios.php"><i class="fas fa-user-check"></i> Lista de Usuarios</a></li>
					</ul>
				</li>
			<?php } ?>
				<li class="principal">
					<a href="#">Clientes</a>
					<ul class="navbar-nav mr-auto">
						<li><a href="registro_cliente.php">Nuevo Cliente</a></li>
						<li><a href="lista_clientes.php">Lista de Clientes</a></li>
					</ul>
				</li>
				<?php 
				if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){
			 ?>
				<li class="principal">
					<a href="#">Proveedores</a>
					<ul class="navbar-nav mr-auto">
						<li><a href="registro_proveedor.php">Nuevo Proveedor</a></li>
						<li><a href="lista_proveedor.php">Lista de Proveedores</a></li>
					</ul>
				</li>
				<?php } ?>

				<li class="principal">
					<a href="#"><i class="fas fa-cubes"></i> Productos</a>
					<ul class="navbar-nav mr-auto">
					<?php 
					if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){
				     ?>

						<li><a href="registro_producto.php">Nuevo Producto</a></li>
						<li><a href="lista_productos.php">Lista de Productos</a></li>
						<li><a href="historial_productos.php"><i class="fas fa-list"></i> Historial de Productos</a></li>
						<?php } ?>
					</ul>
				</li>
				<li class="principal">
					<a href="#">Ventas</a>
					<ul class="navbar-nav mr-auto">
						<li><a href="nueva_venta.php">Nuevo Venta</a></li>
						<li><a href="ventas.php">Ventas</a></li>
					</ul>
				</li>
				<li class="principal">
					<a href="#">Carrito</a>
					<ul class="navbar-nav mr-auto">
						<li><a href="sellcorpanel//"><i class="fas fa-list"></i> Panel Tienda Linea</a></li>
						
					</ul>
				</li>
				<li class="principal">
					<a href="#">Reportes</a>
					<ul class="navbar-nav mr-auto">
				<li><a href="estadistica//">Years</a></li>
					</ul>
				</li>
			</ul>
		</div>
		</nav>