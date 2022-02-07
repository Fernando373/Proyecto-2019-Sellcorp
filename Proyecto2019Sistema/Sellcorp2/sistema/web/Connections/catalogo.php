<?php
$hostname_catalogo = "localhost";
$database_catalogo = "tienda";
$username_catalogo = "root";
$password_catalogo = "";
$catalogo = mysql_pconnect($hostname_catalogo,$username_catalogo,$password_catalogo) or trigger_error(mysql_error(),E_USER_ERROR);
?>