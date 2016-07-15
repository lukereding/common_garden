library(magrittr)
library(rjson)
library(dplyr)

# helper function: returns NA if the feild doesn't exist, otherwise returns the value
ret <- function(entry){
  if(is.null(entry)){
    return("NA")
  }
  else{
    return(entry)
  }
}

# bitchin' colors
g <- c(0.9649929502500952, 0.9531129905215493, 0.9191510752734625, 0.8593537612656912, 0.8817604211736523, 0.7700023490859729, 0.7161563289278935, 0.8232880086631527, 0.6542005475652726, 0.561817977440984, 0.7615832423359858, 0.5861204102347762, 0.43022162338501957, 0.6871358461951652, 0.5600145030589199,0.3290447800273386, 0.587268798255875, 0.5516378970902409, 0.26991762664572966, 0.46791931434441575, 0.5330773688488463, 0.24073795863422207, 0.34003177164489373, 0.4786370052053605, 0.21805042635421357, 0.22328637568306292, 0.38237877700552625, 0.17250549177124488, 0.11951843162770594, 0.24320155229883056)
greens <- c()
for(i in seq(1, length(g), by = 3)){
  greens %<>% c(rgb(g[i], g[1+i], g[2+i]))
}
greens <- colorRampPalette(greens)

files <- list.files("/Users/lukereding/Documents/common_garden/data", pattern = "*.json", full.names = T)
n <- length(files)

# create data frame
df <- data.frame("video_name" = character(n),
                   "large_vs_large" =integer(n),
                   "large_vs_small"= integer(n),
                   "int_vs_int"= integer(n),
                   "large_vs_female"= integer(n),
                   "small_vs_female"= integer(n),
                   "int_vs_female"= integer(n),
                   "female_vs_female"= integer(n),
                   "female_vs_male"= integer(n),
                   "large_courting"= integer(n),
                   "intermediate_courting"= integer(n),
                   "small_courting"= integer(n),
                   "number_focal"= integer(n),
                   "number_large_male"= integer(n),
                   "number_small_male"= integer(n),
                   "number_model_female"= integer(n),
                   "male_chased_juvenile"= integer(n),
                   "tank_id"= character(n),
                   "pairwise_distance_large_males"= double(n),
                   "pairwise_distance_small_males"= double(n),
                   "pairwise_distance_females"= double(n),
                   "pairewise_distance_juvs"= double(n),
                   "total_fish"= integer(n),
                   "date"= character(n),
                 "comments" = character(n),
                 "small_vs_small" = integer(n),
                 "observer" = character(n),
                 stringsAsFactors=FALSE)



for(i in 1:length(files)){
  # read in data
  json_data <- fromJSON(file=files[i])
  
  # extract the data
  df$video_name[i] <-  ret(json_data$video_name) %>% as.character
  df$large_vs_large[i] <-  ret(json_data$large_vs_large) %>% as.numeric
  df$large_vs_small[i] <-  ret(json_data$large_vs_small)%>% as.numeric
  df$int_vs_int[i] <-  ret(json_data$int_vs_int)%>% as.numeric
  df$large_vs_female[i] <-  ret(json_data$large_vs_female)%>% as.numeric
  df$small_vs_female[i] <-  ret(json_data$small_vs_female)%>% as.numeric
  df$int_vs_female[i] <-  ret(json_data$int_vs_female)%>% as.numeric
  df$female_vs_female[i] <-  ret(json_data$female_vs_female)%>% as.numeric
  df$female_vs_male[i] <-  ret(json_data$female_vs_male)%>% as.numeric
  df$large_courting[i] <-  ret(json_data$large_courting)%>% as.numeric
  df$intermediate_courting[i] <-  ret(json_data$intermediate_courting)%>% as.numeric
  df$small_courting[i] <-  ret(json_data$small_courting)%>% as.numeric
  df$number_focal[i] <-  ret(json_data$number_focal)%>% as.numeric
  df$number_large_male[i] <-  ret(json_data$number_large_male)%>% as.numeric
  df$number_small_male[i] <-  ret(json_data$number_small_male)%>% as.numeric
  df$number_model_female[i] <-  ret(json_data$number_model_female)%>% as.numeric
  df$male_chased_juvenile[i] <-  ret(json_data$male_chased_juvenile)%>% as.numeric
  df$tank_id[i] <-  ret(json_data$tank_id) %>% as.character
  df$pairwise_distance_large_males[i] <-  ret(json_data$pairwise_distance_large_males)%>% as.numeric
  df$pairwise_distance_small_males[i] <-  ret(json_data$pairwise_distance_small_males)%>% as.numeric
  df$pairwise_distance_females[i] <-  ret(json_data$pairwise_distance_females)%>% as.numeric
  df$pairewise_distance_juvs[i] <-  ret(json_data$pairewise_distance_juvs)%>% as.numeric
  df$total_fish[i] <-  ret(json_data$total_fish)%>% as.numeric
  df$date[i] <-  ret(json_data$date) %>% as.character
  df$comments[i] <-  ret(json_data$comments) %>% as.character
  df$observer[i] <- ret(json_data$observer) %>% as.character
  df$small_vs_small[i] <- ret(json_data$small_vs_small) %>% as.character
  
}

