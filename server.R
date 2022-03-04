# 2. SERVER ----
server <- function(input, output, session) {

  Sys.sleep(2)
  waiter_hide()
  # 2.1 indices materias ----
  output$indices <- renderUI({
    value1 <- sapl_data %>% 
      filter(ano_apresentacao %in% input$data,
             projeto %in% input$tipo) %>% 
      summarise(n = n())
    
    value2 <- sapl_data %>% 
      filter(ano_apresentacao %in% input$data,
             projeto %in% c('PDL', 'PEC', 'PLC', 'PLO', 'PRE')) %>% 
      summarise(n = n())
    
    value3 <- sapl_data %>% 
      filter(ano_apresentacao %in% input$data,
             projeto %in% input$tipo,
             Grupo == 'Aprovada')%>% 
      summarise(n = n())
    
    value4 <- sapl_data %>% 
      filter(ano_apresentacao %in% input$data,
             projeto %in% input$tipo,
             Grupo == 'Rejeitada') %>% 
      summarise(n = n())
      
    value5 <- sapl_data %>% 
      filter(ano_apresentacao %in% input$data,
             projeto %in% input$tipo,
             Grupo == 'Em tramitação') %>% 
      summarise(n = n())
    
    fluidRow(
      #tablerStatCard(value = countup(value1$n, duration = 4), title = 'total de matérias'),
      tablerStatCard(value = countup(value2$n, duration = 4), title = 'total de proposições'),
      tablerStatCard(value = countup(value3$n, duration = 4), title = 'proposições aprovadas'),
      tablerStatCard(value = countup(value4$n, duration = 4), title = 'proposições rejeitadas'),
      tablerStatCard(value = countup(value5$n, duration = 4), title = 'em tramitação')
    )
    
  })
  
  # 2.2 graficos materias ----
  #e_common(font_family = 'Maiandra GD', theme = 'wonderland')
  
  output$materias_mes <- renderEcharts4r({
    # sapl_data %>%
    #   filter(projeto %in% input$tipo,
    #          ano_apresentacao %in% input$data) %>% 
    #   mutate(mes_apresentacao = month(data, label = TRUE, abbr = FALSE)) %>% 
    #   count(mes_apresentacao) %>% 
    #   mutate(mes_apresentacao = as.character(mes_apresentacao)) %>% 
    #   e_charts(x = mes_apresentacao) %>%
    #   e_bar(n, emphasis = list(itemStyle = list(shadowBlur = 10)),
    #         itemStyle = list(borderRadius = 5),
    #         #barCategoryGap = '45%',
    #         barGap = '0%') %>%
    #   e_mark_point(data = list(type = 'max'), label = list(color = 'white')) %>%
    #   e_tooltip(trigger = 'axis') %>%
    #   e_x_axis(splitLine = list(show = FALSE)) %>% 
    #   e_legend(show = FALSE) %>% 
    #   e_theme('myTheme')
    sapl_data %>% 
      filter(projeto %in% input$tipo,
             ano_apresentacao %in% input$data) %>%
      count(ano_apresentacao) %>% 
      mutate(cond = ifelse(ano_apresentacao == year(Sys.time()), 'blue', 'grey')) %>% 
      group_by(cond) %>% 
      e_charts(x = ano_apresentacao) %>% 
      e_bar(n, emphasis = list(itemStyle = list(shadowBlur = 10)),
            itemStyle = list(borderRadius = 5), stack = TRUE) %>% 
      e_tooltip(formatter = htmlwidgets::JS("
                                        function(params)
                                        {
                                            return `<strong> ${params.value[0]} </strong>
                                                    <br/> 
                                                    Qtd. de matérias: ${params.value[1]}`
                                        }  ")) %>% 
      e_legend(show = FALSE) %>% 
      e_theme('myTheme') %>% 
      e_color(color = c('#0791b7', '#cccccc'))
  })
  output$materias_status <- renderEcharts4r({
    sapl_data %>% 
      filter(projeto %in% input$tipo,
             ano_apresentacao %in% input$data,
             !is.na(Grupo)) %>%
      filter(projeto %nin% c('VT', 'VP', 'REQ', 'IND')) %>% 
      count(Grupo) %>% 
      mutate(prop = round(n*100/sum(n), 1)) %>% 
      e_charts(Grupo) %>% 
      e_pie(n, radius = c("50%", "70%")) %>% 
      e_tooltip(trigger = 'item') %>% 
      e_labels(FALSE) %>% 
      e_theme('myTheme')
  })
  output$materias_tipo <- renderEcharts4r({
    sapl_data %>%
      filter(ano_apresentacao %in% input$data,
             projeto %in% input$tipo) %>%
      count(projeto) %>% 
      mutate(prop = round(n*100/sum(n), 1)) %>% 
      arrange(-desc(n)) %>% 
      e_charts(x = projeto) %>% 
      e_bar(serie = n,
            emphasis = list(itemStyle = list(shadowBlur = 10)),
            itemStyle = list(borderRadius = 5)) %>% 
      e_tooltip(trigger = 'axis') %>% 
      e_flip_coords() %>% 
      e_legend(show = FALSE) %>% 
      e_theme('myTheme')
  })
  output$vetos <- renderEcharts4r({
    sapl_data %>% 
      filter(projeto %in% c('VP', 'VT'),
             ano_apresentacao %in% input$data) %>% 
      count(projeto) %>% 
      e_charts(projeto) %>% 
      e_pie(n, radius = c("50%", "70%")) %>% 
      e_tooltip(trigger = 'item') %>% 
      e_labels(FALSE) %>% 
      e_theme('myTheme')
  })

  output$materias_autoria <- renderEcharts4r({
    sapl_data %>% 
      filter(ano_apresentacao %in% input$data,
             projeto %in% input$tipo) %>%
      mutate(autor = stringr::str_trim(autor)) %>% 
      count(autor) %>% 
      filter(!is.na(autor)) %>% 
      mutate(poder = NA) -> tabela_autoria
    
    
    tabela_autoria %>% 
      mutate(poder = case_when(str_detect(autor, 'Defensoria Pública') ~ 'Defensoria Pública',
                               str_detect(autor, 'Tribunal De Contas') ~ 'Tribunal de Contas',
                               str_detect(autor, 'Tribunal De Justiça') ~ 'Tribunal de Justiça',
                               str_detect(autor, 'Executivo') ~ 'Executivo',
                               is.na(poder) ~ 'Legislativo'))
    
    tabela_autoria <- tabela_autoria %>% 
      as_tibble() %>% 
      rename(name = autor, value = n)
    
    tabela_poder <- tabela_autoria %>% 
      group_by(poder) %>% 
      summarise(value = sum(value)) %>% 
      rename(name = poder)
    
    tabela_poder %>% 
      #group_by(poder) %>%
      #group_nest() %>%
      mutate(value = tabela_poder$value) %>%
      # rename(name = poder,
      #        children = data) %>%
      e_charts() %>% 
      e_treemap(itemStyle = list(borderColor = 'white',
                                 borderWidth = 0.3)) %>% 
      e_tooltip(
        formatter = htmlwidgets::JS("
    function(params){
      return(params.name + ': ' + params.value);
    }
  ")) %>% 
      e_labels(position = 'insideTopLeft', 
               formatter = '{b}\n{c}') %>% 
      e_theme('myTheme')
  })
  
  # 2.2 wordcloud ----
  output$wordcloud <- renderEcharts4r({
    top_words %>% 
      e_color_range(freq, color) %>% 
      e_charts() %>% 
      e_cloud(terms, freq, color, shape = 'circle',
              emphasis = list(itemStyle = list(shadowBlur = 10))) %>% 
      e_tooltip()
  })
  
  # 2.3 dados materias ----
  output$dados <- renderDT({
    sapl_data %>% 
      filter(projeto %in% input$tipo,
             ano_apresentacao %in% input$data) %>%
      select(num_projeto, autor, ementa, data, localizacao_atual, status) %>% 
      #mutate(data = dmy(format(data, '%d/%m/%y'))) %>% 
      datatable(rownames = FALSE, 
                style = 'bootstrap4',
                options = list(paging = TRUE,
                               scrollY = TRUE,
                               #dom = 'ftp',
                               pagelength = 10,
                               searchHighlight = TRUE,
                               search = list(regex = TRUE),
                               language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Portuguese-Brasil.json')
                               # initComplete = JS(
                               #   "function(settings, json) {",
                               #   "$(this.api().table().header()).css({'background-color': '#208ffa', 'color': '#fff'});",
                               #   "}")
                ),
                colnames = c('Matéria', 'Autoria', 'Ementa', 'Data de apresentação', 'Localização atual', 'Status atual')) 
  })
  
  # 2.4 graficos sessoes ----
  output$sessoes_pie <- renderEcharts4r({
    dados_sessoes %>%
      count(tipo_sessao) %>%
      e_charts(tipo_sessao) %>%
      e_pie(serie = n,
            emphasis = list(itemStyle = list(shadowBlur = 10)),
            itemStyle = list(borderRadius = 5),
            radius = c('50%', '70%')) %>%
      e_tooltip() %>% 
      e_labels(FALSE) %>% 
      e_theme('myTheme')
  })

  output$sessoes_barplot <- renderEcharts4r({
    dados_sessoes %>%
      count(mes, tipo_sessao) %>%
      group_by(tipo_sessao) %>%
      mutate(mes = as.character(mes)) %>%
      e_charts(mes) %>%
      e_bar(serie = n,
            emphasis = list(itemStyle = list(shadowBlur = 10)),
            itemStyle = list(borderRadius = 5),
            barGap = '3%') %>%
      e_tooltip(trigger = 'axis') %>% 
      e_theme('myTheme')
  })
  
  output$dados_sessoes <- renderDT({
    dados_sessoes %>% 
      # filter(projeto %in% input$tipo,
      #        ano_apresentacao %in% input$data) %>%
      select(nome_sessao, data_sessao, mes, ano) %>% 
      mutate(data_sessao = as.Date(data_sessao, '%d/%m/%y'),
             mes = month(data_sessao, label = TRUE, abbr = FALSE)) %>% 
      datatable(rownames = FALSE, 
                style = 'bootstrap4',
                options = list(paging = TRUE,
                               scrollY = TRUE,
                               #dom = 'ftp',
                               pagelength = 10,
                               searchHighlight = TRUE,
                               search = list(regex = FALSE),
                               language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Portuguese-Brasil.json')
                               # initComplete = JS(
                               #   "function(settings, json) {",
                               #   "$(this.api().table().header()).css({'background-color': '#208ffa', 'color': '#fff'});",
                               #   "}")
                ),
                colnames = c('Número da Sessão', 'Data', 'Mês', 'Ano')) 
  })
}


