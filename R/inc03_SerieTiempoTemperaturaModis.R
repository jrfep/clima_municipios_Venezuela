##R --vanilla

## cargar paquetes necesarios
require(raster)

## cargar algunas funciones útiles
source("inc00_funciones.R")

## descargamos archivo de nomenclatór para Venezuela
## ver:
## source("inc00_ImportarDatosNomenclator.R")
## #leemos el archivo con los centros poblados
gaz.ven <- read.table("data/ve_populatedplaces_p.txt",sep="\t",header=T)

## #transformamos este objeto en un objeto espacial
gaz.ven$x <- as.numeric(gaz.ven$LONG)
gaz.ven$y <- as.numeric(gaz.ven$LAT)
coordinates(gaz.ven) <- c("x","y")
proj4string(gaz.ven) <- "+proj=longlat +datum=WGS84 +no_defs"

## Capa de municipios de Venezuela, fuente de los datos GADM database of Global Administrative Areas:
##http://biogeo.ucdavis.edu/data/gadm2.8/rds/VEN_adm2.rds
##download.file("http://biogeo.ucdavis.edu/data/gadm2.8/rds/VEN_adm2.rds","VEN_adm2.rds")
adm2 <- readRDS("VEN_adm2.rds")

gaz.ven.adm2 <- over(gaz.ven,adm2)

## #a partir de los datos derivados de Modis creamos una serie de tiempo
## #de mapas de temperatura diurna de la superficie de la tierra (LST_Day)
## #los mapas están guardado en:
mapoteca <- "~/mapas/Venezuela/LST_Day_1km/"

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
mapoteca <- "~/mapas/Venezuela/LST_Night_1km/"
for (ff in sprintf("A%s",2000:2011)) {
    mps <- stack(dir(mapoteca,ff,full.names=T))
    
    gaz.lst <- extract(mps,gaz.ven)
    lsts <- cbind(lsts,mSSt(gaz.lst,ll=7500,ul=NA,cf=0.02,os=-273.15))
}


mLST <- rowMeans(lsts,na.rm=T)
mLSTd <- rowMeans(lsts[,grep("Day",colnames(lsts))],na.rm=T)
mLSTn <- rowMeans(lsts[,grep("Night",colnames(lsts))],na.rm=T)

head(cbind(mLST,mLSTd,mLSTn))


plot(gaz.ven,col=rev(heat.colors(10))[cut(mLST,breaks=10)])


plot(gaz.ven,col=rev(heat.colors(10))[cut(mLST,breaks=10)])
ss <- aggregate(mLST,list(estado=gaz.ven.adm2$NAME_1),median,na.rm=T)
ss <- subset(ss,!is.na(x))
oo <- order(ss$x)


par(mar=c(7,4,0,0))
boxplot(mLST~factor(gaz.ven.adm2$NAME_1,levels=ss[oo,"estado"]),
        las=2,varwidth=T)

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
