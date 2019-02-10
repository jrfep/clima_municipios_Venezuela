edo <- "Zulia"
slc <- "Mara"
edo <- "Yaracuy"

for (edo in c("Zulia","Yaracuy")) {
    for (slc in unique(subset(gaz.ven.adm2,NAME_1 %in% edo)$NAME_2)) {
    ss <- gaz.ven.adm2$NAME_1 %in% edo & gaz.ven.adm2$NAME_2 %in% slc
    wiki.out <- sprintf("../output/wiki.es/Estado%sMunicipio%s.txt",edo,gsub(" ","_",slc))

    cat(file=wiki.out,sprintf("{{clima
|location = Municipio %s, según mediciones de sensores remotos (2000–2011)
|metric first = Y
|single line = Y",slc))


    dts <- stack(data.frame(lsts[ss,,drop=F]))
   ## dts <- stack(lsts[ss,])

    
    dts$años <- unname(sapply(as.character(dts$ind),function(x) substr(strsplit(x,"\\.")[[1]][2],2,5)))
    dts$meses <- cut(as.numeric(unname(sapply(as.character(dts$ind),function(x) substr(strsplit(x,"\\.")[[1]][2],6,9)))),breaks=cumsum(c(0,31,28,31,30,31,30,31,31,30,31,30,31)),labels=month.abb)
    
    qry <- with(subset(dts,grepl("Day",dts$ind)),
                aggregate(data.frame(val=values),
                          by=list(mes=meses),
                          function(x) {quantile(ecdf(x),.995)}))
    
    cat(file=wiki.out,sprintf("|%s record high C = %0.1f\n",qry$mes,qry[,2]),append=T)
    cat(file=wiki.out,sprintf("|year record high C = %0.1f\n",max(qry[,2])),append=T)

    qry <- with(subset(dts,grepl("Day",dts$ind)),
                aggregate(data.frame(val=values),
                          by=list(mes=meses),
                          function(x) {quantile(ecdf(x),.5)}))
    
    cat(file=wiki.out,sprintf("|%s high C = %0.1f\n",qry$mes,qry[,2]),append=T)
    cat(file=wiki.out,sprintf("|year high C = %0.1f\n",mean(qry[,2])),append=T)

    qry <- with(dts,
                aggregate(data.frame(val=values),
                          by=list(mes=meses),
                          function(x) {quantile(ecdf(x),.5)}))

    cat(file=wiki.out,sprintf("|%s mean C = %0.1f\n",qry$mes,qry[,2]),append=T)
    cat(file=wiki.out,sprintf("|year mean C = %0.1f\n",mean(qry[,2])),append=T)

    qry <- with(subset(dts,grepl("Night",dts$ind)),
                aggregate(data.frame(val=values),
                          by=list(mes=meses),
                          function(x) {quantile(ecdf(x),.5)}))

    cat(file=wiki.out,sprintf("|%s low C = %0.1f\n",qry$mes,qry[,2]),append=T)
    cat(file=wiki.out,sprintf("|year low C = %0.1f\n",mean(qry[,2])),append=T)

        qry <- with(subset(dts,grepl("Night",dts$ind)),
                aggregate(data.frame(val=values),
                          by=list(mes=meses),
                          function(x) {quantile(ecdf(x),.005)}))

    cat(file=wiki.out,sprintf("|%s record low C = %0.1f\n",qry$mes,qry[,2]),append=T)
    cat(file=wiki.out,sprintf("|year record low C = %0.1f\n",min(qry[,2])),append=T)



    
    if (exists("pres")) {
        for (mm in month.abb) {
            cat(file=wiki.out,sprintf("|%s precipitation mm = %0.1f\n",mm,),append=T)
        }
        cat(file=wiki.out,sprintf("|year precipitation mm = %0.1f\n",),append=T)
    }
    
    cat(file=wiki.out,sprintf("
|source 1 =  MOD11A2 MODIS/Terra Land Surface Temperature/Emissivity<ref name='SMN'>{{Cita web
 |url= http://doi.org/10.5067/MODIS/MOD11A2.006
 |título= MOD11A2 MODIS/Terra Land Surface Temperature/Emissivity 8-Day L3 Global 1km SIN Grid V006 [Data set]
 |nombre1=Z.|apellido1=Wan
 |nombre2=S.|apellido2=Hook
 |nombre3=G.|apellido3=Hulley
 |year=2015
 |editorial= NASA EOSDIS LP DAAC
 |fechaacceso=5 de julio de 2018}}</ref>
}}"),append=T)
}
}
