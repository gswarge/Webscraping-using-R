
library(rvest)
library(data.table)
library(stringr)

#extract  data from the website

url <- "https://www.vancouvertrails.com/trails/?details=&sort=#list"


trails_webpage <- read_html(url)

#Scraping Trail Names using css class 'trailname'
trail_names_html <-html_nodes(trails_webpage, '.trailname')
trail_names <- html_text(trail_names_html)

head(trail_names_html)
head(trail_names)
str(trail_names)

#Trail Region
trail_region_html <-html_nodes(trails_webpage, '.i-name')
trail_region <- html_text(trail_region_html)
head(trail_region)

#Trail Difficulty
trail_diff_html <-html_nodes(trails_webpage, '.i-difficulty')
trail_diff <- html_text(trail_diff_html)
head(trail_diff)

#Trail-Time
trail_time_html <-html_nodes(trails_webpage, '.i-time')
trail_time <- html_text(trail_time_html)
head(trail_time)
#"1.5 hours" "1.5 hours" "5 hours"   "2 hours"  
#Extracted data is in the form of character, we need to extract digits and convert it into numeric format

trail_time <- as.numeric(str_extract(trail_time,pattern = "\\-*\\d+\\.*\\d*"))
head(trail_time,25)

#Trail Distance
trail_dist_html <-html_nodes(trails_webpage, '.i-distance')
trail_dist <- html_text(trail_dist_html)
head(trail_dist)
trail_dist <- as.numeric(str_extract(trail_dist,pattern = "\\-*\\d+\\.*\\d*"))
head(trail_dist,25)

#Trail Season
trail_season_html <-html_nodes(trails_webpage, '.i-schedule')
trail_season <- html_text(trail_season_html)
head(trail_season)


#Combining all the extracted features of the trails

trails_df <- data.frame(
  Name =trail_names,
  Region = trail_region,
  Difficulty=trail_diff,
  Distance=trail_dist,
  HikeTime = trail_time,
  Season = trail_season
  )
str(trails_df)
library(readr)
write_csv(trails_df, "vancouver_trails.csv")


#Analysing Scaraped Data from the website

library(ggplot2)
library(dplyr)

qplot(data = trails_df,HikeTime,fill = Difficulty)

#HikeTime Vs Region with Difficulty
ggplot(trails_df,aes(x=HikeTime,y=Region))+
  geom_point(aes(size=HikeTime,col=Difficulty))

#Distance Vs Region with Difficulty
ggplot(trails_df,aes(x=Distance,y=Region))+
  geom_point(aes(size=HikeTime,col=Difficulty))


#Seasons Vs Region with Difficulty
ggplot(trails_df,aes(x=Season,y=Region))+
  theme(axis.text.x=element_text(angle=60, hjust=1),axis.title.x = element_blank())+
  geom_point(aes(size=HikeTime,col=Difficulty))

#Plotting Trail Distance vs Difficulty
 trails_df %>%
  ggplot(aes(x=Difficulty,y=Distance,fill=Difficulty,label = HikeTime)) +
  geom_bar(stat="identity")+
  geom_text(size = 3, position = position_stack(vjust = 0.5))+
 theme(axis.text.x=element_text(angle=60, hjust=1),axis.title.x = element_blank(),panel.grid.major = element_line(colour = "grey"), legend.position = "none" )+
  scale_y_continuous(breaks=seq(0, 600, 30))+
  labs(title="Trail Distance vs Difficulty", y= "Distance")
 
 #HIke Time vs Difficulty
 trails_df %>%
   ggplot(aes(x=HikeTime,y=Difficulty,label = Season)) +
   #geom_bar(stat="identity")+
   geom_tile(aes(fill=Distance),colour = "blue") + 
   #geom_text(size = 3, position = position_stack(vjust = 0.5))+
   scale_fill_gradient(low = "green",high = "red")+
   theme(axis.text.x=element_text(angle=60, hjust=1),axis.title.x = element_blank(),panel.grid.major = element_line(colour = "grey"), legend.position = "none" )+
   scale_x_continuous(breaks=seq(0, 30, 1))+
   labs(title="Trail Hike Time vs Difficulty", y= "Distance")+
   NULL
 
 #Trail Regions vs Difficulty
 trails_df %>%
   ggplot(aes(x=Region,y=HikeTime,fill=Difficulty,label = Season)) +
   geom_bar(stat="identity")+
   #geom_tile(aes(fill=Distance),colour = "blue") + 
   #geom_text(size = 3, position = position_stack(vjust = 0.5))+
   scale_fill_gradient(low = "green",high = "red")+
   theme(axis.text.x=element_text(angle=60, hjust=1),axis.title.x = element_blank(),panel.grid.major = element_line(colour = "grey"), legend.position = "none" )+
   #scale_x_continuous(breaks=seq(0, 30, 1))+
   labs(title="Trail Hike Time vs Difficulty", y= "Distance")+
   NULL



