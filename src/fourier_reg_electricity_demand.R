# Time Series Analysis
# Methodology: Dynamic harmonic regression, Fourier transformation 
# Data: Half-hourly electricity demand, Taylor(2003)
# Timo Meiendresch, tmeiendresch@gmx.de
# https://github.com/tm1611


# Intro
rm(list=ls())
graphics.off()

library("astsa")
library("ggplot2")
library("forecast")
library("fpp2")

## Dynamic harmonic regression
# Based on fourier terms:
# Every periodic function can be approximanted by sin/cos#
#for large enough K.
# allows any length of seasonality
# smoothness of the seasonal pattern controlled by K
# K: number of Fourier sin and cos pairs.
# -> Smoother for smaller values of K
# Short term dynamics handled with ARMA error
# Disadvantage: Seasonality assumed to be fixed

# Data: electricity demand from Taylor(2003)
head(taylor)
autoplot(taylor) +
  ggtitle("Half-hourly electricity demand")+ 
  ylab("Megawatts")+
  xlab("Time")
length(taylor)

# train-test split (10 days = 48*10)
train <- subset(taylor, end = length(taylor)-480)
test <- subset(taylor, start = length(taylor)-479)

# check split
lapply(list(taylor,train,test), length)

## Fit1: ARIMA (to show that this won't work properly)
# small subset because it's very slow otherwise
sub_small <- subset(taylor, end = 200)
autoplot(sub_small)
ggAcf(sub_small,lag.max = 50)
ggPacf(sub_small, lag.max = 50)

fit1 <- auto.arima(sub_small)
fit1

checkresiduals(fit1)

## Fit2: Dynamic Harmonic regression
# tslm -> Linear model with ts components
fit2 <- tslm(train ~ fourier(train, K = c(10, 10)))

# forecasting ten days ahead (48*10)
fc2 <- forecast(fit2, newdata=data.frame(fourier(train, K = c(10,10), h=480)))
autoplot(fc2) + 
  xlab("Time") + 
  ylab("Megawatts")
  
accuracy(fc2, taylor)


