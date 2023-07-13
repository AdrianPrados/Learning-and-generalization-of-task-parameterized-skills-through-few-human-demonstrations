%% Generator of synthetic data using only a few human demonstration

clear models
addpath('./m_fcts/');
addpath('./additional_fcts/');
addpath(genpath('Data_FML'));
addpath(genpath('CostFunctions'));
addpath('FastMarchingToolbox/');
addpath(genpath('Demonstrations'));

% Function call python
commandStr = 'python CostFunctions/CostF.py';

%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model.nbStates = 20; %Number of Gaussians in the GMM
model.nbFrames = 2; %Number of candidate frames of reference
model.nbVar = 3; %Dimension of the datapoints in the dataset (here: t,x1,x2)
model.params_diagRegFact = 1E-4; %Optional regularization term
nbData = 200; %Number of datapoints in a trajectory
tStart = tic;

%% Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Load 3rd order tensor data...');
% s(n).Data0 is the n-th demonstration of a trajectory of s(n).nbData datapoints, with s(n).p(m).b and 's(n).p(m).A describing
% the context in which this demonstration takes place (position and orientation of the m-th candidate coordinate system)
load(['Demonstrations/Demos.mat']);
% Observations from the perspective of each candidate coordinate system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data' contains the observations in the different coordinate systems: it is a 3rd order tensor of dimension D x P x N, 
% with D=3 the dimension of a datapoint, P=2 the number of candidate frames, and N=TM the number of datapoints in a 
% trajectory (T=200) multiplied by the number of demonstrations (M=5)
Data = zeros(model.nbVar, model.nbFrames, nbSamples*nbData);
for n=1:nbSamples
	s(n).Data0(1,:) = s(n).Data0(1,:) * 1E-1;
end
Data = get_the_data_for_training(s, model, nbSamples, nbData); % Obstain data for training
%% TP-GMM learning with augmentation using synthetic data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Parameters estimation of TP-GMM with EM:');
model = init_tensorGMM_timeBased(Data, model);
model = getTPGMM(Data, model);
model_init = model;
init_nbSamples = nbSamples;
%% Compute the cost for the initial model (just using human demonstration)
[cost, r] = GMRrepo(s, model_init, nbData, init_nbSamples);
% plot_repo(r, model_init, init_nbSamples, 'Reproduction by original TP-GMM',"ignored")
% plot_current_GMM_in_two_frames(Data, model, s, nbSamples, init_nbSamples);
%% Generation of new situations
iteration = 1;
list_of_cost = cost;
% plot_repo(r, model, nbSamples)
while nbSamples < 10 && iteration < 200
    [dataFML,new_data] = randomDataFML(r,s,model,nbData,1); % Genertaes random initial and end point and the path using human demonstrations
%     figure();
%     plot_repo(new_data, model, 1,'Reproduction of New data')
%     plot_repo(new_data, model, 1,'Reproduction of New data');
    
    % Augment the dataset
    [s, nbSamples] = dataset_aggre(s, new_data, nbSamples);
    % Retrain TPGMM using augmented dataset
    Data = get_the_data_for_training(s, model, nbSamples, nbData);
    model_new = init_tensorGMM_timeBased(Data, model); 
    model_next = getTPGMM(Data, model_new);
    % Compute the cost of new dataset
    [cost_next, r] = GMRrepo(s, model_next, nbData, nbSamples);
    cost_next
    cost 
%     plot_repo(r, model, nbSamples)
    %Comaparison of previous cost and next cost
    if prod(abs(cost_next) <= abs(cost))
        fprintf('Cost reduction: %d \n', cost_next - cost);
        fprintf('New demonstration data added. \n');
        model = model_next; % new TPGMM model
        cost = cost_next;
        list_of_cost = [list_of_cost, cost_next];
%         plot_current_GMM_in_two_frames(Data, model, s, nbSamples, init_nbSamples);
    else
        [s, nbSamples] = remove_last_element(s, nbSamples); % remove the last data
    end
    iteration = iteration + 1;
    close all;
end
%% Result comparison
close all;
[cost, r2] = GMRrepo(s, model, nbData, nbSamples);
plot_repo(r2, model, nbSamples, 'Reproduction by TP-GMM with augmented dataset',"normal")
title("Initial values")
models(1) = model_init;
models(2) = model;
% plot_demo(s, model, init_nbSamples, nbSamples)
fprintf('Total number of generated demonstrations added: %i \n', nbSamples - init_nbSamples);
nb_new_situations = 1;
compare_orig_n_improved_models(s, models, nbData, nb_new_situations);
title('TP-GMM in new sits, black: Original, red: Improved')
% [dataFML,new_situations] = randomDataFML(r,s,model,nbData,1);
% plot_repo(new_situations, model, nb_new_situations, 'Reproduction by TP-GMM with augmented dataset')
tEnd = toc(tStart)
