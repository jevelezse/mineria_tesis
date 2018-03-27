library("arules")
library("arulesViz") #visualización
library("visNetwork")
library("igraph")
library("dplyr")
library("tidyr")
library("magrittr")
genes <- read.csv('/home/jennifer/Escritorio/genesok.csv') 

#genes %<>% filter(cluster %in% c('c1','c5','c3','c4','c2'))
#genes %<>% filter(cluster %in% c('c1','c3','c5'))
genes %<>% filter(gen %in% c('DMD'))

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
plot(rules[1:5], method="grouped", interactive=TRUE)
plot(rules[10:15], method="graph", control=list(type="items"))
plot(rules, method="graph", control=list(type="items"))
plot(rules, method = "graph", control = list(type = "items", + engine = "graphviz"))

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
  visGroups(groupname = "gen=DMD", color = "darkblue") %>%    # darkblue for group "A"
  visGroups(groupname = "B", color = "red")  
  #visOptions( highlightNearest = T )
