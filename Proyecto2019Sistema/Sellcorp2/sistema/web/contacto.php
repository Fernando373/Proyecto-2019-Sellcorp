<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Catalogo | Web</title>

    <!-- Bootstrap -->
    <link href="css/bootstrap-4.3.1.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="css/estilos.css">

  </head>
  <body>
	  <?php include("includes/menu.php") ?>
  
    
    <div class="container">
       <h1 class="text-center">Llamenos 65894651</h1>
       <div class="row">
        <div class="col-sm-4">
            <p class="justificado">
         Sus contactos son muy importantes para nosotros, por favor llene los campos solicitados a continuacion y envianos sus suguerencias.
       </p>
        </div>
        <div class="col-sm-8">
          <p class="justificado">
         Contactenos, atenderemos sus dudas y le presentaremos un esquema de acuerdo a sus necesidades. Use alguno de los medios disponibles o deje sus datos y nos comunicaremos con usted lo mas pronto posible.
       </p>
       <div class="col-sm-offset-1 col-sm-10 col-lg-offset-2 col-lg-8 form-contacto">
       <form class="form-horizontal" name="çontacto" id="contacto" action="">
        <div class="form-group">
          <div class="col-xs-offset-1 col-xs-10">
        <label>Nombre:</label>
         <input class="form-control" type="text" name="nombre" id="nombre" required placeholder="Nombre Completo">
       </div>
     </div>
         <div class="form-group">
           <div class="col-xs-offset-1 col-xs-10">
         <label>Email:</label>
         <input class="form-control" type="email" name="email" id="email" required placeholder="Correo Electronico">
       </div>
     </div>
      <div class="form-group">
        <div class="col-xs-offset-1 col-xs-10">
         <label>Web:</label>
         <input class="form-control" type="text" name="web" id="web" required placeholder="Sitio web">
       </div>
     </div>
      <div class="form-group">
        <div class="col-xs-offset-1 col-xs-10">
         <label>Mensaje:</label>
         <textarea class="form-control" name="msj" id="msj" rows="6" required placeholder="Ingrese su Mensaje"></textarea>
       </div>
     </div>
      <div class="form-group">
          <div class="col-xs-offset-1 col-xs-10">
         <input class="btn btn-success btn-lg pull-right" type="submit" value="Enviar"> 
       </div>
     </div>
       </form>
     </div>
        </div>
        </div>
     
       
    </div>
	  <?php include("includes/footer.php") ?>
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) --> 
    <script src="js/jquery-3.3.1.min.js"></script>

    <!-- Include all compiled plugins (below), or include individual files as needed --> 
    <script src="js/popper.min.js"></script>
    <script src="js/bootstrap-4.3.1.js"></script>
  </body>
</html>
