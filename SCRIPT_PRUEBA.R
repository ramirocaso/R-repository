# ---- RAMIRO CASÓ ----  
#Pasos para crear desde  cero una base de datos simulada para hacer marketing analytics
#ESTE ES UN CAMBIO PEQUEÑO

k.stores <- 20 #20 tiendas, usando "k" como "constante"
k.weeks <- 104 #2 años de datos #Incialmente se crea el df con datos perdidos para luego rellenarla  
store.df <- data.frame(matrix(NA, ncol=10, nrow=k.stores*k.weeks))  
names(store.df) <- c("storeNum", "Year", "Week", "p1sales", "p2sales",  "p1price", "p2price", "p1prom", "p2prom", "country")

dim(store.df) #para cheaquear que se crearon las columnas y filas necesarias, así como los títulos

store.num <- 101:(100+k.stores) 
(store.cty <- c(rep("US", 3), rep("DE", 5), rep("GB", 3), rep("BR", 2), 
                rep("JP", 4), rep("AU", 1), rep("CN", 2)))  
length(store.cty) #para saber que la longitud del vector es la correcta

store.df$storeNum <- rep(store.num, each=k.weeks)  
store.df$country <- rep(store.cty, each=k.weeks) 
rm(store.num, store.cty) #clean up 

store.df$Week <- rep(1:52, times=k.stores*2) 
store.df$Year <- rep(rep(1:2, each=k.weeks/2), times=k.stores)
str(store.df)

#convierte el nivel de medida en factor para que sirva de índice
store.df$storeNum <- factor(store.df$storeNum) 
store.df$country <- factor(store.df$country) 
str(store.df)

head(store.df, 120) #con esto se puede ver dos tiendas
tail(store.df, 120)

set.seed(98250) #seed usado de referencia en el libro sobre la base de un famoso zipcode

#se llenan los datos de plprom con una distribución binomial, para cada fila, con 1 lanzamiento y prob 0.1
#se llenan los datos de p2prom con una distribución binomial, para cada fila, con 1 lanzamiento y prob 0.15
#Esto lo que hace es poner 0's y 1's para decidir si hay o no promoción para cada producto. 


store.df$p1prom <- rbinom(n=nrow(store.df), size=1, p=0.1) 
store.df$p2prom <- rbinom(n=nrow(store.df), size=1, p=0.15) 
head(store.df)


# Ahora llenamos los precios de p1 y p2. 
store.df$p1price <-sample(x=c(2.19,2.29,2.49,2.79, 2.99), size = nrow(store.df), replace = TRUE)
store.df$p2price <-sample(x=c(2.29,2.49,2.59,2.99,3.19), size = nrow(store.df), replace = TRUE)
head(store.df)

# Para simular los datos de ventas, creamos variables temporales.
# Se usa una distribución de Poisson para generar aleatoreamente los datos
# Primero se ponen los resultados antes de la promoción, con media (lambda = 120 y lambda = 100) para P1 y P2
# respectivamente. 

tmp.sales1 <- rpois(nrow(store.df), lambda = 120)
tmp.sales2 <- rpois(nrow(store.df), lambda = 100)

#Dice el libro que uso de fuente, que los efectos de los precios siguen una escala log. 
#Hay que ajustar con los ratios de los logaritmos de los precios (p2/p1) y (p1/p2)

#We have assumed that sales vary as the inverse ratio of prices. 
#That is, sales of  Product 1 go up to the degree that the log(price) of Product 1 is lower than the  log(price) of Product 2. 

tmp.sales1 <- tmp.sales1 *  log(store.df$p2price) / log(store.df$p1price)
tmp.sales2 <- tmp.sales2 * log(store.df$p1price) / log(store.df$p2price)

# último paso es calcular el lift de 30% y 40% cuando ocurre una promocióm.
# Esto se hace multiplicando el vector de promoción (0 y 1) por 0.3 y 0.4 y luego
# multiplicar por las ventas. 

store.df$p1sales <- floor(tmp.sales1*(1+store.df$p1prom*0.3))
store.df$p2sales <- floor(tmp.sales2*(1+store.df$p2prom*0.4))

head(store.df)
