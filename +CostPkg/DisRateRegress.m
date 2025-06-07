% ---------------------------
% (1) Put the data into MATLAB
% ---------------------------
years = (2010:2030)';       % 21 rows total
prices = [ ...
  1183; 917; 721; 663; 588; 381; 293; 219; 180; 156; 
   137; 122; 109; 100;  92;  84;  77;  71;  66;  63;  62 ];

% If you only want "past" (2010–2020), do:
idx_past = (years <= 2020);
years_past  = years(idx_past);
prices_past = prices(idx_past);

% If you want to fit across the entire 2010–2030 window, just use (years, prices) directly.


% -----------------------------------------
% (2a) Fit an exponential decay to 2010--2020
% -----------------------------------------
t = years_past;            % [2010; 2011; ...; 2020]
P = prices_past;           % [1183; 917; ...; 137]
Y = log(P);                % natural log of price

% Fit ln(P) = a + b * t  =>  b should be ~ -r
coe_past = polyfit( t, Y, 1 );
% coe_past(1) = slope = b_past;   coe_past(2) = intercept = a_past

b_past = coe_past(1);
r_past = -b_past;      % annual discount (decay) rate, in year^-1
P0_past = exp( coe_past(2) );  % gives the coefficient at t=0 (not terribly meaningful, but for reference)

fprintf('--- Fit using 2010–2020 data only ---\n');
fprintf('slope b_past = %g  =>  r_past = %g  (approx. %2.2f%% per year decay)\n', ...
         b_past, r_past, 100*r_past);
fprintf('Intercept = %g  (so exp(intercept) = P0 estimate)\n\n', coe_past(2));

% ------------------------------------------
% (2b) Fit an exponential decay to 2010--2030
% ------------------------------------------
t_full = years;           % [2010:2030]'
P_full = prices;          % [1183; 917; ...; 62]
Y_full = log(P_full);

coe_full = polyfit( t_full, Y_full, 1 );
b_full = coe_full(1);
r_full = -b_full;        % discount rate over entire 2010–2030 period
P0_full = exp( coe_full(2) );

fprintf('--- Fit using 2010–2030 data ---\n');
fprintf('slope b_full = %g  =>  r_full = %g  (approx. %2.2f%% per year decay)\n', ...
         b_full, r_full, 100*r_full);
fprintf('Intercept = %g  (so exp(intercept) approx initial P0)\n\n', coe_full(2));

% ----------------------------------------------------------------
% (3) Plot actual price vs. year, and overlay the exponential fit
% ----------------------------------------------------------------
figure;
scatter(years, prices,  75, 'b', 'filled');
hold on;

% Generate a smooth curve from 2010 to 2030
tt = (2010:0.1:2030)';      % fine grid in year
P_fit = exp( polyval(coe_full, tt) );  % polyval returns ln(P), so exp() gives P

plot(tt, P_fit, 'r-', 'LineWidth', 2);
hold off;
grid on;
xlabel('Year', 'FontSize', 12);
ylabel('Battery Price ($/kWh)', 'FontSize', 12);
legend({'Actual data (2010–2030)', 'Exp‐decay fit (2010–2030)'}, ...
       'Location','Northeast');
title(sprintf('Battery Price vs Year  (r = %.2f %%/yr)', 100*r_full), ...
       'FontSize', 14);
% ----------------------------------------
% (Optional) Fit a straight line: P = m*t + c
% ----------------------------------------
p_lin = polyfit(years, prices, 1);
% p_lin(1) = slope m_lin;  p_lin(2) = intercept c_lin
m_lin = p_lin(1);
c_lin = p_lin(2);

fprintf('Linear fit:  P ≈ %.3f * t  +  %.3f\n', m_lin, c_lin);
fprintf('  =>  That slope means price falls by %g $/kWh per year on average.\n', ...
        m_lin );
