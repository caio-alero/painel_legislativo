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

options(encoding = "UTF-8")
#source('webscrapping_sessoes.R', local = TRUE)

# LEITURA DOS DADOS ----

# dados das matérias ----
agrupamento_status <- read.table('agrupamento_status.txt', sep = '\t', header = TRUE)
sapl_data <- readRDS(url('https://github.com/caio-alero/painel_legislativo/blob/main/dados_sapl.rds?raw=TRUE'))

sapl_data <- merge(sapl_data, agrupamento_status, by.y = 'status')
sapl_data$Grupo <- recode_factor(as.factor(sapl_data$Grupo),
                                 '1' = 'Proposição Aprovada',
                                 '2' = 'Proposição Rejeitada',
                                 '3' = 'Em tramitação',
                                 '4' = 'Proposição Retirada',
                                 'NA' = 'NA')

source('webscrapping\\webscrapping_sessoes.R')
source('analise_textual_sapl.R')
source('ui.R')
source('server.R')

shinyApp(ui, server)
