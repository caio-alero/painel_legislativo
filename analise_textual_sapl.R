library(dplyr)
library(stringr)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)


'%ni%' <- Negate('%in%')

# dados %>%
#   filter(str_detect(string = num_projeto,
#                     pattern = c('1323/2021 | 1076/2021'))) -> projetos_teste

# 2. PRÉ-PROCESSAMENTO ----

# 2.1 corpus ----
ementas_corpus <- corpus(sapl_data$ementa)
names(ementas_corpus) <- sapl_data$num_projeto

ementas_toks <- tokens(ementas_corpus, remove_punct = TRUE, remove_symbols = TRUE, remove_numbers = TRUE)

ementas_dtm <- ementas_toks %>% 
  dfm() %>% 
  dfm_remove(c(stopwords('pt'), 'estado', 'rondônia', 'indica', 
               'município', 'poder', 'executivo', 'necessidade',
               'estadual', 'porto', 'velho', 'requer', 'departamento', 
               'casa', 'extenso', 'ro', 'sobre', 'dispõe', 'outras',
               'dá', 'providências', 'institui', 'concede', 'legislativo', 'âmbito',
               'autoriza', 'lei', 'nº', 'sr', 'informações', 'senhor', 'r',
               'medalha', 'mérito', 'crédito', 'dá', 'outras', 'providências',
               'adicional', 'valor', 'abrir', 'secretaria',
               'excelentíssimo', 'quanto', 'serviços', 'governador',
               'n', 'c', 'autoria', 'favor', 'unidade', 'altera',
               'projeto', 'complementar', 'exmo')) 
 

# 3. ANÁLISE DOS DADOS ----
top_words <- topfeatures(ementas_dtm, n = 100)
top_words <- tibble(terms = names(top_words),
                       freq = top_words)

# top_words %>%
#   e_color_range(freq, color) %>%
#   e_charts() %>%
#   e_cloud(terms, freq, color, shape = 'circle',
#           emphasis = list(itemStyle = list(shadowBlur = 10))) %>%
#   e_tooltip()


# 4. ANÁLISE DE TÓPICOS
#dfm_lookup(dfm(ementas_toks), dictionary = projetos_dicio)

# doc_similar %>% 
#   as_tibble() %>% 
#   arrange(desc(correlation)) %>% 
#   filter(document1 == 'PLO 1419/2021')



