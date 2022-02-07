<?php
session_start();

$mensaje='';

if(isset($_POST['btnAccion'])){
    switch ($_POST['btnAccion']){
        case 'Agregar'; //MOSTRAR Y AGREGAR LOS PRODUCTOS AL CARRITO
        if(is_numeric( openssl_decrypt($_POST['id'],COD,KEY ))){
            $codproducto=openssl_decrypt($_POST['id'],COD,KEY);
            $mensaje.="ok ID".$codproducto."<br/>";
        }else{
            $mensaje.="error".$codproducto."<br/>";
        }
        if(is_string( openssl_decrypt($_POST['descripcion'],COD,KEY ))){
            $descripcion=openssl_decrypt($_POST['descripcion'],COD,KEY);
        }else{  $mensaje.="error".$descripcion."<br/>"; break;}
        
        if(is_numeric( openssl_decrypt($_POST['cantidad'],COD,KEY ))){
            $cantidad=openssl_decrypt($_POST['cantidad'],COD,KEY);
        }else{$mensaje.="error".$cantidad."<br/>"; break;} 
        
        if(is_numeric( openssl_decrypt($_POST['precio'],COD,KEY ))){
            $precio=openssl_decrypt($_POST['precio'],COD,KEY);
        }else{ $mensaje.="error".$precio."<br/>";  break;}

        if(!isset($_SESSION['CARRITO'])){
            $producto=array(
                'codproducto'=>$codproducto,
                'descripcion'=>$descripcion,
                'cantidad'=>$cantidad,
                'precio'=>$precio
            );
            $_SESSION['CARRITO'][0]=$producto;
            $mensaje="Producto agregado al carrito";
        }else{
            $idProductos=array_column($_SESSION['CARRITO'],"codproducto");
            if(in_array($codproducto,$idProductos)){
                echo "<script>alert('El producto ya ha sido seleccionado');</script>";
                $mensaje="";
            }else{ 
            $NumeroProductos=count($_SESSION['CARRITO']);
            $producto=array(
                'codproducto'=>$codproducto,
                'descripcion'=>$descripcion,
                'cantidad'=>$cantidad,
                'precio'=>$precio
            );
            $_SESSION['CARRITO'][$NumeroProductos]=$producto;
            $mensaje="Producto agregado al carrito";
            }
        }
        //$mensaje=print_r($_SESSION,true);
       
        break;
        case "Eliminar":
        if(is_numeric( openssl_decrypt($_POST['id'],COD,KEY ))){
            $codproducto=openssl_decrypt($_POST['id'],COD,KEY);
            foreach($_SESSION['CARRITO'] as  $indice=>$producto){
                if($producto['codproducto']==$codproducto){
                    unset($_SESSION['CARRITO'][$indice]);
                    $mensaje="ELEMENTO BORRADO";
                }
            }
            
        }else{
           // $mensaje.="error".$codproducto."<br/>";
        }
        break;

    }
}

?>