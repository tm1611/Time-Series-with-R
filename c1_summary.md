---
title: "Time Series with R: Manipulating Time Series Data in R with xts & zoo"
author: "Timo Meiendresch"
date: "15 January 2019"
output:
  html_document:
    keep_md: true
---


## Ch.1 Introducing xts and zoo objects

An xts object consists of a matrix + index (time).


```r
library(xts)
```

Step 1: Create a simple matrix and an index of two consecutive days. 

```r
x <- matrix(1:4, 2,2 )
x
```

```
##      [,1] [,2]
## [1,]    1    3
## [2,]    2    4
```

```r
idx <- as.Date(c("2019-01-01", "2019-02-01"))
idx
```

```
## [1] "2019-01-01" "2019-02-01"
```

Step 2: Bring matrix and index together as an xts element using the `xts()`function. Take a look at the structure with `str(x)`.

```r
X <- xts(x, order.by=idx)
str(X)
```

```
## An 'xts' object on 2019-01-01/2019-02-01 containing:
##   Data: int [1:2, 1:2] 1 2 3 4
##   Indexed by objects of class: [Date] TZ: UTC
##   xts Attributes:  
##  NULL
```

```r
X
```

```
##            [,1] [,2]
## 2019-01-01    1    3
## 2019-02-01    2    4
```
The xts() constructor allows to specify some more useful options, especially to take care of the frequency and the time zone. Note that xts is a subclass of `zoo`.

#### Deconstructing xts
We can use `coredata()`to extract the data component from an `xts` element and `index()` to extract the index (times). 

## Importing, exporting and converting time series

Use `as.xts()` to convert other time series into xts. Here, `ts` to `xts`.

```r
# Load data from R datasets
data(sunspots)
class(sunspots)
```

```
## [1] "ts"
```

```r
sunspots_xts <- as.xts(sunspots)
head(sunspots_xts)
```

```
##          [,1]
## Jan 1749 58.0
## Feb 1749 62.6
## Mar 1749 70.0
## Apr 1749 55.7
## May 1749 85.0
## Jun 1749 83.5
```

We can also apply the `as.xts` function directly when loading the data, i.e. as: 

```r
as.xts(read.table("file"))
as.xts(read.csv("file"))
```

## Ch. 2 Basic Manipulations


```r
data(edhec, package="PerformanceAnalytics")
head(edhec["2009", 1])
```

```
##            Convertible Arbitrage
## 2009-01-31                0.0491
## 2009-02-28                0.0164
## 2009-03-31                0.0235
## 2009-04-30                0.0500
## 2009-05-31                0.0578
## 2009-06-30                0.0241
```

```r
# Select only variables from Jan09 to Mar09
edhec["2009-01/03",1]
```

```
##            Convertible Arbitrage
## 2009-01-31                0.0491
## 2009-02-28                0.0164
## 2009-03-31                0.0235
```

## Other extraction techniques
Furthermore, we can select rows as:


```r
x[c(1,2,3),]
x[index(x) > "2016-08-20"]
dates <- as.POSIXct(c("2016-06-25","2016-06-27"))
```

## Update and replace elements

```r
# take subset of edhec first
edhec_09 <- edhec["2009", 1]

# replace two random values of edhec_09 with NAs
edhec_09[sample(1:length(edhec_09), 2)] <- NA
edhec_09
```

```
##            Convertible Arbitrage
## 2009-01-31                0.0491
## 2009-02-28                    NA
## 2009-03-31                    NA
## 2009-04-30                0.0500
## 2009-05-31                0.0578
## 2009-06-30                0.0241
## 2009-07-31                0.0611
## 2009-08-31                0.0315
```

## Methods to find periods in your data
For the next few methods we'll use the sample data from the xts package 


```r
data(sample_matrix, package = "xts")
class(sample_matrix)
```

```
## [1] "matrix"
```

```r
OHLC <- as.xts(sample_matrix)
class(OHLC)
```

```
## [1] "xts" "zoo"
```

```r
dim(OHLC)
```

```
## [1] 180   4
```

```r
head(OHLC, 3)
```

```
##                Open     High      Low    Close
## 2007-01-02 50.03978 50.11778 49.95041 50.11778
## 2007-01-03 50.23050 50.42188 50.23050 50.39767
## 2007-01-04 50.42096 50.42096 50.26414 50.33236
```
We can use the `first()`and `last()` function to get  the "first x days/months/etc." or the "last x days/months/etc.". 


```r
first(OHLC[,"Close"], "3 days")
```

```
##               Close
## 2007-01-02 50.11778
## 2007-01-03 50.39767
## 2007-01-04 50.33236
```

