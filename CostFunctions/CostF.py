import torch
import numpy as np
from geomloss import SamplesLoss
import pandas as pd

def WassersDistance(X, Y):
    Loss =  SamplesLoss("sinkhorn",p=1, blur=0.05, reach =1 )
    return Loss( X, Y ).item()
def EnergyDistance(X, Y):
    Loss =  SamplesLoss("energy",p=1, blur=0.05, reach =1)
    return Loss( X, Y ).item()

def main():
    #? Read data from csv file
    A_x = pd.read_csv('/home/adrian/Escritorio/LearningFromFewDemonstration/learning-tp-skills-from-few-demos-main/CostFunctions/Xmat1.csv',header=None).to_numpy()
    A_y = pd.read_csv('/home/adrian/Escritorio/LearningFromFewDemonstration/learning-tp-skills-from-few-demos-main/CostFunctions/Xmat2.csv',header=None).to_numpy()
    B_x = pd.read_csv('/home/adrian/Escritorio/LearningFromFewDemonstration/learning-tp-skills-from-few-demos-main/CostFunctions/Ymat1.csv',header=None).to_numpy()
    B_y = pd.read_csv('/home/adrian/Escritorio/LearningFromFewDemonstration/learning-tp-skills-from-few-demos-main/CostFunctions/Ymat2.csv',header=None).to_numpy()
    """ print(A_x) """
    mode = 'Wasserstein'
    X1 = torch.tensor(A_x)
    X1=torch.reshape(X1,(-1,))
    X2 = torch.tensor(A_y)
    X2=torch.reshape(X2,(-1,))
    Y1 = torch.tensor(B_x)
    Y1=torch.reshape(Y1,(-1,))
    Y2 = torch.tensor(B_y)
    Y2=torch.reshape(Y2,(-1,))
    X =torch.stack((X1,X2), 0)
    Y =torch.stack((Y1,Y2),0)


    if mode == 'Wasserstein':
        Solution = WassersDistance(X, Y)
    elif mode == 'Energy':
        Solution = EnergyDistance(X, Y)
    else:
        print("Error: Invalid mode, using Wasserstein instead")
        Solution = WassersDistance(X, Y)
        
    return Solution

if __name__ == "__main__":
    Sol = main()
    print(Sol)

