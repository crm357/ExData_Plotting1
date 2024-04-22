#### This is the Exploratory Data Analysis First Project -- plot4.R program.

# let's download the dataset
#setwd("")
source <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
dest   <- "Consumption.zip"
download.file(source,dest)
unzip(dest)


# It is advised that the reader pause at this point and examine the results of the unzip,
# to ensure the unzip ran correctly.  Do the "unpacked" files look "reasonable"? 
# Examine by external means how the values are formatted, what does the separator (sep=)
# character look like, and are there column headers.

# This can give you a "heads up" on what to read in to your data table.

# and a heads-up we need indeed!
#   this is a text file
#   there are column headers
#   the separator is a ";"
#   the numbers appear to be real numbers -- 'numeric'

# these are the packages we prefer:
library(data.table)
library(dplyr)
library(lubridate)


# "* We will only be using data from the dates 2007-02-01 and 2007-02-02. One alternative is to 
#    read the data from just those dates rather than reading in the entire dataset and subsetting 
#    to those dates."


# great idea, if you can get the software to work right!

# NOTE: could NOT get fread() to handle the column headers correctly when reading
# household_power_consumption.txt.  read.table() does just fine.  would prefer the
# faster fread for a large table AND it's arguments skip= and nrows=, but, hey, 
# if it don't work, it don't work. fread() abandoned in favor of read.table().

source <- "household_power_consumption.txt"
foo <- read.table(source, 
									header = TRUE, 
									sep = ";", 
									dec = ".", 
									na.strings = "?", 
									colClasses = c("character","character","numeric","numeric","numeric","numeric","numeric","numeric","numeric")
								 )


# now to subset Feb 1 2007 and Feb 2 2007.

# From the project notes -- "We will only be using data from the dates 2007-02-01 and 2007-02-02."
# this author chooses to subset those rows via (UNIX) grep.

# due to the problems encountered with fread and read.table in handling skip=
# and nrows=, we used UNIX to isolate the date/time ranges for the graph,
# and used the result to confirm the record indexes needed for the correct subset.
# from the macOS Ventura Terminal program and grep/cat from UNIX:
#   grep -n ^1\/2\/2007 household_power_consumption.txt >day1.txt
#   grep -n ^2\/2\/2007 household_power_consumption.txt >day2.txt
#   cat day1.txt day2.txt >Feb1_2.txt

# from the 'head(Feb1_2.txt)' and 'tail(Feb1_2.txt)' output, we get...
firstRow <- 66638L
lastRow  <- 69518L   # do we need a row from Sat for the x-axis?

# this range of record indexes of household_power_consumption.txt covers all
# of Feb 1 2007 and Feb 2 2007.


# we now subset the master table to only those observations we need
foo <- foo[firstRow:lastRow,]
# check the results...
anyNA(foo)
unique(foo$Date)
str(foo)

# from lubridate we add a new column of the combined dates/times.
# we do this to not disturb the subset data table.
foo$PlotTimes <- dmy_hms(paste(foo$Date,foo$Time))


# per my comments in previous plot programs, we include those steps in each plot
# for the "customized" x-axis. for a more complete discussion please review
# plot2.R or plot3.R


# for this 4-plot program, and based on our experience from the previous plots,
# we can arrange for the "custom" x-axis labels before running the plots, because
# the x-axis specification doesn't change base on any specific plot.
foo$Date <- dmy(foo$Date)
foo$Date <- as.POSIXct(foo$Date,format = "%Y-%m-%d")
seq_dates <- seq(from = min(foo$Date), to = max(foo$Date), by = "day")


png(filename = "plot4.png")

# this project item wants a 4 x 4 plot arrangement
par(mfrow = c(2, 2))



## first plot
plot(foo$Global_active_power ~ foo$PlotTimes,type = "l", xaxt = "n", xlab = "", ylab = "Global Active Power")
axis(1, at = seq_dates, labels = format(seq_dates,"%a"))



# second plot
plot(foo$Voltage ~ foo$PlotTimes,type = "l", xaxt = "n", xlab = "datetime", ylab = "Voltage")
axis(1, at = seq_dates, labels = format(seq_dates,"%a"))



## third plot
with(foo, plot(foo$PlotTimes,foo$Sub_metering_1, type = "l", col = "black", xaxt = "n", xlab = "", ylab = "Energy sub metering"))
with(foo,lines(foo$PlotTimes, foo$Sub_metering_2, main = "", type = "l", col = "red"))
with(foo,lines(foo$PlotTimes, foo$Sub_metering_3, main = "", type = "l", col = "blue"))
legend("topright",legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"),pch = NA,lwd = 2,lty = c(1,1,1),col = c("black","red", "blue"))
axis(1, at = seq_dates, labels = format(seq_dates,"%a"))



# fourth plot
plot(foo$Global_reactive_power ~ foo$PlotTimes,type = "l", xaxt = "n", xlab = "datetime", ylab = "Global_reactive_power")
axis(1, at = seq_dates, labels = format(seq_dates,"%a"))

dev.off()
