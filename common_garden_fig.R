
## putting it all together

# This is for Mary and Molly's Neuro grant, July 2017:

require(cowplot)
require(tidyverse)
require(magrittr)
source("https://raw.githubusercontent.com/lukereding/random_scripts/master/plotting_functions.R")

### courting and courtships plots

# read in dataframe
df_avg <- read_csv("~/Documents/common_garden/df.csv")
df_avg$treatment <- factor(df_avg$treatment, levels = c("LL", "LS", "INT", "SS", "FF"))

limits <- aes(ymax = avg_court + se_court, ymin=avg_court - se_court)
courts <- df_avg %>%
group_by(treatment) %>%
summarize(avg_court = mean(total_courtship, na.rm=T) * 4, se_court = sd(total_courtship, na.rm=T) / n(), sd_court = sd(total_courtship, na.rm=T) ) %>%
ggplot(aes(treatment, avg_court)) +
  geom_bar(aes(fill=treatment), stat = "identity") +
  geom_errorbar(limits, position=position_dodge(width=0.9), width=0) +
  ylab("events per min.") +
  xlab("") +
  theme_pubr() +
  scale_fill_world(guide = F) +  
  ggtitle("courtship")+
  theme(axis.ticks.x = element_blank(),
        axis.text = element_text(size = 16),
        axis.title = element_text(size = 16),
        title = element_text(size = 20))

limits <- aes(ymax = avg_coerse + se_coerse, ymin=avg_coerse - se_coerse)
cosersion <- df_avg %>%
mutate(coerse = small_vs_female + int_vs_female) %>%
group_by(treatment) %>%
summarize(avg_coerse = mean(coerse, na.rm=T) *4, se_coerse = sd(coerse, na.rm=T) / n()) %>%
ggplot(aes(treatment, avg_coerse)) +
  geom_bar(aes(fill=treatment), stat = "identity") +
  geom_errorbar(limits, position=position_dodge(width=0.9), width = 0) +
  scale_fill_world(guide = F) +  
  ylab("") +
  xlab("") +
  theme_pubr() +
  ggtitle("coercion")+
  theme(axis.ticks.x = element_blank(),
        axis.text = element_text(size = 16),
        axis.title = element_text(size = 16),
        title = element_text(size = 20))


# (x <- plot_grid(courts, cosersion, align = "v", ncol = 1, labels=c("a","b"), rel_heights = c(1,1.2)))


## read in activity and foraging data

act_and_forge <- read_csv("~/Documents/common_garden/forging_activity.csv")
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
plot_grid(courts, cosersion, foraging, activity, labels = c("a", "b", "c", "d"), ncol = 2, nrow = 2, label_size = 18)
ggsave("~/Desktop/cg_fig.pdf", width = 5, height = 5)








