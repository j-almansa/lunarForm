function Efrem = efremformclass(kh,kv,dataname,showflag)
%

lonknots = 360;
latknots = 180;

Efrem = mixsign(curvsign(kh), curvsign(kv));

if strcmp(showflag,'show')
figure('Name',[dataname,'_Efremovich-Krcho_Classification']);
C = reshape(Efrem,[lonknots latknots])';
h = imagesc( C );
set(h,'alphadata',~isnan(C)); % set NaNs totally transparent
set(gca, 'DataAspectRatio', [1 1 1],...
    'YDir','normal',...
    'XLim', [1, lonknots], 'YLim', [1, latknots],...
    'XTick', 1:179:lonknots, 'YTick', 1:89:latknots,...
    'XTickLabel',{'-179.5','0','179.5'},...
    'YTickLabel',{'-89.5','0','89.5'},...
    'Color',[0 0 0]); % set axes bacground to black
subparula = [  20 131 212; %1
               50 184 161; %2
              211 187  88; %3
              249 251  14  %4
            ]./255;
map01 = [ 0   0 255; %1
          0 255   0; %2
        255   0   0; %3
        255 255   0  %4
      ]./255;

map02 = [  30   0 102; %1
          170 212 136; %2
          102  85 170; %3
          255 255 102  %4 255 255 102 / 222 125   0
            ]./255;

colormap(map02);
labels = {'accum','trans','trans','dissi'}; % Efremov-Krcho
lcolorbar(labels);

%\-+  NaN  NaN  kh=0 | kv=0  transit straight-* | transit *-straight
%00   0    1    kh<0 & kv<0  accum
%01   1    2    kh<0 & kv>0  trans conc-conv
%10   2    3    kh>0 & kv<0  trans conv-conc
%11   3    4    kh>0 & kv>0  dissi

end