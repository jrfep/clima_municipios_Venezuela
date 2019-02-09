##R --vanilla
## cargar paquetes necesarios
require(raster)

## definir directorios de trabajo
data.dir <- "../data"
out.dir <- "../output/svg"


## cargar algunas funciones útiles
source("inc00_funciones.R")

## descargamos archivo de nomenclatór para Venezuela
## ver:
## source("inc00_ImportarDatosNomenclator.R")
## #leemos el archivo con los centros poblados
gaz.ven <- read.table(sprintf("%s/ve_populatedplaces_p.txt",data.dir),sep="\t",header=T)

## #transformamos este objeto en un objeto espacial
gaz.ven$x <- as.numeric(gaz.ven$LONG)
gaz.ven$y <- as.numeric(gaz.ven$LAT)
coordinates(gaz.ven) <- c("x","y")
proj4string(gaz.ven) <- "+proj=longlat +datum=WGS84 +no_defs"

## descargamos archivo de municipios para Venezuela
## ver:
## source("inc00_ImportarDatosMunicipios.R")
## #leemos el archivo 
adm2 <- readRDS(sprintf("%s/VEN_adm2.rds",data.dir))

gaz.ven.adm2 <- over(gaz.ven,adm2)

## #a partir de los datos derivados de Modis creamos una serie de tiempo
## #de mapas de temperatura diurna de la superficie de la tierra (LST_Day)
## #los mapas están guardado en:
mapoteca <- "~/mapas/Venezuela/LST_Day_1km/"

## ¡Aquí empieza la diversión!
## aquí hacemos una serie de tiempo con el valor de las imágenes modis
## para cada localidad y cada año y las concatenamos
## Primero la variable LST day (temperatura diurna de la superficie de la tierra)
rm(lsts)
for (ff in sprintf("A%s",2000:2011)) {
    mps <- stack(dir(mapoteca,ff,full.names=T))
    
    gaz.lst <- extract(mps,gaz.ven)
    if (!exists("lsts")) {
        lsts <- mSSt(gaz.lst,ll=7500,ul=NA,cf=0.02,os=-273.15)
    } else {
        lsts <- cbind(lsts,mSSt(gaz.lst,ll=7500,ul=NA,cf=0.02,os=-273.15))
    }
}

## Ahora la variable LST night (... ya deben imaginarse lo que significa)

mapoteca <- "~/mapas/Venezuela/LST_Night_1km/"
for (ff in sprintf("A%s",2000:2011)) {
    mps <- stack(dir(mapoteca,ff,full.names=T))
    
    gaz.lst <- extract(mps,gaz.ven)
    lsts <- cbind(lsts,mSSt(gaz.lst,ll=7500,ul=NA,cf=0.02,os=-273.15))
}

## Ahora podemos calcular los promedios totales, diurnos y nocturnos para cada localidad

mLST <- rowMeans(lsts,na.rm=T)
mLSTd <- rowMeans(lsts[,grep("Day",colnames(lsts))],na.rm=T)
mLSTn <- rowMeans(lsts[,grep("Night",colnames(lsts))],na.rm=T)

head(cbind(mLST,mLSTd,mLSTn))

años <- unname(sapply(colnames(lsts),function(x) substr(strsplit(x,"\\.")[[1]][2],2,5)))
meses <- cut(as.numeric(unname(sapply(colnames(lsts),function(x) substr(strsplit(x,"\\.")[[1]][2],6,9)))),breaks=cumsum(c(0,31,28,31,30,31,30,31,31,30,31,30,31)),labels=month.abb)

## Mapa de la temperatura media en cada centro poblado de Venezuela según los datos de MODIS para el periodo 2000 a 2011

svg(file=sprintf("%s/TemperaturaMedia_Venezuela_Modis.svg",
        out.dir),width=8,height=7)
par(mar=c(0,0,2,0))
plot(adm2,ylim=c(0,12.5),main="Temperatura media en centros poblados de Venezuela\n2000 a 2011",col="wheat")
points(gaz.ven,col=rev(heat.colors(10))[cut(mLST,breaks=10)],pch=3,cex=.5)
plot(adm2,border=rgb(.3,.3,.3,.3),add=T)
legend("bottomleft",legend=levels(cut(mLST,breaks=10)),fill=rev(heat.colors(10)),title="Intervalos °C")
dev.off()


## Diagramas de cajas de la temperatura media de los centros poblados por estados de Venezuela según los datos de MODIS para el periodo 2000 a 2011

ss <- aggregate(mLST,list(estado=gaz.ven.adm2$NAME_1),median,na.rm=T)
ss <- subset(ss,!is.na(x))
oo <- order(ss$x)


svg(file=sprintf("%s/TemperaturaMedia_Municipios_Modis.svg",
        out.dir),width=8,height=7)
par(mar=c(7,4,0,0))
boxplot(mLST~factor(gaz.ven.adm2$NAME_1,levels=ss[oo,"estado"]),
        las=2,varwidth=T,ylab="Temperatura [°C]")
dev.off()




ss <- aggregate(mLST,list(estado=gaz.ven.adm2$NAME_1,municipio=gaz.ven.adm2$NAME_2),median,na.rm=T)
ss <- subset(ss,!is.na(x))
oo <- order(ss$x)
ss[oo,]



gaz.ven@data[!is.na(mLST) & mLST>35,]

plot(mps,1)
points(gaz.ven[!is.na(mLST) & mLST>35,])
gaz.ven@data[!is.na(mLST) & mLST>35 & gaz.ven@data$ADM1 %in% "ZULIA",]


ss <- !is.na(mLST) & mLST>=max(mLST[grepl("Maracaibo",gaz.ven@data[,"FULL_NAME_RG"])])
oo <- order(mLST[ss])
plot(mLST[ss][oo],1:length(oo),xlim=c(32.5,40))
text(mLST[ss][oo],1:length(oo),
     sprintf("%s, %s, estado %s",gaz.ven@data[ss,"FULL_NAME_RG"][oo],
             gaz.ven@data[ss,"ADM1"][oo],
             gaz.ven@data[ss,"ADM1"][oo]),
     cex=.45,adj=-.2,
     col=grepl("Maracaibo",gaz.ven@data[ss,"FULL_NAME_RG"][oo])+1)


tbl <- aggregate(data.frame(dLST=mLST),
                 list(municipio=gaz.ven.adm2$NAME_2),mean,na.rm=T)
tbl[which.max(tbl$dLST),]

tbl <- aggregate(data.frame(dLST=mLST),
                 list(municipio=gaz.ven.adm2$NAME_2),max,na.rm=T)
tbl[which.max(tbl$dLST),]
