# Data Science and Analytics Portfolio

Welcome to my Data Science and Analytics Portfolio! This repository showcases a collection of projects that demonstrate my skills in data analysis, machine learning, and algorithm development. Each project highlights my ability to work with complex datasets, apply advanced analytical techniques, and derive meaningful insights.

## Table of Contents
- [Chicago Crime Analysis](#chicago-crime-analysis)
- [Isle Royale Wolf-Moose Population Analysis](#isle-royale-wolf-moose-population-analysis)
- [Point Cloud Processing using Point Feature Histograms](#point-cloud-processing-using-point-feature-histograms)

## Chicago Crime Analysis
### Overview
This project explores crime data in Chicago from 2015 to 2022, focusing on data visualization and analysis to uncover trends and patterns in criminal activities.

### Key Features
- Data cleaning and preprocessing
- Visualization of crime numbers over time
- Analysis of crime types and their proportions
- Crime distribution across different districts and community areas
- Investigation of arrest rates across districts

### Tools and Technologies
- MATLAB for data visualization and analysis
- Python for data preprocessing and cleaning

### Insights
- Crime numbers have shown a relatively steady trend with a noticeable drop during the pandemic years.
- Theft, battery, and criminal damage are the most prevalent types of crimes.
- Crime distribution is more concentrated in central areas of Chicago.
- Arrest rates vary significantly across districts, indicating potential issues in law enforcement efficiency.

### Files
- [Matlab_Project_Report.pdf](Matlab_Project_Report.pdf): Detailed project report.
- [Chicago_Crime_Data.csv](Chicago_Crime_Data.csv): Dataset used for analysis.

## Isle Royale Wolf-Moose Population Analysis
### Overview
This project analyzes the population dynamics of wolves and moose on Isle Royale, exploring the relationships between predator and prey populations and environmental factors.

### Key Features
- Data cleaning and creation of codebooks
- Exploratory data analysis (EDA) of population trends and environmental variables
- Hypothesis testing and confidence interval estimation
- Linear regression and classification models to predict population dynamics

### Tools and Technologies
- Python with libraries such as Pandas, NumPy, Matplotlib, Seaborn, Statsmodels, and Scikit-learn

### Insights
- There is a moderate negative linear relationship between kill rate and wolf population.
- Moose have a shorter lifespan on Isle Royale compared to their natural lifespan, likely due to predation and harsh environmental conditions.
- Moose number is positively correlated with wolves number and kill rate, and negatively correlated with predation rate and moose recruitment rate.
- Classification models can predict wolves number based on year, moose number, and kill rate with reasonable accuracy.

### Files
- ["final_project_ipynb"的副本.py](“final_project_ipynb”%E7%9A%84%E5%89%AF%E6%9C%AC.py): Python script for data analysis.
- [wolf_moose_yearly.csv](wolf_moose_yearly.csv): Dataset containing yearly counts of wolf and moose populations.
- [moose_deaths.csv](moose_deaths.csv): Dataset containing information about moose deaths.

## Point Cloud Processing using Point Feature Histograms
### Overview
This project introduces optimizations to the traditional Point Feature Histogram (PFH) method for point cloud alignment, enhancing its efficiency and scalability for real-time applications and large-scale datasets.

### Key Features
- Implementation of the PFH method with optimizations such as fast PFH computation, flattened histograms, logarithmic-scaled queries, adaptive filtering, and improved ICP recalculations
- Evaluation of different optimization techniques on point clouds of varying sizes
- Application to real-life room scan data

### Tools and Technologies
- Python for algorithm implementation and optimization
- Visualization tools for point cloud alignment

### Insights
- Optimized PFH algorithms significantly reduce computational complexity and improve alignment accuracy.
- Adaptive filtering techniques enhance robustness to noise and improve processing speed.
- The improved ICP method achieves high-precision alignment suitable for complex objects.

### Files
- [422_report.pdf](422_report.pdf): Detailed project report.
- [query_improved.py](query_improved.py): Core implementation of optimized PFH and ICP alignment.
- [utility.py](utility.py): Utility functions for point cloud processing.
- [timer.py](timer.py): Timer class for performance measurement.
- [filter.py](filter.py): Functions for feature filtering.
- [proj_bin_improved.py](proj_bin_improved.py): Implementation of one-dimensional FPFH histograms.
- [proj_fpfh.py](proj_fpfh.py): Original FPFH computation.
- [proj_pfh.py](proj_pfh.py): Original PFH computation.
- [demo.py](demo.py): Demonstration script for room scan alignment.

## Conclusion
This portfolio highlights my proficiency in various aspects of data science and analytics, from data visualization and statistical analysis to algorithm development and optimization. These projects demonstrate my ability to tackle complex problems, derive actionable insights, and implement efficient solutions. I am excited to bring these skills to a data science or analytics role and contribute to impactful projects.

Feel free to explore the code and reports in this repository. If you have any questions or would like to discuss further, please reach out to me at [liuxt@umich.edu](mailto:liuxt@umich.edu).

Thank you for visiting my portfolio!
