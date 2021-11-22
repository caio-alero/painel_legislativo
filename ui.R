
spinner <- tagList(
  spin_chasing_dots(),
  span("Carregando painel...", style="color:white;")
)

# 1. UI ----
ui <- tablerDashPage(
  navbar = tablerDashNav(
    id = 'mymenu',
    navMenu = tablerNavMenu(
      tablerNavMenuItem(
        tabName = 'tab1',
        icon = "box",
        'Proposições'
      ),
      tablerNavMenuItem(
        tabName = 'tab2',
        icon = "briefcase",
        'Pesquisa textual'
      ),
      tablerNavMenuItem(
        tabName = 'tab3',
        icon = "box",
        'Sessões'
      )
    )
  ),
  footer = tablerDashFooter(),
  title = "Painel Legislativo",
  body = tablerDashBody(
    useWaiter(),
    waiterShowOnLoad(spinner),
    e_theme_register('{"color":["#0791b7","#dad944","#61a0a8","#fb5057","#47c1ff","#f2b3c9"]}', name = "myTheme"),
    tablerTabItems(
      tablerTabItem(
        tabName = 'tab1',
        # 1.1 filtros ----
        fluidRow(
          column(width = 2, 
                 pickerInput(
                   inputId = 'data',
                   label = 'Ano:',
                   choices = year(min(sapl_data$data)):year(max(sapl_data$data)),
                   multiple = TRUE,
                   selected = year(max(sapl_data$data)))
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
      tablerTabItem(
        tabName = 'tab2',
        # 1.4 dados ui ----
        fluidRow(
          tablerCard(
            width = 6,
            title = 'Top 100 palavras mais utilizadas',
            echarts4rOutput('wordcloud')
          )
        ),
        fluidRow(
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
      
      
      tablerTabItem(
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
    )
  )
)