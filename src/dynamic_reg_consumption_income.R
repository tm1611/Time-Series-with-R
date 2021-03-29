# Time Series Analysis 
# Methodology: Dynamic Regression, Comparison to SARIMA
# Data: US consumption, personal income
# Timo Meiendresch, tmeiendresch@gmx.de
# https://github.com/tm1611

# Intro
rm(list=ls())
graphics.off()

library("astsa")
library("ggplot2")
library("forecast")
library("fpp2")

## Dynamic Regression
# Add external information to describe y
# Regression model with ARIMA errors

## Data
head(uschange)
summary(uschange)
str(uschange)


autoplot(uschange[, 1:2], facets =TRUE) +
  xlab("Year") + 
  ylab("") +
  ggtitle("Quarterly changes in US consumption and personal income")

ggplot(aes(x = Income, y=Consumption),
       data=as.data.frame(uschange))+
  geom_point() + 
  ggtitle("Quarterly changes in US consumption and personal income") + 
  geom_smooth(method=lm, se=FALSE) + 
  geom_quantile(col="red", quantiles = c(0.25,0.5,0.75))

fit1 <- lm(Consumption ~ Income, data = uschange)
summary(fit1)
checkresiduals(fit1)

## Regression w ARIMA errors
fit2 <- auto.arima(uschange[,"Consumption"], xreg=uschange[, "Income"])
summary(fit2) # Income+1 -> Consumption +0.2028, c.p.
# Regression part as predictor
# ARIMA error takes care of short-term dynamics

checkresiduals(fit2)

# Forecast with xreg = mean
fc2 <- forecast(fit2, xreg=rep(mean(uschange[,"Income"]),12))
autoplot(fc2) +
  autolayer(fitted(fit2), lwd=1) +
  xlab("Year") +
  ylab("Percentage change")

## Comparison to univariate ARIMA
temp <- uschange[,"Consumption"]
fit3 <- auto.arima(temp)
summary(fit3)
checkresiduals(fit3)

fc3 <- fit3 %>% 
  forecast(h=12)  
  
autoplot(fc3) + 
  autolayer(fitted(fit3)) +
  xlab("Year") +
  ylab("Percentage change")

# Based on RMSE the dynamic Regression w ARIMAerrors
#performs better than SARIMA.


