<?php
include 'global/config.php';
include 'global/conexion.php';
include 'carrito.php';
include 'templates/cabecera.php' 
?>
<br/>
<?php
 
    if($_POST){
        $total=0;
        $SID=session_id();
        $Correo=$_POST['email'];

        foreach($_SESSION['CARRITO'] as  $indice=>$producto){
            $total=$total+($producto['precio']*$producto['cantidad']);


        }

        $sentencia = $pdo->prepare("INSERT INTO tblventas (ID,ClaveTransaccion, PaypalDatos, Fecha, Correo, Total, status, estado) 
        VALUES (NULL,:ClaveTransaccion, '', NOW(),:Correo,:Total, 'pendiente','1');");
        $sentencia->bindParam(":ClaveTransaccion",$SID);
        $sentencia->bindParam(":Correo",$Correo);
        $sentencia->bindParam(":Total",$total);
        $sentencia->execute();
        $idVenta=$pdo->lastInsertId();

        foreach($_SESSION['CARRITO'] as  $indice=>$producto){

            $sentencia = $pdo->prepare("INSERT INTO `tbldetalleventa` (`ID`, `IDVENTA`, `IDPRODUCTO`, `PRECIOUNITARIO`, `CANTIDAD`, `DESCARGADO`) 
            VALUES (NULL,:IDVENTA,:IDPRODUCTO,:PRECIOUNITARIO,:CANTIDAD, '0');");
             $sentencia->bindParam(":IDVENTA",$idVenta);
             $sentencia->bindParam(":IDPRODUCTO",$producto['codproducto']);
             $sentencia->bindParam(":PRECIOUNITARIO",$producto['precio']);
             $sentencia->bindParam(":CANTIDAD",$producto['cantidad']);
             $sentencia->execute();

        }
       // echo "<h3>".$total."</h3>";
        
    }
?>
<!--  
<script src="https://www.paypal.com/sdk/js?client-id=sb"></script>
<script>paypal.Buttons().render('body');</script> -->
<script src="https://www.paypalobjects.com/api/checkout.js"></script>

<style>
    /*Media query for mobile viewport*/
    @media screen and (max-width: 400px) {
        #paypal-button-container{
            width: 100%;
        }
    }
     /*Media query for desktop viewport*/
     @media screen and (min-width: 400px){
        #paypal-button-container{
            width: 250px;
            display: inline-block;

        }
    }
    
</style>

<div class="jumbotron text-center">
    <h1 class="display-4">Estas a punto de completar tu compra!!</h1>
    <p class="lead">Paga con paypal la cantidad de: 
        <h4>Bs.<?php echo number_format($total,2); ?></h4>
        <!-- boton de paypal -->
        <div id="paypal-button-container"></div>
    </p>
    
    <p>Tu recibo podra ser descargado para que puedas pasar por tus productos, o te los enviamos, una vez que se procese el pago<br>
    <strong>(Para aclarar tus dudas contactanos fmurguia12@gmail.com)</strong>
    </p>
</div>
<script>
    paypal.Button.render({
        env: 'sandbox', //sandbox | production
        style: {
            label: 'checkout', //checkout | credit | pay | buynow| generic
            size: 'responsive', //small | medium | large | responsive
            shape: 'pill', //pill | rect
            color: 'gold' // gold | blue | silver | black
        },
        //PayPal Cliente IDs - replace width your own
        // Create a PayPal app: https://developer.paypal.com/developer/aplications/create
        client: {
            sandbox : 'AfzF-RJ7ED57ucZ70KKZf3dVonG5mXrQkJX9UpC2IxC_2EMk-hyBcZhRRhz348HCcwFUq2oSq8s54QEQ',
            production: 'AaObB5QXH-LvAEIW12-5Z1ZGbZPhkx8j3GOV2v0fJ85nOy2aBG6lue5wxKR_XF4GSpQwsWU-WDjeYpWI'
        },
        //Wait fot the PayPal button to be clicked
        payment: function(data, actions){
            return actions.payment.create({
                payment: {
                    transactions: [
                        {
                            amount: { total: '<?php echo $total; ?>', currency: 'MXN' },
                            description:"Compra de productos a Sellcorp:Bs<?php echo number_format($total,2);?>",
                            custom:"<?php echo $SID;?>#<?php echo openssl_encrypt($idVenta,COD,KEY); ?>"
                        }
                    ]
                }
            });
        },
        //WAIT FOR the payment to be authorized by the customer
        onAuthorize: function(data, actions){
            return actions.payment.execute().then(function() {
                console.log(data);
                window.location="verificador.php?paymentToken="+data.paymentToken+"&paymentID="+data.paymentID;
            });
        }
    }, '#paypal-button-container');
    </script>





<?php include 'templates/pie.php'; ?> 