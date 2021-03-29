# Time Series Analysis
# Methodology: SARIMA, ETS, Box-Cox
# Data: Monthly Electricity production
# Timo Meiendresch, tmeiendresch@gmx.de
# https://github.com/tm1611

# Intro
rm(list=ls())
graphics.off()

library("astsa")
library("ggplot2")
library("forecast")
library("fpp2")
library("magrittr")

# Data
autoplot(usmelec)
summary(usmelec)

# seasonalplot
ggseasonplot(usmelec, year.labels = TRUE, continuous = TRUE)
seasonplot(usmelec)

# Histogram
hist(usmelec,
     breaks = 20, 
     main = "Monthly US Electricity Production",
     xlab= "",
     probability = TRUE)

# Check ACF/PACF
acf2(usmelec)

# check series after differencing 
autoplot(diff(usmelec))

### train-test split, backtesting ###
train <- subset(usmelec, end = length(usmelec) - 36)

# Seasonal naive forecast
snaive_fc <- snaive(train, h=36)
snaive_fc %>% 
  checkresiduals()

accuracy(snaive_fc, usmelec)

autoplot(usmelec)+
  autolayer(snaive_fc, PI = FALSE, col="red")

### Simple Exponential Smoothing
ses_fc <- ses(train, h = 36)
ses_fc %>% 
  checkresiduals()

accuracy(ses_fc, usmelec)

### Holt-Winter's method (trend + seasonality)
hw_fc <- hw(train, h = 36, seasonal = "multiplicative")
autoplot(usmelec)+
  autolayer(hw_fc, PI =FALSE, col="red")

accuracy(hw_fc, usmelec)

hw_fc %>% 
  checkresiduals()

### ETS models
ets_model <- ets(train)
ets_fc <- forecast(ets_model, h=36)

autoplot(usmelec)+
  autolayer(ets_fc, PI=FALSE, col ="red")

accuracy(ets_fc, usmelec)
checkresiduals(ets_fc)
summary(ets_fc)

## Variance transformation
lmd <- BoxCox.lambda(usmelec)

autoplot(BoxCox(usmelec, lambda = lmd)) +
  xlab("Year") + 
  ylab("") +
  ggtitle("Transformed Monthly Electricity Consumption")

# Seasonal ARIMA model using BoxCox transform
autoplot(diff(usmelec))

lmd = BoxCox.lambda(usmelec)
autoplot(BoxCox(usmelec, lmd))

BC_elec_d <- diff(BoxCox(usmelec,lmd))
autoplot(BC_elec_d)

acf2(BC_elec_d)

# Seasonal ARIMA without BoxCox on train data (lowest RMSE)
ARIMA_fit <- auto.arima(train)

ARIMA_fit %>% 
  checkresiduals()

ARIMA_fc <- forecast(ARIMA_fit, h = 36)
accuracy(ARIMA_fc, usmelec)

autoplot(usmelec) +
  autolayer(ARIMA_fc, PI = FALSE, col="red")

# ARIMA with BoxCox (spoiler: not really helpful)
lmd <- BoxCox.lambda(train)
train_BC <- BoxCox(train, lmd)
ARIMA_fit_BC <- auto.arima(train_BC)

ARIMA_fit_BC %>% 
  checkresiduals()

ARIMA_BC_fc <- forecast(ARIMA_fit_BC, h=36)

ARIMA_BC_fc_inv <- InvBoxCox(ARIMA_BC_fc$mean, lambda = lmd)
accuracy(ARIMA_BC_fc_inv, usmelec)  
  