```r
head(last(OHLC[,"Close"], "1 month"),3)
```

```
##               Close
## 2007-06-01 47.65123
## 2007-06-02 47.72569
## 2007-06-03 47.50198
```

We can also use integers to specify n 

```r
first(OHLC[,"Close"], n=3)
```

```
##               Close
## 2007-01-02 50.11778
## 2007-01-03 50.39767
## 2007-01-04 50.33236
```

`first()` and `last()` can be nested for internal intervals 

```r
# take last 3 days of first 2 months
# Backwards induction
last(first(OHLC[,"Close"], "2 months"), "3 days")
```

```
##               Close
## 2007-02-26 50.75481
## 2007-02-27 50.69206
## 2007-02-28 50.77091
```

```r
# negative specifications
first(first(OHLC[, "Close"], "1 months"),"-27 days")
```

```
##               Close
## 2007-01-29 49.91875
## 2007-01-30 50.02180
## 2007-01-31 50.22578
```

## Math operations using xts
xts is a matrix. Math operations are on the intersection of times (common dates). 

```r
# Take subset as first matrix
a <- first(OHLC[,"Close"], "3 days")
a
```

```
##               Close
## 2007-01-02 50.11778
## 2007-01-03 50.39767
## 2007-01-04 50.33236
```

```r
# Create a second xts matrix 
x <- matrix(rnorm(4,20,1))

# Note that idx is in the same format as "a"
idx <- seq(from = as.POSIXct("2007-01-03"), to = as.POSIXct("2007-01-06"), "1 day")
b <- xts(x, order.by=idx)
b
```

```
##                [,1]
## 2007-01-03 19.77391
## 2007-01-04 19.90189
## 2007-01-05 20.11247
## 2007-01-06 21.66821
```

```r
cbind(a, b)
```

```
##               Close        b
## 2007-01-02 50.11778       NA
## 2007-01-03 50.39767 19.77391
## 2007-01-04 50.33236 19.90189
## 2007-01-05       NA 20.11247
## 2007-01-06       NA 21.66821
```

Math operations are on the intersection of times only. 

```r
a + b # Applied only if we have the same dates
```

```
##               Close
## 2007-01-03 70.17158
## 2007-01-04 70.23425
```

```r
# add a to b using index of b
b + merge(a, index(b))
```

```
##                  e1
## 2007-01-03 70.17158
## 2007-01-04 70.23425
## 2007-01-05       NA
## 2007-01-06       NA
```

```r
# fill missings with 0 <- takes values from b. 
b + merge(a, index(b), fill = 0)
```

```
##                  e1
## 2007-01-03 70.17158
## 2007-01-04 70.23425
## 2007-01-05 20.11247
## 2007-01-06 21.66821
```

```r
# use locf to fill in missing values
b + merge(a, index(b), fill = na.locf)
```

```
##                  e1
## 2007-01-03 70.17158
## 2007-01-04 70.23425
## 2007-01-05 70.44483
## 2007-01-06 72.00056
```

## Ch. 3 Merging time series 
Series can be combined by column using `cbind()` or `merge()`. These joins on index (i.e. by time). Inner, outer, left and right joins are possible.


```r
# Outer join: all available dates
merge(a, b) # defaul join="outer"
```

```
##               Close        b
## 2007-01-02 50.11778       NA
## 2007-01-03 50.39767 19.77391
## 2007-01-04 50.33236 19.90189
## 2007-01-05       NA 20.11247
## 2007-01-06       NA 21.66821
```

```r
# Inner join: Only common points in time
merge(a, b, join="inner")
```

```
##               Close        b
## 2007-01-03 50.39767 19.77391
## 2007-01-04 50.33236 19.90189
```

```r
# Right join: Joining according to index of right series dates
merge(a, b, join="right")
```

```
##               Close        b
## 2007-01-03 50.39767 19.77391
## 2007-01-04 50.33236 19.90189
## 2007-01-05       NA 20.11247
## 2007-01-06       NA 21.66821
```

```r
# Use fill to fill with a specific number
merge(a, b, join="right", fill=-1)
```

```
##               Close        b
## 2007-01-03 50.39767 19.77391
## 2007-01-04 50.33236 19.90189
## 2007-01-05 -1.00000 20.11247
## 2007-01-06 -1.00000 21.66821
```

```r
merge(a, c(1,1,1))
```

```
##               Close c.1..1..1.
## 2007-01-02 50.11778          1
## 2007-01-03 50.39767          1
## 2007-01-04 50.33236          1
```

```r
merge(a, 3)
```

