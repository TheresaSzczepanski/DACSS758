# scrapingInR-moduleTwo.r
# This file demonstrates the use of RSelenium 
#
# dr 2.11.2021
# es checked 2.8.2022
# rp checked (and failed) 9.16.2023
# rp checked 9.15.2024
# ------------------------------------------

# RSelenium provides more advanced functionality for scraping
# websites that have more complicated structures
# than the sort of static structure that rvest works well for.

# =-=-=-=-=-=-=-=-=
# Front end matters
# =-=-=-=-=-=-=-=-=

library(rvest)
library(tidyverse)
library(RSelenium)
library(wdman) #to download drivers
library(netstat) # to generate port

# =-=-=-=-=-=-=-=-=
# Opening a Browser
# =-=-=-=-=-=-=-=-=

#downloading drivers
selenium()
# to see where the downloaded drivers are stored
selenium_object <- selenium(retcommand =T, check = F)
selenium_object
# If you use Chrome, make sure to go to the folder where the drivers are stored
# Delete Chromedriver license

binman::list_versions("chromedriver")
# chromedriver is for version 114. 
# If your Chrome is in a newer version, make sure to download Chrome 114
# Using firefox is actually easier

# Initiate our browser. This will open a Firefox browser on your machine
#rD <- rsDriver(browser="firefox", 
#               port = free_port(), chromever = NULL, iedrver = NULL)

rD <- rsDriver(port = free_port())


#rD <- rsDriver(browser="chrome", port=4555L, verbose=F, chromever = "129.0.6668.59")
#mydriver <- rsDriver(browser=c("phantomjs"),port=4444L)
 
# rD <- rsDriver(browser="firefox", 
#                netstat::free_port(), verbose=F)
remDr <- rD[["client"]]
# server: The Selenium server instance.
# client: The remote driver (i.e., the browser automation interface).
# Getting the client object, which is the browser controller that lets you interact with the web browser


# =-=-=-=-=-=-=-=-=
# Getting to the site
# =-=-=-=-=-=-=-=-=

# We are able to navigate the web browser from inside R now. 
# We are going to go straight to the search results page.
# Note, however, that you can also enter search queries directly from R with RSelenium. 
# For more on that, see this helpful tutorial: http://joshuamccrain.com/tutorials/web_scraping_R_selenium.html

remDr$navigate("https://www.courtlistener.com/?type=o&q=citizenship&type=o&order_by=dateFiled%20desc&stat_Precedential=on&court=scotus")

# =-=-=-=-=-=-=-=-=
# Navigating the site
# =-=-=-=-=-=-=-=-=

# While we can navigate, let's just do a single page for now.
# To demonstrate, we'll click on the first link (i.e., "[[1]]")
# Note that we are finding the button to click by using the CSS selector
# in precisely the ways we do in our previous tutorial.
remDr$findElements("css", ".visitable")[[1]]$clickElement()

# =-=-=-=-=-=-=-=-=
# Scrape
# =-=-=-=-=-=-=-=-=

# First, we'll slow things down so the page can load
Sys.sleep(5) 

# Now we'll get the full HTML
# getPageSource() fetches the HTML content (i.e., the page source) of the current web page that the browser is displaying
html <- remDr$getPageSource()[[1]]
                         
# From that HTML, we'll parse it down to the opinion that we are interested in pulling.                                               
opinion <- read_html(html) %>% 
  html_nodes(".plaintext") %>% 
  html_text()

# And here's what that opinion looks like.
writeLines(opinion)

# =-=-=-=-=-=-=-=-=
# Looping
# =-=-=-=-=-=-=-=-=

# So that's interesting but we probably want more than just one opinion.
# Here, we can set up to iterate through all of the opinions on the page,

# create an empty vector to store opinions
opinions <- c()

# go back to the first page
remDr$navigate("https://www.courtlistener.com/?type=o&q=citizenship&type=o&order_by=dateFiled%20desc&stat_Precedential=on&court=scotus")

# each page of results has 20 opinions, so we'll loop from 1 to 20
for (i in 1:20){
  # click on the ith link
  print(i)
  remDr$findElements("css", ".visitable")[[i]]$clickElement()

  # get the full HTML
  html <- remDr$getPageSource()[[1]]
    
  # parse it down to the opinion.                                               
  opinion <- read_html(html) %>% 
    html_nodes(".plaintext") %>% 
    html_text()
    
  # add that opinion to the opinions object
  opinions <- c(opinions, opinion)
    
  # go *back* a page so we can click on the next ith link
  remDr$goBack()
}

opinions[15]
  
# Now we've made it through 20 so click on the next tab of results
# We probably want even more though, so we could iterate this through 
# each of the pages of the results. 

# The other thing you are probably noticing is that these are *big* opinions
# and thus memory intensive. We may want to start thinking about more
# efficient ways to store all of the opinions. For now, though, we have
# another option for acquiring texts that we want!
