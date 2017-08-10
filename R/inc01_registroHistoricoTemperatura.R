##R --vanilla

## definir directorios de trabajo
data.dir <- "../Rdata"
out.dir <- "../output"

## cargar los datos para el estado Zulia
load(sprintf("%s/climaZulia.rda",data.dir))

## seleccionar un municipio
mi.municipio <- "Lagunillas"
dts <- subset(temperatura,municipio %in% mi.municipio)

## definir periodo histórico de los datos
dts$fch <- dts$año+(dts$mes-.5)/12
periodo.historico <- seq(min(temperatura$año),max(temperatura$año)+1,length=5)

## definir periodo de actividad de las estaciones climáticas
periodo.actividad <- with(dts,aggregate(fch,list(serial=serial),range))

##########
## Figuras resumen de la secuencia histórica de datos de precipitación para el municipio seleccionado
##########

##########
## precipitación mensual por estación
####

svg(file=sprintf("%s/HistoricoTemperatura_Municipio_%s_EstadoZulia.svg",
        out.dir,gsub(" ","_",mi.municipio)),width=10,height=8)
layout(matrix(1:4,ncol=1))
par(mar=c(3,3,0,3),oma=c(3,3,3,3))
for (k in 1:4) {

    maxy <- max(c(max(dts$temperatura,na.rm=T),
                  35+2*nrow(periodo.actividad)))
    plot(temperatura~fch,dts,type="p",xlim=periodo.historico[k:(k+1)],ylim=c(0,maxy),col="slateblue",lwd=2,axes=F)
    axis(2)
    axis(1,at=(periodo.historico[1]:periodo.historico[5]),
         labels=(periodo.historico[1]:periodo.historico[5]),cex=.5)
    segments(periodo.actividad$x[,1],35+2*(1:nrow(periodo.actividad)),
             periodo.actividad$x[,2],35+2*(1:nrow(periodo.actividad)),
             lwd=2,lty=3,col="grey67")
    ss <- periodo.actividad$x[,1] < periodo.historico[k+1] &
        periodo.actividad$x[,2] > periodo.historico[k]
    axis(4,35+2*(1:nrow(periodo.actividad))[ss],periodo.actividad$serial[ss],las=2,cex.axis=.75,col.axis="grey47")
    box()
}
mtext("Año",1,line=1,outer=T)
mtext("Precipitación mensual [mm]",2,line=1,outer=T)
mtext("Serial de estación meteorológica INAMEH",4,line=1,outer=T)
mtext(sprintf("Municipio %s, estado Zulia",mi.municipio),3,line=1,outer=T)

if (require(png) & exists("logo")) {
    par(fig=c(.07,.23,.8,1.),new=TRUE,cex.axis=.8,xpd=NA,mar=c(0,0,0,0))
    plot(1,1,pch=NA,axes=F,xlim=c(0,3),ylim=c(0,3),xlab="",ylab="")
    rasterImage(logo, 0.1, 0.1, 3, 3)
}
dev.off()




