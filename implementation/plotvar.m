function [X,clim] = plotvar(geomatrix,resolution,varname,units,logscale,projection,colorflag,saveflag,showflag)

[latknots,lonknots] = size(geomatrix);
auxmat = geomatrix';
X = auxmat(:);
nrobs = length(X);

% Transform to logarithmic scale
if logscale~=0
moonellipsoid = referenceEllipsoid;
moonellipsoid.SemimajorAxis = 1738000;% radius of Moon at Equator [m]
moonellipsoid.InverseFlattening = 3234.93; % inverse flattening

%lat = meshgrid(89.5:-1:-89.5,1:lonknots);
%w = distance(lat(:),zeros(nrobs,1),lat(:),ones(nrobs,1),referenceEllipsoid('moon'));
lat = meshgrid(90-(resolution/2):-resolution:-(90-(resolution/2)),1:lonknots);
w = distance(lat(:),zeros(nrobs,1),lat(:),resolution*ones(nrobs,1),moonellipsoid);


% Log scaling in Florinsky's pp 134
%    m = 2 for K, and m=1 for the rest
%    n according to window-cell width
n = cell2mat(arrayfun(@(x) paramn(w(x)),1:length(w),'un',0))';
logtransform = @(variable) ( sign(variable) .* log(1 + logscale.^n.*abs(variable)) );

X = logtransform(X);
end


m = min(X);
M = max(X);
clim = [m M];
fprintf('plotting range of %s: [%g, %g]\n',varname,m,M);
if m<0 && M>0
    absm = abs(m);
    absM = abs(M);
    if absM-absm >= 0      
        clim=[-absm absm];
    else
        clim=[-absM absM];
    end
end

% What does this do?
% Try Topography Curvature K with 0 log scaling and this fragment
%{
if logscale==0
    Xsigma = std(X,'omitnan');
    clim = (1/100)*[-Xsigma Xsigma];
end
%}

if strcmp(showflag,'show')
fig=figure('Name',sprintf('%s',varname));
if strcmp(projection,'Plate Carree')
    imagesc( reshape(X,[lonknots latknots])' );
    set(gca,...
        'YDir','normal',...
        'DataAspectRatio', [1 1 1],...
        'CLim',clim,...
        'XLim', [1, lonknots], 'YLim', [1, latknots],...
        'XTick', 1:179:lonknots, 'YTick', 1:89:latknots,...
        'XTickLabel',{'-179.5','0','179.5'},...
        'YTickLabel',{'-89.5','0','89.5'});
else
    Xrefvec = [1 90 180];%for mollweid
    %Xrefvec = [1 90 180];%for ortho
    axesm hammer;
    %axesm ortho;
    geoshow(reshape(X,[lonknots latknots])',Xrefvec,'DisplayType', 'texturemap');
end
axis off;

if strcmp(colorflag,'color')
    %colormap(moonjetcmap);
    %colormap(mooncmap);
    colormap(blueorangeBcmap);
else
    colormap(gray);
end
end %ENDOF showflag

cbh = colorbar;
cbh.Label.String = sprintf('[%s]',units);

fname = regexprep(lower( sprintf('../images/%s_logfactor%d_%s_%s.jpg',varname,logscale,projection,colorflag)  ),'\s+','');
if strcmp(saveflag,'save')
    saveas(fig,fname);
end

