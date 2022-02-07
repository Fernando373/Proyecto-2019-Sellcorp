<?php
include 'global/config.php';
include 'carrito.php';
include 'templates/cabecera.php'
?>

<br>
<h3>Lista del carrito</h3>
<?php if(!empty($_SESSION['CARRITO'])) {?>
<table class="table table-light table-bordered">
    <tbody>
        <tr>
            <th width="40%">Descripcion</th>
            <th width="15%" class="text-center">Cantidad</th>
            <th width="20%" class="text-center">Precio</th>
            <th width="20%" class="text-center">Sub Total</th>
            <th width="5%">--</th>
        </tr>
        <?php $total = 0;?>
        <?php foreach($_SESSION['CARRITO'] as $indice=>$producto){?>
        <tr>
        <td width="40%"><?php echo $producto['descripcion']?></td>
            <td width="15%" class="text-center"><?php echo $producto['cantidad']?></td>
            <td width="20%" class="text-center"><?php echo $producto['precio']?></td>
            <td width="20%" class="text-center"><?php echo number_format($producto['precio']*$producto['cantidad'],2); ?></td>
            <td width="5%">
            
            <form action="" method="post">
                <input type="hidden" name="id" id="id" value="<?php echo  openssl_encrypt($producto['codproducto'],COD,KEY);?>">
            <button class="btn btn-danger" type="submit" name="btnAccion" value="Eliminar">Eliminar</button></td>

            </form>
            
        </tr>
        <?php $total = $total+($producto['precio']*$producto['cantidad']);?>
        <?php } ?>
        <tr>
            <td colspan="3" align="right"><h3>Total</h3></td>
            <td align="right"><h3>Bs.<?php echo number_format($total,2); ?></h3></td>
            <td></td>
        </tr>

        <tr>
            <td colspan="5">
            <form action="pagar.php" method="post">
                <div class="alert alert-success" role="alert">
                <div class="form-group">
                    <label for="my-input">Correo de contacto:</label>
                    <input id="email" name="email" class="form-control" type="email" placeholder="Ingrese su correo" required>
                </div>
                <small id="emailHelp" class="form-text text-muted">
                    El recibo de este producto se enviara al correo
                </small>
                </div>
                <button class="btn btn-primary btn-lg btn-block" type="submit" name="btnAccion" value="proceder" >Proceder a Pagar</button>
            
            </form>
                

            </td>
        </tr>
    </tbody>
</table>
<?php }else{  ?>
    <div class="alert alert-success">
        No tiene productos en el carrito
    </div>
<?php } ?>
<?php include 'templates/pie.php'; ?>