function [] = ProcessSampleData(FileName)
%
% [] = ProcessSampleData(FileName)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 19 jan 2026
%
% given a set of samples, compute the distances between points, how
% frequently they occur, and the discrepancy between the distribution of
% distances relative to a normal distribution.
%
% INPUTS:
%     FileName - the .xlsx sheet to be input.
%                size/type/units: 1-by-1 / string / []
%
% OUTPUTS:
%     none
%

% initial cleanup
clc, close all


%% DATA IMPORT %%
%%%%%%%%%%%%%%%%%

% import the sampling plan
MyTab = readtable(FileName);

% extract all values (except the response)
X = table2array(MyTab(:, 1:end-1));


%% COMPUTE THE DISTANCE AND DISCREPANCY %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute the distances
[J, Dist] = jd(X, 1);

% compute the discrepancy
Disc = centered_L2_discrepancy(X);


%% PLOT RESULTS %%
%%%%%%%%%%%%%%%%%%

% plot a histogram (account for the multiplicity of each distance reported)
histogram(repelem(Dist, J));

% axis labels
xlabel("Distance");
ylabel("Frequency");

% plot title
title(sprintf("Discrepancy = %.4e", Disc));

% enlarge the font
set(gca, "FontSize", 18);

% ----------------------------------------------------------

end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function [J,distinct_d] = jd(X, p)
% Computes the distances between all pairs of points in a sampling plan X
% using the p-norm, sorts  them  in  ascending order and removes multiple 
% occurences. 
%
% Inputs:
%       X - sampling plan being evaluated
%       p - distance norm (p=1 rectangular - default, p=2 Euclidean)
%
% Outputs:
%       J - multiplicity array (that is, the number of pairs separated by 
%           each distance value).
%       distinct_d - list of distinct distance values
%
% Copyright 2007 A Sobester
%
% This program is free software: you can redistribute it and/or modify  it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any
% later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License and GNU
% Lesser General Public License along with this program. If not, see
% <http://www.gnu.org/licenses/>.

% assume a 1-norm unless specified otherwise
if (nargin < 2)
    p = 1;
end

% extract the sampling plan
% Number of points in the sampling plan
n = size(X,1);

% Compute the distances between all pairs of points
d = zeros(1,n*(n-1)/2);

for i = 1:n-1
    for j = i+1:n
            % Distance metric: p-norm
            d((i-1)*n-(i-1)*i/2+j-i) = norm(X(i,:)-X(j,:),p);	    
    end
end

% Remove multiple occurences
distinct_d = unique(d);

% Pre-allocate memory for J
J = zeros(size(distinct_d));

% Generate multiplicity array
for i = 1:length(distinct_d)
    % J(i) will contain the number of pairs separated
    % by the distance distinct_d(i)
    J(i) = sum(ismember(d,distinct_d(i)));
end
end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function Dc2 = centered_L2_discrepancy(X)
% CENTERED_L2_DISCREPANCY Computes the centered L2 discrepancy
% written by ChatGPT
%
% INPUT:
%   X  - N x d matrix of sample points in [0,1]^d
%
% OUTPUT:
%   Dc2 - centered L2 discrepancy value
%
% Reference:
%   Hickernell, F. J. (1998). A generalized discrepancy and quadrature error bound.

% get the number of samples and design space dimension
[N, d] = size(X);

% Term 1
term1 = (13/12)^d;

% Term 2
term2 = 0;
for i = 1:N
    prod_i = 1;
    for k = 1:d
        prod_i = prod_i * ...
            (1 + 0.5 * abs(X(i,k) - 0.5) ...
            - 0.5 * abs(X(i,k) - 0.5)^2);
    end
    term2 = term2 + prod_i;
end
term2 = (2 / N) * term2;

% Term 3
term3 = 0;
for i = 1:N
    for j = 1:N
        prod_ij = 1;
        for k = 1:d
            prod_ij = prod_ij * ...
                (1 + 0.5 * abs(X(i,k) - 0.5) ...
                + 0.5 * abs(X(j,k) - 0.5) ...
                - 0.5 * abs(X(i,k) - X(j,k)));
        end
        term3 = term3 + prod_ij;
    end
end
term3 = term3 / N^2;

% Centered L2 discrepancy
Dc2 = sqrt(term1 - term2 + term3);

end