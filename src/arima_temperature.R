# Time Series Analysis
# Methodology: SARIMA
# Data: Global mean temperature deviations
# Timo Meiendresch, tmeiendresch@gmx.de
# https://github.com/tm1611

# Introduction
rm(list=ls())
graphics.off()

# libraries
library("astsa")
library("ggplot2")
library("forecast")
library("fpp2")
library("aTSA")

# data
temp <- globtemp

# Plots
autoplot(temp) +
  ggtitle("Global Temperature Deviations")+
  ylab("Deviation (°C)")+
  xlab("Year")

acf2(temp, main = "P/ACF Global Temperature Deviations")

# differencing the data
temp_d <- diff(temp)

autoplot(temp_d)+
  ggtitle("Differenced Series of Global Temperature Deviations")+
  xlab("Year")+
  ylab("Differenced Deviation")

acf2(temp_d, main = "P/ACF Differenced Global Temperature Deviations")
adf.test(temp_d)

# Fit best arima model by AICc
fit1 <- auto.arima(globtemp)
fit1

fc1 <- fit1 %>% 
    forecast::forecast(h = 36)

autoplot(fc1) +
  autolayer(fitted(fc1), series = "fitted values")+
  xlab("Year")+
  ylab("deviation")+
  ggtitle("Forecast from ARIMA (1,1,3)")+
  theme(legend.position = "none")

# Forecasts
sarima.for(temp, n.ahead= 30, p=3, d=1, q=0)

### subsetting start = 1950; train-test split for backtesting (aka Cross-validation)
str(globtemp)
temp_post <- window(globtemp, start=1950)
train <- window(temp_post, end = 1999)
test <- window(temp_post, start = 2000)

autoplot(train)
autoplot(test)

acf2(diff(train))

# fit model to train
fit_train <- auto.arima(train)
fit_train

fc_train <- fit_train %>% 
  forecast::forecast(h=16)

autoplot(temp) +
  autolayer(fitted(fc_train))+
  autolayer(fc_train, PI = FALSE)

accuracy(fc_train, temp_post)

# Now: Use the complete post-1950 subset to fit a model and forecast upt to 2050
fit_post <- auto.arima(temp_post)
fc_post <- forecast::forecast(fit_post, h=35)
fit_post

autoplot(fc_post) +
  autolayer(fitted(fc_post)) +
  xlab("Year")+
  ylab("Temperature deviations")

autoplot(globtemp) +
  autolayer(fc_post, PI = FALSE, col="red") +
  autolayer(fc1, PI = FALSE) +
  xlab("Year")+
  ylab("Temperature deviations")


