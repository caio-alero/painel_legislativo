library(rvest)      # web scrapping
library(dplyr)      # manipular dados
library(stringr)    # manipular os textos
library(xml2)       # ler html
library(jbkmisc)
library(tm)

# o código de scrape a seguir serve tanto para PLO como PLC
# tipos de materia: PLO, PLC, VP
# uma_pagina = TRUE ou FALSE

#sapl_scrap <- function(URL, tipo_materia = NULL, uma_pagina = FALSE) {
sapl_scrap <- function(URL, uma_pagina = FALSE) {

  # extraindo o numero total de paginas
  num_total_pages <- ifelse(uma_pagina,
                            1,
                            str_replace(URL, 'page=PAGE&', '') %>% 
                              read_html() %>% 
                              xml_find_all('//nav/ul') %>% 
                              xml_text() %>% 
                              str_clean() %>%
                              str_match_all('[0-9]+') %>% 
                              unlist() %>% 
                              as.numeric() %>% 
                              max())

  
  
  # scrapping das ementas
  num_projeto <- list()
  data_apresentacao <- list()
  localizacao_atual <- list()
  autor <- list()
  ementas <- list()
  status <- list()
  data_ultima_tram <- list()
  resultado <- list()
  
  for(i in 1:num_total_pages) {
    
    
    url <- str_replace(URL, 'PAGE', as.character(i))
    pagina <- read_html(url) %>% xml_root()
    
    # numero de materia
    nodes_link <- xml_find_all(pagina, '//td//a')
    #num_projeto[[i]] <- xml_text(nodes_link)[str_detect(xml_text(nodes_link), tipo_materia)]
    num_projeto[[i]] <- xml_text(nodes_link)[!(xml_text(nodes_link) %in% c('Texto Original', '', 'Acompanhar Matéria'))]
    num_projeto[[i]] <- num_projeto[[i]][!str_detect(num_projeto[[i]], pattern = '\n')]
    
    # textos
    textos <- xml_find_all(pagina, '//td') %>% 
      xml_text() %>% 
      str_clean()
    
    textos <- textos[textos != ' ']
    textos <- textos[-1]
    
    #-----------------------------------------------------------------------------------------------------------
    #                 data de apresentacao
    #-----------------------------------------------------------------------------------------------------------
    data_apresentacao[[i]] <- xml_find_all(pagina, '//td/text()[6]') %>% 
      xml_text() %>% 
      str_clean() %>% 
      str_trim()
    
    
    #-----------------------------------------------------------------------------------------------------------
    #                  AUTORIA
    #-----------------------------------------------------------------------------------------------------------
    autores <- ifelse(str_detect(textos, 'Autor: '),
                      ifelse(str_detect(textos, 'Localização Atual'), 
                             gsub('.*Autor: (.+) Localização Atual.*', '\\1', textos),
                             removeWords(gsub('.*Autor: (.+)', '\\1', textos), c('Texto Original', 
                                                                                 'Acompanhar Matéria',
                                                                                 'Norma.*',
                                                                                 'Data.*',
                                                                                 'Audiência.*'))),
                      NA) %>% 
      stringi::stri_trim_right()
    
    
    autor[[i]] <- ifelse(str_detect(autores, 'Resultado'),
           gsub('Resultado.*', '\\1', autores),
           autores) %>% 
      str_trim()

    #-----------------------------------------------------------------------------------------------------------
    #                  LOCALIZACAO ATUAL
    #-----------------------------------------------------------------------------------------------------------
    loc_atual <- ifelse(str_detect(textos, 'Localização Atual'),
                        gsub('.*Localização Atual: (.+) Status.*', '\\1', textos),
                        NA)
    localizacao_atual[[i]] <- ifelse(str_detect(textos, 'Localização Atual:'), loc_atual, NA)
    
    #-----------------------------------------------------------------------------------------------------------
    #                     EMENTAS
    #-----------------------------------------------------------------------------------------------------------
    ementas[[i]] <- ifelse(str_detect(textos, 'Ementa'),
                           gsub('.*Ementa: (.+) Apresentação.*', '\\1', textos))
    


    #-----------------------------------------------------------------------------------------------------------
    #                       STATUS
    #-----------------------------------------------------------------------------------------------------------
    status2 <- ifelse(str_detect(textos, 'Status'), 
                      gsub('.*Status: (.+) Data Fim Prazo.*', '\\1', textos), 
                      NA)
    status[[i]] <- ifelse(str_detect(textos, 'Status:'), status2, NA)

    
    #-----------------------------------------------------------------------------------------------------------
    #                RESULTADO
    #-----------------------------------------------------------------------------------------------------------
    resultados <- ifelse(str_detect(textos, 'Resultado'), 
                         ifelse(str_detect(textos, 'Data Votação'), 
                                gsub('.*Resultado: (.+) Data Votação.*', '\\1', textos),
                                gsub('.*Resultado: (.+)', '\\1', textos)
                         ),
                         NA)
    
    resultados <- ifelse(str_detect(resultados, 'Data Da Última Tramitação'),
                             gsub('Data Da Última Tramitação.*', '\\1', resultados),
                             resultados)
    
    resultados <- ifelse(str_detect(resultados, 'Texto Original'),
                         gsub('Texto Original.*', '\\1', resultados),
                         resultados) %>% str_trim()
    
    resultado[[i]] <- ifelse(str_detect(resultados, 'Norma Jurídica'),
                             gsub('Norma Jurídica.*', '\\1', resultados),
                             resultados) %>% str_trim()
    
    print(i)
    
  }
  
  
  dados_ws <- tibble(num_projeto = unlist(num_projeto),
                      ementa = unlist(ementas),
                      data_apresentacao = unlist(data_apresentacao),
                      autor = unlist(autor),
                      localizacao_atual = unlist(localizacao_atual),
                      status = unlist(status),
                      resultado = unlist(resultado))
  
  return(dados_ws)
}

