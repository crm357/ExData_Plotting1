#### This is the Exploratory Data Analysis First Project -- plot1.R program.

# let's download the dataset
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
#   there are column beaders
#   the separator is a ";"
#   the numbers appear to be real numbers -- 'numeric'

# these are the packages we prefer:
library(data.table)
library(dplyr)

# so, let us use a completely specified read.table() to ensure we load all data
# items correctly. (we miss here and those plot could look pretty weird! :)

source <- "household_power_consumption.txt"
foo <- read.table(source,
									header = TRUE, 
									skip = 0, 
									sep = ";", 
									dec = ".", 
									na.strings = "?", 
									colClasses = c("character","character","numeric","numeric","numeric","numeric","numeric","numeric","numeric")
								 )

# From the project notes -- "We will only be using data from the dates 2007-02-01 and 2007-02-02."
# this author chooses to subset those rows via grep.

#FebIndexes <- grep("^1/2/2007|^2/2/2007", foo$Date, value = TRUE)   # verify grep
FebIndexes <- grep("^1/2/2007|^2/2/2007", foo$Date, value = FALSE)
foo <- foo[FebIndexes,]
# check the results...
anyNA(foo)
unique(foo$Date)
str(foo)


# on to plot1:  a histogram -- a frequency distribution of Global Active Power
png(filename = "plot1.png")
hist(foo$Global_active_power, 
		 col = "red", 
		 xlab = "Global Active Power (kilowatts)", 
		 main = "Global Active Power"
		 )
dev.off()
