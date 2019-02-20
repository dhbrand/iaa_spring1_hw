library(tidyverse)
library(extrafont)
font_import()
results <- haven::read_sas("financial_analytics/data/opt_results.sas7bdat")

sd_risk <- sd(results$Portfolio_Stdev_Results)
ggplot(results, aes(Portfolio_Stdev_Results, Expected_Return_Results)) +
  geom_line(size=2) +
  geom_point(size=8, color='blue') +
  theme_bw() +
  labs(x='Risk', y='Return', title='Efficient Frontier') +
  theme(plot.title = element_text(hjust = 0.5, size = 32, face = 'bold', family = 'Raleway'), 
        axis.title = element_text(size = 24, face = 'bold', family = 'Raleway'), 
        axis.text = element_text(size = 16, face = 'bold', family = 'Raleway'), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(arrow = arrow(),
                                 size = 2), 
        panel.border = element_blank()) +
  scale_y_continuous(limits = c(0.0005, .00085), 
                     breaks = c(0.0006, 0.0007, 0.0008), 
                     labels = c('0.06%', '0.07%', '0.08%')) +
  scale_x_continuous(breaks = c(0.00008, 0.0001, 0.00012), 
                     labels = c('0.008%', '0.010%', '0.012%'))

