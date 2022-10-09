
# Data Preparation Solution - R

## R Dataframe

```r

stock <- c('GOOGL','TSLA')
datetime <- c('2022-10-07 10:00:00','2022-10-07 11:00:00','2022-10-07 12:00:00','2022-10-07 13:00:00','2022-10-07 14:00:00','2022-10-07 15:00:00')
price <- c(500,500,500,800,500,800,800,800,800,800,500,1200)

stockprice <-
  cbind.data.frame(stock, datetime=rep(ymd_hms(datetime), each = length(stock)), price)

summary(stockprice)

```

## R Answer 1

```r

library(tidyverse)

stockprice_scd <- 
  stockprice %>%
  group_by(stock) %>% # Set partition for lag / lead in the next
  mutate(previous_price = lag(price, n = 1, order_by = datetime)) %>% # Find lag price
  filter(previous_price != price | is.na(previous_price)) %>% # Where Clause
  mutate(starttime = datetime,
         endtime = replace_na(lead(datetime, n = 1, order_by = datetime), ymd('3000-01-01')) - hms('00:00:00.001')) %>% # Find lead time
  select(stock, price, starttime, endtime) %>% # Reduce selected columns
  arrange(stock, starttime) # Re-order

stockprice_scd

```


## R Answer 2

```r

stockprice_scd <- 
  stockprice %>%
  group_by(stock) %>% # Set partition for lag / lead in the next
  mutate(previous_price = lag(price, n = 1, order_by = datetime)) %>% # Find lag price
  filter(previous_price != price | is.na(previous_price)) %>% # Where Clause
  mutate(starttime = datetime,
         endtime = replace_na(lead(datetime, n = 1, order_by = datetime), ymd_hms('2022-10-07 16:00:00')) - hms('00:00:00.001')) %>% # Find lead time
  select(stock, price, starttime, endtime) %>% # Reduce selected columns
  arrange(stock, starttime) # Re-order

stockprice_scd %>%
  mutate(holdtime = endtime - starttime) %>% # Time difference
  mutate(longestholdtime = max(holdtime), shortestholdtime = min(holdtime)) %>% # Find longest and shortest time
  summarise(firstprice = first(price),
            lastprice = last(price),
            shortestholdtime = first(na.omit(ifelse(holdtime == shortestholdtime, price, NA))), # Find first appearance only
            longestholdprice = first(na.omit(ifelse(holdtime == longestholdtime, price, NA))))

```
