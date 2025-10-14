n = 15;
lams_tko = linspace(0,1,n);
lams_clb = linspace(0,.15,n);
fburn = zeros(n,n);
batt = zeros(n,n);
for itko = 1:n
    for iclb = 1:n
        Aircraft = Aircraft2;
        %Aircraft = ans;
        Aircraft.Specs.Performance.Range = UnitConversionPkg.ConvLength(800, "naut mi", "m");
        Aircraft.Settings.Analysis.Type = -1;
        
        Aircraft.Specs.Weight.EM = 400;
        
        Aircraft.Specs.Power.P_W.EM = 10;
        
        Aircraft.Specs.Propulsion.SLSPower(:,[3,4]) = [200,200]*10*1000; % EM weight x spec pow x watt/kw
        Aircraft.Specs.Propulsion.SLSThrust(:,[3,4]) = Aircraft.Specs.Propulsion.SLSPower(:,[3,4])/Aircraft.Specs.Performance.Vels.Tko;
        
        Aircraft.Specs.Power.LamUps = [];
        Aircraft.Specs.Power.LamDwn = [];
        % upstream power splits
        Aircraft.Specs.Power.LamUps.SLS = 1;

            Aircraft.Specs.Power.LamUps.Tko = lams_tko(itko);
     

        if lams_clb(iclb)==0
            Aircraft.Specs.Power.LamUps.Clb = 0;
        else
            Aircraft.Specs.Power.LamUps.Clb = 1;
        end
        Aircraft.Specs.Power.LamUps.Crs = 0;
        Aircraft.Specs.Power.LamUps.Des = 0;
        Aircraft.Specs.Power.LamUps.Lnd = 0;
        
        
        % downstream power splits
        Aircraft.Specs.Power.LamDwn.SLS = .15;
        
        Aircraft.Specs.Power.LamDwn.Tko = .15;
        Aircraft.Specs.Power.LamDwn.Clb = lams_clb(iclb);
        Aircraft.Specs.Power.LamDwn.Crs = 0;
        Aircraft.Specs.Power.LamDwn.Des = 0;
        Aircraft.Specs.Power.LamDwn.Lnd = 0;
        
        % settings
        Aircraft.Settings.PowerStrat = -1;
        Aircraft.Settings.PowerOpt = 0;
        % -1 = prioritize downstream, go from fan back to energy sources
        
        Aircraft = Main(Aircraft, @MissionProfilesPkg.NarrowBodyMission);
        %end
        fburn(iclb,itko) = Aircraft.Specs.Weight.Fuel;
        batt(iclb,itko) = Aircraft.Specs.Weight.Batt;
    end
end

%%
[X,Y]= meshgrid(lams_tko, lams_clb);
figure;
hold on;
scatter(X, Y, 50, fburn, 'filled'); % Points inside with color
colorbar; % Add a colorbar for the colormap
colormap('jet'); % Choose a colormap, e.g., 'jet'
plot(CornerRange, CornerPayload, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'Color', 'black'); % Line with markers
xlabel('Range (nm)');
ylabel('Payload (kg)');
title('Baseline Aircraft Fuel Burn (kg) Colormap');
grid on;
hold off;