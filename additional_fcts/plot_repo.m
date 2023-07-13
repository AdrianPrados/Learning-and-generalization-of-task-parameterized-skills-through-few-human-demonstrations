function plot_repo(r, model_, nbSamples, figure_title,mode, m, color)
nargin
    if nargin < 5
        figure;
        color = 1;
        mode = "reduced";
    else
        figure;
        color = 1;

    end

%     title(figure_title);
    hold on; box off;
    switch color
        case 1
            xx = round(linspace(1,64, nbSamples));
        case 2
            xx = round(linspace(192,256, nbSamples));
        case 3
            xx = round(linspace(129,192, nbSamples));
        case 4
            xx = round(linspace(65,128, nbSamples));    
    end
    clrmap = colormap('jet');
    clrmap = min(clrmap(xx,:),.95);
    limAxes = [-1.2 2 -1.1 2];
%     limAxes = [-1 1 -1 1];
    
    colPegs = 'red';
    contador = 1;
    for n=1:nbSamples
        %Plot frames
        if n >3
            mode = "reduced";
        end
        for m=1:model_.nbFrames
            if mode == "reduced"
                r(n).p(2).b(2) = r(n).p(2).b(2) * 1.75;
                r(n).p(2).b(3) = r(n).p(2).b(3) * 1.75;
            end
            if m > 1
                colPegs = 'blue';
            else
                colPegs = 'red';
            end
            
            variable = plotPegs(r(n).p(m), colPegs);
            
        end
        if mode == "reduced"
%             disp(contador)
            variable.Vertices = (variable.Vertices)/3;
            contador = contador + 1;
        else
            variable.Vertices = (variable.Vertices);
        end
    end
    
%     for n=1:nbSamples
% %         Plot Gaussians
%         plotGMM(r(n).Data(:,1:5:end), r(n).Sigma(:,:,1:5:end), [0 0 1], .05);
%     end
    for n=1:nbSamples
        %Plot trajectories
        plot(r(n).Data(1,1), r(n).Data(2,1),'.','markersize',12,'color','black');
        plot(r(n).Data(1,:), r(n).Data(2,:),'-','linewidth',1.5,'color','black');
        plot(r(n).Data(1,1), r(n).Data(2,1),'.','markersize',12,'color','r');
        plot(r(n).Data(1,:), r(n).Data(2,:),'-','linewidth',1.5,'color','r');
    end
    axis(limAxes); axis square; set(gca,'xtick',[],'ytick',[]);
    axis on
%     axis
%     print('map.png','-dpng')
%     map = imread('map.png');
%     map = rgb2gray(map);
%     map= imbinarize(map);
%     map = flipdim(map,1);
%     figure();
%     imshow(map)
%     axis
    %title(figure_title)
end