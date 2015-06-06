# Habituation probability

This software will allow you to plot habituation probability graphs and generate 
statistical comparisons between groups (if there are multiple groups) using data from the
Multi-worm tracker (MWT; Swierczek et al., 2011). 


## Figures it generates
* Reversal probability versus stimulus (plotted on x-axis as time of presentation)
* 95% confidence intervals (Clopper Pearson method) for reversal probability

## Statistics reported (if multiple groups)
* Logistic regression comparing final reversal probability between groups.


## How to use it

### Installation Dependencies

`Java`, `R`, R packages `ggplot2`, `plyr`, and `stringr`, and the Multi-worm Tracker 
Analysis software (`Chore.jar`) as a shell script in the executable path named `Chore`. 
To "easily" do this on a Mac or Linux OS, please follow the following installation 
instructions:

#### For Mac OSX
1. Install Homebrew by typing the following into the command line:

	`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
	
	
2. Install the Multi-worm Tracker Analysis software via Homebrew to install Chore.jar and
have it accesible as a shell script in the executable path named "Chore":
	`brew install homebrew/science/multi-worm-tracker`


#### For Linux
1. Install Linuxbrew by typing the following into the command line:

	`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"`


2. Put brew in your executable path by adding the commands below to either `.bashrc` or 
`.zshrc`: 
	~~~
	export PATH="$HOME/.linuxbrew/bin:$PATH"
	export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
	export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
	~~~

3. Install the Multi-worm Tracker Analysis software via Homebrew to install Chore.jar and
	have it accesible as a shell script in the executable path named `Chore`:
	`brew install homebrew/science/multi-worm-tracker`


### Running the analysis

* Put your unzipped MWT experiment folders inside an experiment directory in the project's 
data directory

* In the Shell, set the working directory to project's root directory 
(`Habituation_probability/`)

* Call `bin/habituation_probability_driver.sh` from the Bash Shell

* `habituation_probability_driver.sh` requires the following arguments from the user: 
(1) gigabytes of memory to be used to run Choreography (dependent upon the machine you are 
using, (2) type of stimulus and (4) relative path to the directory where your data is 
stored (e.g., `data/Experiment_1`).

 
See example below:

~~~
bash bin/habituation_probability_driver.sh 4 puff data/Experiment_1
~~~
