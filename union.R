t1 <- read.csv("/home/jennifer/Escritorio/gen.csv")
t2 <- read.csv("/home/jennifer/Escritorio/tabla1.csv")

a <- as.data.frame(t1)
b <- as.data.frame(t2)

tablita <- merge(a,b,by.x="paciente_id",by.y="id")

write.csv(tablita, file = "/home/jennifer/Escritorio/weka.csv",  row.names = FALSE)
