## Get arguements from command line
##    $4 in shell is #1 (args[1]) in R: path to data (suggest relative path from project's root directory)
##  	$5 in shell is #2 (args[2]) in R: time to stimulus onset 
##		$6 in shell is #3 (args[3]) in R: number of stimuli
##		$7 in shell is #4 (args[4]) in R: interstimulus interval

## Make args a list of the items in the command line after the script was called.
args <- commandArgs(trailingOnly = TRUE)

## assign variable names to arguements
data_dir_path <- args[1]
stim_onset <- args[2]
num_stim <- args[3]
isi <- args[4]

## load data into R (data.srev)
data <- read.table(data_dir_path, header = FALSE)

## split up the first column (V1) into date, plate, time and strain 

## load stringr library (necessary for string manipulation using regular expressions)
library(stringr)

## extract date information from first column (V1). Date is always 8 numeric characters.
date <- str_extract(data$V1, "[0-9]{8}")

## extract plate information from first column (V1). Plate is the date (8 numeric characters) and an 
## underdash (-) and the time (6 numeric characters: HH:MM:SS)
plate <- str_extract(data$V1, "[0-9]{8}_[0-9]{6}")

## extract strain information from first column (V1). We are trying to be flexible to grab the correct
## info whether someone enters the strain name, the gene name, or the allele name. It might be 
## better to be more limited and consistent about what one enters into the filename in the MWT
## Tracker program for filename.
strain <- str_extract(data$V1,"[A-Za-z]+[-]?[0-9]+")

## extract time information from first column (V1). Time gets included into the path string when we use 
## grep to combine all the files. It's format is: ##.###. But there could be more or less numeric 
## digits before or after the decimal place.
time <- str_extract(data$V1, "[0-9]+[.][0-9]+")

## make time numeric
time <- as.numeric(time)

## round time to 1s
time <- round(time, digits = 0)

## make time a factor
time <- as.factor(time)

## combine new columns with merged file
data <- cbind(date, plate, strain, time, data[,2:dim(data)[2]])

##clean up the workspace
rm(date, plate, strain, time)

##name columns  
colnames(data) <- c("date", "plate", "strain",  "time", "wrongway", "no_response", "reversal",
                    "dist_avg", "dist_std", "dist_sem", "dist_min", "dist_25th", "dist_median",
                    "dist_75th", "dist_max", "dur_avg", "dur_std", "dur_sem", "dur_min", "dur_25th",
                    "dur_median", "dur_75th", "dur_max")

## make a data frame containing only the count data for probabilities
data_prob <- data[,1:7]

## make a list of the strains
strain_list  <- unique(data$strain)

## summarise data by strain (so that we can plot the proportion of worms 
## responding for each strain). 

## load the plyr library to access the data frame summarizing function "ddply"
library(plyr)

## For each strain, calculate the number of worms respoding and the sample size,
data_prob_aggregate <- ddply(data_prob, c("strain", "time"), summarise,
                             reversal = sum(reversal),
                             N = sum(no_response + reversal))

## Calculate the proportion of worms responding
data_prob_aggregate <- ddply(data_prob_aggregate, c("strain", "time"), transform, 
                             rev_prob= (reversal / N)
                             
## take a look at the data
head(data_prob_aggregate)

## load the binom libary to calculate 95% confidence intervals 
library(binom)

## Calculate the 95% binomial confidence intervals for responding the stimulus
## (Clopper-Pearson method)
conf_int <- binom.confint(data_prob_aggregate$reversal, data_prob_aggregate$N, 
                          methods = "exact")

## Checkout the confidence intervals
conf_int

## Add these confidence intervals to the data frame
data_prob_aggregate$conf_int_lower <- conf_int$lower
data_prob_aggregate$conf_int_lower <- conf_int$upper

## Checkout the data again
head(data_prob_aggregate)

## Plot figure

