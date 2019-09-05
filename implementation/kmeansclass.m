function idx = kmeansclass(datamatrix,numclasses,metric,dataname,showflag)
%

%%{
lonknots = 360;
latknots = 180;

idx = kmeans(datamatrix,numclasses,'Distance',metric,'MaxIter',200,'Display','final','Replicates',5);

%%{
% Silhouette Plots
figure;
[silh,h] = silhouette(datamatrix,idx,metric);
set(findobj(gca,'Type','Bar'),'EdgeColor',[.8 .8 1])
xlabel 'Silhouette Value';
ylabel 'Cluster';

fprintf('Mean of clustering: %g\n',mean(silh,'omitnan'));
%%}


if strcmp(showflag,'show')
    figure('Name',sprintf('%s_%d-Means_Classification',dataname,numclasses));
    R = reshape(idx,[lonknots latknots])';
    h = imagesc( R );
    set(h,'alphadata',~isnan(R)); % set NaNs totally transparent
    set(gca, 'DataAspectRatio', [1 1 1],...
        'YDir','normal',...
        'XLim', [1, lonknots], 'YLim', [1, latknots],...
        'XTick', 1:179:lonknots, 'YTick', 1:89:latknots,...
        'XTickLabel',{'-179.5','0','179.5'},...
        'YTickLabel',{'-89.5','0','89.5'},...
        'Color',[0 0 0]); % set axes bacground to black
    map00 = [   0 128 102;
               85 170 102;
              170 212 102;
              255 255 102]./255;
    map01 = [ 126  47 142;
              217  83  25;
              237 177  32;
                0 114 189]./255;
    if numclasses == 12
        colormap(jet(12));
    else
       colormap(map00);
    end
    lcolorbar( arrayfun(@num2str, 1:numclasses, 'UniformOutput', false) );
end
%%}







% ALTERNATIVE k-means: Intended to be used with own metrics; still in
% progress.
%{
lonknots = 360;
latknots = 180;

X = datamatrix;
[~,nvars] = size(X);

rowseed = randi(latknots,1,numclasses);
colseed = randi(lonknots,1,numclasses);
seed = rowseed.*colseed;
C = X(seed,:); % initial cluster centers

maxiter = 100; % maximum number of iterations
iter = 1;

if strcmp(showflag,'show')
    hf1 = figure('Name',sprintf('%s_%d-Means_Classification',dataname,numclasses));
end;

%pause on;
while (iter <= maxiter)
    %metric = 'euclidean';
    dist = pdist2(X,C,metric);
    [~,idx] = min(dist,[],2);
    mM = cell2mat(arrayfun(@(v) mean(X(idx == v,:)),1:numclasses,'UniformOutput',false));
    M = reshape(mM,nvars,numclasses)';
    if all(all(eq(M,C))), break; end;
    C = M;
    iter = iter + 1;
    % Plot Thematic Map
    if strcmp(showflag,'show')
        set(0, 'currentfigure', hf1);
        %imagesc(reshape(idx,latknots,lonknots)');
        R = reshape(idx,[lonknots latknots])';
        h = imagesc( R );
        set(h,'alphadata',~isnan(R)); % set NaNs totally transparent
        set(gca, 'DataAspectRatio', [1 1 1],...
            'YDir','normal',...
            'XLim', [1, lonknots], 'YLim', [1, latknots],...
            'XTick', 1:179:lonknots, 'YTick', 1:89:latknots,...
            'XTickLabel',{'-179.5','0','179.5'},...
            'YTickLabel',{'-89.5','0','89.5'},...
            'Color',[0 0 0]); % set axes bacground to black
        colormap(winter(numclasses));
        %hcb = colorbar('YTick',1:k,...
        %         'YTickLabel',arrayfun(@num2str, 1:numclasses, 'UniformOutput', false));
        %set(hcb,'XTickMode','manual');
        lcolorbar( arrayfun(@num2str, 1:numclasses, 'UniformOutput', false) );
        title(sprintf('[metric: %s | iter: %d/%d]',metric,iter-1,maxiter),...
              'FontWeight','normal','FontSize',8);
    end
    %drawnow;
    %keyboard;
end
fprintf('Numiter: %d\n',iter);
%}