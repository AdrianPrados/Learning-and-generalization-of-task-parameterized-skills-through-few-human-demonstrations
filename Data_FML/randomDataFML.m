%% Random Data FML generator
% This function generates the synthetica data using Fast Marching Learning
% algorithm.
% Prados, A., Mora, A., López, B., Muñoz, J., Garrido, S., & Barber, R. (2023). 
% Kinesthetic Learning Based on Fast Marching Square Method for Manipulation. Applied Sciences, 13(4), 2028.
function [pathCorrected,sCopy] = randomDataFML(r,s, model, nbData, nbSamples)
    %% PARAMETERS FOR FML
    n = length(s);% Number of demonstrations.
    sat = 0.7;% Saturation, between 0 and 1.
    aoi_size = 20;% Pixels of the area of influence.
    colPegs = 'red';
    p =[];
    val = 1;
    %% GENERATION OF RANDOM POSE
    lim_x = [-1.2, 0.8];          % X limits
    lim_y = [-1.1, 0.9];          % Y limits
    posicion = [rand()*(lim_x(2)-lim_x(1))+lim_x(1);rand()*(lim_y(2)-lim_y(1))+lim_y(1);0];% Posición aleatoria en el plano XY
    
%     random_number = 2 * rand() - 1;
    angulo = deg2rad(rand() * (225 - 45) + 45);         % Random angle for orientation
    rotacion = [1,0,0,0;
        0,cos(angulo),-sin(angulo), posicion(1);
        0, sin(angulo),cos(angulo),posicion(2);
        0,0,0,1];  % Matriz de rotación alrededor del eje X
%     rotacion
    r(1).p(2).A = rotacion(1:3,1:3);
    r(1).p(2).b = rotacion(1:3,4);


    %% GENERATION OF THE MAP
    for n=1:nbSamples
        %Plot frames
        for m=1:model.nbFrames
            if m>1
                colPegs = 'blue';
            end
            variable = plotPegs(r(n).p(m), colPegs,0.6,"on");

        end
        variable.Vertices = (variable.Vertices)/3;
        r(1).p(2).b(2) = r(1).p(2).b(2) / 3;
        r(1).p(2).b(3) = r(1).p(2).b(3) / 3;
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
    
    figure(1)
    hold on
    plot(r(1).p(1).b(2),r(1).p(1).b(3),'b*')
    plot(r(1).p(2).b(2),r(1).p(2).b(3),'g*')
    hold off
    
    figure(3)
    imshow(map) 
    
    %% GENERATION OF DATA VIA FML
    ini_x = interp1([axi(1) axi(2)],[0.5 sizeY],r(1).p(1).b(2));
    ini_y = interp1([axi(3) axi(4)],[0.5 sizeX],r(1).p(1).b(3));
    fin_x = interp1([axi(1) axi(2)],[0.5 sizeY],r(1).p(2).b(2));
    fin_y = interp1([axi(3) axi(4)],[0.5 sizeX],r(1).p(2).b(3));
    start = [ini_x ini_y];
    goal = [fin_x fin_y];
    figure(3)
    hold on
    plot(ini_x,ini_y,'r*')
    plot(fin_x,fin_y,'g*')
    hold off
%     demos{1} = [[r(1).p(1).b(2),r(1).p(1).b(3)];[r(1).p(2).b(2),r(1).p(2).b(3)]];
    demos{val} = [[ini_x fin_x];[ini_y fin_y]];
    for i=1:length(s)
        val=val+1;
        dataX = interp1([axi(1) axi(2)],[0.5 sizeY],s(i).Data0(2,:));
        dataY = interp1([axi(3) axi(4)],[0.5 sizeX],s(i).Data0(3,:));
        demos{val} = [dataX;dataY];   
    end

    [F, T, end_point, dx, dy] = FML (map, demos, sat, aoi_size);
    figure(200)
    imshow(F')
    
    for i = 1:val
        start_point = demos{i}(:,1);
        [D,~] = perform_fast_marching(F,goal');
        path = compute_geodesic(D, start_point);
        starts(:, i) = start_point;
%         if i == 1
%             path(:,end)= [end_point(1);end_point(2)]; 
%         end
        paths{i} = path(:,1:end);
    end

    % Plotting results.
    imagesc(map);
    colormap gray(256);
    hold on;
    axis xy;
    box on;
    h = streamslice(-dx,-dy); % Reproductions field with stream lines.
    set(h,'color','b');
    
    for i = 1:length(paths)  
        ff = plot(paths{i}(1,:),paths{i}(2,:),'b','LineWidth',3);
        f = plot(starts(1,i),starts(2,i),'g.','markersize',30);
    end
    
    for i = 1:n
        hold on
        g = scatter(demos{i}(1,:),demos{i}(2,:),'.r');
    end
    
    plot(goal(1),goal(2),'r*','markersize',15,'linewidth',3);
    
    set(gca,'xtick',[], 'ytick',[]);
    hold off;
    axis image
    %% Only need length of the data demonstrated
    n = length(path); % Original path
    t_old = linspace(0, 1, n); 
    t_new = linspace(0, 1, 200); 
    
    % Interpolation of the points
    spl = spline(t_old, path);
    path_new = ppval(spl, t_new);
    path_x = interp1([0.5 sizeY],[axi(1) axi(2)],path_new(1,:));
    path_y = interp1([0.5 sizeX],[axi(3) axi(4)],path_new(2,:));
    pathCorrected = [path_x;path_y];
%     figure(1);
%     hold on;
%     plot(path_x,path_y,'b');

    % Create a copy of s to generate the GMM
    sCopy.p = s(1).p(1);
    sCopy.Data = s(1).Data(2:3,:);
    sCopy(1).p(1).A = r(1).p(1).A;
    sCopy(1).p(1).b = r(1).p(1).b;
    sCopy(1).p(2).A = r(1).p(2).A;
    sCopy(1).p(2).b = r(1).p(2).b;
    sCopy(1).Data(1,:) = path_x;
    sCopy(1).Data(2,:) = path_y;

    
end