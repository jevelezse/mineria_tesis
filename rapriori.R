rm(list=ls())
library("arules")
library("arulesViz") #visualización
library("visNetwork")
library("igraph")
library("dplyr")
library("tidyr")
library("magrittr")
library("stringr")

par_clust <- "" 
par_n <- 5
par_tipo <- "confidence"

genes <- read.csv('/home/jennifer/Escritorio/genesok.csv') 
#genes$edad1 <- gsub(",","-",genes$edad1)#Cambio de coma
#genes %<>% filter(cluster %in% c('c1','c5','c3','c4','c2'))
#genes %<>% filter(cluster %in% c('c1','c3','c5'))
genes %<>% filter(gen %in% c("BRCA2","BRCA1","ATM"))

#genes %<>% select(-cluster)

#genes <- sapply(genes,as.factor)
#genes$cluster <- discretize(genes$cluster)
#genes$edad <- discretize(genes$edad)
#genes$sexo <- discretize(genes$sexo)
g <- as(genes, "transactions")
rules <- apriori(g, parameter = list(supp = 0.05, conf = 0.6, target = "rules"))
rules <-sort(rules, by ="lift")
#gato <- as(rules,"data.frame")
gatos <- data.frame(lhs = labels(lhs(rules)), rhs = labels(rhs(rules)), rules@quality) 
gatos$id <- rownames(gatos)
gatos %>% filter((grepl("BRCA1",lhs)|grepl("BRCA2",lhs)|grepl("ATM",lhs))) %>% select(id)-> rules_filtered
rules_filtered <- as.vector(rules_filtered) #Filtro de reglas por gen.

plot(rules[rules_filtered[1:30,1]], method="graph", control=list(type="items"))

summary(rules)
inspect(rules)

#plot(rules[1:5], method="graph", control=list(type="items"))
#plot(rules[1:10], method="graph", control=list(type="items"))
#plot(rules[1:5], method="grouped", interactive=TRUE)
#plot(rules[10:15], method="graph", control=list(type="items"))
#plot(rules, method="graph", control=list(type="items"))
#plot(rules, method = "graph", control = list(type = "items", + engine = "graphviz"))

inspect(head(rules, by = "lift"))
## filter spurious rules 
inspect(rules, by = "lift")
plot(rules[rules_filtered[1:30,1]], method="graph", control=list(type="items"))

#####

#Grafo mas lindo###

ig <- plot(rules[1:10], method="graph", control=list(type="items") )

# saveAsGraph seems to render bad DOT for this case
tf <- tempfile( )
saveAsGraph(rules[1:10], file = tf, format = "dot" )
# clean up temp file if desired
#unlink(tf)

# let's bypass saveAsGraph and just use our igraph
ig_df <- get.data.frame(ig, what = "both" )
visNetwork(
  nodes = data.frame(
    id = ig_df$vertices$name
    ,value = ig_df$vertices$support # could change to lift or confidence
    ,title = ifelse(ig_df$vertices$label == "",ig_df$vertices$name, ig_df$vertices$label)
    ,ig_df$vertices
  )
  , edges = ig_df$edges
) %>%
  visEdges( arrows = "to" ) %>%
  visGroups(groupname = "gen=DMD", color = "red") %>%    # darkblue for group "A"
  visGroups(groupname = "B", color = "red")  
  #visOptions( highlightNearest = T )

####### Codigo se Sergio########

#Crear dataframe
rules_test <- rules[,] # Filtro de reglas. 

df_rules = data.frame(
  lhs = labels(lhs(rules_test)),
  rhs = labels(rhs(rules_test)), 
  rules_test@quality)

df_rules %<>% filter(grepl(par_clust,lhs)|grepl(par_clust,rhs))%>% top_n(par_n,par_tipo)
# Ajustar contenido de las celdas
df_rules$regla <- rownames(df_rules)
df_rules$lhs <- gsub("[\\{\\}]", "", df_rules$lhs)
df_rules$rhs <- gsub("[\\{\\}]", "", df_rules$rhs)

#### Ajustar a formato de tres tablas

## left hand 
lista <- str_split(df_rules$lhs,",")
names(lista) <- as.vector(df_rules[,"regla"])

## convert to data.frame
df_reglas_lhs <- data.frame(regla = rep(names(lista), sapply(lista, length)),titulo = unlist(lista), type = "from")

## right hand
lista <- str_split(df_rules$rhs,",")

names(lista) <- as.vector(df_rules[,"regla"])

## convert to data.frame

df_reglas_rhs <- data.frame(regla = rep(names(lista), sapply(lista, length)),
                            titulo = unlist(lista),type = "to")

df_reglas_lhs$regla <- paste("rule",df_reglas_lhs$regla,sep = "")
df_reglas_rhs$regla <- paste("rule",df_reglas_rhs$regla,sep = "")


# Propiedades
df_rules <- df_rules[,c("regla","support", "confidence", "lift")]
df_rules$regla <- paste("rule",df_rules$regla,sep = "")

df1 <- rbind(df_reglas_lhs,df_reglas_rhs)

df1n1 <- data.frame(edge = df1$regla, type = rep("regla",dim(df1)[1]))
df1n2 <- data.frame(edge = df1$titulo, type = rep("Condicion",dim(df1)[1]))
dfn <- rbind(df1n1,df1n2) 

colnames(df_reglas_rhs) <- c("origen","destino","type")
colnames(df_reglas_lhs) <- c("destino","origen","type")
df_reglas_gato <- rbind (df_reglas_lhs,df_reglas_rhs)

dfnodos <- dfn %>% group_by(edge,type) %>% summarise(n = n())

nodes <- data.frame(id = dfnodos$edge, group = dfnodos$type, label = dfnodos$edge)
edges <- data.frame(from = df_reglas_gato$origen ,to=df_reglas_gato$destino)
set.seed(1234)
visNetwork(nodes, edges, width = "90%") %>% 
  visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
  #visNodes(shape = "square") %>%                        # square for all nodes
  visEdges(arrows ="to") %>%                            # arrow "to" for all edges
  visGroups(groupname = "regla") %>%    # darkblue for group "A"
  visGroups(groupname = "Condicion",shape = "icon",icon = list(code = "f007", color = "pink"), color = "red") 

