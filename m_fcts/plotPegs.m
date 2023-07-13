function h= plotPegs(p, colPegs, fa, mode)
    if nargin < 4
        mode = "on";
    end
	if ~exist('colPegs')
		colPegs = 'red';
%         colPegs = [1    1    1; 1    1    1];
	end
	if ~exist('fa')
		fa = .6;
    end
    if mode == "off"
        axis off;
    else
        axis on
    end
% 	pegMesh = [-4 -3.5; -4 10; -1.5 10; -1.5 -1; 1.5 -1; 1.5 10; 4 10; 4 -3.5; -4 -3.5]' *1E-1;
    pegMesh = [-4 -3.5; -4 5; -1.5 5; -1.5 -1; 1.5 -1; 1.5 5; 4 5; 4 -3.5; -4 -3.5]' *1E-1;
	for m=1:length(p)
		dispMesh = p(m).A(2:3,2:3) * pegMesh + repmat(p(m).b(2:3),1,size(pegMesh,2));
%         h(m) = patch(dispMesh(1,:),dispMesh(2,:),colPegs(m,:),'linewidth',1,'edgecolor','none','facealpha',fa);
%         if mode =="off"
%             dispMesh(1,:) = (dispMesh(1,:) - (-1.2)) / (0.8 - (-1.2));
%             dispMesh(2,:) = (dispMesh(2,:) - (-1.1)) / (0.9 - (-1.1));
%         end
%         dispMesh
        axis([-1.2 2 -1.1 2]);
        hold on
        h(m) = fill(dispMesh(1,:),dispMesh(2,:),colPegs);
    end
end