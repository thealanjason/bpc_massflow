# Bayesian Parameter Calibration for Mass Flow Models

This lab is used to calibrate the parameters of a Mass Point Model (MPM) using Markov-chain Monte Carlo method.

## Pre-requisites
In order to use containers (apptainer) for certain computational units, we first need to build them. This can be done by running the following command

```
cd  <computational_unit>
apptainer build <computational_unit>.sif <coomputational_unit.def>
cd ..
```

An example for the `lhs` computational unit is shown below. 
```
cd lhs
apptainer build lhs.sif lhs.def
cd ..
```

## Running the Workflow
We use `nextflow` to run this usecase which is specified through the SHOWME.how file. 

1. Create and activate the conda environment
```
conda env create -f environment.yml
conda activate showmehow
```

2. Run the workflow

```
nextflow run SHOWME.how -params-file params.yml
```
