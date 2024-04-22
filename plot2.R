#### This is the Exploratory Data Analysis First Project -- plot2.R program.

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
# faster fread() for a large table AND it's arguments skip= and nrows=, but, hey, 
# if it don't work, it don't work. fread() abandoned in favor of read.table(). FYI.

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

# due to the "chicken-and-egg" issue of figuring values for skip= and nrows= 
# we used UNIX to isolate the date/time ranges for the graph, and used the 
# result to confirm the record indexes needed for the correct subset.
# from the macOS Ventura Terminal program and it's grep & cat from UNIX:
#    grep -n ^1\/2\/2007 household_power_consumption.txt >day1.txt
#    grep -n ^2\/2\/2007 household_power_consumption.txt >day2.txt
#    cat day1.txt day2.txt >Feb1_2.txt

# from the 'head Feb1_2.txt' and 'tail Feb1_2.txt' output, we get...
firstRow <- 66638L
lastRow  <- 69518L   # do we need a row from Sat for the x-axis?

# this range of record indexes of household_power_consumption.txt covers all
# of Feb 1 2007 and Feb 2 2007.


# we now subset the master table to only February those observations we need
foo <- foo[firstRow:lastRow,]
# check the results...
anyNA(foo)
unique(foo$Date)
str(foo)

# from lubridate we add a new column of the combined dates/times.
#   we do this to not disturb the original data.
foo$PlotTimes <- dmy_hms(paste(foo$Date,foo$Time))


# on to Plot2:  a line graph -- Global Active Power for Feb 1 2007 and Feb 2 2007
png(filename = "plot2.png")

# we begin with the actual line plot
plot(foo$Global_active_power ~ foo$PlotTimes,
		 type = "l", 
		 xaxt = "n", 
		 xlab = "", 
		 ylab = "Global Active Power (kilowatts)")

# and now for the "customized" x-axis.

# you MUST do these sequence of steps to get axis() to work correctly.
# make even a trivial change, and the "Thu Fri Sat" will not appear.
foo$Date  <- dmy(foo$Date)
foo$Date  <- as.POSIXct(foo$Date, format = "%Y-%m-%d")
seq_dates <- seq(from = min(foo$Date), to = max(foo$Date), by = "day")
axis(1, at = seq_dates, labels = format(seq_dates,"%a"))

dev.off()
