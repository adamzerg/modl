
# Data Preparation Quiz

## 1. Slowly Changing Dimension

### Data
---

| datetime                 | stock | price     |
| ------------------------ | ----- | --------- |
| 2022-10-07T10:00:00.000Z | GOOGL | $500.00   |
| 2022-10-07T10:00:00.000Z | TSLA  | $500.00   |
| 2022-10-07T11:00:00.000Z | GOOGL | $500.00   |
| 2022-10-07T11:00:00.000Z | TSLA  | $800.00   |
| 2022-10-07T12:00:00.000Z | GOOGL | $500.00   |
| 2022-10-07T12:00:00.000Z | TSLA  | $800.00   |
| 2022-10-07T13:00:00.000Z | GOOGL | $800.00   |
| 2022-10-07T13:00:00.000Z | TSLA  | $800.00   |
| 2022-10-07T14:00:00.000Z | GOOGL | $800.00   |
| 2022-10-07T14:00:00.000Z | TSLA  | $800.00   |
| 2022-10-07T15:00:00.000Z | GOOGL | $500.00   |
| 2022-10-07T15:00:00.000Z | TSLA  | $1,200.00 |

---

### Problem

Given a dataset capturing stock price of google and tesla every hour.
Can you build a slowly changing dimension table, so it records time range for each stock when price has changed,
while the total number of records can be reduced?

### Example

---

| stock | price     | starttime                | endtime                  |
|-------|-----------|--------------------------|--------------------------|
| GOOGL | $500.00   | 2022-10-07T10:00:00.000Z | 2022-10-07T12:59:59.999Z |
| GOOGL | $800.00   | 2022-10-07T13:00:00.000Z | 2022-10-07T14:59:59.999Z |
| GOOGL | $500.00   | 2022-10-07T15:00:00.000Z | 2999-12-31T23:59:59.999Z |
| TSLA  | $500.00   | 2022-10-07T10:00:00.000Z | 2022-10-07T10:59:59.999Z |
| TSLA  | $800.00   | 2022-10-07T11:00:00.000Z | 2022-10-07T14:59:59.999Z |
| TSLA  | $1,200.00 | 2022-10-07T15:00:00.000Z | 2999-12-31T23:59:59.999Z |

---

### SQL Schema
Table: StockPrice

```postgresql

create table StockPrice (
  datetime timestamp,
  stock varchar,
  price money
);

insert into StockPrice values
('2022-10-07 10:00','GOOGL',500),
('2022-10-07 10:00','TSLA',500),
('2022-10-07 11:00','GOOGL',500),
('2022-10-07 11:00','TSLA',800),
('2022-10-07 12:00','GOOGL',500),
('2022-10-07 12:00','TSLA',800),
('2022-10-07 13:00','GOOGL',800),
('2022-10-07 13:00','TSLA',800),
('2022-10-07 14:00','GOOGL',800),
('2022-10-07 14:00','TSLA',800),
('2022-10-07 15:00','GOOGL',500),
('2022-10-07 15:00','TSLA',1200);

```

### SQL Attempt

```postgresql

select *,
--Use LAG function to get the previous record's attribute (stock price in this case)
lag(price) over (partition by stock order by stock, datetime) as prevprice
into StockPriceSCD_10
from StockPrice;

select * from StockPriceSCD_10;

select
	stock,
    price,
    datetime as starttime,
    --Use the LEAD Function to get the next record's datetime as EndTime.
    lead(datetime,1,'3000-01-01') over (partition by stock order by stock, datetime) - time '00:00:00.001' as endtime
into StockPriceSCD
from StockPriceSCD_10
where prevprice <> price or prevprice is null;
	-- Keep only the necessary records (records which has changes, or first record of each stock)

select * from StockPriceSCD;

```

### R Dataframe

```r

stock <- c('GOOGL','TSLA')
datetime <- c('2022-10-07 10:00:00','2022-10-07 11:00:00','2022-10-07 12:00:00','2022-10-07 13:00:00','2022-10-07 14:00:00','2022-10-07 15:00:00')
price <- c(500,500,500,800,500,800,800,800,800,800,500,1200)

stockprice <-
  cbind.data.frame(stock, datetime=rep(ymd_hms(datetime), each = length(stock)), price)

summary(stockprice)

```

### R Attempt

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