
# Data Preparation Quiz

## 1. Consecutive count

### Data

| id  | stock |
| --- | ----- |
| 1   | GOOGL |
| 2   | GOOGL |
| 3   | GOOGL |
| 4   | META  |
| 5   | GOOGL |
| 6   | TSLA  |
| 7   | TSLA  |
| 8   | TSLA  |
| 9   | TSLA  |

### Problem

Find all the stocks that appear at least three times consecutively.
The query result format is in the following example.

### Example

| stock | consecutivecount |
| ----- | ---------------- |
| GOOGL | 3                |
| TSLA  | 4                |

Explanation: GOOGL appears consecutively for three times, TSLA for four times, where META less than three so no appearance.

## 2. Slowly Changing Dimension

### Data

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

### Problem

Given a dataset capturing stock price of google and tesla every hour.
Can you build a slowly changing dimension table, so it records time range for each stock when price has changed,
while the total number of records can be reduced?

### Example

| stock | price     | starttime                | endtime                  |
|-------|-----------|--------------------------|--------------------------|
| GOOGL | $500.00   | 2022-10-07T10:00:00.000Z | 2022-10-07T12:59:59.999Z |
| GOOGL | $800.00   | 2022-10-07T13:00:00.000Z | 2022-10-07T14:59:59.999Z |
| GOOGL | $500.00   | 2022-10-07T15:00:00.000Z | 2999-12-31T23:59:59.999Z |
| TSLA  | $500.00   | 2022-10-07T10:00:00.000Z | 2022-10-07T10:59:59.999Z |
| TSLA  | $800.00   | 2022-10-07T11:00:00.000Z | 2022-10-07T14:59:59.999Z |
| TSLA  | $1,200.00 | 2022-10-07T15:00:00.000Z | 2999-12-31T23:59:59.999Z |

## 3. Sort subset for re-granular

### Data

Please take the last result example from above as the data.

| stock | price     | starttime                | endtime                  |
| ----- | --------- | ------------------------ | ------------------------ |
| GOOGL | $500.00   | 2022-10-07T10:00:00.000Z | 2022-10-07T12:59:59.999Z |
| GOOGL | $800.00   | 2022-10-07T13:00:00.000Z | 2022-10-07T14:59:59.999Z |
| GOOGL | $500.00   | 2022-10-07T15:00:00.000Z | **2022-10-07T15:59:59.999Z** |
| TSLA  | $500.00   | 2022-10-07T10:00:00.000Z | 2022-10-07T10:59:59.999Z |
| TSLA  | $800.00   | 2022-10-07T11:00:00.000Z | 2022-10-07T14:59:59.999Z |
| TSLA  | $1,200.00 | 2022-10-07T15:00:00.000Z | **2022-10-07T15:59:59.999Z** |


### Problem

For each stock, can you find the price that has longest / shortest holding time?
Note you might need to adjust back the last ending time above in each stock to 2022-10-07 15:59:59 first,
so it reflect the actual time length of the price.

### Example

| stock | firstprice | lastprice | shortestholdprice | longestholdprice |
| ----- | ---------- | --------- | ----------------- | ---------------- |
| GOOGL | $500.00    | $500.00   | $500.00           | $500.00          |
| TSLA  | $500.00    | $1,200.00 | $500.00           | $800.00          |

