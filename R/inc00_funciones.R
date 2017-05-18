### Función para transformar valores de mapas obtenidos con la herramienta
### MODIS SubSets a los valores verdaderos de las variables
mSSt <- function(x,ll=-2000,ul=10000,cf=0.0001,os=0,setNA=0) {
    if (!is.na(ll)) ## ll: limite inferior
        x[x<ll] <- NA
    if (!is.na(ul))  ## ul: limite superior
        x[x>ul] <- NA
    
    x<- (x*cf) + os ## cf: factor de corrección, os: "offset"
    if (!is.na(setNA)) ## setNA: valor que corresponde con valores nulos
        x[x==setNA] <- NA
    return(x)
}

## Función sencilla para contar los valores únicos en un vector
luq <- function(x,contar.NA=FALSE) {
    if (contar.NA==F) {
	x <- x[!is.na(x)]
    }
    length(unique(x))
}
