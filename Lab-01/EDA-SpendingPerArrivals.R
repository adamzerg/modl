

## https://data.gov.mo/Detail?id=3546225a-2a34-4645-b01e-6752aed03993
## https://data.gov.mo/Detail?id=6466a42d-cd30-40a3-9017-3e0066e6b077

# Load package

install.packages("tidyverse")
install.packages("ggvis")
library(tidyverse)
library(readxl)
library(dplyr)
library(lubridate)
library(ggvis)

# Load package alter way

install.packages("pacman")
pacman::p_load(pacman, dplyr, GGally, ggplot2, ggthemes, ggvis, httr, lubridate, plotly, rio, rmarkdown, shiny, stringr, tidyr, gridExtra)

# Ingest 1st data set

if (!file.exists("visitorArrivals.xlsx")) {
  download.file('https://api.data.gov.mo/datadir/downloadSingleFile?fileId=838&dataDirId=3546225a-2a34-4645-b01e-6752aed03993&token=5L75uK9FSkGq59OvGhT62fBYiu5puhQPv', 'visitorArrivals.xlsx', method='curl' )
}
visitorArrivals <- read_excel("visitorArrivals.xlsx", col_name = TRUE)

head(visitorArrivals)
summary(visitorArrivals)
nchar(visitorArrivals$period)

df1 <- visitorArrivals %>%
  filter(nchar(period) > 5) %>%
  mutate(YearMonth = gsub("\\月","", gsub("\\年","-", period))) %>%
  mutate(PeriodDate = as_date(paste0(.$YearMonth, "-1"), format = "%Y-%m-%d")) %>%
  mutate(PeriodYear = year(PeriodDate)) %>%
  mutate(PeriodQuarter = quarter(PeriodDate)) %>%
  mutate(YearQuarter = PeriodYear + PeriodQuarter*.1) %>%
  mutate(YearQuarterCont = PeriodYear + PeriodQuarter*.25)
  
par(mfrow=c(3,1)) # all plots on one page
par(pch=22, col="red") # plotting symbol and color
plot(df1$PeriodDate,df1$value, type="l")
par(pch=22, col="blue") # plotting symbol and color
plot(df1$PeriodDate,df1$value, type="s")
par(pch=22, col="green") # plotting symbol and color
plot(df1$PeriodDate,df1$value, type="b")

par(mfrow=c(2,1)) # all plots on one page
par(pch=22, col="red") # plotting symbol and color
plot(df1$PeriodDate,df1$value, type="l")
par(pch=22, col="blue") # plotting symbol and color
boxplot(df1$value~df1$PeriodYear)


# Ingest 2nd dataset

if (!file.exists("totalSpendingOfVisitors.xlsx")) {
  download.file('https://api.data.gov.mo/datadir/downloadSingleFile?fileId=842&dataDirId=6466a42d-cd30-40a3-9017-3e0066e6b077&token=5L75uK9FSkGq59OvGhT62fBYiu5puhQPv', 'totalSpendingOfVisitors.xlsx', method='curl' )
}
totalSpendingOfVisitors <- read_excel("totalSpendingOfVisitors.xlsx", col_name = TRUE)

head(totalSpendingOfVisitors)

df2 <- totalSpendingOfVisitors %>%
  mutate(SpendingInThousandMOP = as.numeric(value)*1000) %>%
  filter(nchar(period) > 5) %>%
  mutate(PeriodYear = as.numeric(substr(period,1,4))) %>%
  mutate(PeriodQuarter = as.integer(case_when(
          grepl("\\年第一季", period) ~ 1,      
          grepl("\\年第二季", period) ~ 2,
          grepl("\\年第三季", period) ~ 3,
          grepl("\\年第四季", period) ~ 4
          ))) %>%
  mutate(YearQuarter = PeriodYear + PeriodQuarter*.1) %>%
  mutate(YearQuarterCont = PeriodYear + PeriodQuarter*.25)


