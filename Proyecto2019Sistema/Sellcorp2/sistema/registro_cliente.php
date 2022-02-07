<?php
session_start();

    include "../conexion.php";
    
    if(!empty($_POST))
    {
            $alert='';
            if(empty($_POST['nombre']) || empty($_POST['telefono']) || empty($_POST['direccion']))
            {
                    $alert='<p class="msg_error"> Todos los campos son obligatorios. </p>';
            } else {
                    $nit        = $_POST['nit'];
                    $nombre     = $_POST['nombre'];  
                    $telefono   = $_POST['telefono']; 
                    $direccion  = $_POST['direccion']; 
                    $usuario_id = $_SESSION['idUser'];

                    $result = 0;

                    if (is_numeric($nit) and $nit !=0) {
                       $query = mysqli_query($conection,"SELECT * FROM cliente WHERE nit='$nit' "); 
                       $result = mysqli_fetch_array($query);
                    }
                    if($result > 0 ){
                            $alert='<p class="msg_error">El NIT ya existe, ingrese otro. </p>';
                      }else {
                            $query_insert=mysqli_query($conection, "INSERT INTO cliente(nit,nombre,telefono,direccion,usuario_id)
                            VALUES ('$nit','$nombre','$telefono','$direccion','$usuario_id')");
                            if($query_insert){
                                $alert='<p class="msg_save">Cliente guardado exitosamente. </p>';
                            }else{
                                $alert='<p class="msg_error">Error al guardar el cliente. </p>';
                            }
                    }
            }
    }



?>
<!DOCTYPE html>
<html lang="en">
<head>
        <meta charset="UTF-8">
<?php include "includes/scripts.php"; ?>
  <title>Registro de clientes</title>
  
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
                   <h1> Registro de clientes </h1>
                   <hr>
                   <div class="alert"> <?php echo isset($alert)? $alert : ''; ?> </div>

                <form action="" method="post">
                  <label for="nit"> NIT </label>
                   <input type="number" name="nit" id="nit" placeholder="Numero de nit" onkeypress="return solonumeros(event)" onpaste="return false">
                   <label for="nombre"> Nombre </label>
                   <input type="text" name="nombre" id="nombre" placeholder="Nombre completo" onkeypress="return sololetras(event)" onpaste="return false">
                   <label for="telefono"> Telefono </label>
                   <input type="number" name="telefono" id="telefono" placeholder="Telefono" onkeypress="return solonumeros(event)" onpaste="return false">
                   <label for="direccion">Direccion</label>
                   <input type="text" name="direccion" id="direccion" placeholder="Direccion completa">
                   <input type="submit" value="Guardar Cliente" class="btn_save">
                </form>


        </div>


  </section>
  <?php include "includes/footer.php"; ?>
</body>
</html>