##R --vanilla

##cargar paquetes
require(vegan)
require(RColorBrewer)
require(sp)

## definir directorios de trabajo
data.dir <- "Rdata"
out.dir <- "output"

## cargar los datos para el estado Zulia
load(sprintf("%s/climaZulia.rda",data.dir))

## matriz con promedios mensuales por estación
mtz <- with(precipitacion,tapply(precip,list(serial,mes),median,na.rm=T))
mtz <- mtz[ rowSums(is.na(mtz))==0,]

meses <- c("ENERO","FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE")

colnames(mtz) <- substr(tolower(meses),1,3)

##extraemos las coordenadas de las estaciones
xys <- coordinates(ec.xy[match(rownames(mtz),ec.xy@data$SERIAL),])

## Capa de municipios de Venezuela, fuente de los datos GADM database of Global Administrative Areas:
##http://biogeo.ucdavis.edu/data/gadm2.8/rds/VEN_adm2.rds
##download.file("http://biogeo.ucdavis.edu/data/gadm2.8/rds/VEN_adm2.rds","VEN_adm2.rds")
adm2 <- readRDS("VEN_adm2.rds")


## Extraemos los componentes principales de la matriz
pca1 <- rda(mtz)
scrs <- scores(pca1,1:2,"sites")

##El primer eje representa la magnitud de la precipitación, el segundo eje separa el semestre de diciembre a mayo del trimestre de agosto a octubre (junio, julio y noviembre parece que influyen poco en este eje 
plot(pca1)
text(pca1,"species",col=2,font=2)

## para mejorar la representación visual hacemos:
## (1) el tamaño proporcional a la precipitación total anual, y
## (2) el color representa la proporción de precipitación entre dic-may:

precipitacion.anual <- rowSums(mtz)
proporcion.sem.seco <- rowSums(mtz[,c(1:5,12)])/precipitacion.anual

plot(pca1,type="n")
symbols(scrs[,1],scrs[,2],circle=precipitacion.anual,inches=.2,
        bg=rgb(proporcion.sem.seco,0.0,
            max(proporcion.sem.seco)-proporcion.sem.seco,
            maxColorValue=max(proporcion.sem.seco)),
        fg=rgb(proporcion.sem.seco,0.0,
            max(proporcion.sem.seco)-proporcion.sem.seco,
            maxColorValue=max(proporcion.sem.seco)),add=T)

## definimos tres grupos de estaciones en estos dos ejes:

grp <- 1+(scrs[,1]>0) ## umbral del primer eje (positivos vs. negativos)
grp[scrs[,2] < -5] <- 3 ## umbral en el segundo eje (casos extremos)

clrs <- brewer.pal(3,"Spectral") ## colores para los tres grupos

plot(pca1,type="n")
symbols(scrs[,1],scrs[,2],circles=rowSums(mtz),inches=.12,
        bg=clrs[grp],fg=1,add=T)
text(pca1,"species",col=1,font=2)

## finalmente visualizamos la ubicación de las estaciones en cada grupo,
## junto con un diagrama de precipitación promedio mensual por grupo:

svg(file=sprintf("%s/ClasificacionEstaciones_EstadoZulia.svg",
        out.dir),width=8,height=8)

par(mar=c(0,0,0,0),fig=c(0,1,0,1),new=F)
plot(subset(adm2,NAME_1 %in% "Zulia"),border="pink",col="aliceblue",lwd=1.5)

if (exists("logo"))
    rasterImage(logo, -74.15, 8.2, -72.9, 9.45)

symbols(xys[,1],xys[,2],circles=sqrt(rowSums(mtz)),inches=.10,
        bg=clrs[grp],fg=1,add=T)
title("Precipitación promedio mensual [mm] por estaciones climáticas",line=-2)
title("Estado Zulia",line=-3)

par(fig=c(.75,.95,.7,.9),new=TRUE,las=2,cex.axis=.8)
barplot(apply(mtz[grp==1,],2,median),col=clrs[1],ylim=c(0,250),main="Promedio Grupo 1",xpd=NA,cex.main=.9)
par(fig=c(.8,1.,.08,.28),new=TRUE,las=2,cex.axis=.8)
barplot(apply(mtz[grp==3,],2,median),col=clrs[3],ylim=c(0,250),main="Promedio Grupo 3",xpd=NA,cex.main=.9)
par(fig=c(.1,.3,.6,.8),new=TRUE,las=2,cex.axis=.8)
barplot(apply(mtz[grp==2,],2,median),col=clrs[2],ylim=c(0,250),main="Promedio Grupo 2",xpd=NA,cex.main=.9)


        


dev.off()

