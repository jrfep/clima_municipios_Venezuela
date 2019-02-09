##R --vanilla
##
require(rvest)
setwd("~/tmp")
## Para la representación de la temperatura de la superficie de la tierra utilizamos el producto MOD11A2 derivado de datos de sensores Modis.

##Reference: Wan, Z., Hook, S., Hulley, G. (2015). MOD11A2 MODIS/Terra Land Surface Temperature/Emissivity 8-Day L3 Global 1km SIN Grid V006 [Data set]. NASA EOSDIS LP DAAC. doi: 10.5067/MODIS/MOD11A2.006

## Información sobre la fuente de datos y sus características espaciales y temporales se encuentra en:
## #https://gcmd.nasa.gov/KeywordSearch/Metadata.do?Portal=daacs&KeywordPath=Parameters|LAND+SURFACE|SURFACE+THERMAL+PROPERTIES|LAND+SURFACE+TEMPERATURE|[Freetext%3D%27Modis%27]&OrigMetadataNode=GCMD&EntryId=MOD11A25&MetadataView=Full&MetadataType=0&lbnode=mdlb1

## datos sobre la validación del producto
## #https://landval.gsfc.nasa.gov/ProductStatus.php?ProductID=MOD11

## Aceso directo a los datos:
## #https://e4ftl01.cr.usgs.gov/MOLT/

repositorio <- "https://e4ftl01.cr.usgs.gov/MOLT/"

## existen varias versiones disponibles, la version 6 es más reciente, pero no se ha actualizado la información sobre su validación, por tanto usamos la versión 005
## # MOD11A2.004/ 
## # MOD11A2.005/ 
## # MOD11A2.006/      

versiones <- "MOD11A2.005/"

## Definimos el directorio para descargar los datos:
mapoteca <- "~/mapas/download/MOD11A2/V5/hdfs"
system(sprintf("mkdir -p %s",mapoteca))

## descargamos la lista de directorios (fechas de la serie de tiempo)
download.file(sprintf("%s%s",repositorio,versiones),
              sprintf("%s/indice.html",mapoteca))

## leemos esta lista:
pg <- read_html(sprintf("%s/indice.html",mapoteca))
lista.fechas <- grep("^2[0-9]+",lapply(html_nodes(pg,"a"),xml_text),value=T)

## para cada fecha descargamos la lista de archivos, y extraemos los archivos que cubren Venezuela, definidos por las files (h11 y h12) y columnas (v07 y v08).

##aa <- lista.fechas[1]
for (aa in lista.fechas) {
    download.file(sprintf("%s%s%s",repositorio,versiones,aa),
                  sprintf("%s/fecha.html",mapoteca))
    
    pg1 <- read_html(sprintf("%s/fecha.html",mapoteca))
    hdfs <- unlist(lapply(html_nodes(pg1,"a"),xml_attr,"href"))
    
    cat(file=sprintf("%s/lista_archivos_descarga",mapoteca),
        sprintf("%s%s%s%s\n",repositorio,versiones,aa,
                grep("hdf",grep("h1[12]v0[78]",hdfs,value=T),value=T)),
        append=T)
}

## para descargar nos colocamos en la carpeta destino
setwd(mapoteca)

## La descarga requiere registrarse en https://urs.earthdata.nasa.gov
## Se realiza el acceso al sitio por cualquier navegador y se exportar las credenciales de acceso de la sesión (por ejemplo con Advance Cookie Manager add-on en Firefox, https://www.facebook.com/cookiemanager/ exporto a un archivo "galletas")

system(sprintf("wget --load-cookies galletas --continue -i %s/lista_archivos_descarga",mapoteca))

