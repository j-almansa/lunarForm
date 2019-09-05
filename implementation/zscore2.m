function [z,mu,sigma] = zscore2(x,flag,dim)
%ZSCORE2 Standardized z score.
%   Modified version of MATLAB built-in zcore.m that removes NaN's from
%   calculations

%   Copyright 1993-2006 The MathWorks, Inc. 


% [] is a special case for std and mean, just handle it out here.
if isequal(x,[]), z = []; return; end

if nargin < 2
    flag = 0;
end
if nargin < 3
    % Figure out which dimension to work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Compute X's mean and sd, and standardize it
mu = mean(x,dim,'omitnan');
sigma = std(x,flag,dim,'omitnan');
sigma0 = sigma;
sigma0(sigma0==0) = 1;
z = bsxfun(@minus,x, mu);
z = bsxfun(@rdivide, z, sigma0);

