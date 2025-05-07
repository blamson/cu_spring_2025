# Math 7393 - Bayesian Statistics - Final Project

The goal of this project is to take publicly available data, analyze it, and use that data to create a logistic regression model from a bayesian perspective.

# Research Question

I want to understand the interplay of various predictors of an individuals poverty status according to the Supplemental Poverty Measure (SPM). We know of many usual predictors of poverty; age, education, state of residence, etc. On their own that may not be too interesting, however, I think there is a lot of value in examining the relationship between these predictors in determining an SPM poverty classification. As an example, say we hold an individuals out-of-pocket medical expenses fixed, how much of an impact does education or age play into a possible poverty classification? As another example, say we have two 70 year olds. How much influence does marital status have on poverty? Is an older adult who is single at more or less risk of poverty than someone who was widowed? If two people have the same adjusted gross income, does race still play an important part in risk of poverty due to other factors? 

Using this information, I intend to estimate the probability that an individual is classified as poor according to the SPM. I also intend to identify which variables are the most influential in making this prediction.

Note: For more information on the supplemental poverty measure here is information from the Census Bureau: [Link](https://www.ssa.gov/policy/docs/ssb/v75n3/v75n3p55.html)

Here is a general motivation for using the SPM versus the official measure taken from that link.

> Critics of the official measure point out that the official income or resource measure fails to account for noncash government benefits, taxes, medical out-of-pocket (MOOP) expenses, and work expenses. Those critics also point out that the official thresholds are a very narrow measure of necessary expenditures—that is, food—and are based on very old data. They argue that the official thresholds also fail to adjust for geographic differences in the cost of living, and that the official measure's unit of analysis (the Census-defined family) is too narrow.


# Main Dataset

For this project I opted to use one of the many research datasets provided by the Census Bureau themselves [found here](https://www.census.gov/data/datasets/time-series/demo/supplemental-poverty-measure/acs-research-files.html). The data I'm using includes a variety of information the bureau uses in their SPM classification. I am exclusively using their table from 2023.

## Directory Navigation

I tried to keep this simple. 

- `/data/`: Contains two things. First is a version of the dataset found above that is much smaller and compressed. For the original dataset you will need to follow the link. It's over a gig in size so it is absolutely not being kept here.

- `/notebooks/`: Contains all of my work. From EDA to modeling to assessment, it's all there in their corresponding quarto files.

- `/scripts/`: Used for helper functions to make my code less of a total nightmare.

# Usage guide

As this is simply a class project I do not have an RENV setup. Installation of necessary libraries is left to the user. All necessary libraries will be at the top of each respective notebook.

All notebooks are intended to be ran top to bottom in isolation. It is recommended, though not necessary, to wipe the local environment variables before running other notebooks. There should be no risk of other notebooks interfering with output, though I make no guarantees of this. However, I do not prioritize consistency in my variable naming in this repository so if one does not take my recommendation your environment namespace will become unwieldy.