```
##               Close X3
## 2007-01-02 50.11778  3
## 2007-01-03 50.39767  3
## 2007-01-04 50.33236  3
```

```r
merge(a, as.POSIXct("2019-01-01"))
```

```
##               Close
## 2007-01-02 50.11778
## 2007-01-03 50.39767
## 2007-01-04 50.33236
## 2019-01-01       NA
```
Next: Consider rbind() to combine series by row. Rows are inserted in time order. All rows in rbind() must have a time and the numbers of columns must match.


```r
rbind(a, b)
```

```
##               Close
## 2007-01-02 50.11778
## 2007-01-03 50.39767
## 2007-01-03 19.77391
## 2007-01-04 50.33236
## 2007-01-04 19.90189
## 2007-01-05 20.11247
## 2007-01-06 21.66821
```

## Handling missingness
locf means "las observation carried forward" and can be used to deal with NAs. 

```r
# Create a series with NAs
z <- rbind(a,b)
z[c(3,4)] <- NA
z
```

```
##               Close
## 2007-01-02 50.11778
## 2007-01-03 50.39767
## 2007-01-03       NA
## 2007-01-04       NA
## 2007-01-04 19.90189
## 2007-01-05 20.11247
## 2007-01-06 21.66821
```

```r
# use na.locf()
cbind(z, na.locf(z), na.locf(z, fromLast = TRUE))
```

```
##               Close  Close.1  Close.2
## 2007-01-02 50.11778 50.11778 50.11778
## 2007-01-03 50.39767 50.39767 50.39767
## 2007-01-03       NA 50.39767 19.90189
## 2007-01-04       NA 50.39767 19.90189
## 2007-01-04 19.90189 19.90189 19.90189
## 2007-01-05 20.11247 20.11247 20.11247
## 2007-01-06 21.66821 21.66821 21.66821
```
In the last series last observation has been carried forward from before and from later observations. 

Other functions to deal with NAs:

* `na.fill(object, fill, ...)`
*  `na.trim(object, ...)`
* `na.omit(object, ...)`

We can also interpolate NAs with: 

* `na.approx(object, ...)`

## Lags and differences
Use `lag()` to shift observations in time. number of lags k and NA handling can be modified. 


```r
# compare standard differences to initial series
cbind(b, diff(b))
```

```
##                   b   diff.b.
## 2007-01-03 19.77391        NA
## 2007-01-04 19.90189 0.1279773
## 2007-01-05 20.11247 0.2105778
## 2007-01-06 21.66821 1.5557351
```

```r
cbind(b, lag(b, k = -1))
```

```
##                   b lag.b..k....1.
## 2007-01-03 19.77391       19.90189
## 2007-01-04 19.90189       20.11247
## 2007-01-05 20.11247       21.66821
## 2007-01-06 21.66821             NA
```

```r
# Create own first differences
z <- cbind(b, lag(b))
z$first_diff <- z$b - z$lag.b.
z
```

```
##                   b   lag.b. first_diff
## 2007-01-03 19.77391       NA         NA
## 2007-01-04 19.90189 19.77391  0.1279773
## 2007-01-05 20.11247 19.90189  0.2105778
## 2007-01-06 21.66821 20.11247  1.5557351
```

## Ch. 4 Apply functions by time
Two main approaches to apply functions on discrete periods or intervals. Using `period.apply(x, INDEX, FUN, ...)` or `split()`. 

To find the index of the last observation of an interval, we can use the function `endpoints(x, on="years")`.


```r
# Using period.apply(x, INDEX, FUN, ...)
ep <- endpoints(OHLC, "months", k = 2)
OHLC[ep]$Close
```

```
##               Close
## 2007-02-28 50.77091
## 2007-04-30 49.33974
## 2007-06-30 47.76719
```

```r
# k = 2 specifies that every two months are taken
period.apply(OHLC$Close, INDEX=ep, FUN=mean)
```

```
##               Close
## 2007-02-28 50.50184
## 2007-04-30 49.55491
## 2007-06-30 47.87453
```
To reach a similar result we can also use shortcut functions: 

* `apply.monthly(), apply.yearly(), apply.quarterly(), etc.`


```r
apply.monthly(OHLC$Close, mean)
```

```
##               Close
## 2007-01-31 50.22791
## 2007-02-28 50.79533
## 2007-03-31 49.48246
## 2007-04-30 49.62978
## 2007-05-31 48.26699
## 2007-06-30 47.46899
```

The `split(x, f="months")` function splits data into chunks of time lists. 

```r
OHLC_monthly <- split(OHLC[,"Close"], f="months")

lapply(X = OHLC_monthly, FUN=mean)
```

