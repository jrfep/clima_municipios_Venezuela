## Los datos originales de las estaciones climáticas de Zulia, Bolívar, Lara y Falcón fueron descargados en octubre 2015 de la página del Instituto Nacional de Meteorología e Hidrología de la República Bolivariana de Venezuela (INAMEH, http://www.inameh.gob.ve/web/, enlace de "Climatología" / "Datos Hidrometeorológicos"). En mayo de 2017 este enlace está roto (mensaje "No support") y no se pudo completar la descarga de datos de otros estados.

## Para Agosto de 2017 los datos estaban disponibles nuevamente a través de un formulario web ubicado en http://estaciones.inameh.gob.ve/descargaDatos/vistas/bajarArchivo.php
## Aparentemente, a través de este formulario se pueden descargar datos recientes de todos los estados, pero existen notables vacíos en la cobertura temporal. Para la mayoría de los estados hay datos de 2000 a 2017 pero con grandes vacíos entre 2006 y 2012.
## El procedimiento para descargar estos datos desde una sesión de 'R' y con ayuda del programa 'wget' se detalla a continuación:

##R --vanilla
require(gdata)

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
        ##(aparentemente solo disponible entre 2000 y 2017, con vacíos)
        for (yy in 2000:2017) {
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

## También aparecen valores de 88888.8 en las series de tiempo, pero no se explica a que se refiere este código.


## Resumimos todos los datos de precipitación

dts <- data.frame()
for (edos in 1:24) {
    for (yy in 2017:1990) {
        dd <- try(read.xls(sprintf("%s/var3800/%s_%s.xls",dir.datos,yy,edos),stringsAsFactors=F))
        if (!any(class(dd) %in% "try-error"))
            dts <- rbind(dts,dd)
    }
}
dts <- subset(dts,!valor %in% c(66666.6,77777.7,88888.8,99999.9))
dts$fch <- sapply(as.character(dts$Fecha),function(x) as.numeric(strsplit(x,"-")[[1]][1])+((as.numeric(strsplit(x,"-")[[1]][2])-0.5)/12))

## Gráfica de valores de precipitación por fecha
plot(valor~fch,dts)

##para ver la distribución de registros por año
table(floor(dts$fch))