# get treatment
df$treatment <- gsub("[[:digit:]]","", df$tank_id)

# get total courtship events:
df %<>% mutate(total_courtship = large_courting + small_courting + intermediate_courting)

# get overall (total) aggression
df %<>% mutate(total_aggression = large_vs_large + large_vs_small + int_vs_int + large_vs_female + int_vs_female + female_vs_female + female_vs_male)


# function to use to collapse all the videos from one day into a single row
avg_if_numeric <- function(x){
  if(!is.character(x)){
    return(mean(x, na.rm=T))
  }
  else{
    if(length(levels(factor(x))) > 1){
      warning("you are trying to collapse non-matching characters. will take the first one, but beware.")
    }
    return(x[1])
  }
}

# to get the sum total of each behavior for each day:
df %<>% group_by(date, tank_id) %>% summarise_each(funs(avg_if_numeric))

# get the dates worked out
df$date %<>% as.Date(format = "%m-%d-%Y")

# graph some things
# define new theme

theme_luke <- function(font_size = 18, font_family = "", line_size = .5) {
  half_line <- font_size / 2
  small_rel <- 0.857
  small_size <- small_rel * font_size
  
  theme_grey(base_size = font_size, base_family = font_family) %+replace%
    theme(
      rect              = element_rect(fill = "transparent", colour = NA, color = NA, size = 0, linetype = 0),
      text              = element_text(family = font_family, face = "plain", colour = "black",
                                       size = font_size, hjust = 0.5, vjust = 0.5, angle = 0, lineheight = .9,
                                       margin = ggplot2::margin(), debug = FALSE),
      axis.text         = element_text(colour = "black", size = small_size),
      #axis.title        = element_text(face = "bold"),
      axis.text.x       = element_text(margin = ggplot2::margin(t = small_size / 4), vjust = 1),
      axis.text.y       = element_text(margin = ggplot2::margin(r = small_size / 4), hjust = 1),
      axis.title.x      = element_text(
        margin = ggplot2::margin(t = small_size / 2, b = small_size / 4)
      ),
      axis.title.y      = element_text(
        angle = 90,
        margin = ggplot2::margin(r = small_size / 2, l = small_size / 4),
      ),
      axis.ticks        = element_line(colour = "black", size = line_size),
      axis.line.x       = element_line(colour = "black", size = line_size),
      axis.line.y       = element_line(colour = "black", size = line_size),
      legend.key        = element_blank(),
      legend.margin     = grid::unit(0.1, "cm"),
      legend.key.size   = grid::unit(1, "lines"),
      legend.text       = element_text(size = rel(small_rel)),
      #    legend.position   = c(-0.03, 1.05),
      # legend.justification = c("left", "right"),
      panel.background  = element_blank(),
      panel.border      = element_blank(),
      panel.grid.major  = element_blank(),
      panel.grid.minor  = element_blank(),
      strip.text        = element_text(size = rel(small_rel)),
      strip.background  = element_rect(fill = "grey80", colour = "grey50", size = 0),
      plot.background   = element_blank(),
      plot.title        = element_text(face = "bold",
                                       size = font_size,
                                       margin = ggplot2::margin(b = half_line))
    )
}

# multiplot function for later:
# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


################################
############# ploting ##############
######################################
library(ggplot2)
library(dplyr)
library(viridis)


################################
######## time trends: ################
#########################################


# plot by date:
ggplot(df, aes(date, total_aggression, color = treatment)) + 
  geom_line(size=1.25, position = position_dodge(width=3)) +
  scale_size(name = "total aggressions") +
  theme_luke() + 
  geom_point(aes(size = total_aggression),position = position_dodge(width=3)) +
  ylab("average aggressions per video") +
  # scale_color_manual(values=greens(5)[2:5]) +
  scale_colour_brewer(palette = "Dark2") +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  scale_x_date() 