tempo_inicial <- Sys.time()

for(ano in 2021:2021){
  dados_ws <- sapl_scrap(URL = str_replace_all(string = 'https://sapl.al.ro.leg.br/materia/pesquisar-materia?page=PAGE&tipo=&ementa=&numero=&numeracao__numero_materia=&numero_protocolo=&ano=&o=&tipo_listagem=1&tipo_origem_externa=&numero_origem_externa=&ano_origem_externa=&data_origem_externa_0=&data_origem_externa_1=&local_origem_externa=&data_apresentacao_0=01%2F01%2FAAAA&data_apresentacao_1=31%2F12%2FAAAA&data_publicacao_0=&data_publicacao_1=&autoria__autor=&autoria__primeiro_autor=unknown&autoria__autor__tipo=&autoria__autor__parlamentar_set__filiacao__partido=&relatoria__parlamentar_id=&em_tramitacao=&tramitacao__unidade_tramitacao_destino=&tramitacao__status=&materiaassunto__assunto=&indexacao=', 
                                               pattern = 'AAAA', replacement = as.character(ano)))
  
  # tratamento dos dados ----
  for(i in 1: nrow(dados_ws)) {
    if(grepl('PLO', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'PLO' 
    if(grepl('PLC', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'PLC'
    if(grepl('PRE', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'PRE'
    if(grepl('PEC', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'PEC'
    if(grepl('VT', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'VT'
    if(grepl('VP', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'VP'
    if(grepl('IND', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'IND'
    if(grepl('REQ', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'REQ'
    if(grepl('ECM', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'ECM'
    if(grepl('PDL', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'PDL'
    if(grepl('CEDP', as.character(dados_ws$num_projeto[i]), fixed = TRUE)) dados_ws$projeto[i] <- 'CEDP'
  }
  
  dados_ws$data <- gsub(' De ', '', dados_ws$data_apresentacao) %>% 
    strptime(format = '%d %B %Y')
  
  dados_ws <- dados_ws %>% 
    mutate(num_projeto = gsub('\\-.*', '', num_projeto),
           data_apresentacao = format(lubridate::dmy(data_apresentacao), '%d/%m/%Y'),
           mes_apresentacao = lubridate::month(data_apresentacao, label = TRUE, abbr = TRUE),
           ano_apresentacao = as.character(substring(data_apresentacao, 7, 11)),
           num_projeto = str_trim(num_projeto, side = 'right'))
  
  saveRDS(dados_ws, file = str_replace('data/saplAAAA.rds', 'AAAA', as.character(ano)))
  
}

Sys.time() - tempo_inicial


files <- list.files(path = 'data/', pattern = '.rds', full.names = TRUE)
sapl_data <- do.call("bind_rows", lapply(files, readRDS)) 

write.table(sapl_data, 'dados_completos_SAPL.txt', sep = '\t', row.names = FALSE, quote = FALSE)
