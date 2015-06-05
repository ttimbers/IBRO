## Written by: Tiffany A. Timbers, Ph.D.
## April 23, 2015
##
## This is the driver script that will call modulars scripts to attack each chunk
## of the problem: this software will allow you to plot habituation probability graphs and 
## generate statistical comparisons between groups (if there are multiple groups) using 
## data from the Multi-worm tracker (Swierczek et al., 2011). 
##
##
## Set working directory to project's root directory
##
## Requires the following input from the user:
##
##		$1: gigabytes of memory to be used to run Choreography (dependent upon
##			the machine you are using
##		$2: type of stimulus 
##		$3:	directory that data is in 

## Set amount of memory to be devoted to running Choreography
export MWT_JAVA_OPTIONS=-Xmx$1g

## Call choreography to analyze the MWT data. This must be done for each plate (i.e. 
## each folder from  your experiment today). Choreography output options here ask for 
## reversals occurring within 0.5 s of a stimulus and speed over the duration of the 
## entire experiment (averaged over all the worms on the plate).
cd $3
for folder in */; do Chore --shadowless --pixelsize 0.027 --minimum-move-body 2 --minimum-time 20 --segment --output speed,midline,morphwidth --plugin Reoutline::despike --plugin Respine --plugin MeasureReversal::$2::dt=1::collect=0.5 $folder; done

## need to create a large file containing all data files with 
## data, plate name and strain name in each row
grep -H '[.]*' $(find . -name '*.rev') > data.srev

cd ../..

## create figure (Reversal probability versus stimulus number, plotting 95% confidence 
## interval) and do stats (Logistic regression comparing initial reversal probability and
## final reversal probability between groups).
rscript bin/habituation_probability_plotNstats.R $3

