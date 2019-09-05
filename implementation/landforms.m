%% Title
% Description
%
clear all;
close all;
clc;
format short g;

%% Data Input
% description
%
fname = '../data/topogrd1.dat';
%fname = '../data/geoidgrd.dat';
%fname = '../data/thickgrd.dat';

latknots = 180*(4^(fname(16) == '2'));
lonknots = 360*(4^(fname(16) == '2'));

data = dlmread(fname);
Xmatlatlon = (reshape(data',[lonknots latknots]))'; %lat x lon
Xmatlonlat = Xmatlatlon'; %lon x lat
X = Xmatlonlat(:); %lon-wise NB: Multiply by 1e3 for thickgrd.dat
nrobs = latknots*lonknots;
summary(X,'Topography','m');



%% Landform Classification
% description
%
moonellipsoid = referenceEllipsoid;
moonellipsoid.SemimajorAxis = 1738000;% radius at Equator [m] (Earth in WGS84: 6378137 [m])
moonellipsoid.InverseFlattening = 3234.93; % inverse flattening (Earth in WGS84: 298.257223563)
%distance(lat1,lon1,lat2,lon2,moonellipsoid); % distance in [m]

partial = array2table(NaN(nrobs,5),'VariableNames',{'r','t','s','p','q'});
auxXmat = Xmatlonlat;
auxXmat(1,:)   = NaN;
auxXmat(end,:) = NaN;
auxXmat(:,1)   = NaN;
auxXmat(:,end) = NaN;
auxX = auxXmat(:);%reshape(auxXmat',[nrobs 1]);
%lon = meshgrid([1.5:179.5 -180.5:-2.5],1:178)';
%lat = meshgrid(88.5:-1:-88.5,1:358);
%coord = [lat(:) lon(:)];
%dists = arrayfun(@(x) distance(coord(x,1),coord(x,2),coord(x,1),coord(x,2)-1,moonellipsoid),1:length(coord),'un',0);
lat = meshgrid(89.5:-1:-89.5,1:lonknots);
w = distance(lat(:),zeros(nrobs,1),lat(:),ones(nrobs,1),moonellipsoid); % lengths of 1 arcdegree along latitude per observation
partial.r = (circshift(auxX,  ( lonknots-1 ))+...
             circshift(auxX, -( 1          ))+...
             circshift(auxX, -( lonknots+1 ))+...
             circshift(auxX,  ( lonknots+1 ))+...
             circshift(auxX,  ( 1          ))+...
             circshift(auxX, -( lonknots-1 ))-...
             2*(circshift(auxX,  ( lonknots ))+...
                auxX                          +...
                circshift(auxX, -( lonknots )))) ./ (3*w.^2);
partial.t = (circshift(auxX,  ( lonknots+1 ))+...
             circshift(auxX,  ( lonknots   ))+...
             circshift(auxX,  ( lonknots-1 ))+...
             circshift(auxX, -( lonknots-1 ))+...
             circshift(auxX, -( lonknots   ))+...
             circshift(auxX, -( lonknots+1 ))-...
             2*(circshift(auxX,  ( 1        ))+...
                auxX                          +...
                circshift(auxX, -( 1        )))) ./ (3*w.^2);
partial.s = (circshift(auxX,  ( lonknots-1 ))+...
             circshift(auxX, -( lonknots-1 ))-...
             circshift(auxX,  ( lonknots+1 ))-...
             circshift(auxX, -( lonknots+1 ))) ./ (4*w.^2);
partial.p = (circshift(auxX,  ( lonknots-1 ))+...
             circshift(auxX, -( 1          ))+...
             circshift(auxX, -( lonknots+1 ))-...
             circshift(auxX,  ( lonknots+1 ))-...
             circshift(auxX,  ( 1          ))-...
             circshift(auxX, -( lonknots-1 ))) ./ (6*w);
partial.q = (circshift(auxX,  ( lonknots+1 ))+...
             circshift(auxX,  ( lonknots   ))+...
             circshift(auxX,  ( lonknots-1 ))-...
             circshift(auxX, -( lonknots-1 ))-...
             circshift(auxX, -( lonknots   ))-...
             circshift(auxX, -( lonknots+1 ))) ./ (6*w);

curvature = array2table(NaN(nrobs,5),'VariableNames',{'kh','kv','H','K','E'});
p2q2 = (partial.p).^2 + (partial.q).^2;
p2r = (partial.p).^2 .* partial.r;
p2t = (partial.p).^2 .* partial.t;
q2t = (partial.q).^2 .* partial.t;
q2r = (partial.q).^2 .* partial.r;
pqs = partial.p .* partial.q .* partial.s;
rt = partial.r .* partial.t;
s2 = (partial.s).^2;
curvature.kh = -(q2r - 2.*pqs + p2t)./ (p2q2 .* (1 + p2q2).^(1/2));
curvature.kv = -(p2r + 2.*pqs + q2t)./ (p2q2 .* (1 + p2q2).^(3/2));
curvature.K = (rt - s2) ./ (1 + p2q2).^2;
curvature.H = 1/2 .* (curvature.kv + curvature.kh);
curvature.E = 1/2 .* (curvature.kv - curvature.kh);




%% Plotting
% description
%
offplots = {%'Elevation - Plate Carree'
            'Elevation - Mollweid'
            'Horizontal Curvature'
            'Vertical Curvature'
            'Difference Curvature'
            'Mean Curvature'
            'Curvature Gauss'
            'Classification - Gauss'
           };
flag = @(name) regexprep(char(ismember(name,offplots)*'off'),'[^of]{3}','on');


n = cell2mat(arrayfun(@(x) paramn(w(x)),1:length(w),'un',0))';
logtransform = @(variable) ( sign(variable) .* log(1 + 10.^n.*abs(variable)) );


plotvar(reshape(X,[lonknots latknots])','Topography','m','Plate Carree','gray','nosave');
logkh = logtransform(curvature.kh);
plotvar(reshape(logkh,[lonknots latknots])','Horizontal Curvature','m','Plate Carree','color','nosave');


Xrefvec = [1 90 90];%for mollweid
%Xrefvec = [1 90 180];%for ortho
fig = figure('Name','Elevation - Mollweid');
fig.Visible = flag(fig.Name);
axesm mollweid;
%axesm ortho;
axis off;
%geoshow(circshift(reshape(X,[lonknots latknots])',lonknots/2,2),Xrefvec,'DisplayType', 'texturemap');
geoshow(reshape(X,[lonknots latknots])',Xrefvec,'DisplayType', 'texturemap');
colormap(mooncmap);
colorbar;
%print -djpeg ../images/topo_mollweid0_color.jpg;





if ~strcmp(flag('Horizontal Curvature'),'off')
logkv = logtransform(curvature.kv);
fig = figure('Name','Vertical Curvature');
fig.Visible = flag(fig.Name);
%imagesc( reshape(curvature.kv,[lonknots latknots])' );
imagesc( reshape(logkv,[lonknots latknots])' );
set(gca,...
    'YDir','normal',...
    'DataAspectRatio', [1 1 1],...
    'XLim', [1, lonknots], 'YLim', [1, latknots],...
    'XTick', 1:89:lonknots, 'YTick', 1:44:latknots,...
    'XTickLabel',{'-179.5','-89.5','0.5','89.5','179.5'},...
    'YTickLabel',{'-89.5','-60.5','0','60.5','89.5'});
colormap;
%colorbar;



logE = logtransform(curvature.E);
fig = figure('Name','Difference Curvature');
fig.Visible = flag(fig.Name);
%imagesc( reshape(curvature.E,[lonknots latknots])' );
imagesc( reshape(logE,[lonknots latknots])' );
set(gca,...
    'YDir','normal',...
    'DataAspectRatio', [1 1 1],...
    'XLim', [1, lonknots], 'YLim', [1, latknots],...
    'XTick', 1:89:lonknots, 'YTick', 1:44:latknots,...
    'XTickLabel',{'-179.5','-89.5','0.5','89.5','179.5'},...
    'YTickLabel',{'-89.5','-60.5','0','60.5','89.5'});
colormap;
%colorbar;



logH = logtransform(curvature.H);
fig = figure('Name','Mean Curvature');
fig.Visible = flag(fig.Name);
%imagesc( reshape(curvature.H,[lonknots latknots])' );
imagesc( reshape(logH,[lonknots latknots])' );
set(gca,...
    'YDir','normal',...
    'DataAspectRatio', [1 1 1],...
    'XLim', [1, lonknots], 'YLim', [1, latknots],...
    'XTick', 1:89:lonknots, 'YTick', 1:44:latknots,...
    'XTickLabel',{'-179.5','-89.5','0.5','89.5','179.5'},...
    'YTickLabel',{'-89.5','-60.5','0','60.5','89.5'});
colormap;
%colorbar;




%--------------------------------------------------------------------------
%{
% Code fragment from imshowrgb.m (Allan's); same results as imshow
    figure;
    nstd = 1/24;
    magn = 100;
    img = cast(logK, 'single');
    img = img-repmat(mean(img), nrobs, 1);
    stdvar = std(img);
    img = reshape(img, lonknots, latknots)';
    %stds = sqrt(1/2997); stdvar = [stds stds stds];
    r = img/(2*nstd*stdvar)+0.5; r(r<0)=0; r(r>1)=1;
    imshow(r, 'InitialMagnification', magn)
%}
%--------------------------------------------------------------------------

logK = logtransform(curvature.K);
Ksigma = std(logK,'omitnan');
fig = figure('Name','Curvature Gauss');
fig.Visible = flag(fig.Name);
%imagesc( reshape(curvature.K,[lonknots latknots])' );
%    'CLim',(1/12)*[-Ksigma Ksigma],...
imagesc( reshape(logK,[lonknots latknots])' );
set(gca,...
    'YDir','normal',...
    'CLim',(1/12)*[-Ksigma Ksigma],...
'DataAspectRatio', [1 1 1],...
    'XLim', [1, lonknots], 'YLim', [1, latknots],...
    'XTick', 1:89:lonknots, 'YTick', 1:44:latknots,...
    'XTickLabel',{'-179.5','-89.5','0.5','89.5','179.5'},...
    'YTickLabel',{'-89.5','-60.5','0','60.5','89.5'});
colormap;




Gauss = mixsign(curvsign(curvature.K), curvsign(curvature.H));
fig = figure('Name','Classification - Gauss');
fig.Visible = flag(fig.Name);
%imagesc( circshift(reshape(Gauss,lonknots,latknots)',lonknots/2,2) );
imagesc( reshape(Gauss,[lonknots latknots])' );
set(gca, 'DataAspectRatio', [1 1 1],...
    'YDir','normal',...
    'XLim', [1, lonknots], 'YLim', [1, latknots],...
    'XTick', 1:89:lonknots, 'YTick', 1:44:latknots,...
    'XTickLabel',{'-179.5','-89.5','0.5','89.5','179.5'},...
    'YTickLabel',{'-89.5','-60.5','0','60.5','89.5'});
%'XTickLabel',{'0.5','89.5','179.5','269.5','359.5'},...
colormap(gray);
%{
map = [   0   0   0; %NaN...?
          0   0 255; %0
          0 255   0; %1
        255   0   0; %2
        255 255   0  %3
      ]./255;
colormap(map);
hcb=colorbar('YTickLabel',{'NaN','conc','conv','depr','hills'});
set(hcb,'Ytick',[0 1 2 3 4],'YTickMode','manual');
%}
%\-+  NaN  K=0 | H=0  ridges, valleys, planes
%00   0    K<0 & H<0  concave saddles
%01   1    K<0 & H>0  convex saddles
%10   2    K>0 & H<0  depressions
%11   3    K>0 & H>0  hills


end %BIG IF