```
## [[1]]
## [1] 50.22791
## 
## [[2]]
## [1] 50.79533
## 
## [[3]]
## [1] 49.48246
## 
## [[4]]
## [1] 49.62978
## 
## [[5]]
## [1] 48.26699
## 
## [[6]]
## [1] 47.46899
```

## Converting periodicity
Function `to.period()` to aggregate OHLC data.


```r
to.period(x = OHLC$Close, period = "months", name="OHLC")
```

```
##            OHLC.Open OHLC.High OHLC.Low OHLC.Close
## 2007-01-31  50.11778  50.67835 49.88096   50.22578
## 2007-02-28  50.35784  51.17899 50.35784   50.77091
## 2007-03-31  50.57075  50.61559 48.28969   48.97490
## 2007-04-30  48.87032  50.32556 48.87032   49.33974
## 2007-05-31  49.47138  49.58677 47.60536   47.73780
## 2007-06-30  47.65123  47.76719 47.14660   47.76719
```

```r
# Alternatively use the shortcut function
to.monthly(OHLC$Close, name = "OHLC")
```

```
##          OHLC.Open OHLC.High OHLC.Low OHLC.Close
## Jan 2007  50.11778  50.67835 49.88096   50.22578
## Feb 2007  50.35784  51.17899 50.35784   50.77091
## Mar 2007  50.57075  50.61559 48.28969   48.97490
## Apr 2007  48.87032  50.32556 48.87032   49.33974
## May 2007  49.47138  49.58677 47.60536   47.73780
## Jun 2007  47.65123  47.76719 47.14660   47.76719
```
Note that `OHLC = FALSE` is an option and that we can

## Rolling functions
First, `split- lapply - do.call(rbind)` paradigm is useful to split a time series apply certain cumulative calculations before binding the time series back together. 

```r
OHLC_monthly <- split(OHLC[,1], f="months")
OHLC_monthly <- lapply(OHLC_monthly, FUN=cumsum)
OHLC_monthly <- do.call(rbind, OHLC_monthly)
```

Rolling windows to apply a function on a certain period, eg. always 3 days, etc. 

```r
# calculate three-day mean of OHLC
head(rollapply(OHLC[,4], 3, mean))
```

```
##               Close
## 2007-01-02       NA
## 2007-01-03       NA
## 2007-01-04 50.28260
## 2007-01-05 50.35487
## 2007-01-06 50.28269
## 2007-01-07 50.16919
```

## Ch. 5 Index, Attributes, and TimeZones

```r
# Check index and timezone
index(OHLC)[1:3]
```

```
## [1] "2007-01-02 CET" "2007-01-03 CET" "2007-01-04 CET"
```

```r
indexClass(OHLC)
```

```
## [1] "POSIXct" "POSIXt"
```

```r
indexTZ(OHLC)
```

```
## [1] ""
```

```r
# Change index format 
head(OHLC[,1],3)
```

```
##                Open
## 2007-01-02 50.03978
## 2007-01-03 50.23050
## 2007-01-04 50.42096
```

```r
indexFormat(OHLC) <- "%d %b %Y"
head(OHLC[,1],3)
```

```
##                 Open
## 02 Jan 2007 50.03978
## 03 Jan 2007 50.23050
## 04 Jan 2007 50.42096
```
Always check and set your time zone to avoid surprises. This can be done with the xts constructor as it has a `tzone=...` argument

## Periodicity
Identify periods of the data you are working with. Useful for regular timestamps


```r
# Check periodicity of OHLC
periodicity(OHLC)
```

```
## Daily periodicity from 2007-01-02 to 2007-06-30
```

```r
periodicity(to.monthly(OHLC))
```

```
## Monthly periodicity from Jan 2007 to Jun 2007
```

```r
# counting days, months, seconds, etc.
nquarters(OHLC)
```

```
## [1] 2
```

```r
nmonths(OHLC)
```

```
## [1] 6
```

```r
nweeks(OHLC)
```

```
## [1] 26
```

```r
# weekly index
head(.indexwday(OHLC))
```

```
## [1] 2 3 4 5 6 0
```

```r
# check monthly index 
head(.indexmday(OHLC))
```

```
## [1] 2 3 4 5 6 7
```

```r
# check yearly index
tail(.indexyday(OHLC))
```

```
## [1] 175 176 177 178 179 180
```

Left out: Modifying timestamps to remove times to allow for uniqueness (`make.index.unique()`) or, if too many time stamps are availabe the `align.time()`command will help, setting the n argument to the number of second you'd like to round to.  
