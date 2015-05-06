# Habituation probability

This software will allow you to plot habituation probability graphs and generate 
statistical comparisons between groups (if there are multiple groups) using data from the
Multi-worm tracker (Swierczek et al., 2011). 

# This is still a work in progress and is not yet functional.


## Figures it generates
* Reversal probability versus stimulus number
* 95% confidence intervals (Clopper Pearson method) for reversal probability

## Statistics reported (if multiple groups)
* Logistic regression comparing initial reversal probability between groups.
* Logistic regression comparing final reversal probability between groups.


## How to use it

* Set working directory to project's root directory

* Call habituation_probability_driver.sh from the Bash Shell

* habituation_probability_driver.sh requires the following arguments from the user: 
(1) path to chore.jar (offline analys program Choreography), (2) gigabytes of memory to 
be used to run Choreography (dependent upon the machine you are using, (3) type of 
stimulus, (4) path to data.srev, (5) time to stimulus onset, (6) number of stimuli and 
(7) interstimulus interval. 
See example below:

~~~
bash bin/habituation_probability_driver.sh /Users/this_user/Chore.jar tap data/Figure1/data.srev 8 100 30 10
~~~

* More instructions to come as code is developed further.