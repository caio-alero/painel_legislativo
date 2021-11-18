#####################################################
#   Histórico de tramitações das matérias por
# comissão
#
# Caio Oliveira - 02/02/2021
#####################################################

library(dplyr)
library(xml2)
library(stringr)
library(jbkmisc)

url_pag <- 'https://sapl.al.ro.leg.br/sistema/relatorios/historico-tramitacoes?tramitacao__data_tramitacao_0=01%2F01%2F2020&tramitacao__data_tramitacao_1=31%2F12%2F2020&tramitacao__unidade_tramitacao_local=&tramitacao__unidade_tramitacao_destino=35&tipo=&tramitacao__status=&autoria__autor=29&pesquisar=Pesquisar'

read_html(url_pag) %>% 
  xml_find_all('//tr') %>% 
  xml_text()  %>% 
  str_clean() %>% 
    length() - 2
