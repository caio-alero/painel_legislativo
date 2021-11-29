
spinner <- tagList(
  spin_chasing_dots(),
  span("Carregando painel...", style="color:white;")
)

# 1. UI ----
  ui <- navbarPage(title = "Painel Legislativo", id = "tabs",
                 tabPanel("Home",
                          useWaiter(),
                          waiterShowOnLoad(spinner),
                          e_theme_register('{"color":["#0791b7","#dad944","#cccccc", "#fb5057","#47c1ff","#f2b3c9"]}', name = "myTheme"),
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
                          )
                 ),
                 tabPanel("Foo", 
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
                          )),
                 tabPanel("Bar", 
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