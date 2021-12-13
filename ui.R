
spinner <- tagList(
  spin_chasing_dots(),
  span("Carregando painel...", style="color:white;")
)

# 1. UI ----
ui <- tabler_page(
  title = 'Painel Legislativo',
  dark = FALSE,
  tabler_navbar(
    nav_menu = tabler_navbar_menu(
      tabler_navbar_menu_item(
        icon = icon('chart-bar'),
        tabName = 'tab1',
        text = 'Proposições'
      ),
      tabler_navbar_menu_item(
        tabName = 'tab2',
        'Pesquisa textual'
      ),
      tabler_navbar_menu_item(
        tabName = 'tab3',
        'Sessões'
      )
    )
  ),
  tabler_body(
    useWaiter(),
    waiterShowOnLoad(spinner),
    e_theme_register('{"color":["#0791b7","#dad944","#cccccc", "#fb5057","#47c1ff","#f2b3c9"]}', name = "myTheme"),
    tabler_tab_items(
      tabler_tab_item(
        tabName = 'tab1',
        # 1.1 filtros ----
        fluidRow(
          column(width = 2, 
                 pickerInput(
                   inputId = 'data',
                   label = 'Ano:',
                   choices = sort(unique(year(sapl_data$data)), decreasing = TRUE),
                   multiple = TRUE,
                   selected = unique(year(sapl_data$data)))
          ),
          
          column(width = 3,
                 pickerInput(
                   inputId = 'tipo',
                   label = 'Tipo da matéria:',
                   choices = unique(sapl_data$projeto),
                   selected = unique(sapl_data$projeto),
                   multiple = TRUE,
                   options = pickerOptions(actionsBox = TRUE, 
                                           title = 'Tipo',
                                           selectAllText = 'Selecionar todos',
                                           deselectAllText = 'Anular todos'))
          )
        ),
        
        # 1.2 indices ui ----
        uiOutput(outputId = 'indices'),
        
        # 1.3 graficos ui ----
        fluidRow(
          tablerCard(
            width = 12,
            title = 'Matérias apresentadas por mês',
            echarts4rOutput('materias_mes')
          )
        ),
        
        fluidRow(
          tablerCard(
            width = 4,
            title = 'Status',
            echarts4rOutput('materias_status')
          ),
          tablerCard(
            width = 4,
            title = 'Tipo da matéria',
            echarts4rOutput('materias_tipo')
          ),
          tablerCard(
            width = 4,
            title = 'Vetos',
            echarts4rOutput('vetos')
          )
        ),
        
        # 1.3 autoria ui ----
        fluidRow(
          tablerCard(
            width = 12,
            title = 'Autoria',
            echarts4rOutput('materias_autoria')
          )
        ),
      ),
      tabler_tab_item(
        tabName = 'tab2',
        # 1.4 dados ui ----
        tabler_row(
          tablerCard(
            width = 12,
            title = 'Top 100 palavras mais utilizadas',
            echarts4rOutput('wordcloud')
          )
        ),
        tabler_row(
          tablerCard(
            width = 12,
            title = 'Dados',
            column(
              width = 12,
              dataTableOutput('dados')
            )
          ) 
        )
      ),
      
      
      tabler_tab_item(
        tabName = 'tab3',
        fluidRow(
          tablerCard(
            width = 8,
            title = 'Sessões realizadas por mês',
            echarts4rOutput('sessoes_barplot')
          ),
          tablerCard(
            width = 4,
            title = 'Tipo de sessão',
            echarts4rOutput('sessoes_pie')
          )
        ),
        tablerCard(
          width = 12,
          title = 'Sessões',
          column(
            width = 12,
            dataTableOutput('dados_sessoes')
          )
        )
      )
    ),
    footer = tabler_footer(
      left = "Rstats, 2020",
      right = a(href = "https://www.google.com", "More")
    )
  )
)