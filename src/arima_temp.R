# pre
rm(list=ls())
graphics.off()

# libraries
library("astsa")
library("ggplot2")
library("forecast")
library("fpp2")
library("aTSA")

# data
df <- read.csv("temp.csv")
temp <- ts(df[,2],start = 1880,end = 2015, frequency = 1)

# descriptive
summary(temp)
str(temp)
head(temp)

# plots 
autoplot(temp) +
  ggtitle("Global Temperature Deviations")+
  ylab("Deviation (°C)")+
  xlab("Year")

# P/ACF
ggAcf(temp)
ggPacf(temp)

# differencing
temp_d <- diff(temp)

# plot differenced series
autoplot(temp_d)+
  ggtitle("Differenced Series of Global Temperature Deviations")+
  xlab("Year")+
  ylab("Differenced Deviation")

# P/ACF, LB
ggAcf(temp_d)
ggPacf(temp_d)
Box.test(temp_d, lag=10, type="Ljung")

# Unit Root: ADF
adf.test(temp, nlag = 10)
adf.test(temp_d)

# auto fit
fit1 <- auto.arima(temp)
fit1

# auto fit suggests ARIMA(1,1,3)
sarima(temp, p=1, d = 1, q = 3) # Ljung-Box looks good to me... 

# other specifications 
sarima(temp, p=0, d = 1, q = 2)
sarima(temp, p=1, d = 1, q = 1)
sarima(temp, p=2, d = 1, q = 1)

# check residuals
checkresiduals(fit1)
adf.test(fit1$residuals)
ggAcf(fit1$residuals)
ggPacf(fit1$residuals)

# Forecast 35 years to 2050
fc1 <- fit1 %>% 
  forecast::forecast(h = 35)

autoplot(fc1) +
  autolayer(fitted(fc1), series = "fitted values")+
  xlab("Year")+
  ylab("deviation")+
  ggtitle("Forecasts from ARIMA (1,1,3)")+
  theme(legend.position = "none")# 