ggsave("aggressions_over_time.pdf", path = "/Users/lukereding/Documents/common_garden/data/")

ggplot(df, aes(date, total_courtship, color = treatment)) + 
  geom_line(size=1.25, position = position_dodge(width=3)) +
  theme_luke() + 
  scale_size(name = "total displays") +
  geom_point(aes(size = total_courtship),position = position_dodge(width=3)) +
  ylab("average displays per video") +
  # scale_color_manual(values=greens(5)[2:5]) +
  scale_colour_brewer(palette = "Dark2") +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  scale_x_date() 
ggsave("displays_over_time.pdf", path = "/Users/lukereding/Documents/common_garden/data/")

ggplot(df, aes(date, pairewise_distance_juvs, color = treatment)) + 
  geom_line(size=1.25, position = position_dodge(width=1)) +
  theme_luke() + 
  geom_point(size=3, position = position_dodge(width=1)) +
  ylab("average distance between juvs. per video") +
  # scale_color_manual(values=greens(5)[2:5]) +
  scale_colour_brewer(palette = "Dark2") +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  scale_x_date() 





#########################################
############### non-time plots: ###########
###############################################


df %>%
  ggplot(aes(treatment, total_courtship)) +
  geom_boxplot(aes(fill=treatment), outlier.shape=NA) +
  geom_jitter(width=0.3, height=0.15, aes(size = total_aggression)) +
  scale_fill_brewer(palette = "Dark2", guide= F) +
  scale_size(name = "total aggressions") + 
  ylab("# courtships per video") +
  ggtitle("number of courtship events per video") +
  theme_luke()
ggsave("number_total_displays.pdf", path = "/Users/lukereding/Documents/common_garden/data/")


######## for the grant ? #####


courts <- df %>%
  mutate(aggresion_towards_females = large_vs_female + small_vs_female + int_vs_female + female_vs_female) %>%
  ggplot(aes(treatment, total_courtship)) +
  geom_boxplot(aes(fill=treatment), outlier.shape=NA) +
  # geom_jitter(width=0.3, height=0.15, aes(size = aggresion_towards_females)) +
  geom_jitter(width=0.3, height=0) +
  scale_fill_brewer(palette = "Dark2", guide= F) +
  # scale_size(name = "chases towards\nfemales") + 
  ylab("# courtships per video") +
  ggtitle("number of courtship events per video") +
  theme_luke() +
  theme(legend.justification=c(1,0), legend.position=c(1,0.7))

towards_females <- df %>%
  mutate(aggression_towards_males = large_vs_large + large_vs_small + int_vs_int + female_vs_male) %>%
  mutate(aggresion_towards_females = large_vs_female + small_vs_female + int_vs_female + female_vs_female) %>% 
  ggplot(aes(treatment, aggresion_towards_females)) +
  geom_boxplot(aes(fill=treatment), outlier.shape=NA) +
  # geom_jitter(width=0.3, height=0.15, aes(size = total_courtship)) +
  geom_jitter(width=0.3, height=0) +
  scale_fill_brewer(palette = "Dark2", guide= F) +
  # scale_size(name = "average displays\nper video") + 
  ylab("# chases towards females") +
  theme_luke() +
  theme(legend.justification=c(0,1.1), legend.position=c(0.05,1))

(x <- plot_grid(courts, towards_females))
ggplot2::ggsave("for_grant.pdf", path = "/Users/lukereding/Documents/common_garden/data/", width = 11.3, height = 7.67)

############################



# overall aggression
#bar plot
df %>% group_by(treatment) %>% summarise(agg = mean(total_aggression)) %>% 
  ggplot(aes(treatment, agg)) +
  geom_bar(stat="identity", aes(fill = treatment)) +
  theme_luke() +
  ylab("average # aggressive events per video") +
  scale_fill_manual(values =viridis(5)[1:4], guide = FALSE)

# box plot
df %>%
  ggplot(aes(treatment, total_aggression)) +
  geom_boxplot(aes(fill=treatment), outlier.shape=NA) +
  geom_jitter(width=0.3, height=0.15, aes(size = total_courtship)) +
  scale_size(name = "number of\ndisplays") + 
  scale_fill_brewer(palette = "Dark2", guide= F) +
  ylab("# chases") +
  ggtitle("average number of chases per video") +
  theme_luke()

