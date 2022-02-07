$(document).ready(function() {

	$('#confirmar_clave').keyup(function() {

		var clave = $('#clave').val();
		var confirmar_clave = $('#confirmar_clave').val();
		//var crearusuario = $('#crearusuario').val();
		
		if ( clave == confirmar_clave ) {
			$('#error2').text("Coinciden!").css("color","green");
			//crearusuario.disabled = true;
			//$('#btn_save').visible = true;
		} else {
			$('#error2').text("No Coinciden!").css("color","red");
			//crearusuario.disabled = false;
			//$('#btn_save').visible = false;
		}
		if (confirmar_clave == "") {
			$('#error2').text("No se puede dejar en blanco").css("color","red");
		}

	});

});


$(document).ready(function() {

	$('#clave').keyup(function() {

		var clave = $('#clave').val();
		//var confirmar_clave = $('#confirmar_clave').val();
		//var crearusuario = $('#crearusuario').val();
		
		if (clave > 8 ) {
			$('#error1').text("Seguridad media!").css("color","green");
			//crearusuario.disabled = true;
			//$('#btn_save').visible = true;
		} else {
			$('#error1').text("Seguridad baja!").css("color","red");
			//crearusuario.disabled = false;
			//$('#btn_save').visible = false;
		}
		if (clave > 10) {
			$('#error1').text("Segurirdad alta!").css("color","gren");
		}

	});

});

$(document).ready(function() {

	$('#txt_cant_producto').keyup(function() {

		var cant = $('#txt_cant_producto').val();
		var exi = $('#txt_existencia').val();
	if (cant < exi){
			
		$('#error1').text("Bajo en stock").css("color","green");

	}

	});

});

					
