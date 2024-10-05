# scrapingInR-moduleThree.r
# This file demonstrates the use of RedditExtractoR 
#
# rp 9.17.2024
# ------------------------------------------


#install.packages("RedditExtractoR")
library(RedditExtractoR)

### Search for subreddits and their attributes based on a keyword
cats <- find_subreddits("cats")
View(cats)
# Return a dataframe with comments and host of metadata for the comments.


### Search all of reddit (or specific subreddits) for URLs that match a specific search.
kitten <- find_thread_urls(keywords="cute kittens", 
                            subreddit="cats", 
                            sort_by="new", 
                            period="month")
View(kitten)
## sort_by options:
# "relevance": Sorts by relevance to the search term.
# "hot": Sorts by how popular the thread is (upvoted, heavily commented, etc.).
# "top": Sorts by the highest-voted threads.
# "new": Sorts by the newest threads.
# "comments": Sorts by threads with the most comments.
# "controversial": Sorts by threads with mixed votes (both upvotes and downvotes).
## period options:
# "hour": Returns threads from the last hour.
# "day": Returns threads from the last day.
# "week": Returns threads from the last week.
# "month": Returns threads from the last month.
# "year": Returns threads from the last year.
# "all": Returns threads from all time.


### Search a specific reddit (or subreddit) URL.
# first choose an url (I choose the first one from kitten)
url <- "https://www.reddit.com/r/cats/comments/1fiumir/our_cat_live_mostly_outdoors_so_we_decided_to_not/"
# Get content from the thread
thread_content <- get_thread_content(url)  
thread_content

# More than one URL?
kitten_content <- lapply(kitten$url, get_thread_content)  
View(kitten_content)
View(kitten_content[[5]]$comments)
View(kitten_content[[5]]$threads)


### Search all posts from a user
user <- "nationalgeographic"
user_post <- get_user_content(user) 
View(user_post$nationalgeographic$threads)

