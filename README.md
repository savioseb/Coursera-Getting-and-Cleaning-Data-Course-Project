---
title: "ReadMe Document for Getting and Cleaning Data Course Project"
author: "Savio Sebastian"
date: "February 22, 2015"
output: html_document
---

<br>
<br>

## Introduction
This is a part of the course work project submission for 'Getting and Cleaning Data'.

## How to Run

* The file <code>run_analysis.R</code> can be downloaded and loaded into the environment using the <code>source</code> command (The output of the execution is given below for your reference).

* It will automatically start Download of the Data Set file from: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

* The script will then extract the contents of the zip file <code>(getdata-projectfiles-UCI HAR Dataset.zip)</code> and create a folder in the working directory called <code>UCI HAR Dataset</code>.

* After running through a couple of transformations the <B>tidy dataset</B> will be produced and written to file: <code>tidy.txt</code>

* Information regarding the transformations done on the raw dataset is explained in the <code>CodeBook.md</code>.

## Reference Output


```{r loadingScript, cache=TRUE}

source( "run_analysis.R")

```




<br>
<br>