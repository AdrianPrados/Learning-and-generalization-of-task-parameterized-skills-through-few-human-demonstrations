function  map = dataFML(r,model, nbSamples)

    %% PARAMETERS
    n = 1;% Number of demonstrations.
    sat = 0.5;% Saturation, between 0 and 1.
    aoi_size = 15;% Pixels of the area of influence.
    limAxes = [-1.2 0.8 -1.1 0.9];
%     limAxes = [-1 1 -1 1];
    colPegs = [0.2863 0.0392 0.2392; 0.9137 0.4980 0.0078];
    p =[];

    %% GENERATION OF THE MAP
    for n=1:nbSamples
        %Plot frames
        for m=1:model.nbFrames
            variable = plotPegs(r(n).p(m), colPegs(m,:),0.6,"on");
            pause()
        end
    end
    %saveas(variable,'map.png')
%     print('map.png','-dpng')
    axi = axis;
    f=gca;
    set(gca,'xtick',[],'ytick',[]);
    exportgraphics(f,'map.png','ContentType','image')
    
    map = imread('map.png');
    map = rgb2gray(map);
    map= imbinarize(map);
    map = flipdim(map,1);
    [sizeX,sizeY] = size(map);
    
    figure(3)
    imshow(map)                                 
    %%
    % Simulation of kinesthetic teaching.
    % Con esto se rellena el path
    % Comentar para cargar el LASA
%     for k=1:n
%         dataset = kinesthetic_teaching (map', p);
%         p = [p dataset]; % This line is just to help plotting previous points.
%         demos{k} = dataset; 
%     end
    
    for k= 1:nbSamples
        for i =1:length(r(1).Data)
%             if i == 1
%               r(1).Data(1,i) = interp1([axi(1) axi(2)],[0.5 sizeY],r(1).Data(1,i));
%               r(1).Data(2,i) = interp1([axi(3) axi(4)],[0.5 sizeX],r(1).Data(2,i));
%             end
              r(1).Data(1,i) = interp1([axi(1) axi(2)],[0.5 sizeY],r(1).Data(1,i));
              r(1).Data(2,i) = interp1([axi(3) axi(4)],[0.5 sizeX],r(1).Data(2,i));

        end
        demosPrev = r.Data;
        dataset = kinesthetic_teaching (map', demosPrev);
        figure(3)
        hold on
        plot(r(1).Data(1,1),r(1).Data(2,1),'r*');
        hold off
        X=[];
        Y=[];
        for i=1:length(r(1).Data)
        X= [X;interp1([0.5 sizeY],[axi(1) axi(2)],r(1).Data(1,i))];
        Y = [Y;interp1([0.5 sizeX],[axi(3) axi(4)],r(1).Data(2,i))];
        end
        demos{k}=demosPrev;
    end
%     figure(100)
%     imshow(flipdim(map,1))
%     hold on
%     plot(dataset(2,:), dataset(1,:),'-b');
%     pause()
    % Executing the FML algorithm.
    %disp(demos{1})
    disp(r(1).Data)
    [F, T, end_point, dx, dy] = FML(map, demos, sat, aoi_size);
    
    % To see the velocity matriz representation
    figure(200)
    imshow(F')
    
    % Getting some reproductions from the initial poitns of the demos.
    for i = 1:n
        start_point = demos{i}(:,1);
        path = compute_geodesic(T, round(start_point));
        starts(:, i) = start_point;
        paths{i} = path;
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
        f = plot(starts(1,i),starts(2,i),'k.','markersize',30);
    end
    
    for i = 1:n
        g = scatter(demos{i}(1,:),demos{i}(2,:),'.r');
    end
    
    plot(end_point(1),end_point(2),'k*','markersize',15,'linewidth',3);
    
    set(gca,'xtick',[], 'ytick',[]);
    hold off;
    axis image




end