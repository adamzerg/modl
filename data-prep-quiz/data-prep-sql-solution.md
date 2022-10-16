
# Data Preparation Solution - SQL

## SQL Schema 1

Table: Logs

```postgresql

create table Logs (id int, stock varchar(50));

insert into Logs (id, stock) values
('1', 'GOOGL'),
('2', 'GOOGL'),
('3', 'GOOGL'),
('4', 'META'),
('5', 'GOOGL'),
('6', 'TSLA'),
('7', 'TSLA'),
('8', 'TSLA'),
('9', 'TSLA');

```

## SQL Answer 1

```postgresql

with recursive RLE(id, stock, numCount) as (
    select id, stock, 1 numCount
    from Logs anchor
    where id = 1
    union all
    select member.id, member.stock, case when member.stock = RLE.stock then numCount + 1 else 1 end numCount
    from Logs member
    join RLE
    on member.id = RLE.id + 1
)
select stock, max(numcount) consecutivecount
from RLE
where numCount >= 3
group by stock
order by 1;

```

## SQL Schema 2

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

## SQL Answer 2

```postgresql

select *,
-- Use LAG function to get the previous record's attribute (stock price in this case)
lag(price) over (partition by stock order by stock, datetime) as prevprice
into StockPriceSCD_10
from StockPrice;

select * from StockPriceSCD_10;

select
	stock,
    price,
    datetime as starttime,
    -- Use the LEAD Function to get the next record's datetime as EndTime.
    lead(datetime,1,'3000-01-01') over (partition by stock order by stock, datetime) - time '00:00:00.001' as endtime
into StockPriceSCD
from StockPriceSCD_10
where prevprice <> price or prevprice is null;
	-- Keep only the necessary records (records which has changes, or first record of each stock)

select * from StockPriceSCD;

```

## SQL Answer 3

```postgresql

select
	stock,
    price,
    datetime as starttime,
    lead(datetime,1,'2022-10-07 16:00') over (partition by stock order by stock, datetime) - time '00:00:00.001' as endtime
    -- Adjust back last ending time
into StockPriceSCD
from StockPriceSCD_10
where prevprice <> price or prevprice is null;

select
	distinct stock,
    first_value(price) over (partition by stock order by starttime) as FirstPrice,
    first_value(price) over (partition by stock order by starttime desc) as LastPrice,
    first_value(price) over (partition by stock order by endtime - starttime) as ShortestHoldPrice,
    first_value(price) over (partition by stock order by endtime - starttime desc) as LongestHoldPrice
from StockPriceSCD
order by stock;

```
