## Get arguements from command line
##    $3 in shell is #1 (args[1]) in R: path to data (suggest relative path from project's root directory)

## Make args a list of the items in the command line after the script was called.
args <- commandArgs(trailingOnly = TRUE)

## assign variable names to arguements
data_dir_path <- args[1]

## load data into R (data.srev)
data <- read.table(paste(data_dir_path, "/data.srev", sep=""), header = FALSE)

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
strain <- str_extract(data$V1,"[0-9]{6}/[A-Za-z]+[-]?[0-9]*[A-Za-z]*")
strain <- sub("[0-9]+/", "", strain)

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
colnames(data) <- c("date", "plate", "strain",  "time", "wrongway", "no_response", "rev",
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

## For each strain, calculate the number of worms responding and the sample size,
data_prob_aggregate <- ddply(data_prob, c("strain", "time"), summarise,
                             reversal = sum(rev),
                             N = sum(no_response + rev))

## Calculate the proportion of worms responding
data_prob_aggregate <- ddply(data_prob_aggregate, c("strain", "time"), transform, 
                             rev_prob= (reversal / N))
                             
## make time numeric
data_prob_aggregate$time <- factor(data_prob_aggregate$time)

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
data_prob_aggregate$conf_int_upper <- conf_int$upper

## Checkout the data again
head(data_prob_aggregate)

## Plot figure

## load the ggplot2 library
library(ggplot2)

## make an object called my_plot which contains the plotting commands
my_plot <- ggplot(data_prob_aggregate, aes(time, rev_prob, color=factor(strain))) + ## plot Reversal probability against time for each strain
        geom_line(aes(group=strain)) + ## make a line connecting all the points in the plot
        geom_point(size = 3) + ## make points larger
        geom_errorbar(aes(ymin=conf_int_lower, ymax=conf_int_upper), ## add 95% confidence intervals
                      width=.1) + ## make the confidence interval 0.1 width
        ggtitle('Habituation') + ## add a title to the plot
        labs(x="Time(s)", y="Reversal Probability") + ## label the x and y axes
        theme(plot.title = element_text(size = 16, vjust=2), ## Make the plot title larger and higher
               legend.title=element_blank(), ## remove the legend label
               legend.key=element_rect(fill='white'), ## remove the blocks around the legend items
               legend.text=element_text(size = 12), ## make the legend text font larger
               panel.background = element_rect(fill = 'grey96'), ## make the plot background grey
               axis.text.x=element_text(colour="black", size = 12, angle = 90), ## change the x-axis values font to black and make larger
               axis.text.y=element_text(colour="black", size = 12), ## change the y-axis values font to black and make larger
               axis.title.x = element_text(size = 14, vjust = -0.2), ## change the x-axis label font to black, make larger, and move away from axis
               axis.title.y = element_text(size = 14, vjust = 1.3)) + ## change the y-axis label font to black, make larger, and move away from axis
        ylim(c(0,1)) ## Set the y-axis limits to a range from 0 to 1

## call the object to plot the figure
my_plot

## Get the name of the folder to save the figure to
folder_to_save_in <- str_extract(data_dir_path, "/.{1,}")

## make a folder in results to hold figure and stats
system(paste("mkdir results", folder_to_save_in, sep=""))

## make a variable containing the folder path to save to and the name of the figure
path_to_save <- paste("results", folder_to_save_in, "/figure.pdf", sep="")

## Save figure in results in appropriate folder
pdf(path_to_save, width=9, height=6)
my_plot
dev.off()

## Do a logistic regression to test if there is a significant difference 
## between habituated levels if there are multiple strains in the dataset
if (length(strain_list) > 1) {
  ## fit a logistic regression with reversal probility modeled against strain
  my_glm <- glm(rev_prob ~ strain, weights = N, family = binomial(link = "logit"), 
                data = data_prob_aggregate)
  
  ## Get the logistic regression summary statistics
  summary(my_glm)
  
  ## write stats to a text file
  my_glm_summary <- capture.output(summary(my_glm), file = NULL)
  write.table(my_glm_summary, file=paste("results", folder_to_save_in, "/stats.txt", sep=""), append = TRUE, quote=FALSE, row.names=FALSE, col.names=FALSE)
  write.table("", file=paste("results", folder_to_save_in, "/stats.txt", sep=""), append = TRUE, quote=FALSE, row.names=FALSE, col.names=FALSE)
  
  ## load the library to perform multiple comparisons
  library(multcomp)
  
  ## perform a Tukey's HSD multiple comparison posthoc test
  glht_my_glm <- glht(my_glm, mcp(strain="Tukey"))
  summary(glht_my_glm) 
  
  ## write stats to a text file
  my_tukey_summary <- capture.output(summary(glht_my_glm), file = NULL)
  write.table(my_tukey_summary, file=paste("results", folder_to_save_in, "/stats.txt", sep=""), append = TRUE, quote=FALSE, row.names=FALSE, col.names=FALSE)
  write.table("", file=paste("results", folder_to_save_in, "/stats.txt", sep=""), append = TRUE, quote=FALSE, row.names=FALSE, col.names=FALSE)
} 

