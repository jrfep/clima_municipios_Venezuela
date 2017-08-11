##R --vanilla

## Los datos originales de las estaciones climáticas de Zulia, Bolívar, Lara y Falcón fueron descargados en octubre 2015 de la página del Instituto Nacional de Meteorología e Hidrología de la República Bolivariana de Venezuela (INAMEH, http://www.inameh.gob.ve/web/, enlace de "Climatología" / "Datos Hidrometeorológicos"). En mayo de 2017 este enlace está roto (mensaje "No support") y no se pudo completar la descarga de datos de otros estados

## Para Agosto de 2017 los datos estaban disponibles nuevamente a través de un formulario web ubicado en http://estaciones.inameh.gob.ve/descargaDatos/vistas/bajarArchivo.php
## Aparentemente, a través de este formulario se pueden descargar datos recientes (2015 a 2017) de todos los estados.

## El procedimiento para descargar estos datos es el siguiente:

## definimos la carpeta destino para la descarga:
dir.datos <- "../data/INAMEH"

## seleccionamos algunas variables a descargar, por ejemplo:
##1600 # temperatura del aire
##1610 # temperatura máxima del aire
##1620 # temperatura mínima del aire
##3800 # precipitacion

for (vv in c(1600,1610,1620,3800)) {
    ## creamos la carpeta para guardar archivos de cada variable
    system(sprintf("mkdir -p %s/var%s",dir.datos,vv))
    ## lista de los IDs para los estados
    for (edos in 1:24) {
        ## definimos los años de interés
        ##(aparentemente solo disponible entre 2015 y 2017)
        for (yy in 2010:2017) {
            ## construimos una solicitud de descarga que enviamos con el
            ## programa 'wget' usando la opción 'post-data' y grabamos a un
            ## archivo en la carpeta seleccionada, con el año y código de
            ## estado:
            system(sprintf("wget --post-data='tipo=3&idestado=%1$s&ano=%2$s&elemento=%3$s' http://estaciones.inameh.gob.ve/descargaDatos/vistas/descargarArchivo.php -O %4$s/var%3$s/%2$s_%1$s.xls",edos,yy,vv,dir.datos))
        }
    }
}

## tomar en cuenta la siguiente leyenda en la página de descarga:
## 'Para los datos Mensuales seran descargados todos los datos mensuales del año seleccionado CON VERIFICACIÓN DE CALIDAD.'
## '77777.7: Dato Faltante.'
## '66666.6: Dato Erroneo.'
## '99999.9: Dato Perdido.'
