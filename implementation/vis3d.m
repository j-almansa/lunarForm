function vis3d(data,colorvector,dataname,datatype,closeupflag,saveflag)
%
latknots = 180;
lonknots = 360;

fig=figure('Name',sprintf('%s - %s',dataname,datatype));
surf(reshape(data,[lonknots latknots])',reshape(colorvector,[lonknots latknots])','EdgeColor','none','FaceColor','interp');



gausscmap = [ 150 125   0; %1
              170 212 136; %2
                0 212 200; %3
              255 255   0  %4 255 255 102 / 222 125   0
            ]./255;
efremcmap = [   0 212 200; %1
              170 212 136; %2
              150 125   0; %3
              255 255   0  %4 255 255 102 / 222 125   0
            ]./255;
sharycmap = [   0   0 156  %12
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
gausskmeancmap = [   0 128 102;
                    85 170 102;
                   170 212 102;
                   255 255 102]./255;
efremkmeancmap = [ 126  47 142;
                   217  83  25;
                   237 177  32;
                     0 114 189]./255;
sharykmeancmap = parula(12);


switch datatype
    case 'gaussclass'
        colormap(gausscmap);
        lcolorbar({'conc','conv','depr','hills'},...
                  'Location','horizontal','FontSize',7);
    case 'efremclass'
        colormap(efremcmap);
        lcolorbar({'accum','trans','trans','dissi'},...
                  'Location','horizontal','FontSize',7);
    case 'sharyclass'
        colormap(sharycmap);
        lcolorbar({'depre|  +','depre|  -',...
                   'sconc|---','sconc|--+','sconc|-++','sconc|+--',...
                   'sconv|-++','sconv|+--','sconv|++-','sconv|+++',...
                   'hills|  -','hills|  +'},...
                  'Location','horizontal','FontSize',7);
    case {'gausskmean','pcakmean','pcakmean_zscore'}
        colormap(gausskmeancmap);
        lcolorbar({'1','2','3','4'},'Location','horizontal','FontSize',7);
    case 'efremkmean'
        colormap(efremkmeancmap);
        lcolorbar({'1','2','3','4'},'Location','horizontal','FontSize',7);
    case {'sharykmean','pcakmean12','pcakmean12_zscore'}
        colormap(sharykmeancmap);
        lcolorbar({'1','2','3','4','5','6',...
                   '7','8','9','10','11','12'},'Location','horizontal','FontSize',7);
    case {'kv','kh','E','K','H'}
        if strcmp(dataname,'Geoid Anomalies')
            colormap(blueorangeCcmap);
        else
            colormap(blueorangeBcmap);
        end
        colorbar('southoutside','FontSize',7);
    case 'plain'
        colormap(gray);
        colorbar('southoutside','FontSize',7);
end


switch dataname
    case 'Topography'
        daspect([1 1 500]);
        if strcmp(closeupflag,'closeup')
            set(gca,'CameraPosition',[-120.715976551806 -1071.12803298773 467216.985863208],...
                    'CameraTarget',[174.204200266614 100.996012222387 5618.1776708244],...
                    'CameraViewAngle',1.79595470834089,...
                    'PlotBoxAspectRatio',[2 1 0.2],...
                    'Position',[0.13 0.1915 0.775 0.7335]);
        else
            set(gca,'CameraPosition',[-103.03711805834 -1090.5170926605 457585.04045631],...
                    'CameraViewAngle',5.6086199641387,...
                    'PlotBoxAspectRatio',[2 1 0.2],...
                    'Position',[0.13 0.1915 0.775 0.7335]);
        end
        light('Position',[-0.755126220130862 0.260010809110106 300.908113390446]);
    case 'Geoid Anomalies'
        daspect([1 1 20]);
        if strcmp(closeupflag,'closeup')
            set(gca,'CameraPosition',[-179.938293877997 -1384.26551110943 26790.4952503101],...
                    'CameraTarget',[93.5403873356759 91.2934101890925 -234.017114008328],...
                    'CameraViewAngle',1.62536921360346,...
                    'PlotBoxAspectRatio',[2 1 0.25],...
                    'Position',[0.13 0.1915 0.775 0.7335]);
        else
            set(gca,'CameraPosition',[-92.9786812136723 -1385.05892129852 27125.1673643184],...
                    'CameraViewAngle',4.19398641542829,...
                    'PlotBoxAspectRatio',[2 1 0.25],...
                    'Position',[0.13 0.1915 0.775 0.7335]);
        end
        light('Position',[1.2986142630086 -4.52880613779401 33.5023340213146]);
    case 'Crustal Thickness'
        daspect([1 1 1250])
        if strcmp(closeupflag,'closeup')
            set(gca,'CameraPosition',[203.083317096744 -44.4575354629557 2660418.31521206],...
                    'CameraTarget',[213.926410110373 105.641876187386 69910.9765221212],...
                    'CameraViewAngle',2.43389817063747,...
                    'PlotBoxAspectRatio',[2 1 0.6],...
                    'Position',[0.13 0.1915 0.775 0.7335]);
        else
            set(gca,'CameraPosition',[169.656906986371 -59.5994116503415 2658828.83868994],...
                    'CameraViewAngle',5.01201408584104,...
                    'PlotBoxAspectRatio',[2 1 0.6],...
                    'Position',[0.13 0.1915 0.775 0.7335]);
        end
%        set(gca,'CameraPosition',[17.0722484113742 -1006.85385015754 2182863.88041721],...
%                'CameraViewAngle',5.01201408584104,...
%                'PlotBoxAspectRatio',[2 1 0.6],...
%                'Position',[0.13 0.1915 0.775 0.7335]);
        light('Position',[-3.34609110488638 -2.61425288522971 2551.51871066684]);
end

lighting gouraud;
material dull;
axis off;

fname = regexprep(lower( sprintf('../images/other/%s_%s_closeup3d.jpg',dataname,datatype)  ),'\s+','');
if strcmp(saveflag,'save')
    saveas(fig,fname);
end
