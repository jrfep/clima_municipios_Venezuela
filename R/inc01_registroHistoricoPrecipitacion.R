##R --vanilla

## definir directorios de trabajo
data.dir <- "Rdata"
out.dir <- "output"

## cargar los datos para el estado Zulia
load(sprintf("%s/climaZulia.rda",data.dir))

## seleccionar un municipio
mi.municipio <- "Lagunillas"
dts <- subset(precipitacion,municipio %in% mi.municipio)

## definir periodo histórico de los datos
dts$fch <- dts$año+(dts$mes-.5)/12
periodo.historico <- seq(min(precipitacion$año),max(precipitacion$año)+1,length=5)

## definir periodo de actividad de las estaciones climáticas
periodo.actividad <- with(dts,aggregate(fch,list(serial=serial),range))

## Figura resumen de la secuencia histórica de datos de precipitación para el municipio seleccionado
svg(file=sprintf("%s/HistoricoPrecipitacion_Municipio_%s_EstadoZulia.svg",
        out.dir,mi.municipio),width=7,height=6)
layout(matrix(1:4,ncol=1))
par(mar=c(3,3,0,3),oma=c(3,3,3,3))
for (k in 1:4) {

    maxy <- max(c(max(dts$precip,na.rm=T),
                  300+20*nrow(periodo.actividad)))
    plot(precip~fch,dts,type="h",xlim=periodo.historico[k:(k+1)],ylim=c(0,maxy),col="slateblue",lwd=2,axes=F)
    axis(2)
    axis(1,at=(periodo.historico[1]:periodo.historico[5]),
         labels=(periodo.historico[1]:periodo.historico[5]),cex=.5)
    segments(periodo.actividad$x[,1],300+20*(1:nrow(periodo.actividad)),
             periodo.actividad$x[,2],300+20*(1:nrow(periodo.actividad)),
             lwd=2,lty=3,col="grey67")
    ss <- periodo.actividad$x[,1] < periodo.historico[k+1] &
        periodo.actividad$x[,2] > periodo.historico[k]
    axis(4,300+20*(1:nrow(periodo.actividad))[ss],periodo.actividad$serial[ss],las=2,cex.axis=.75,col.axis="grey47")
    box()
}
mtext("Año",1,line=1,outer=T)
mtext("Precipitación mensual [mm]",2,line=1,outer=T)
mtext("Serial de estación meteorológica INAMEH",4,line=1,outer=T)
mtext(sprintf("Municipio %s, estado Zulia",mi.municipio),3,line=1,outer=T)
dev.off()
