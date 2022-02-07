<?php
include 'global/config.php';
include 'global/conexion.php';
include 'carrito.php';
include 'templates/cabecera.php' 
?>
<?php
// print_r($_GET);

/*$ClientID="AfzF-RJ7ED57ucZ70KKZf3dVonG5mXrQkJX9UpC2IxC_2EMk-hyBcZhRRhz348HCcwFUq2oSq8s54QEQ";
$Secret="EK_WAGplkXgkmXcuVxgwyCbH0FyB457uL_kmNZnDX9KBf_cueDeIRo2NNyBsqsXTEPfmHydKz-LWBIpK";*/

$login = curl_init(LINKAPI."/v1/oauth2/token");
curl_setopt($login,CURLOPT_RETURNTRANSFER,TRUE);
curl_setopt($login,CURLOPT_USERPWD,CLIENTID.":".SECRET);
curl_setopt($login, CURLOPT_POSTFIELDS,"grant_type=client_credentials");
$Respuesta = curl_exec($login);


 // print_r($Respuesta);

 $objRespuesta = json_decode($Respuesta);
 $AcessToken = $objRespuesta->access_token;
 // print_r($AcessToken);

  $venta =curl_init(LINKAPI."/v1/payments/payment/".$_GET['paymentID']);

  curl_setopt($venta,CURLOPT_HTTPHEADER,array("Content-Type: application/json","Authorization: Bearer ".$AcessToken));

  curl_setopt($venta,CURLOPT_RETURNTRANSFER,TRUE);

  $resv = curl_exec($venta);

 //print_r($resv);

  $objDatosTransaccion = json_decode($resv);
 // print_r($objDatosTransaccion->payer->payer_info->email);

  $state=$objDatosTransaccion->state;
  $email=$objDatosTransaccion->payer->payer_info->email;

  $total = $objDatosTransaccion->transactions[0]->amount->total;
  $currency = $objDatosTransaccion->transactions[0]->amount->currency;
  $custom = $objDatosTransaccion->transactions[0]->custom;

  $clave=explode("#", $custom);

  $SID=$clave[0];
  $claveVenta=openssl_decrypt($clave[1],COD,KEY);

  curl_close($venta);
  curl_close($login);

  // echo $claveVenta;

  if ($state=="approved") {
  	$mensajePaypal="<h3>Pago aprobado</h3>";
  	$sentencia=$pdo->prepare("UPDATE tblventas SET PaypalDatos = :PaypalDatos, 
  												status = 'aprobado' 
  												WHERE tblventas.ID = :ID;");
  	$sentencia->bindParam(":ID",$claveVenta);
  	$sentencia->bindParam(":PaypalDatos",$resv);
  	$sentencia->execute();

  	$sentencia=$pdo->prepare("UPDATE tblventas SET status= 'completo'
  												WHERE tblventas.ClaveTransaccion=:ClaveTransaccion;
  												AND tblventas.Total=:TOTAL;
  												AND tblventas.ID=:ID;");
  	$sentencia->bindParam(":ClaveTransaccion",$SID);
  	$sentencia->bindParam(":TOTAL",$total);
  	$sentencia->bindParam(":ID",$claveVenta);
  	$sentencia->execute();

  	$completado=$sentencia->rowCount();

    session_destroy();
  }else{
  	$mensajePaypal = "<h3>Hay un problema con el pago </h3";

  	
  }
  // echo $mensajePaypal;
?>
<div class="jumbotron">
	<h1 class="display-4"> Listo! </h1>
	<hr class="my-4">
	<p class="lead"><?php echo $mensajePaypal; ?></p>
	<p><?php 
		if ($completado>=1) {

			$sentencia=$pdo->prepare("SELECT * FROM tbldetalleventa as tv , producto as p WHERE tv.IDPRODUCTO=p.codproducto AND tv.IDVENTA =:ID;");

		  	$sentencia->bindParam(":ID",$claveVenta);
  			$sentencia->execute();

  			$listaProductos=$sentencia->fetchAll(PDO::FETCH_ASSOC);

  			//print_r($listaProductos);	
		}
	?>
		<div class="row">
			<?php foreach($listaProductos as $producto){ ?>
			<div class="col-3">
				<div class="card">
					<img class="card-img-top" src="<?php echo $producto['foto']; ?>">
					<div class="card-body">
						
						<p class="card-text"><?php echo $producto['descripcion']; ?></p>

            <?php if($producto['DESCARGADO']<DESCARGASPERMITIDAS) { ?>
    <form action="descargas.php" method="post">
      <input type="hidden" name="IDVENTA" id="" value="<?php echo openssl_encrypt($claveVenta, COD, KEY); ?>">
      <input type="hidden" name="IDPRODUCTO" id="" value="<?php echo openssl_encrypt($producto['IDPRODUCTO'],COD,KEY); ?>">
      <button class="btn btn-success" type="submit">Descargar Recibo.</button>
  <?php }else{ ?>
    <button class="btn btn-success" type="button" disabled>Descargar Recibo.</button>
  <?php } ?>
  
</form>

					</div>
				</div>

			</div>

		<?php } ?>
		</div> <br>
		<br>
  </p></div>
    

<?php include 'templates/pie.php'; ?>