function [] = MorrisScreening()
%
% [] = MorrisScreening()
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 29 jan 2026
%
% adapted from code written by Forrester and Sobester from their
% "Engineering Design via Surrogate Modelling: A Practical Guide" textbook
%
% utilize the morris method for screening to identify the dominant
% variables in the aircraft sizing process.
%
% INPUTS:
%     none
%
% OUTPUTS:
%     none
%

% seed the random number generator for repeatable outcomes
rng(16);

% define the range of values for each variable
Range = [ ...
     80    , 100    ; ... % passengers, discrete
    650    , 850    ; ... % design range (m), continuous
      0.55 ,   0.65 ; ... % cruise speed (mach), continuous
      8    ,  12    ; ... % maximum r/c (m/s), continuous
      0.120,   0.600; ... % battery specific energy (kWh/kg), continuous
      3    ,   7    ; ... % electric motor power-to-weight ratio (kW/kg), continuous
      3    ,   7    ; ... % electric generator power-to-weight ratio (kW/kg), continuous
      1    ,   3    ; ... % propulsion architecture, discrete
     40    ,  80    ; ... % battery cells in series (for HTE), discrete
      4    ,  12    ; ... % takeoff power split (for HTE), continuous
      0    ,   3    ; ... % climb power split (for HTE), continuous
      1    ,   6    ; ... % propulsors on half of the DTE propulsion system, discrete
      2    ,   6    ; ... % L/D benefit for DEP systems, continuous
     22    ,  26    ; ... % cruise l/d, continuous
     17.6  ,  20.8  ; ... % climb l/d, continuous
    ]';

% define the number of design variables
k = length(Range);

% define the number of levels along each dimension
p = 10;

% number of random orientations - keep as is from textbook
r = 20;

% define the step length factor - keep as is from textbook
xi = 1;

% create a screening plan (from uniform distribution)
UnifX = screeningplan(k, p, xi, r);

% get the number of samples
nsamp = size(UnifX, 1);

% reset discrete variable values
UnifX(:, [1, 8, 9, 12]) = rand(nsamp, 4);

% get the design data
X = Range(1, :) + (Range(2, :) - Range(1, :)) .* UnifX;

% ensure the discrete variables are integer values
X(:, [1, 8, 9, 12]) = round(X(:, [1, 8, 9, 12]));

% allocate memory for the function evaluations
F = zeros(nsamp, 1);
W = zeros(nsamp, 1);

% loop through all the samples
parfor isamp = 1:nsamp
    
    % try to run it
    try
        
        % get the aircraft
        AC = AircraftSpecsPkg.RegionalTurboprop(0);
        
        % set the number of passengers
        AC.Specs.TLAR.MaxPax = X(isamp, 1);
        
        % set the design range
        AC.Specs.Performance.Range = X(isamp, 2) * 1000;
        
        % set the cruise speed
        AC.Specs.Performance.Vels.Crs = X(isamp, 3);
        
        % set the maximum rate of climb
        AC.Specs.Performance.RCMax = X(isamp, 4);
        
        % set the battery gravimetric specific energy
        AC.Specs.Power.SpecEnergy.Batt = X(isamp, 5);
        
        % set the electric motor and generator power-to-weight ratios
        AC.Specs.Power.P_W.EM = X(isamp, 6);
        AC.Specs.Power.P_W.EG = X(isamp, 7);
        
        % get the propulsion system architecture
        iarch = X(isamp, 8);
        
        % check the propulsion architecture
        if     (iarch == 2)
            
            % set the number of battery cells in series
            AC.Specs.Power.Battery.SerCells = X(isamp, 9);
            
            % set the takeoff and climb power splits
            AC.Specs.Power.LamDwn.SLS = X(isamp, 10);
            AC.Specs.Power.LamDwn.Tko = X(isamp, 10);
            AC.Specs.Power.LamDwn.Clb = X(isamp, 11);
            
        elseif (iarch == 3)
            
            % set the number of distributed propulsors
            AC.Specs.Propulsion.NumDTE = X(isamp, 12) * 2;
            
        end
        
        % set the lift-to-drag ratios
        if (iarch == 3)
            
            % get the multiplicative factor
            LDMult = 1 + X(isamp, 13) / 100;
            
        else
            
            % no multiplicative factor
            LDMult = 1;
            
        end
        
        % set the lift-to-drag ratios
        AC.Specs.Aero.L_D.Crs = X(isamp, 14) * LDMult;
        AC.Specs.Aero.L_D.Clb = X(isamp, 15) * LDMult;
        AC.Specs.Aero.L_D.Des = X(isamp, 15) * LDMult;
        
        % create the propulsion architecture
        AC = AircraftSpecsPkg.RegionalTurbopropPropulsion(AC, iarch);
        
        % size the aircraft
        ACOut = Main(AC, @MissionProfilesPkg.RegionalTurbopropMission);
        
        % get the fuel burn
        F(isamp) = ACOut.Specs.Weight.Fuel;
        W(isamp) = ACOut.Specs.Weight.MTOW;
        
    catch
        
        % sample failed
        F(isamp) = NaN;
        W(isamp) = NaN;
        
    end    