par(mfrow=c(2,1)) # all plots on one page
par(pch=22, col="steelblue") # plotting symbol and color
plot(df2$YearQuarter,df2$SpendingInThousandMOP, type="s")
par(pch=22, col="green") # plotting symbol and color
boxplot(df2$SpendingInThousandMOP~df2$PeriodYear, col = "green")


# Merge to one set

head(df)

df1a <- df1 %>% group_by(YearQuarterCont) %>%
  summarise(
    ArrivalCount.Sum = sum(value, na.rm = TRUE)
  )

df <- merge(df1a, df2) %>%
  mutate(AverageSpendingInThousandMOP = SpendingInThousandMOP / ArrivalCount.Sum)
  

# Make 3 plots

par(mfrow=c(2,2)) # all plots on one page
par(pch=22, col="steelblue") # plotting symbol and color
plot(df$YearQuarterCont,df$SpendingInThousandMOP, type="l")
par(pch=22, col="green") # plotting symbol and color
plot(df$YearQuarterCont,df$ArrivalCount.Sum, type="l")
par(pch=22, col="orange") # plotting symbol and color
plot(df$YearQuarterCont,df$AverageSpendingInThousandMOP, type="l")
barplot(height=df$AverageSpendingInThousandMOP, names.arg=df$YearQuarterCont)


# Plot both lines in the same Y axis

dev.off()
plot(df$YearQuarterCont,df$SpendingInThousandMOP, type="l", col="steelblue")
lines(df$YearQuarterCont,df$ArrivalCount.Sum, type="l", col="green")



## = (mapping) := (setting) ~ (evaluated in data) 
## = is always scaled, and := is never scaled. ~ is always used with the name of the variable

# ggvis

df %>%
ggvis(x = ~YearQuarterCont, y = ~AverageSpendingInThousandMOP) %>%
  #layer_bars(opacity := .2) %>%
  layer_smooths(stroke:= "orange", span = input_slider(0.1, 1, value=1)) %>%  
  #add the initial x axis in order to set x labes to blank
  add_axis('x', title='Year', properties = axis_props(labels=list(fill='blank'))) %>%
  
  #details for right axis i.e. the bars
  add_axis("y", orient = "right", title = "Average Spending In Thousand MOP", title_offset = 50) %>% 
  
  #details for left axis i.e. the lines + plotting of lines 
  add_axis("y", 'ylines' , orient = "left", title= "Arrival Counts in Millions" , grid=F ) %>%
  layer_lines(stroke := 'green', prop('y', ~ArrivalCount.Sum/1000000, scale='ylines'))

  #layer_lines(stroke := 'steelblue',   prop('y', ~SpendingInThousandMOP, scale='ylines'))








df %>%
  ggvis(~YearQuarter, ~AverageSpendingInThousandMOP) %>%
  layer_points(fill:= "green", size := input_slider(5, 120, value=20), opacity := .4) %>%
  layer_smooths(stroke:= "orange", span = input_slider(0.1, 1, value=1)) %>%
  layer_model_predictions(model="loess",stroke:="blue", opacity := .4)



## visitorsFromTheGreaterBayArea <- import("visitorsFromTheGreaterBayArea.xlsx")


if (!file.exists("visitorsFromTheGreaterBayArea.xlsx")) {
  download.file('https://api.data.gov.mo/datadir/downloadSingleFile?fileId=1458&dataDirId=8425e95c-9550-44d0-b804-51fe490030f3&token=qpAdIV529r7KO8FhTBKfDLOeM0AIMFbuf', 'visitorsFromTheGreaterBayArea.xlsx', method='curl' )
}
visitorsFromTheGreaterBayArea <- read_excel("visitorsFromTheGreaterBayArea.xlsx", col_name = TRUE)

head(visitorsFromTheGreaterBayArea)
## summary(visitorsFromTheGreaterBayArea)
## nchar(visitorsFromTheGreaterBayArea$period)
