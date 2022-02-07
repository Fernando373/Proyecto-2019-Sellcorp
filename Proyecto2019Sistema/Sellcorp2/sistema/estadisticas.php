<?php
//Activamos el almacenamiento en el buffer


  require_once "modelo/consultas.php";

  //Datos para mostrar el gráfico de barras de las ventas
 $consulta = new Consultas();

   //Datos para mostrar el gráfico de barras de los vendedores
/*  $vendedores = $consulta->Vendedores();
  $nombre='';
  $totalesu='';
  while ($regnombre= $vendedores->fetch_object()) {
    $nombre=$nombre.'"'.$regnombre->nombre .'",';
    $totalesu=$totalesu.$regnombre->total .','; 
  }
*/
  //Datos para mostrar el gráfico de barras de las ventas
  $productos = $consulta->Productos();
  $nombrep='';
  $total='';
  while ($regnombrep= $productos->fetch_object()) {
    $nombrep=$nombrep.'"'.$regnombrep->nombre .'",';
    $total=$total.$regnombrep->precio .','; 
  }

  //Quitamos la última coma
  $nombre=substr($nombre, 0, -1);
  $total=substr($total, 0, -1);

?>
<!--Contenido-->
      <!-- Content Wrapper. Contains page content -->
      <div class="content-wrapper">        
        <!-- Main content -->
        <section class="content">
            <div class="row">
              <div class="col-md-12">
                  <div class="box">
                    <div class="box-header with-border">
                          <h1 class="box-title">Estadisticas </h1>
                        <div class="box-tools pull-right">
                        </div>
                    </div>
                    <!-- /.box-header -->
                    <!-- centro -->
                   
                    <div class="panel-body">
                        <div class="col-lg-6 col-md-6 col-sm-6 col-xs-6">
                          <div class="box box-primary">
                              <div class="box-header with-border">
                                Compras 
                              </div>
                              <div class="box-body">
                                <canvas id="compras" width="400" height="300"></canvas>
                              </div>
                          </div>
                        </div>
                        <div class="col-lg-6 col-md-6 col-sm-6 col-xs-6">
                          <div class="box box-primary">
                              <div class="box-header with-border">
                                Ventas 
                              </div>
                              <div class="box-body">
                                <canvas id="ventas" width="400" height="300"></canvas>
                              </div>
                          </div>
                        </div>
                       <div class="col-lg-6 col-md-6 col-sm-6 col-xs-6">
                          <div class="box box-primary">
                              <div class="box-header with-border">
                                Mejores Vendedores
                              </div>
                              <div class="box-body">
                                <canvas id="vendedores" width="400" height="300"></canvas>
                              </div>
                          </div>
                        </div>
                         <div class="col-lg-6 col-md-6 col-sm-6 col-xs-6">
                          <div class="box box-primary">
                              <div class="box-header with-border">
                                Productos Mas Vendidos
                              </div>
                              <div class="box-body">
                                <canvas id="productos" width="400" height="300"></canvas>
                              </div>
                          </div>
                        </div>
                        
                    </div>
                    <!--Fin centro -->
                  </div><!-- /.box -->
              </div><!-- /.col -->
          </div><!-- /.row -->
      </section><!-- /.content -->

    </div><!-- /.content-wrapper -->
  <!--Fin-Contenido-->


<script src="estadistica/js/chartJS/chart.min.js"></script>
<script src="estadistica/js/chartJS/Chart.bundle.min.js"></script> 
<script type="text/javascript">


var ctx = document.getElementById("productos").getContext('2d');
var productos = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: [<?php echo $nombrep; ?>],
        datasets: [{
            label: 'Mejores Productos',
            data: [<?php echo $preciop; ?>],
            backgroundColor: [
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(255, 206, 86, 0.2)',
                'rgba(75, 192, 192, 0.2)',
                'rgba(153, 102, 255, 0.2)',
                'rgba(255, 159, 64, 0.2)',
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(255, 206, 86, 0.2)',
                'rgba(75, 192, 192, 0.2)'
            ],
            borderColor: [
                'rgba(255,99,132,1)',
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)',
                'rgba(75, 192, 192, 1)',
                'rgba(153, 102, 255, 1)',
                'rgba(255, 159, 64, 1)',
                'rgba(255,99,132,1)',
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)',
                'rgba(75, 192, 192, 1)'
            ],
            borderWidth: 1
        }]
    },
    options: {
        scales: {
            yAxes: [{
                ticks: {
                    beginAtZero:true
                }
            }]
        }
    }
});


</script>


</script>


<?php 

ob_end_flush();
?>


