##R --vanilla
require(raster)
data.dir <- "../data"
Rdata.dir <- "../Rdata"
out.dir <- "../output"


## descargamos archivo de municipios para Venezuela
## ver:
## source("inc00_ImportarDatosMunicipios.R")
## #leemos el archivo 
adm2 <- readRDS(sprintf("%s/VEN_adm2.rds",data.dir))

load(sprintf("%s/LSTdata.rda",Rdata.dir))
        

for (edo in  unique(gaz.ven.adm2$NAME_1)[1]) {

    if (edo %in% c("Lara","Zulia")) {
        load(sprintf("%s/clima%s.rda",Rdata.dir,edo))
        qry <-extract(adm2,ec.xy)
        
        for (slc in unique(subset(gaz.ven.adm2,NAME_1 %in% edo)$NAME_2)) {
            wiki.out <- sprintf("../output/wiki.es/Estado%sMunicipio%s.txt",edo,gsub(" ","_",slc))

            
            inameh <- subset(ec.xy,qry$NAME_2 %in% slc)

            ss <- gaz.ven.adm2$NAME_1 %in% edo & gaz.ven.adm2$NAME_2 %in% slc
            titulo <- sprintf("Municipio %s, según  mediciones de sensores remotos (2000–2011)",slc)
refs <- "|source 1 =  MOD11A2 MODIS/Terra Land Surface Temperature/Emissivity<ref name='SMN'>{{Cita web
 |url= http://doi.org/10.5067/MODIS/MOD11A2.006
 |título= MOD11A2 MODIS/Terra Land Surface Temperature/Emissivity 8-Day L3 Global 1km SIN Grid V006 [Data set]
 |nombre1=Z.|apellido1=Wan
 |nombre2=S.|apellido2=Hook
 |nombre3=G.|apellido3=Hulley
 |year=2015
 |editorial= NASA EOSDIS LP DAAC
 |fechaacceso=5 de julio de 2018}}</ref>"
            
            dts <- stack(data.frame(lsts[ss,,drop=F]))
            ## dts <- stack(lsts[ss,])
            
            
            dts$años <- unname(sapply(as.character(dts$ind),function(x) substr(strsplit(x,"\\.")[[1]][2],2,5)))
            dts$meses <- cut(as.numeric(unname(sapply(as.character(dts$ind),function(x) substr(strsplit(x,"\\.")[[1]][2],6,9)))),breaks=cumsum(c(0,31,28,31,30,31,30,31,31,30,31,30,31)),labels=month.abb)
            
            slcTrmax <- with(subset(dts,grepl("Day",dts$ind)),
                             aggregate(data.frame(val=values),
                                       by=list(mes=meses),
                                      function(x) {quantile(ecdf(x),.995)}))
            
            slcTmax <- with(subset(dts,grepl("Day",dts$ind)),
                                 aggregate(data.frame(val=values),
                                           by=list(mes=meses),
                                           function(x) {quantile(ecdf(x),.5)}))
            
            slcTmean <- with(dts,
                             aggregate(data.frame(val=values),
                                       by=list(mes=meses),
                                       function(x) {quantile(ecdf(x),.5)}))
            slcTmin <- with(subset(dts,grepl("Night",dts$ind)),
                            aggregate(data.frame(val=values),
                                      by=list(mes=meses),
                                      function(x) {quantile(ecdf(x),.5)}))
            slcTrmin <- with(subset(dts,grepl("Night",dts$ind)),
                             aggregate(data.frame(val=values),
                                       by=list(mes=meses),
                                       function(x) {quantile(ecdf(x),.005)}))
            
            
            if (nrow(inameh)>0) {
                refs[2] <- "|source 2 =  Instituto Nacional de Meteorología e Hidrología de la República Bolivariana de Venezuela<ref name='INAMEH'>{{Cita web
 |url= http://www.inameh.gob.ve/web/
 |título= Climatología / Datos Hidrometeorológicos
 |year=2015
 |editorial= Instituto Nacional de Meteorología e Hidrología de la República Bolivariana de Venezuela (INAMEH)
 |fechaacceso=17 de octubre de 2015}}</ref>"

                
                wch <- subset(temperatura,serial %in% inameh$SERIAL)
                titulo <- sprintf("Municipio %s, según datos de %s estaciones meteorológicas (%s-%s) y sensores remotos (2000-2011)",slc, length(unique(wch$serial)),min(wch$año),max(wch$año))
                
                slcTmean <- aggregate(data.frame(Tmean=wch$temperatura),list(mes=wch$mes),mean,na.rm=T)                
            }


    cat(file=wiki.out,sprintf("{{clima
|location = %s
|metric first = Y
|single line = Y",titulo))
      
    cat(file=wiki.out,sprintf("|%s record high C = %0.1f\n",slcTrmax$mes,slcTrmax[,2]),append=T)
    cat(file=wiki.out,sprintf("|year record high C = %0.1f\n",max(slcTrmax[,2])),append=T)

    
    cat(file=wiki.out,sprintf("|%s high C = %0.1f\n",slcTmax$mes,slcTmax[,2]),append=T)
    cat(file=wiki.out,sprintf("|year high C = %0.1f\n",max(slcTmax[,2])),append=T)


    cat(file=wiki.out,sprintf("|%s mean C = %0.1f\n",slcTmean$mes,slcTmean[,2]),append=T)
    cat(file=wiki.out,sprintf("|year mean C = %0.1f\n",mean(slcTmean[,2])),append=T)


    cat(file=wiki.out,sprintf("|%s low C = %0.1f\n",slcTmin$mes,slcTmin[,2]),append=T)
    cat(file=wiki.out,sprintf("|year low C = %0.1f\n",min(slcTmin[,2])),append=T)


    cat(file=wiki.out,sprintf("|%s record low C = %0.1f\n",slcTrmin$mes,slcTrmin[,2]),append=T)
    cat(file=wiki.out,sprintf("|year record low C = %0.1f\n",min(slcTrmin[,2])),append=T)

    
    if (exists("pres")) {
        for (mm in month.abb) {
            cat(file=wiki.out,sprintf("|%s precipitation mm = %0.1f\n",mm,),append=T)
        }
        cat(file=wiki.out,sprintf("|year precipitation mm = %0.1f\n",),append=T)
    }
    
    cat(file=wiki.out,sprintf("
%s
}}", paste(refs,collapse="\n")),append=T)
        }
    }
}
