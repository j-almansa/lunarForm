function Shary = sharyformclass(K,H,kh,kv,E,dataname,showflag)
%

lonknots = 360;
latknots = 180;

Gauss = gaussformclass(K,H,dataname,'noshow');
strkh = curvsign(kh);
strkv = curvsign(kv);
strE = curvsign(E);

sgnkh = NaN(size(Gauss));
sgnkh( regexp(strkh,'0') ) = 0;
sgnkh( regexp(strkh,'1') ) = 1;

sgnkv = NaN(size(Gauss));
sgnkv( regexp(strkv,'0') ) = 0;
sgnkv( regexp(strkv,'1') ) = 1;

sgnE = NaN(size(Gauss));
sgnE( regexp(strE,'0') ) = 0;
sgnE( regexp(strE,'1') ) = 1;


Shary = NaN(size(Gauss));

%%{
% Hills
Shary( (Gauss == 4) & (sgnE == 1) ) = 12;%1;
Shary( (Gauss == 4) & (sgnE == 0) ) = 11;%6;

% Depressions
Shary( (Gauss == 3) & (sgnE == 1) ) = 2;%7;
Shary( (Gauss == 3) & (sgnE == 0) ) = 1;%12;

% Saddle Convex
Shary( (Gauss == 2) & (sgnkh == 0) ) = 7;%2;
Shary( (Gauss == 2) & (sgnkh == 1) & (sgnkv == 0) ) = 8;%5;
Shary( (Gauss == 2) & (sgnkh == 1) & (sgnkv == 1) & (sgnE == 0) ) = 9;%4;
Shary( (Gauss == 2) & (sgnkh == 1) & (sgnkv == 1) & (sgnE == 1) ) = 10;%3;

% Saddle Concave
Shary( (Gauss == 1) & (sgnkh == 1) ) = 6;%11;
Shary( (Gauss == 1) & (sgnkh == 0) & (sgnkv == 1) ) = 5;%8;
Shary( (Gauss == 1) & (sgnkh == 0) & (sgnkv == 0) & (sgnE == 1) ) = 4;%9;
Shary( (Gauss == 1) & (sgnkh == 0) & (sgnkv == 0) & (sgnE == 0) ) = 3;%10;


if strcmp(showflag,'show')
figure('Name',[dataname,'_Shary_Classification']);
C = reshape(Shary,[lonknots latknots])';
h = imagesc( C );
set(h,'alphadata',~isnan(C)); % set NaNs totally transparent
set(gca, 'DataAspectRatio', [1 1 1],...
    'YDir','normal',...
    'XLim', [1, lonknots], 'YLim', [1, latknots],...
    'XTick', 1:179:lonknots, 'YTick', 1:89:latknots,...
    'XTickLabel',{'-179.5','0','179.5'},...
    'YTickLabel',{'-89.5','0','89.5'},...
    'Color',[0 0 0]); % set axes bacground to black

map00 = [   0   0 156  %12
            0   0 254; %7
            0 135   0; %10
            0 165   0; %9
            0 195   0; %8
            0 255   1; %11
          255 255   0; %2
          255 204   0; %5
          255 185   1; %4
          254 155   1; %3
          254   0   0; %6
          200   0   0]./255; %1
colormap(map00);
labels = {'depre|  +',...
          'depre|  -',...
          'sconc|---',...
          'sconc|--+',...
          'sconc|-++',...
          'sconc|+--',...
          'sconv|-++',...
          'sconv|+--',...
          'sconv|++-',...
          'sconv|+++',...
          'hills|  -',...
          'hills|  +'}; % Shary
lcolorbar(labels,'FontSize',5);%,'Direction','reverse');

%\-+  NaN  NaN  kh=0 | kv=0  transit straight-* | transit *-straight
%00   0    1    kh<0 & kv<0  accum
%01   1    2    kh<0 & kv>0  trans conc-conv
%10   2    3    kh>0 & kv<0  trans conv-conc
%11   3    4    kh>0 & kv>0  dissi
end