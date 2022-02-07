<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Catalogo | Web</title>

    <!-- Bootstrap -->
    <link href="css/bootstrap-4.3.1.css" rel="stylesheet">

  </head>
  <body>
	  <?php include("includes/menu.php") ?>
  
    
    <div class="container">
       <h1 class="text-center">Catalogo</h1>
       <?php
$query = ($catalogo,"SELECT * FROM");
?>
    </div>
    <hr>
	  <?php include("includes/footer.php") ?>
    <hr>
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) --> 
    <script src="js/jquery-3.3.1.min.js"></script>

    <!-- Include all compiled plugins (below), or include individual files as needed --> 
    <script src="js/popper.min.js"></script>
    <script src="js/bootstrap-4.3.1.js"></script>
  </body>
</html>
