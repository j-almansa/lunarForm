function Gauss = gaussformclass(K,H,dataname,showflag)
%

lonknots = 360;
latknots = 180;

Gauss = mixsign(curvsign(K), curvsign(H));

if strcmp(showflag,'show')
figure('Name',[dataname,'_Gauss_Classification']);
C = reshape(Gauss,[lonknots latknots])';
h = imagesc( C );
set(h,'alphadata',~isnan(C)); % set NaNs totally transparent
set(gca, 'DataAspectRatio', [1 1 1],...
    'YDir','normal',...
    'XLim', [1, lonknots], 'YLim', [1, latknots],...
    'XTick', 1:179:lonknots, 'YTick', 1:89:latknots,...
    'XTickLabel',{'-179.5','0','179.5'},...
    'YTickLabel',{'-89.5','0','89.5'},...
    'Color',[0 0 0]); % set axes bacground to black

%lowest parula color 53  42 135;
subparula = [  20 131 212; %1
               50 184 161; %2
              211 187  88; %3
              249 251  14  %4
            ]./255;
map00 = [  63  63  63; %1
          134 134 134; %2
          204 204 204; %3
          255 255 255  %4
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
labels = {'conc','conv','depr','hills'}; % Gauss
lcolorbar(labels);

%\-+  NaN  NaN  K=0 | H=0  ridges, valleys, planes
%00   0    1    K<0 & H<0  concave saddles
%01   1    2    K<0 & H>0  convex saddles
%10   2    3    K>0 & H<0  depressions
%11   3    4    K>0 & H>0  hills
end