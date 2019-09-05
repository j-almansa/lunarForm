%% Title
% Description
%
clear all;
close all;
clc;
format longg;

%% Data Input
% description
%

% Uncomment only one of the following three lines
fname = '../data/topogrd1.dat'; % Topography
%fname = '../data/geoidgrd.dat'; % Geoid Anomalies
%fname = '../data/thickgrd.dat'; % Crustal Thickness

latknots = 180*(4^(fname(16) == '2'));%2DO: use regular expression instead
lonknots = 360*(4^(fname(16) == '2'));%idem

resolution = 180/latknots;

data = dlmread(fname);
Xmatlatlon = (reshape(data',[lonknots latknots]))'; %lat x lon
Xmatlatlonshifted = circshift(Xmatlatlon,lonknots/2,2); % shifted 180 degrees
Xmatlonlatshifted = Xmatlatlonshifted'; %lon x lat
X = (1e3^(~isempty(strfind(fname,'thick'))))*Xmatlonlatshifted(:); %lon-wise; also, converts thickgrd.dat from km to m
nrobs = latknots*lonknots;


switch fname(9:12)
    case 'topo'
        dataname = 'Topography';
    case 'geoi'
        dataname = 'Geoid Anomalies';
    case 'thic'
        dataname = 'Crustal Thickness';
end

% Gaussian smoothing for Topography
if strcmp(dataname,'Topography')
h = fspecial('gaussian', 3, 1);
Xmatfiltered = imfilter(reshape(X,[lonknots latknots])', h, 'symmetric');
Xmatfiltered = imfilter(Xmatfiltered, h, 'symmetric');
auxfiltered = Xmatfiltered';
X = auxfiltered(:);
end

%% Calculation of Curvatures
% description
%
[kh,kv,H,K,E] = curvatures(reshape(X,[lonknots latknots])',resolution);



%% Classification of Moonforms
% description
%

Gauss = gaussformclass(K,H,dataname,'noshow');
Efrem = efremformclass(kh,kv,dataname,'noshow');
Shary = sharyformclass(K,H,kh,kv,E,dataname,'noshow');

% Use mydist when kmeansclass.m is defined by own algorithm (see inside)
%    mydist = @(v,w) sum(abs( repmat(sign(v),size(w,1),1) - sign(w) ), 2);
GaussClust = kmeansclass([K H],4,'cosine',dataname,'noshow');
EfremClust = kmeansclass([kh kv],4,'cosine',dataname,'noshow');
SharyClust = kmeansclass([K H kh kv E],12,'cosine',dataname,'noshow');



%% Plotting
% description
%


% Logarithmic transformation of curvatures, clim centering, and 2D visualization.
% Must be kept uncommented for visualization of curvatures, also in 3D
% further below.
%%{
micell = cell(1,6);
climcell = cell(1,6);
[micell{1}, climcell{1}] = plotvar(reshape(X,[lonknots latknots])',resolution,dataname,'m',0,'Plate Carree','gray','nosave','noshow');
[micell{2}, climcell{2}] = plotvar(reshape(kh,[lonknots latknots])',resolution,[dataname,'_kh'],'log',10,'Plate Carree','color','nosave','noshow');
[micell{3}, climcell{3}] = plotvar(reshape(kv,[lonknots latknots])',resolution,[dataname,'_kv'],'log',10,'Plate Carree','color','nosave','noshow');
[micell{4}, climcell{4}] = plotvar(reshape(E,[lonknots latknots])',resolution,[dataname,'_E'],'log',10,'Plate Carree','color','nosave','noshow');
[micell{5}, climcell{5}] = plotvar(reshape(K,[lonknots latknots])',resolution,[dataname,'_K'],'log',100,'Plate Carree','color','nosave','noshow');
[micell{6}, climcell{6}] = plotvar(reshape(H,[lonknots latknots])',resolution,[dataname,'_H'],'log',10,'Plate Carree','color','nosave','noshow');
%%}


% PCA of curvatures, k-means on scores, and visualization in 3D
%{
logcurvatures = zscore2([micell{3} micell{2} micell{4} micell{5} micell{6}]);
score = PCAoncurv(logcurvatures,{'kv','kh','E','K','H'},'show');
PCAClust = kmeansclass([score(:,1) score(:,2) score(:,3)],4,'cosine',dataname,'noshow');
vis3d(X,PCAClust,dataname,'pcakmean4_zscore','closeup','save');
%}



% Visualization of curvatures in 3D
%{
vis3d(X,micell{1},dataname,'plain','closeup','nosave');
vis3d(X,micell{2},dataname,'kh','closeup','nosave');
vis3d(X,micell{3},dataname,'kv','closeup','nosave');
vis3d(X,micell{4},dataname,'E','closeup','nosave');
vis3d(X,micell{5},dataname,'K','closeup','nosave');
vis3d(X,micell{6},dataname,'H','closeup','nosave');
%}



% Visualization of classifications and clusterings in 3D
%{
vis3d(X,Gauss,dataname,'gaussclass','closeup','nosave');
vis3d(X,Efrem,dataname,'efremclass','closeup','nosave');
vis3d(X,Shary,dataname,'sharyclass','closeup','nosave');
vis3d(X,GaussClust,dataname,'gausskmean','closeup','nosave');
vis3d(X,EfremClust,dataname,'efremkmean','closeup','nosave');
vis3d(X,SharyClust,dataname,'sharykmean','closeup','nosave');
%}



% Visualization of a mosaic of curvatures in 2D
%{
figure;
for i=1:length(micell)
    subplot(3,2,i);
    plotX = micell{i};
    climX = climcell{i};
    imagesc( reshape(plotX,[lonknots latknots])' );
    set(gca,...
        'YDir','normal',...
        'DataAspectRatio', [1 1 1],...
        'CLim',climX,...
        'XLim', [1, lonknots], 'YLim', [1, latknots],...
        'XTick', 1:179:lonknots, 'YTick', 1:89:latknots,...
        'XTickLabel',{'-179.5','0','179.5'},...
        'YTickLabel',{'-89.5','0','89.5'},...
        'FontSize',6);
    if i==1
        colormap(gca,gray)
    else
        colormap(gca,blueorangecmap);
    end
    %colorbar;
end
%}



% Visualization of statistical summaries of curvatures
%{
summary(X,dataname,'m','nosave');
summary(kh,[dataname,'_kh'],'m^{-1}','save');
summary(kv,[dataname,'_kv'],'m^{-1}','save');
summary(E,[dataname,'_E'],'m^{-1}','save');
summary(K,[dataname,'_K'],'m^{-2}','save');
summary(H,[dataname,'_H'],'m^{-1}','save');
%}



% Visualization of leverages of curvatures in 2D
%{
% Original variables
plotvar(reshape(leverage(X),[lonknots latknots])',resolution,[dataname,'_leverage'],' ',0,'Plate Carree','color','nosave','show');
plotvar(reshape(leverage(kh),[lonknots latknots])',resolution,[dataname,'_kh_leverage'],' ',10,'Plate Carree','color','nosave','show');
plotvar(reshape(leverage(kv),[lonknots latknots])',resolution,[dataname,'_kv_leverage'],' ',10,'Plate Carree','color','nosave','show');
plotvar(reshape(leverage(E),[lonknots latknots])',resolution,[dataname,'_E_leverage'],' ',10,'Plate Carree','color','nosave','show');
plotvar(reshape(leverage(K),[lonknots latknots])',resolution,[dataname,'_K_leverage'],' ',100,'Plate Carree','color','nosave','show');
plotvar(reshape(leverage(H),[lonknots latknots])',resolution,[dataname,'_H_leverage'],' ',10,'Plate Carree','color','nosave','show');

% Logarithmically scaled variables
plotvar(reshape(leverage(X),[lonknots latknots])',resolution,[dataname,'_leverage'],'m',0,'Plate Carree','color','nosave','show');
plotvar(reshape(leverage(micell{2}),[lonknots latknots])',resolution,[dataname,'_kh_leverage'],'log',10,'Plate Carree','color','nosave','show');
plotvar(reshape(leverage(micell{3}),[lonknots latknots])',resolution,[dataname,'_kv_leverage'],'log',10,'Plate Carree','color','nosave','show');
plotvar(reshape(leverage(micell{4}),[lonknots latknots])',resolution,[dataname,'_E_leverage'],'log',10,'Plate Carree','color','nosave','show');
plotvar(reshape(leverage(micell{5}),[lonknots latknots])',resolution,[dataname,'_K_leverage'],'log',100,'Plate Carree','color','nosave','show');
plotvar(reshape(leverage(micell{6}),[lonknots latknots])',resolution,[dataname,'_H_leverage'],'log',10,'Plate Carree','color','nosave','show');
%}



% Visualization of zscores of input data in 2D
%plotvar(reshape(zscore(X),[lonknots latknots])',resolution,dataname,'m',0,'Plate Carree','gray','nosave');
