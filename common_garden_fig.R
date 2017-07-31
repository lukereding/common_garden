
## putting it all together

# This is for Mary and Molly's Neuro grant, July 2017:

require(cowplot)
require(tidyverse)
require(magrittr)
source("https://raw.githubusercontent.com/lukereding/random_scripts/master/plotting_functions.R")

# 
# generate_label_df <- function(x, y, dataframe){
#   require(lmPerm)
#   require(multcompView)
#   require(magrittr)
#   arguments <- as.list(match.call())
#   # do the anova
#   model <- aovp(eval(arguments$y, dataframe) ~ eval(arguments$x, dataframe), data = dataframe)
#   print(summary(model))
#   if(summary(model)[[1]][5][1,] > 0.05){
#     warning("the ANOVA is not significant")
#   }
#   
#   HSD <- TukeyHSD(model, ordered = FALSE, conf.level = 0.95)
#   print(HSD)
#   
#   # Extract labels and factor levels from Tukey post-hoc 
#   Tukey.levels <- HSD[[1]][,4]
#   Tukey.labels <- multcompLetters(Tukey.levels)['Letters']
#   plot.labels <- names(Tukey.labels[['Letters']])
#   
#   boxplot.df <- split(dataframe, eval(arguments$x, dataframe)) %>%
#     lapply(., function(z) eval(arguments$y, z)) %>%
#     lapply(., max, na.rm=T) %>%
#     unlist# %>%
#   #add(((range(.)[2] - range(.)[1])))
#   
#   boxplot.df <- data.frame(
#     height = boxplot.df,
#     names(boxplot.df)
#   )
#   names(boxplot.df)[2] <- "plot.labels"
#   
#   # Create a data frame out of the factor levels and Tukey's homogenous group letters
#   plot.levels <- data.frame(plot.labels, 
#                             labels = Tukey.labels[['Letters']],
#                             stringsAsFactors = FALSE)
#   
#   # Merge it with the labels
#   labels.df <- merge(plot.levels, boxplot.df, sort = FALSE)
#   print(labels.df)
#   
#   return(labels.df)
# }
# # 
# # ggplot(df_avg, aes(y=total_courtship, x=treatment)) + 
# #   geom_boxplot() +
# #   geom_text(data = generate_label_df(x = treatment, y = total_courtship,df_avg), 
# #             aes(x = plot.labels, y = height, label = labels), vjust = -1)
# # 
# 
# 


### courting and courtships plots

# read in dataframe
df_avg <- read_csv("~/Documents/common_garden/df.csv")
df_avg$treatment <- factor(df_avg$treatment, levels = c("LL", "LS", "INT", "SS", "FF"))

# limits <- aes(ymax = avg_court + se_court, ymin=avg_court - se_court)
courts <- df_avg %>% 
  group_by(treatment) %>%
  summarize(avg_court = mean(total_courtship, na.rm=T) * 6, 
            total_number = n(), 
            sd_court = sd(total_courtship, na.rm = T), 
            se_court = sd_court / n())

court_plot <- ggplot(courts, aes(treatment, avg_court)) +
  geom_bar(aes(fill=treatment), stat = "identity") +
  geom_errorbar(aes(ymin = avg_court - se_court, ymax = avg_court + se_court), position=position_dodge(width=0.9), width=0) +
  ylab("events per min.") +
  xlab("") +
  scale_y_continuous(limits = c(0, 13))+
  theme_pubr() +
  scale_fill_world(guide = F) +  
  ggtitle("courtship") +
  # geom_text(data = generate_label_df(x = treatment, y = total_courtship, df_avg),
  #           aes(x = plot.labels, y = height, label = labels), vjust = -1) +
  theme(axis.ticks.x = element_blank(),
        axis.text = element_text(size = 16),
        axis.title = element_text(size = 16),
        title = element_text(size = 20)) 


df_avg %<>% mutate(coerse = small_vs_female + int_vs_female)
cosersion <- df_avg %>% 
  group_by(treatment) %>%
  summarize(avg_coerse = mean(coerse, na.rm=T) * 6, 
            total_number = n(), 
            sd_coerse = sd(coerse, na.rm=T),
            se_coerse = sd(coerse, na.rm=T) / n())

cosersion_plot <- cosersion %>%
  ggplot(., aes(x = treatment, y = avg_coerse)) +
  geom_bar(aes(fill=treatment), stat = "identity") +
  geom_errorbar(aes(ymin = avg_coerse - se_coerse, ymax = avg_coerse + se_coerse), position=position_dodge(width=0.9), width = 0) +
  scale_fill_world(guide = F) +  
  ylab("") +
  xlab("") +
  theme_pubr() +
  ggtitle("coercion")+
  # geom_text(data = generate_label_df(x = treatment, y = coerse, df_avg),
  #           aes(x = plot.labels, y = height, label = labels), vjust = -1) +
  theme(axis.ticks.x = element_blank(),
        axis.text = element_text(size = 16),
        axis.title = element_text(size = 16),
        title = element_text(size = 20)) 

# (x <- plot_grid(courts, cosersion, align = "v", ncol = 1, labels=c("a","b"), rel_heights = c(1,1.2)))


## read in activity and foraging data

act_and_forge <- read_csv("~/Documents/common_garden/forging_activity_summarized.csv")
act_and_forge$treatment <- factor(act_and_forge$treatment, levels = c("LL", "LS", "INT", "SS", "FF"))


names(act_and_forge)

activity <- act_and_forge %>%
  ggplot(aes(x = treatment, y = time_active_per_fish_per_minute)) +
  geom_col(aes(fill = treatment)) +
  geom_errorbar(aes(ymin=time_active_per_fish_per_minute-time_active_per_fish_per_minute_se, ymax=time_active_per_fish_per_minute+time_active_per_fish_per_minute_se), colour="black", width=0) +
  theme_pubr() +
  ylab("") +
  ggtitle("activity") +
  scale_fill_world(guide = F) +
  theme(axis.ticks.x = element_blank(),
        axis.text = element_text(size = 16),
        axis.title= element_text(size = 16),
        title = element_text(size = 20))

# foraging events per treatment
foraging <- act_and_forge %>%
  ggplot(aes(x = treatment, y = foraging_per_fish_per_minute)) +
  geom_col(aes(fill = treatment)) +
  geom_errorbar(aes(ymin=foraging_per_fish_per_minute-foraging_per_fish_per_minute_se, ymax=foraging_per_fish_per_minute+foraging_per_fish_per_minute_se), colour="black", width=0) +
  theme_pubr() +
  ylab("events per min.") +
  ggtitle("foraging") +
  scale_fill_world(guide = F) +
  theme(axis.ticks.x = element_blank(),
        axis.text = element_text(size = 16),
        axis.title = element_text(size = 16),
        title = element_text(size = 20))




# plot everything together
plot_grid(court_plot, cosersion_plot, foraging, activity, labels = c("a", "b", "c", "d"), ncol = 2, nrow = 2, label_size = 18)
ggsave("~/Desktop/cg_fig.pdf", width = 5, height = 5)








