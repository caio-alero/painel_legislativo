library(dplyr)
library(Cairo)
library(ggplot2)
library(bbplot)
library(extrafont)
library(ggsci)

loadfonts(device = 'win')

files <- list.files(path = 'data/', pattern = '.rds', full.names = TRUE)
sapl_data <- do.call("bind_rows", lapply(files, readRDS)) 
agrupamento_status <- read.table('agrupamento_status.txt', sep = '\t', header = TRUE) %>% as_tibble()

sapl_data <- merge(sapl_data, agrupamento_status, by = 'status')
sapl_data$Grupo <- recode_factor(as.factor(sapl_data$Grupo),
                                 '1' = 'Proposição Aprovada',
                                 '2' = 'Proposição Rejeitada',
                                 '3' = 'Em tramitação',
                                 '4' = 'Proposição Arquivada',
                                 'NA' = 'NA')

sapl_data <- as_tibble(sapl_data)


# materias por ano
ggsave('testjpeg.jpg', width = 10, height = 6)
sapl_data %>% 
  filter(ano_apresentacao == 2021) %>% 
  count(mes_apresentacao) %>% 
  ggplot(aes(x = mes_apresentacao, y = n, label = n, fill = '')) +
  geom_bar(stat = 'identity', width = 0.7) +
  # geom_line(color = 'grey30', size = 1) +
  # geom_point(color = 'grey30') +
  # geom_label(aes(x = 2019, y = 4500, label = "Em 2021 houve\n um aumento de x%\n em relação a 2020"), 
  #            hjust = 0, 
  #            vjust = 0.5, 
  #            lineheight = 0.8,
  #            colour = "#555555", 
  #            fill = "white", 
  #            label.size = NA, 
  #            family = 'Bahnschrift',
  #            size = 5)  +
  # geom_curve(aes(x = 2020, y = 4100, xend = 2021, yend = 3800), 
  #            colour = "#555555", 
  #            size=0.5, 
  #            curvature = -0.2,
  #            arrow = arrow(length = unit(0.03, "npc"))) + 
  geom_text(vjust = -0.2, family = 'Bahnschrift', size = 5) +
  scale_fill_jama() +
  labs(x = '', y = '', subtitle = 'Número de matérias apresentadas') +
  coord_cartesian(ylim = c(0, 600)) +
  theme_classic(base_size = 16) +
  theme(
    legend.position = 'none',
    axis.line.x = element_line(colour = "#333333", size = 1),
    panel.grid.major.y = element_line(colour = 'gray'),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.background = element_rect(fill = 'white'),
    axis.title.y = element_text(angle = 0, vjust = 1, hjust = 10),
    title = element_text(size = 14),
    text = element_text(size = 18, family = 'Bahnschrift')
  )
dev.off()


sapl_data %>% 
  filter(ano_apresentacao == 2008) %>% 
  count(projeto)


dados_sessoes %>% 
  count(tipo_sessao) %>% 
  mutate(porc = round(n*100/sum(n), 1))



