# **Learning and generalization of task-parameterized skills through few human demonstrations.**

<p align="center">
  <img src="./Images/Group 52.jpg" height=200 />
</p>

In this paper, we introduce a groundbreaking concept that enriches the original training dataset with synthetic data, thereby enabling significant improvements in policy learning. Consequently, this novel approach empowers the acquisition of task-parameterized skills with a limited number of demonstrations, paving the way for enhanced practicality. The final result of this work is to present a real application in the field of aid to dependent persons. For this purpose, tests have been carried out for the task of sweeping an area by our manipulator robot ADAM, through a few demonstrations captured by a human demonstrator.

# Installation
To be used on your device, follow the installation steps below.

**Requierements:**
- Python 3.10.0 or higher
- numpy
- geomloss
- pandas
- torch
- Matlab 2021b or higher


## Install miniconda (highly-recommended)
It is highly recommended to install all the dependencies on a new virtual environment. For more information check the conda documentation for [installation](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) and [environment management](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html). For creating the environment use the following commands on the terminal.

```bash
conda create -n SyntheticLearning python==3.10.9
conda activate SyntheticLearning
```

## Install from source
Firstly, clone the repository in your system.
```bash
git clone https://github.com/AdrianPrados/Learning-and-generalization-of-task-parameterized-skills-through-few-human-demonstrations.git
```
Then, enter the directory and install the required dependencies
```bash
cd SyntheticLearning
pip install -r requirements.txt
```

# Description

In this repository a description of the algorithm used in the paper is presented. The algortihm is based on the extraction of the characteristics for human few demonstrations. The code is divided in diferente folders:

[```m_fcts```](./m_fcts/) folder contains key functions extracted from [PbDlib](https://gitlab.idiap.ch/rli/pbdlib-matlab/). (MATLAB version)

[```additional_fcts```](./additional_fcts/) folder contains additional functions to implement the algorithm described in the paper. Those functions as been generated based on the code in [PbDlib](https://gitlab.idiap.ch/rli/pbdlib-matlab/). (MATLAB version)

[```Demonstrations```](./Demonstrations/) folder contains different demonstrations to start the learning process without the necessity to generate new data.

[```CostFunctions```](./CostFunctions/) folder contains the [```CostF.py```](./CostFunctions/CostF.py) script that allows the method to estimate the p-Wassersteins value for the cost function.

[```Data_FML```](./Data_FML/) folder contains the code used to extract the characteristics from the demonstrations. (Python version)

# Executing program
If you want to launch the method with some of the demonstrations recorded, just have to run the following command in the MATLAB console:

```matlab
SyntheticDataGenerator.m
```
You can change the different values of the algorithm in the [```SyntheticDataGenerator.m```](./SyntheticDataGenerator.m) script.

If you want to generate your own demonstrations run in the MATLAB console:

```matlab
GenerateDemonstrations.m
```
At the start the algorithm will load a map that will randomly generate the orientation and position of the endpoint and by clicking on the screen you can take data to obtain your own dataset. Once finished you must store the ```sCopy``` values and the number of ```nbSamples``` data in a single .mat which you can load into the [```SyntheticDataGenerator.m```](./SyntheticDataGenerator.m) script. The results of that proccess is shown in the following image:

<p align="center">
  <img src="./Images/Frame 8.jpg" height=120 />
</p>


The code was written and tested on MATLAB 2021b in Ubuntu 20.04. The final swept task using the ADAM robot is presented in this [video](https://youtu.be/pD1HdoWJmfs).

# Citation
This work has been done by [Adrián Prados](http://roboticslab.uc3m.es/roboticslab/people/prados). If you use this code or the data please cite the following papers:

### Paper for KFML data generator 
```bibtex
@article{prados2023kinesthetic,
  title={Kinesthetic Learning Based on Fast Marching Square Method for Manipulation},
  author={Prados, Adri{\'a}n and Mora, Alicia and L{\'o}pez, Blanca and Mu{\~n}oz, Javier and Garrido, Santiago and Barber, Ram{\'o}n},
  journal={Applied Sciences},
  volume={13},
  number={4},
  pages={2028},
  year={2023},
  publisher={MDPI}
}
```
### Paper for the algorithm
```bibtex
@article{prados2024learning,
  title={Learning and generalization of task-parameterized skills through few human demonstrations},
  author={Prados, Adrian and Garrido, Santiago and Barber, Ramon},
  journal={Engineering Applications of Artificial Intelligence},
  volume={133},
  pages={108310},
  year={2024},
  publisher={Elsevier}
}
```

## Acknowledgement
This work was supported by RoboCity2030 DIH-CM (S2018/NMT-4331, RoboCity2030 Madrid Robotics Digital Innovation Hub) and by the project PLEC2021-007819 financed by MCIN/AEI /10.13039/501100011033 and by UE NextGenerationEU/PRTR