ggsave("no_aggressions.pdf", path = "/Users/lukereding/Documents/common_garden/data/")


# large - large aggression
# df %>% filter(treatment == "LL") %>% select(large_vs_large) %>% ggplot(aes(large_vs_large)) + geom_dotplot() + theme_luke()


# number of females / large males identified
# df %>% 
#   group_by(treatment) %>%
#   summarise(model_females_found = mean(number_model_female)) %>% 
#   ggplot(aes(treatment, model_females_found)) +
#   geom_bar(stat="identity", aes(fill = treatment)) +
#   theme_luke() +
#   ylab("average # adult females found per video") +
#   ggtitle("average # adult females found per video") +
#   scale_fill_manual(values =viridis(5)[1:4], guide = FALSE)

df %>%
  ggplot(aes(treatment, number_model_female)) +
  geom_boxplot(aes(fill=treatment), outlier.shape=NA) +
  geom_jitter(width=0.2, size=5, aes(color = number_focal)) +
  scale_colour_continuous(low="white", high="forestgreen", name ="number focal\nfish identified") +
  scale_fill_brewer(palette = "Dark2", guide= F) +
  ylab("# females") +
  ggtitle("number of adult females found per video") +
  theme_luke() +
  scale_size_continuous(range = c(1,6))

ggsave("adult_females_found.pdf", path = "/Users/lukereding/Documents/common_garden/data/")


# distance between focal fish:
# df %>%
#   group_by(treatment) %>%
#   summarise(focal_dist = mean(pairewise_distance_juvs, na.rm=T)) %>%
#   ggplot(aes(treatment, focal_dist)) +
#   geom_bar(stat="identity", aes(fill = treatment)) +
#   theme_luke() +
#   ylab("average # pixels") +
#   ggtitle("average distance between focal juveniles") +
#   scale_fill_manual(values =viridis(5)[1:4], guide = FALSE)

df %>%
  ggplot(aes(treatment, pairewise_distance_juvs)) +
  geom_boxplot(aes(fill=treatment), outlier.size = NA) +
  geom_jitter(width=0.2, size = 5, aes(color = total_aggression)) + 
  scale_fill_brewer(palette = "Dark2", guide= F) +
  scale_colour_continuous(low="grey80", high="forestgreen") +
  ylab("# pixels") +
  ggtitle("distance between focal juveniles") +
  theme_luke() + 
  scale_size_continuous(range = c(2,6))

ggsave("dist_bt_focal_juvs.pdf", path = "/Users/lukereding/Documents/common_garden/data/")


# average distance between large / intermediate males

df %>%
  group_by(treatment) %>% 
  ggplot(aes(treatment, pairwise_distance_large_males)) +
  geom_boxplot(aes(fill=treatment)) +
  geom_jitter(width=0.2, size=5, aes(color = total_aggression)) + 
  scale_fill_brewer(palette = "Dark2", guide= F) +
  scale_colour_continuous(low="grey80", high="forestgreen") +
  ylab("# pixels") +
  ggtitle("distance between large / intermediate males") +
  theme_luke()
ggsave("dist_bt_large_males.pdf", path = "/Users/lukereding/Documents/common_garden/data/")


# average distance between model females

df %>%
  ggplot(aes(treatment, pairwise_distance_females)) +
  geom_boxplot(aes(fill=treatment), outlier.shape = NA) +
  geom_jitter(width=0.2, size= 5, aes(color = total_aggression)) +
  scale_colour_continuous(low="grey80", high="forestgreen") +
  scale_fill_brewer(palette = "Dark2", guide= F) +
  ylab("# pixels") +
  ggtitle("distance between model females") +
  theme_luke()
ggsave("dist_bt_model_females.pdf", path = "/Users/lukereding/Documents/common_garden/data/")


df %>%
  ggplot(aes(treatment, number_focal)) +
  geom_boxplot(aes(fill=treatment), outlier.shape=NA) +
  geom_jitter(width=0.3, height=0.15, size = 5) +
  scale_fill_brewer(palette = "Dark2", guide= F) +
  ylab("# number focal fish") +
  ggtitle("number of focal individuals per video") +
  theme_luke()
ggsave("no_focal.pdf", path = "/Users/lukereding/Documents/common_garden/data/")

# to make into a single pdf:
# pdfunite `ls -tr *.pdf` out.pdf



