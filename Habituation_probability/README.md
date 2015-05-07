# Habituation probability

This software will allow you to plot habituation probability graphs and generate 
statistical comparisons between groups (if there are multiple groups) using data from the
Multi-worm tracker (MWT; Swierczek et al., 2011). 


## Figures it generates
* Reversal probability versus stimulus number
* 95% confidence intervals (Clopper Pearson method) for reversal probability

## Statistics reported (if multiple groups)
* Logistic regression comparing final reversal probability between groups.


## How to use it

* Put your unzipped MWT experiment folders inside an experiment directory in the project's 
data directory

* In the Shell, set the working directory to project's root directory

* Call habituation_probability_driver.sh from the Bash Shell

* habituation_probability_driver.sh requires the following arguments from the user: 
(1) absolute path to chore.jar (offline analys program Choreography), (2) gigabytes of memory to 
be used to run Choreography (dependent upon the machine you are using, (3) type of 
stimulus and (4) path to directory where your data is stored.

 
See example below:

~~~
bash bin/habituation_probability_driver.sh /Users/tiffany/Documents/PostDoc/IBRO/Habituation_probability/bin/Chore.jar 8 puff data/Experiment_1
~~~
