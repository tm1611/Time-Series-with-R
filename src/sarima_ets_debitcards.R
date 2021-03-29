# Time Series Analysis
# Methodology: SARIMA, ETS
# Data: Retail Debit Card Usage
# Timo Meiendresch, tmeiendresch@gmx.de
# https://github.com/tm1611

# Intro
rm(list=ls())
graphics.off()

# libraries
library("astsa")
library("ggplot2")
library("forecast")
library("fpp2")

# data 
series <- debitcards
summary(series)
str(series)

autoplot(series)+
  ggtitle("Retail debit card usage in Iceland")+
  xlab("millions ISK")+
  ylab("Year")

# seasonal plots
ggseasonplot(series)
ggseasonplot(series, polar = TRUE)
ggsubseriesplot(series) + 
  ggtitle("Retail debit card usage by month")+
  ylab("millions ISK")

gglagplot(series)

# P/ACF
acf2(series)
ggAcf(diff(series))
ggPacf(diff(series))

# train test split
train <- subset(series, end = length(series) - 36)

autoplot(diff(train)) # -> Increasing variation
ggAcf(diff(train)) #-> MA terms for 12,24 lags 
ggPacf(diff(train)) 

# Forecast 1: SARIMA 
fit1 <- auto.arima(train)
fit1
fc1 <- fit1 %>% 
  forecast::forecast(h=36)

autoplot(series)+
  autolayer(fc1, PI = FALSE, lty=1, lwd=1) +
  autolayer(fitted(fc1), lty=2)

autoplot(fc1)
checkresiduals(fc1)

# Forecast 2: SARIMA + BoxCox
lmd <- BoxCox.lambda(train)
autoplot(BoxCox(train, lmd))
autoplot(diff(BoxCox(train, lmd)))

ggAcf(diff(BoxCox(train, lmd)))
ggPacf(diff(BoxCox(train, lmd)))

fit2 <- auto.arima(train, lambda=lmd)
fit2

fc2 <- fit2 %>% 
  forecast::forecast(h=36)

autoplot(series) +
  autolayer(fc2, PI = FALSE, lty=1, lwd=1)+
  autolayer(fitted(fc2), lty=2)

autoplot(fc2)
checkresiduals(fc2)

# Forecast 3: ETS
fit3 <- ets(train)
fit3

fc3 <- fit3 %>% 
  forecast::forecast(h=36)

autoplot(series)+
  autolayer(fc3, PI = F, lty=1, lwd=1) +
  autolayer(fitted(fc3), lty=2)

checkresiduals(fit3)

# Compare the three models
acc1 <- accuracy(fc1, series)
acc2 <- accuracy(fc2, series)
acc3 <- accuracy(fc3, series)

rbind(acc1,acc2,acc3)

# Next steps: Apply the "best" model to the entire data
# Based on RMSE: Best fit from ETS (fit3)

ffit <- ets(series)
ffit

# ETS(M,A,M)
# Error: Multiplicative 
# Trend: Additive
# Season: Multiplicative

ffc <- ffit %>% 
  forecast::forecast(h=36)

autoplot(ffc) +
  autolayer(fitted(ffc), lty=2) +
  xlab("Year") + 
  ylab("Millions ISK")
