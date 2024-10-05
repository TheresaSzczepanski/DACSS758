# Week 4 Quiz material: Fill in the blanks and answer quiz questions
# scraping + RegEx + NLP


library(rvest)
library(tidyverse)
library(stringr)
library(stringi)
library(cleanNLP)
library(polite)
library(robotstxt)

paths_allowed("https://www.law.northwestern.edu/faculty/fulltime/") # checking whether scrapable

url <- "https://www.law.northwestern.edu/faculty/fulltime/"
nu.fac.base <- read_html(url)

## Scraping: NAME + TITLE
nu.fac.name <- nu.fac.base %>%
  html_nodes("#faculty")%>%
  html_nodes("p")%>%
  html_text2() # better than html_text()

# check: OUTPUT SHOULD SHOW A CHARACTER CONTAINING ALL PROFESSORS' NAMES
# AND TITLES
#nu.fac.name
head(nu.fac.name)



# Let's use stringr() to remove/replace strings we don't want to keep
nu.fac <- str_replace_all(nu.fac.name, "\r", "")
nu.fac<-trimws(nu.fac)
nu.fac <- unlist(nu.fac)
class(nu.fac) # character vector!



# one more step to separate name from position 
# and remove the space before names
nu.fac.t <- str_split(nu.fac, ",",2)

nu.fac.t
#nu.fac


# converting list into dataframe nu.fac.t

nu.fac.t.dataframe <- as_tibble(matrix(unlist(nu.fac.t), nrow=length(nu.fac.t), byrow=TRUE)) %>%
  rename(c.fullname = V1)%>%
  rename(position = V2)

View(nu.fac.t.dataframe) # check


# Let's add a column containing individualized profile webpage
nu.fac.url <-  nu.fac.base %>%
  html_nodes("#faculty")%>%
  html_nodes("a") %>%
  html_attr("href")
  
head(nu.fac.url) # check how it looks like

# it contains "unwanted info." Let's keep what we want only!
nu.fac.url <- tibble(indurl = nu.fac.url) %>%
  filter(str_detect(indurl, "/faculty/profiles/"))

# combining url column to the existing name tibble
# Do you notice anything?
#[Make sure the line below works]
nu.fac.t <- bind_cols(nu.fac.t.dataframe, nu.fac.url) 

view(nu.fac.t)

# nu.fac.t: rows are arranged by alphabetially using last name
# rearrange this by first name
nu.fac.t.arr <- nu.fac.t %>%
  arrange(c.fullname) 

# checking
head(nu.fac.t.arr)


#==============================================================
# HANDLING NAMES! 
# creating four different columns respectively for
# first & middle & last names and suffix

# Create an empty data frame to store the results
name_df <- data.frame(First_Name = character(0), 
                      Middle_Name = character(0), 
                      Last_Name = character(0), 
                      Suffix = character(0), 
                      stringsAsFactors = FALSE)


# Split the names and populate the data frame

for (name in nu.fac.t.arr$c.fullname) {
  parts <- str_split(trimws(name), "\\s+")
  if (length(parts[[1]]) == 1) {
    name_df <- rbind(name_df, data.frame(First_Name = parts[[1]], 
                                         Middle_Name = "", Last_Name = "", Suffix = ""))
  } else if (length(parts[[1]]) == 2) {
    name_df <- rbind(name_df, data.frame(First_Name = parts[[1]][1],
                                         Middle_Name = "", Last_Name = parts[[1]][2], Suffix = ""))
  } else if (length(parts[[1]]) == 3) {
    name_df <- rbind(name_df, data.frame(First_Name = parts[[1]][1], 
                                         Middle_Name = parts[[1]][2], Last_Name = parts[[1]][3], Suffix = ""))
  } else if (length(parts[[1]]) == 4) {
    name_df <- rbind(name_df, data.frame(First_Name = parts[[1]][1], 
                                         Middle_Name = parts[[1]][2], Last_Name = parts[[1]][3], Suffix = parts[[1]][4]))
  }
}

View(name_df)


# do some more work using stringr (removing punctuation)
# and stringi (handling accented alphabets)
nu.names.tb <- as_tibble(name_df) # tibbling.
nu.names.tb <- nu.names.tb %>% modify_at(c("First_Name", "Middle_Name", "Last_Name", "Suffix"),
                                         str_to_lower) %>%
  mutate(First_Name = str_remove_all(First_Name, "[:punct:]")) %>%
  mutate(First_Name = stri_trans_general(First_Name, id = "Latin-ASCII")) %>%
  mutate(Last_Name = str_remove_all(Last_Name, "[:punct:]")) %>%
  mutate(Last_Name = stri_trans_general(Last_Name, id = "Latin-ASCII")) %>%
  mutate(Middle_Name = str_remove_all(Middle_Name, "[:punct:]")) %>%
  mutate(Middle_Name = stri_trans_general(Middle_Name, id = "Latin-ASCII"))
View(nu.names.tb)




# combining this columns with nu.fac.t.arr
nu.fac.t.arr <- bind_cols(nu.fac.t.arr, nu.names.tb)

View(nu.fac.t.arr)

