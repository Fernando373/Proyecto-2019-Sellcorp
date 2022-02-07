<?php
session_start();
if($_SESSION['rol']!=1 and $_SESSION['rol'] !=2)
  {
      header("location: ./");
  }
    include "../conexion.php";
    
    if(!empty($_POST))
    {
            $alert='';
            if(empty($_POST['proveedor']) || empty($_POST['contacto']) || empty($_POST['telefono']) || empty($_POST['direccion']))
            {
                    $alert='<p class="msg_error"> Todos los campos son obligatorios. </p>';
            } else {
                    $proveedor=$_POST['proveedor'];
                    $contacto=$_POST['contacto'];
                    $telefono=$_POST['telefono'];
                    $direccion=$_POST['direccion']; 
                    $usuario_id=$_SESSION['idUser'];

                            $query_insert=mysqli_query($conection, "INSERT INTO proveedor(proveedor,contacto,telefono,direccion, usuario_id)
                            VALUES ('$proveedor','$contacto','$telefono','$direccion','$usuario_id')");
                            if($query_insert){
                                $alert='<p class="msg_save">Proveedor guardado exitosamente. </p>';
                            }else{
                                $alert='<p class="msg_error">Error al guardar el proveedor. </p>';
                            }
                    }
             mysqli_close($conection);
    }



?>
<!DOCTYPE html>
<html lang="en">
<head>

        <meta charset="UTF-8">
<?php include "includes/scripts.php"; ?>
	<title>Registro de proveedores</title>
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
</head>
<body>
    <?php include "includes/header.php"; 
    ?>
	<section id="container">

        <div class="form_register">
                   <h1><i class="far fa-building"></i> Registro de provedores </h1>
                   <hr>
                   <div class="alert"> <?php echo isset($alert)? $alert : ''; ?> </div>

                <form action="" method="post">
                   <label for="proveedor">Proveedor</label>
                   <input type="text" name="proveedor" id="proveedor" placeholder="Nombre del proveedor" onkeypress="return sololetras(event)" onpaste="return false">
                   <label for="contacto"> Contacto </label>
                   <input type="text" name="contacto" id="contacto" placeholder="Nombre completo del contacto" onkeypress="return sololetras(event)" onpaste="return false">
                   <label for="telefono"> Telefono </label>
                   <input type="number" name="telefono" id="telefono" placeholder="Telefono"
                   onkeypress="return solonumeros(event)" onpaste="return false">
                   <label for="direccion">Direccion</label>
                   <input type="text" name="direccion" id="direccion" placeholder="Direccion completa">
                   
                   <input type="submit" value="Guardar Proveedor" class="btn_save">
                </form>


        </div>


	</section>
	<?php include "includes/footer.php"; ?>
</body>
</html>