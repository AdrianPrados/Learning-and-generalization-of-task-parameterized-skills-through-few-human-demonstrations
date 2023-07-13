%% Script for the data generation
% This script allow the useer to generate new datasets in an easy way based
% on the original dataset.
% Load the model
model.nbStates = 5; %Number of Gaussians in the GMM
model.nbFrames = 2; %Number of candidate frames of reference
model.nbVar = 3; %Dimension of the datapoints in the dataset (here: t,x1,x2)
model.params_diagRegFact = 1E-4; %Optional regularization term
mode = "normal";
nbData = 200; %Number of datapoints in a trajectory
load('Demos.mat');
Data = zeros(model.nbVar, model.nbFrames, nbSamples*nbData);
for n=1:nbSamples
	s(n).Data0(1,:) = s(n).Data0(1,:) * 1E-1;
end
Data = get_the_data_for_training(s, model, nbSamples, nbData);
model = init_tensorGMM_timeBased(Data, model);
model = getTPGMM(Data, model);
model_init = model;
init_nbSamples = nbSamples;

colPegs = 'red';
[cost, r] = GMRrepo(s, model_init, nbData, init_nbSamples);

%% PARAMETERS
nbSamples = 3; % Number of data to be collected
sCopy = s;
for y=1:nbSamples
    
    %     n = length(s);% Number of demonstrations.
    sat = 0.9;% Saturation, between 0 and 1.
    aoi_size = 30;% Pixels of the area of influence.
    colPegs = 'red';
    p =[];
    val = 1;
    %% GENERATION OF RANDOM POSE
    lim_x = [-1.2, 0.8];          % Límites de posición en X
    lim_y = [-1.1, 0.9];          % Límites de posición en Y
    posicion = [rand()*(lim_x(2)-lim_x(1))+lim_x(1);rand()*(lim_y(2)-lim_y(1))+lim_y(1);0];% Posición aleatoria en el plano XY
    %angulo = deg2rad(rand() * (225 - 45) + 45);         % Ángulo aleatorio en radianes
    if y ==1
        angulo = deg2rad(100);
    elseif y==2
        angulo = deg2rad(45);
    elseif y==3
        angulo = deg2rad(215);
%     elseif y==4
%         angulo= deg2rad(85);   
    end
    rotacion = [1,0,0,0;
        0,cos(angulo),-sin(angulo), posicion(1);
        0, sin(angulo),cos(angulo),posicion(2);
        0,0,0,1];  % Matriz de rotación alrededor del eje X
    %     rotacion
    r(1).p(2).A = rotacion(1:3,1:3);
    r(1).p(2).b = rotacion(1:3,4);

    %% GENERATION OF THE MAP
    for n=1:1
        %Plot frames
        for m=1:2
            if m > 1
                colPegs = 'blue';
            end
            variable = plotPegs(r(n).p(m),colPegs,"on");
        end
        variable.Vertices = (variable.Vertices)/3;
%         r(1).p(2).b(2) = r(1).p(2).b(2)/3 ;
%         r(1).p(2).b(3) = r(1).p(2).b(3)/3;
    end
    axi = axis;
    f=gca;
    set(gca,'xtick',[],'ytick',[]);
    exportgraphics(f,'map.png','ContentType','image')

    map = imread('map.png');
    map = rgb2gray(map);
    map= imbinarize(map);
    map = flipdim(map,1);
    [sizeX,sizeY] = size(map);

    for k=1:n
        dataset = kinesthetic_teaching (map', p);
        p = [p dataset]; % This line is just to help plotting previous points.
        demos{k} = dataset;
        starts(:, k) = demos{k}(:,1);
    end
%     % Executing the FML algorithm.
%     [F, T, end_point, dx, dy] = FML(map, demos, sat, aoi_size);
%     % To see the velocity matriz representation
%     figure()
%     imshow(F')
% 
%     n=1;
%     % Getting some reproductions from the initial poitns of the demos.
%     for i = 1:n
%         start_point = demos{i}(:,1);
%         path = compute_geodesic(T, round(start_point));
%         starts(:, i) = start_point;
%         paths{i} = path(:,1:end);
%     end

    % Plotting results.
    imagesc(map);
    colormap gray(256);
    hold on;
    axis xy;
    box on;
%     h = streamslice(-dx,-dy); % Reproductions field with stream lines.
%     set(h,'color','b');

    for i = 1:length(demos)
        ff = plot(demos{i}(1,:),demos{i}(2,:),'b','LineWidth',3);
        f = plot(starts(1,i),starts(2,i),'k.','markersize',30);
    end

%     for i = 1:n
%         g = scatter(demos{i}(1,:),demos{i}(2,:),'.r');
%     end

%     plot(end_point(1),end_point(2),'k*','markersize',15,'linewidth',3);

    set(gca,'xtick',[], 'ytick',[]);
    hold off;
    axis image

    %% Convert the  values
    n = length(demos{1}); % Original path
    t_old = linspace(0, 1, n);
    t_new = linspace(0, 1, 200);

    % Interpolation of the points
    spl = spline(t_old, demos{1});
    path_new = ppval(spl, t_new);
    path_x = interp1([0.5 sizeY],[axi(1) axi(2)],path_new(1,:));
    path_y = interp1([0.5 sizeX],[axi(3) axi(4)],path_new(2,:));
    path_x(1,1)= -0.8;
    path_y(1,1)= -0.8;
    pathCorrected = [path_x;path_y];


    %% Load the values in the matrix
    sCopy(y).p(2).A = r(1).p(2).A;
    sCopy(y).p(2).b = [0;path_x(1,200);path_y(1,200)];
    sCopy(y).Data0(1,:) = sCopy(y).Data(1,:);
    sCopy(y).Data0(2,:) = path_x;
    sCopy(y).Data0(3,:) = path_y;
    sCopy(y).Data(2,:) = path_x;
    sCopy(y).Data(3,:) = path_y;
    sCopy(y).nbData = length(pathCorrected);
    pause()
    close all;
end