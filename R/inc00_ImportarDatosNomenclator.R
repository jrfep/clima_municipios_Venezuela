##R --vanilla
#######
##Nomenclator ('Gacetero','Gacetilla') de Venezuela disponible de varias fuentes: ######

## #(1) la página de DIVA-GIS: http://www.diva-gis.org/gdata
## #descargamos (archivo sin fecha de actualización):
## #download.file("http://biogeo.ucdavis.edu/data/diva/gaz/VEN_gaz.zip","data/VEN_gaz.zip")
## #descomprimimos
##unzip("data/VEN_gaz.zip")
## #leemos el archivo en formato 'dbf'
##require(foreign)
##gaz.ven <- read.dbf("data/VEN.dbf",as.is=T)
## #seleccionamos exclusivamente los centros poblados (clase 'P')
##gaz.ven <- subset(gaz.ven,F_CLASS %in% "P")

## #(2) la página de NGA: http://geonames.nga.mil/gns/html/
## #descargamos (archivo actualizado en 2017-04-07):
## #download.file("http://geonames.nga.mil/gns/html/cntyfile/ve.zip","data/ve.zip")
## #descomprimimos
##unzip("data/ve.zip")
## #Nota de la referencia: "Toponymic information is based on the Geographic Names Database, containing official standard names approved by the United States Board on Geographic Names and maintained by the National Geospatial-Intelligence Agency. More information is available at the Maps and Geodata link at www.nga.mil. The National Geospatial-Intelligence Agency name, initials, and seal are protected by 10 United States Code Section 425."
## #descripción de campos: http://geonames.nga.mil/gns/html/gis_countryfiles.html
