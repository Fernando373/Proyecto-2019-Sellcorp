 <?php
include 'global/config.php';
include 'global/conexion.php';
include 'carrito.php';

?>
<?php
print_r($_POST);

if ($_POST) {
	$IDVENTA=openssl_decrypt($_POST['IDVENTA'], COD, KEY);
	$IDPRODUCTO=openssl_decrypt($_POST['IDPRODUCTO'], COD, KEY);

	$sentencia=$pdo->prepare("SELECT * FROM tbldetalleventa
								WHERE IDVENTA=:IDVENTA;
								AND IDPRODUCTO=:IDPRODUCTO;
								AND descargado<".DESCARGASPERMITIDAS);
	$sentencia->bindParam(":IDVENTA",$IDVENTA);
	$sentencia->bindParam(":IDPRODUCTO",$IDPRODUCTO);
	$sentencia->execute();

	$listaProductos=$sentencia->fetchAll(PDO::FETCH_ASSOC);

	print_r($listaProductos);
	if ($sentencia->rowCount()>0) {

		echo "Comprobante en descarga...";

		$nombreArchivos="archivos/".$listaProductos[0]['IDPRODUCTO'].".pdf";

		$nuevoNombreArchivo=$_POST['IDVENTA'].$_POST['IDPRODUCTO'].".pdf";

		echo $nuevoNombreArchivo;

		header("Content-Transfer-Encoding: binary");
		header("Content-type: application/force-download");
		header("Content-Disposition: attachment: filename=$nuevoNombreArchivo");
		readfile("$nombreArchivos");

		$sentencia=$pdo->prepare("UPDATE tbldetalleventa set descargado=descargado+1
														WHERE IDVENTA=:IDVENTA AND IDPRODUCTO=:IDPRODUCTO");

		$sentencia->bindParam(":IDVENTA",$IDVENTA);
		$sentencia->bindParam(":IDPRODUCTO",$IDPRODUCTO);
		$sentencia->execute(); 
		} else {
		include 'templates/cabecera.php';
		echo "<br><br><br><br><br><h2>Ya descargaste el comprobante de tu venta, si tienes algun problema comunicate con nosotros </h2>";
		include 'templates/pie.php';

	}

}

?>


