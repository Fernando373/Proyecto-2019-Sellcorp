<?php 
	session_start();
 ?>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<?php include "includes/scripts.php"; ?>
	<title>Sisteme Ventas</title>
</head>
<body>
	<?php 
  include "includes/header.php"; 
  include "../conexion.php";
  //Datos empresa
  $nit = '';
  $nomreEmpresa = '';
  $razonSocial = '';
  $telEmpresa = '';
  $emailEmpresa = '';
  $dirEmpresa = '';
  $iva = '';
  $query_empresa = mysqli_query($conection, "SELECT * FROM configuracion");
  $row_empresa = mysqli_num_rows($query_empresa);
  if ($row_empresa) {
    while ($arrInfoEmpresa = mysqli_fetch_assoc($query_empresa)) {
      $nit = $arrInfoEmpresa['nit'];
      $nomreEmpresa = $arrInfoEmpresa['nombre'];
      $razonSocial = $arrInfoEmpresa['razon_social'];
      $telEmpresa = $arrInfoEmpresa['telefono'];
     $emailEmpresa = $arrInfoEmpresa['email'];
     $dirEmpresa = $arrInfoEmpresa['direccion'];
    $iva = $arrInfoEmpresa['iva'];
    }
  }

  //LLAMANDO PROCEDIMINETO PARA CANTIDADES
  $query_dash = mysqli_query($conection,"CALL dataDashboard();");
  $result_das = mysqli_num_rows($query_dash);
  if ($result_das > 0) {
    $data_dash = mysqli_fetch_assoc($query_dash);
   // mysqli_close($conection);
  }
 //print_r($data_dash);
  ?>
	<section id="container">



    <h1 class="titlePanelControl">Productos con bajo stock</h1>

    <table>
      <tr>
        <th>Codigo</th>
        <th>Descripcion</th>
        <th>Existencia</th>
        
      </tr>
      <?php
       include "../conexion.php";
        $query = mysqli_query($conection,"SELECT p.codproducto, p.descripcion, p.existencia FROM producto p WHERE p.estatus = '1' AND p.existencia < '6' ORDER BY p.codproducto DESC");
        
        //mysqli_close($conection);

        $result = mysqli_num_rows($query);
				if($result>0){
					while($data = mysqli_fetch_array($query)){
      ?>
      <tr class="row<?php echo $data["codproducto"];?>">
          <td> <?php echo $data["codproducto"];?></td>
          <td> <?php echo $data["descripcion"]; ?></td>
          <td class="celExistencia"> <?php echo $data["existencia"]; ?></td>
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







   

		<div class="divContainer">
			<div>
			<h1 class="titlePanelControl">Panel de Control</h1>
			</div>
		  <div class="dashboard">
        <?php if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){
          ?>
        <a href="lista_usuarios.php">
          <i class="fas fa-users"></i>
          <p>
            <strong>Usuarios</strong><br>
            <span><?= $data_dash['usuarios']; ?></span>
          </p>
        </a>
        <?php } ?>  
         <a href="lista_clientes.php">
          <i class="fas fa-user"></i>
          <p>
            <strong>Clientes</strong><br>
            <span><?= $data_dash['clientes']; ?></span>
          </p>
        </a>  <?php if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){
          ?>
         <a href="lista_proveedor.php">
          <i class="fas fa-building"></i>
          <p>
            <strong>Proveedores</strong><br>
            <span><?= $data_dash['proveedores']; ?></span>
          </p>
        </a>  <?php } ?> 
         <a href="lista_productos.php">
          <i class="fas fa-cubes"></i>
          <p>
            <strong>Productos</strong><br>
            <span><?= $data_dash['productos']; ?></span>
          </p>
        </a>  
        <?php if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){
          ?>
         <a href="ventas.php">
          <i class="far fa-file-alt"></i>
          <p>
            <strong>Ventas</strong><br>
            <span><?= $data_dash['ventas']; ?></span>
          </p>
        </a> <?php } ?> 
        <a href="ventas.php">
          <i class="far fa-file-alt"></i>
          <p>
            <strong>Total de Ventas</strong><br>
            <span>Bs.<?= $data_dash['totalventas']; ?></span>
          </p>
        </a>  
        <?php if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){
          ?>
        <a href="ventas.php">
          <i class="far fa-file-alt"></i>
          <p>
            <strong>Ventas Internet</strong><br>
            <span><?= $data_dash['internet']; ?></span>
          </p>
        </a> <?php } ?>
        <a href="ventas.php">
          <i class="fas  fa-money"></i>
          <p>
            <strong>Total Internet</strong><br>
            <span>Bs.<?= $data_dash['totinte']; ?></span>
          </p>
        </a>
      </div>		
    </div>

    <div class="divInfoSistem">
      <div>
        <h1 class="titlePanelControl">Configuracion</h1>
      </div>
      <div class="containerPerfil">
        <div class="containerDataUser">
          <div class="logoUser">
            <img src="img/userss.png">
          </div>
          <div class="divDataUser">
            <h4>Informacion personal</h4>
            <div>
              <label>Nombre:</label><span><?php echo $_SESSION['nombre']; ?></span>
            </div>
            <div>
              <label>Correo:</label><span><?php echo $_SESSION['email']; ?></span>
            </div>
            <h4>Datos Usuario</h4>
            <div>
              <label>Rol:</label><span><?= $_SESSION['rola']; ?></span>
            </div>
            <div>
              <label>Usuario:</label><span><?php echo $_SESSION['user']; ?></span>
            </div>
            <h4>Cambiar Password</h4>
              <form action="" method="post" name="frmChangePass" id="frmChangePass">
                <div>
                  <input type="password" name="txtPassUser" id="txtPassUser" placeholder="Contrasena actual" required>
                </div><br>
                <div>
                  <input class="newPass" type="password" name="txtNewPassUser" id="txtNewPassUser" placeholder="Nueva contrasena" required>
                </div><br>
                <div>
                  <input class="newPass" type="password" name="txtPassConfirm" id="txtPassConfirm" placeholder="Confirmar contrasena" required>
                </div>
                <div class="alertChangePass" style="display: none;">
                  
                </div>
                <div>
                  <button type="submit" class="btn_save btnChangePass"><i class="fas fa-key"></i> Cambiar contrasena</button>
                </div>
              </form>
            
          </div>
        </div> 
        <?php if($_SESSION['rol'] == 1){
          ?>
        <div class="containerDataEmpresa">
          <div class="logoUser">
            <img src="img/userss.png">
          </div>
          <h4>Datos de la empresa</h4>

          <form action="" method="post" name="frmEmpresa" id="frmEmpresa">
            <input type="hidden" name="action" value="updateDataEmpresa">
            <div>
              <label>Nit:</label><input type="text" name="txtNit" id="txtNit" placeholder="Nit de la empresa" value="<?= $nit; ?>" required>
            </div>
            <div>
              <label>Nombre:</label><input type="text" name="txtNombre" id="txtNombre" placeholder="Nombre de la empresa" value="<?= $nomreEmpresa; ?>" required>
            </div>
            <div>
              <label>Razon Social:</label><input type="text" name="txtRSocial" id="txtRSocial" placeholder="Razon Social" value="<?= $razonSocial; ?>" required>
            </div>
            <div>
              <label>Telefono:</label><input type="text" name="txtTelEmpresa" id="txtTelEmpresa" placeholder="Telefono de la empresa" value="<?= $telEmpresa; ?>" required>
            </div>
            <div>
              <label>Correo Electronico:</label><input type="email" name="txtEmailEmpresa" id="txtEmailEmpresa" placeholder="Correo de la empresa" value="<?= $emailEmpresa; ?>" required>
            </div>
            <div>
              <label>Direccion :</label><input type="text" name="txtDirEmpresa" id="txtDirEmpresa" placeholder="Nit de la empresa" value="<?= $dirEmpresa; ?>" required>
            </div>
            <div>
              <label>IVA (%) :</label><input type="text" name="txtIva" id="txtIva" placeholder="Impuesto al valor agregado (IVA)" value="<?= $iva; ?>" required>
            </div>
            <div class="alertFormEmpresa" style="display: none;"></div>
            <div>
              <button type="submit" class="btn_save btnChangePass"><i class="far fa-save fa-lg"></i> Guardar Datos</button>
            </div>
          </form>

        </div>
      <?php } ?>
      </div>
    </div>


  </section>
  <?php include "includes/footer.php"; ?>
  

  <?php
  include "../conexion.php";
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