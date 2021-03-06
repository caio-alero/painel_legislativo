library(reshape2)
library(DT)
library(echarts4r)
library(countup)
library(shiny)
library(dplyr)
library(lubridate)
library(stringr) 
library(summaryBox)
library(thematic)
library(showtext)
library(bslib)
library(shinydashboard)
library(OSUICode)
library(shinyWidgets)
library(waiter)
library(tablerDash)
library(Hmisc)

options(encoding = "UTF-8")

# LEITURA DOS DADOS -------------------------------

# dados das materias -------------------------------
files <- list.files(path = 'data/', pattern = '.rds', full.names = TRUE)
sapl_data <- do.call("bind_rows", lapply(files, readRDS)) 
agrupamento_status <- read.table('agrupamento_status.txt', sep = '\t', header = TRUE, encoding = 'UTF-8') %>% as_tibble()

sapl_data <- inner_join(agrupamento_status, sapl_data, by = 'status')

sapl_data$Grupo <- recode_factor(as.factor(sapl_data$Grupo),
                                 '1' = 'Proposição Aprovada',
                                 '2' = 'Proposição Rejeitada',
                                 '3' = 'Em tramitação',
                                 '4' = 'Proposição Arquivada',
                                 'NA' = 'NA')
# sapl_data %>% 
#   mutate(Grupo = ifelse(str_detect(localizacao_atual, 'Arquivo') & Grupo == 'Em tramitação', 'Proposição Arquivada', Grupo)) -> sapl_data

source('webscrapping\\webscrapping_sessoes.R')
source('analise_textual_sapl.R')
source('ui.R')
source('server.R')

shinyApp(ui, server)
