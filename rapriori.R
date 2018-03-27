library("arules")
library("arulesViz") #visualización 
library("dplyr")
library("tidyr")
library("magrittr")
genes <- read.csv('/home/jennifer/Escritorio/output.csv') 

genes %<>% filter(cluster %in% c('c1','c5','c3','c4','c2'))
#genes %<>% filter(cluster %in% c('c1','c5'))
genes %<>% filter(gen %in% c('BRCA1','BRCA2'))

#genes %<>% select(-cluster)

#genes <- sapply(genes,as.factor)
#genes$cluster <- discretize(genes$cluster)
#genes$edad <- discretize(genes$edad)
#genes$sexo <- discretize(genes$sexo)
g <- as(genes, "transactions")
rules <- apriori(g, parameter = list(supp = 0.01, conf = 0.6, target = "rules"))
#gato <- as(rules,"data.frame")
gatos <- data.frame(lhs = labels(lhs(rules)), rhs = labels(rhs(rules)), rules@quality) 
summary(rules)
inspect(rules)

plot(rules[1:5], method="graph", control=list(type="items"))
plot(rules[1:10], method="graph", control=list(type="items"))
plot(rules[10:15], method="graph", control=list(type="items"))
plot(rules, method="graph", control=list(type="items"))
