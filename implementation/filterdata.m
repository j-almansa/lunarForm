%function filterdata(fname)
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
fname = '../data/topogrd1.dat';
%fname = '../data/geoidgrd.dat';
%fname = '../data/thickgrd.dat';

latknots = 180*(4^(fname(16) == '2'));%2DO: correct with one index before the dot in fname
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

% 2D filtering technique:
%    h = fspecial(filtertype, windowsize, standardeviation)
%    filteredimage = imfilter(unfilteredimage, myfilter, 'replicate');


mat = reshape(X,[lonknots latknots])';
h = fspecial('gaussian', 3, 1);

plotvar(mat,resolution,dataname,'m',0,'Plate Carree','gray','nosave','show');
%{
for i=1:2
    mat = imfilter(mat, h, 'symmetric');
    plotvar(mat,resolution,dataname,'m',0,'Plate Carree','gray','nosave','show');
    mat = mat(1:2:end,1:2:end);
    plotvar(mat,resolution,dataname,'m',0,'Plate Carree','gray','nosave','show');
end
%}


mat1 = impyramid(mat,'reduce');
mat2 = impyramid(mat1,'reduce');

plotvar(mat1,resolution,dataname,'m',0,'Plate Carree','gray','nosave','show');
plotvar(mat2,resolution,dataname,'m',0,'Plate Carree','gray','nosave','show');