end

% filter out NaN
idx = isnan(F) | isnan(W);

% remove all NaN
X(idx, :) = [];
F(idx, :) = [];
W(idx, :) = [];

% save the data
save("MorrisScreening.mat", "X", "F", "W");

% create a screening plot for fuel burn
screening_plot(X, F, xi, p, ...
    {'Pax','R','M_{Crs}','R/C','e_{batt}', ...
     'P/W_{(EM)}', 'P/W_{(EG)}', 'A', 'CiS', ...
     '\lambda_{Tko}', '\lambda_{Clb}', 'n_{prop}', ...
     'k_{(L/D)}', 'L/D_{Crs}', 'L/D_{Clb}' ...
    });

% create a screening plot for MTOW
screening_plot(X, W, xi, p, ...
    {'Pax','R','M_{Crs}','R/C','e_{batt}', ...
     'P/W_{(EM)}', 'P/W_{(EG)}', 'A', 'CiS', ...
     '\lambda_{Tko}', '\lambda_{Clb}', 'n_{prop}', ...
     'k_{(L/D)}', 'L/D_{Crs}', 'L/D_{Clb}' ...
    });

% ----------------------------------------------------------

end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function Bstar = randorient(k, p, xi)
% Generates a random orientation for a screening matrix
%
% Inputs:
%       k - number of design variables
%       p - number of discreet levels along each dimension
%       xi- elementery effect step length factor
%
% Output:
%       Bstar - random orientation matrix
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


% Step length
Delta = xi/(p-1);

m = k + 1;

% A truncated p-level grid in one dimension
xs = (0:1/(p-1):1-Delta);
xsl = length(xs);

% Basic sampling matrix
B = [zeros(1,k); tril(ones(k))];

% Randomization

% Matrix with +1s and -1s on the diagonal with equal probability
Dstar = diag(2*round(rand(1,k))-1);

% Random base value
xstar = xs(floor(rand(1,k)*xsl)+1);

% Permutation matrix
Pstar = zeros(k);
rp = randperm(k);
for i=1:k, Pstar(i,rp(i))=1; end

% A random orientation of the sampling matrix
Bstar = (ones(m,1)*xstar+(Delta/2)*...
    ((2*B-ones(m,k))*Dstar+ones(m,k)))*Pstar;

end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function X = screeningplan(k, p, xi, r)
% Generates a Morris screening plan with a specified number of elementary
% effects for each variable.
%
% Inputs:
%       k - number of design variables
%       p - number of discreet levels along each dimension
%       xi- elementery effect step length factor
%       r - number of random orientations (=number of elementary effects
%           per variable).
%
% Output:
%       X - screening plan built within a [0,1]^k box
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


X = [];
for i=1:r
    X = [X; randorient(k,p,xi)];
end
end

% ----------------------------------------------------------
% ----------------------------------------------------------
% ----------------------------------------------------------

function screening_plot(X, t, xi, p, Labels)
% Generates a variable elementary effect screening plot
%
% Inputs:
%       X - screening plan built within a [0,1]^k box (e.g. with
%           screening_plan.m)
%       Objhandle - name of the objective function
%       Range - 2xk matrix (k - number of design variables) of lower bounds
%               (first row) and upper bounds (second row) on each variable.
%       xi- elementery effect step length factor
%       p - number of discreet levels along each dimension
%       Labels - 1xk cell array containing the names of the variables
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

k = size(X,2);
r = size(X,1)/(k+1);

for i=1:r
    for j = (i-1)*(k+1)+1:(i-1)*(k+1)+k
       F(find(X(j,:)-X(j+1,:)~=0),i) = (t(j+1)-t(j))/(xi/(p-1));
    end
end

% Compute statistical measures
for i=1:k
    ssd(i) = std(F(i,:));
    sm(i)  = mean(F(i,:));
end
 
figure, hold on
 
for i=1:k
    text(sm(i),ssd(i),Labels(i),'FontSize',25)
end
 
axis([min(sm-25) max(sm+100) min(ssd-25) max(ssd+50)]);
xlabel('Sample means')
ylabel('Sample standard deviations')
set(gca,'FontSize',14)   

end