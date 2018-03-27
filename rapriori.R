library("arules")
library("arulesViz") #visualización 
library("dplyr")
library("tidyr")
library("magrittr")
genes <- read.csv('/home/jennifer/Escritorio/genesok.csv') 

#genes %<>% filter(cluster %in% c('c1','c5','c3','c4','c2'))
#genes %<>% filter(cluster %in% c('c1','c3','c5'))
genes %<>% filter(gen %in% c('BRCA2','BRCA1','ATM'))

#genes %<>% select(-cluster)

#genes <- sapply(genes,as.factor)
#genes$cluster <- discretize(genes$cluster)
#genes$edad <- discretize(genes$edad)
#genes$sexo <- discretize(genes$sexo)
g <- as(genes, "transactions")
rules <- apriori(g, parameter = list(supp = 0.1, conf = 0.6, target = "rules"))
rules <-sort(rules, by ="lift")
#gato <- as(rules,"data.frame")
gatos <- data.frame(lhs = labels(lhs(rules)), rhs = labels(rhs(rules)), rules@quality) 
gatos$id <- rownames(gatos)
gatos %>% filter((grepl("BRCA1",lhs)|grepl("BRCA2",lhs)|grepl("ATM",lhs))) %>% select(id)-> rules_filtered
rules_filtered <- as.vector(rules_filtered) #Filtro de reglas por gen.

plot(rules[rules_filtered[1:30,1]], method="graph", control=list(type="items"))

summary(rules)
inspect(rules)

plot(rules[1:5], method="graph", control=list(type="items"))
plot(rules[1:10], method="graph", control=list(type="items"))
plot(rules[10:15], method="graph", control=list(type="items"))
plot(rules, method="graph", control=list(type="items"))

inspect(head(rules, by = "lift"))
## filter spurious rules 
inspect(rules, by = "lift")
plot(rules[rules_filtered[1:30,1]], method="graph", control=list(type="items"))

