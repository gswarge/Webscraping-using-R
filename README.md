# Webscraping using R
This is part of my series of documenting my small experiments using R and solving #DataScience problems
Lot of my experiements might be redundant and may have been already written and blogged about by someone, but this is more of a personal diary and in this process, if anyone gets inspired or learns something new then thats the best thing that could happen.
If a more knowledgeable person than me stumbles upon what i have done and thinks there is a much better way to do things, please feel free to share the feedback and i will update the feedback as post script.

Precursor: I recently moved to Vancouver, Canada, and i wanted to go on, as many hikes as possible before the Summer gives way to Fall and then to Winter.I Googled about the trails around Vancouver and found a neat website www.vancouvertrails.com. Then i thought maybe why not make a google sheet and track the trails, as i finish them and note down my experience about it. I could have just copy pasted the trails data into a google sheet and would have moved on, but then it woould not have been fun, So i thought, why not write an R code to scrape the website data and export it as a csv, which i will then upload on my google sheet. (yes i like to make things as much fun as possible)
Goal: To scrape website data and export it as a csv file and while I’m at it, use ggplot to do some data analysis for fun. (simple enough)
Libraries: I started looking in the documentation of R libraries to find out which libraries to use and which functions to use after some 15 mins of googling, found library “rvest” which i liked.
Step 1: Reading the URL
There is a function “read_html”, we will use that to read the html on the given webpage.
url <- “https://www.vancouvertrails.com/trails/?details=&sort=#list"
trails_webpage <- read_html(url)
If you have visited above URL, you see it has the list of all the trails (167 to be precise) in and around Vancouver
Step 2: Scraping the Data which is required
Now, the best part of the rvest library is that you can extract the data from html nodes, what that means is you can straightaway select the nodes with their id’s or css classes and extract the text from the html tags. So i went to my url and fired up the “firebug” on the browser and soon figuered that the names of the hikes have been encapsulated in the “.trailname” css class, using this css class i can extract all the trail names on the webpage.
There are 2 functions that we will use here:
html_nodes : Use this function to extract the nodes that we like (in this case nodes with “.trailname” as css class
html_text: Use this function to extract the text in between the html nodes (in this case our trail names)
#Scraping Trail Names using css class ‘trailname’
trail_names_html <-html_nodes(trails_webpage, ‘.trailname’)
trail_names <- html_text(trail_names_html)
head(trail_names)
Output:
[1] “Abby Grind” “Admiralty Point” 
[3] “Al’s Habrich Ridge Trail” “Aldergrove Regional Park”
[5] “Alice Lake” “Ancient Cedars Trail”
Similarly, now i will do this for all other attributes for each trail: Region, Difficulty, Time, Distance, Season. Each of these attributes have their own css classes:i-name, i-time,i-difficulty,i-distance,i-schedule
#Trail Region
trail_region_html <-html_nodes(trails_webpage, '.i-name')
trail_region <- html_text(trail_region_html)
head(trail_region)
Output:
[1] "Fraser Valley East" "Tri Cities"         "Howe Sound"        
[4] "Surrey and Langley" "Howe Sound"         "Whistler"
#Trail Difficulty
trail_diff_html <-html_nodes(trails_webpage, '.i-difficulty')
trail_diff <- html_text(trail_diff_html)
head(trail_diff)
Output:
[1] "Intermediate" "Easy"   "Intermediate" "Easy"         "Easy"        
[6] "Intermediate"
#Trail Season
trail_season_html <-html_nodes(trails_webpage, '.i-schedule')
trail_season <- html_text(trail_season_html)
head(trail_season)
Output:
[1] "year-round"  "year-round"   "July - October"   "year-round"      
[5] "April - November" "June - October"  
>
One thing to note, when we extract time, it is in the form of an character: Eg:1.5 Hours, 3 Hours. We want it in numeric form, To convert it into a numeric form, used a library : Stringr and the function:`str_extract`
Logic is that i used the regular expression to match the pattern and extracted the same from the html text. For regular expression help, you can refer to the cheatsheet of `stringr` here.
So this is what i did to convert it to numeric form:
#Extracting Trail Times:
trail_time_html <-html_nodes(trails_webpage, '.i-time')
trail_time <- html_text(trail_time_html)
head(trail_time)
#"1.5 hours" "1.5 hours" "5 hours"   "2 hours"  
#Extracted data is in the form of character, we need to extract digits and convert it into numeric format
trail_time <- as.numeric(str_extract(trail_time,pattern = "\\-*\\d+\\.*\\d*"))
head(trail_time,25)
Output:
[1]  1.50  1.50  5.00  2.00  2.00  2.00  3.50  5.00
[9]  5.00  1.50  1.00  5.00 11.00  3.00  1.00  2.00
[17]  1.50  1.00  0.50  3.50  0.25  5.00  4.00  2.00
[25]  3.50
Similarly did the same thing for Trail Distance as the information is in character form Eg: 4km:
#Trail Distance
trail_dist_html <-html_nodes(trails_webpage, '.i-distance')
trail_dist <- html_text(trail_dist_html)
head(trail_dist)
trail_dist <- as.numeric(str_extract(trail_dist,pattern = "\\-*\\d+\\.*\\d*"))
head(trail_dist,25)
Output:
[1]  4.0  5.0  7.0  5.0  6.0  5.0  6.1 12.0 10.0  3.0  2.6 10.0 29.0  8.0  2.5
[16]  5.0  4.0  4.2  1.0  6.0  0.8  7.5  7.0  8.0 10.0
Step 3: Now that we have all our information lets collate it into a dataframe and export it to .csv file. To be able to do this, we use a function write_csv from library readr
library(readr)
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

write_csv(trails_df, "vancouver_trails.csv")
Step 4: Analysis of Data
For this part, using a library ggplot2 to visualise the data

Regions vs Hike Time & Difficulty Level

Regions Vs Distance & Difficulty Level

Region Vs Seasons with Difficulty & Hike Time
