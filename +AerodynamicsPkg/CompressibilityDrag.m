function CompDragCoeff = CompressibilityDrag(Inputs)
% Calculate compressibility drag coefficient
% Inputs should be a struct containing all required fields

% Calculate Mach difference
DelMach = Inputs.Mach - Inputs.DesignMach;

% Find indices for supersonic and subsonic regions
IdxSuper = find(DelMach > 0.05);
IdxSub = find(DelMach <= 0.05);

% Initialize output array
CompDragCoeff = zeros(size(Inputs.Mach));

% setup the tables
[PCW, BSUB, PCAR, BSUP, WFI] = SetupTables();

% Calculate supersonic drag if needed
if ~isempty(IdxSuper)
    CdcSuper = ComputeSupersonic(Inputs, IdxSuper, PCAR, BSUP, WFI);
    CompDragCoeff(IdxSuper) = CdcSuper;
end

% Calculate subsonic drag if needed
if ~isempty(IdxSub)
    CdcSub = ComputeSubsonic(Inputs, IdxSub, PCW, BSUB );
    CompDragCoeff(IdxSub) = CdcSub;
end
end

function [PCWTab, BSUBTab, PCARTab, BSUPTab, WFITab] = SetupTables()

PCW = [
    13007.0, 0.100, 0.120, 0.140, 0.160, 0.180, 0.220, 0.300;
    -0.800, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00;
    -0.200, 0.0600, 0.040, 0.020, 0.0200, 0.0100, 0.0080, 0.0020;
    -0.160, 0.0720, 0.050, 0.030, 0.0260, 0.0170, 0.0160, 0.0060;
    -0.120, 0.1000, 0.060, 0.040, 0.0380, 0.0250, 0.0240, 0.0120;
    -0.080, 0.1250, 0.080, 0.050, 0.0490, 0.0350, 0.0330, 0.0190;
    -0.040, 0.1600, 0.120, 0.080, 0.0680, 0.0540, 0.0470, 0.0300;
    -0.020, 0.2000, 0.160, 0.120, 0.1100, 0.0700, 0.0590, 0.0390;
     0.000, 0.2800, 0.220, 0.160, 0.1200, 0.0930, 0.0770, 0.0520;
     0.010, 0.3400, 0.270, 0.200, 0.1520, 0.1180, 0.0930, 0.0610;
     0.020, 0.4400, 0.330, 0.240, 0.1970, 0.1530, 0.1170, 0.0730;
     0.030, 0.6400, 0.450, 0.310, 0.2550, 0.2030, 0.1480, 0.0870;
     0.040, 1.1000, 0.660, 0.410, 0.3250, 0.2700, 0.1870, 0.1030;
     0.050, 1.9000, 1.020, 0.560, 0.4000, 0.3500, 0.2350, 0.1270
];

BSUB = [
    17004.0, 1.00, 1.20, 1.40, 1.50;
    0.2000, 0.00, 0.00, 0.00, 0.00;
    0.5000, 0.00, 0.00, 0.00, 0.00;
    0.7000, 0.00, 0.00, 0.00, 0.00;
    0.7800, 0.00, 0.00, 0.00, 0.00;
    0.8200, 0.00, 0.00, 0.150, 0.210;
    0.8400, 0.00, 0.150, 0.200, 0.350;
    0.8600, 0.090, 0.220, 0.400, 0.520;
    0.8800, 0.200, 0.380, 0.610, 0.780;
    0.9000, 0.380, 0.580, 0.910, 1.100;
    0.9100, 0.530, 0.750, 1.100, 1.330;
    0.9200, 0.730, 0.950, 1.300, 1.600;
    0.9300, 0.950, 1.200, 1.650, 1.930;
    0.9400, 1.300, 1.550, 2.050, 2.490;
    0.9500, 1.750, 2.200, 2.900, 3.650;
    0.9600, 2.450, 3.250, 4.500, 6.400;
    0.9650, 3.000, 4.220, 6.300, 8.450;
    0.9700, 3.900, 5.600, 9.500, 11.500
];

PCAR = [
    16009.0, 1.00, 1.50, 2.00, 2.50, 3.00, 3.50, 4.00, 5.00, 6.00;
    0.050, 2.400, 1.700, 1.170, 0.850, 0.730, 0.670, 0.600, 0.540, 0.520;
    0.070, 3.100, 2.250, 1.580, 1.100, 0.890, 0.770, 0.700, 0.620, 0.600;
    0.090, 3.550, 2.610, 1.880, 1.240, 0.990, 0.870, 0.750, 0.670, 0.650;
    0.110, 3.850, 2.880, 2.030, 1.330, 1.070, 0.920, 0.800, 0.710, 0.680;
    0.130, 3.970, 3.050, 2.140, 1.410, 1.120, 0.960, 0.840, 0.740, 0.710;
    0.150, 4.000, 3.100, 2.170, 1.480, 1.160, 0.990, 0.860, 0.750, 0.720;
    0.200, 3.900, 3.000, 2.200, 1.550, 1.200, 1.000, 0.860, 0.740, 0.700;
    0.250, 3.680, 2.850, 2.160, 1.570, 1.200, 1.000, 0.830, 0.700, 0.650;
    0.300, 3.430, 2.700, 2.100, 1.550, 1.170, 0.920, 0.770, 0.630, 0.580;
    0.400, 3.030, 2.450, 1.900, 1.470, 1.100, 0.880, 0.730, 0.590, 0.530;
    0.500, 2.750, 2.220, 1.710, 1.370, 1.020, 0.840, 0.730, 0.570, 0.520;
    0.600, 2.490, 2.000, 1.550, 1.260, 0.970, 0.810, 0.740, 0.560, 0.510;
    0.700, 2.250, 1.800, 1.410, 1.170, 0.910, 0.790, 0.710, 0.550, 0.510;
    0.800, 1.990, 1.620, 1.300, 1.100, 0.880, 0.750, 0.700, 0.550, 0.500;
    0.900, 1.800, 1.500, 1.200, 1.000, 0.840, 0.700, 0.660, 0.540, 0.500;
    1.000, 1.650, 1.400, 1.100, 0.950, 0.800, 0.700, 0.660, 0.540, 0.500
];

BSUP = [
    14006.0, 1.00, 1.10, 1.20, 1.30, 1.40, 1.50;
    1.000, 24.50, 20.00, 16.20, 13.40, 11.10, 9.50;
    1.050, 30.70, 23.60, 20.00, 16.00, 12.90, 10.50;
    1.100, 33.00, 26.20, 21.50, 17.40, 14.00, 11.10;
    1.150, 34.30, 27.30, 22.30, 18.20, 14.80, 11.60;
    1.200, 34.70, 27.70, 22.50, 18.50, 15.00, 11.90;
    1.250, 34.50, 27.50, 22.40, 18.20, 14.90, 11.90;
    1.300, 33.80, 27.00, 22.00, 17.60, 14.50, 11.70;
    1.350, 32.90, 26.40, 21.70, 17.30, 14.20, 11.40;
    1.400, 32.40, 25.90, 21.40, 17.20, 14.10, 11.00;
    1.500, 32.00, 25.60, 21.10, 17.00, 14.10, 10.90;
    1.600, 32.00, 25.60, 21.00, 17.00, 14.10, 10.90;
    1.800, 32.00, 25.60, 21.00, 17.00, 14.20, 11.40;
    2.000, 32.00, 25.60, 21.00, 17.10, 14.40, 11.80;
    2.200, 32.00, 25.60, 21.00, 17.30, 14.60, 12.00
];

WFI = [
    13010.0, 0.10, 0.120, 0.140, 0.150, 0.160, 0.170, 0.180, 0.190, 0.200, 0.220;
    1.000, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0;
    1.050, 0.0, 0.0, 0.00040, -0.00030, -0.00080, -0.00110, -0.00100, -0.00040, 0.00030, 0.00180;
    1.100, 0.0, 0.0, 0.00060, -0.00060, -0.00140, -0.00180, -0.00140, -0.00060, 0.00040, 0.00260;
    1.150, 0.0, 0.0, 0.00030, -0.00080, -0.00170, -0.00200, -0.00150, -0.00060, 0.00040, 0.00240;
    1.200, 0.0, 0.0, 0.00020, -0.00080, -0.00170, -0.00180, -0.00140, -0.00060, 0.00030, 0.00200;
    1.300, 0.0, 0.0, 0.00020, -0.00060, -0.00100, -0.00100, -0.00080, -0.00050, 0.00010, 0.00120;
    1.400, 0.0, 0.0, 0.00010, -0.00030, -0.00030, -0.00030, -0.00020, -0.00010, 0.00030, 0.00090;
    1.500, 0.0, 0.0, 0.00010, 0.00000, 0.00030, 0.00030, 0.00040, 0.00040, 0.00050, 0.00070;
    1.600, 0.0, 0.0, 0.00000, 0.00040, 0.00050, 0.00090, 0.00090, 0.00080, 0.00070, 0.00050;
    1.700, 0.0, 0.0, 0.00000, 0.00050, 0.00070, 0.00120, 0.00110, 0.00100, 0.00080, 0.00050;
    1.800, 0.0, 0.0, 0.00000, 0.00060, 0.00090, 0.00120, 0.00110, 0.00100, 0.00080, 0.00050;
    1.900, 0.0, 0.0, 0.00000, 0.00060, 0.00090, 0.00100, 0.00100, 0.00090, 0.00080, 0.00050;
    2.000, 0.0, 0.0, 0.00000, 0.00050, 0.00090, 0.00110, 0.00100, 0.00090, 0.00070, 0.00050
];

% Create interpolation tables
% Extract x and y coordinates and values for each table
[PCW_x, PCW_y] = meshgrid(PCW(1,2:end), PCW(2:end,1));
PCW_z = PCW(2:end, 2:end);

PCWTab.x = PCW_x;
PCWTab.y = PCW_y;
PCWTab.z = PCW_z;

[BSUB_x, BSUB_y] = meshgrid(BSUB(1,2:end), BSUB(2:end,1));
BSUB_z = BSUB(2:end, 2:end);

BSUBTab.x = BSUB_x;
BSUBTab.y = BSUB_y;
BSUBTab.z = BSUB_z;

[PCAR_x, PCAR_y] = meshgrid(PCAR(1,2:end), PCAR(2:end,1));
PCAR_z = PCAR(2:end, 2:end);

PCARTab.x = PCAR_x;
PCARTab.y = PCAR_y;
PCARTab.z = PCAR_z;

[BSUP_x, BSUP_y] = meshgrid(BSUP(1,2:end), BSUP(2:end,1));
BSUP_z = BSUP(2:end, 2:end);

BSUPTab.x = BSUP_x;
BSUPTab.y = BSUP_y;
BSUPTab.z = BSUP_z;

[WFI_x, WFI_y] = meshgrid(WFI(1,2:end), WFI(2:end,1));
WFI_z = WFI(2:end, 2:end);

WFITab.x = WFI_x;
WFITab.y = WFI_y;
WFITab.z = WFI_z;

end

function CdcSuper = ComputeSupersonic(Inputs, Idx, PCAR, BSUP, WFI)
% Calculate compressibility drag for supersonic speeds
Mach = Inputs.Mach(Idx);
Nn = length(Mach);
DelMach = Mach - Inputs.DesignMach;
AR = Inputs.AspectRatio;
TC = Inputs.ThicknessToChord;
MaxCamber70 = Inputs.MaxCamberAt70Semispan;
Sweep25 = Inputs.Sweep;
WingTaperRatio = Inputs.TaperRatio;
FuseArea = Inputs.FuselageCrossSection;
BaseArea = Inputs.BaseArea;
WingArea = Inputs.WingArea;
FuselageLenToDiamRatio = Inputs.FuselageLengthToDiameter;
DiamToWingSpanRatio = Inputs.FuselageDiameterToWingSpan;

% Calculate ART
ART = AR * tan(Sweep25/57.2958) + (1.0 - WingTaperRatio)/(1.0 + WingTaperRatio);

% Prepare interpolation points
X = zeros(Nn, 2);
X(:,1) = DelMach;
X(:,2) = ART;

% Interpolate CD3 from PCAR table
CD3 = interp2(PCAR.x, PCAR.y, PCAR.z, X(:,1), X(:,2), 'linear');

% Clamp negative values to zero
CD3(CD3 <= 0) = 0;

% Calculate wing compressibility drag
CompressDragCoeff = CD3 .* (TC^(5.0/3.0) * (1.0 + 0.1 * MaxCamber70));

% Add fuselage contribution if present
if FuseArea > 0.0
    SOS = 1.0 + BaseArea/FuseArea;
    X(:,1) = Mach;
    X(:,2) = SOS;
    
    % Interpolate CD4 from BSUP table
    CD4 = interp2(BSUP.x, BSUP.y, BSUP.z, X(:,1), X(:,2), 'linear');
    
    % Clamp negative values to zero
    CD4(CD4 <= 0) = 0;
    
    % Calculate fuselage compressibility drag
    FuselageCompressDragCoeff = CD4 .* (FuseArea/WingArea * (1.0/FuselageLenToDiamRatio^2));
    
    CompressDragCoeff = CompressDragCoeff + FuselageCompressDragCoeff;
    
    % Add wing-fuselage interference for Mach >= 1.0
    IdxMach = find(Mach >= 1.0);
    if ~isempty(IdxMach)
        X(:,2) = DiamToWingSpanRatio;
        
        % Interpolate CD5 from WFI table
        CD5 = interp2(WFI.x, WFI.y, WFI.z, X(IdxMach,1), X(IdxMach,2), 'linear');
        
        % Handle special case for wing taper ratio
        if WingTaperRatio == 1.0
            WingTaperRatio = 0.5;
        end
        
        % Calculate interference drag
        IntCompressDragCoeff = CD5 .* (1.0/(1.0 - WingTaperRatio)/cos(Sweep25/57.2958));
        
        CompressDragCoeff(IdxMach) = CompressDragCoeff(IdxMach) + IntCompressDragCoeff;
    end
end

CdcSuper = CompressDragCoeff;
end

function CdcSub = ComputeSubsonic(Inputs, Idx, PCW, BSUB)
% Calculate compressibility drag for subsonic speeds
Mach = Inputs.Mach(Idx);
Nn = length(Mach);
DelMach = Mach - Inputs.DesignMach;
TC = Inputs.ThicknessToChord;
MaxCamber70 = Inputs.MaxCamberAt70Semispan;
FuseArea = Inputs.FuselageCrossSection;
BaseArea = Inputs.BaseArea;
WingArea = Inputs.WingArea;
FuselageLenToDiamRatio = Inputs.FuselageLengthToDiameter;

% Calculate TOC
TOC = TC^(2.0/3.0);

% Prepare interpolation points
X = zeros(Nn, 2);
X(:,1) = DelMach;
X(:,2) = TOC;

% Interpolate CD1 from PCW table
CD1 = interp2(PCW.x, PCW.y, PCW.z, X(:,1), X(:,2), 'linear');

% Clamp negative values to zero
CD1(CD1 <= 0) = 0;

% Calculate wing compressibility drag
CompressDragCoeff = CD1 .* (TC^(5.0/3.0) * (1.0 + 0.1 * MaxCamber70));

% Add fuselage contribution if present
if FuseArea > 0.0
    SOS = 1.0 + BaseArea/FuseArea;
    X(:,1) = Mach;
    X(:,2) = SOS;
    
    % Interpolate CD2 from BSUB table
    CD2 = interp2(BSUB.x, BSUB.y, BSUB.z, X(:,1), X(:,2), 'linear');
    
    % Clamp negative values to zero
    CD2(CD2 <= 0) = 0;
    
    % Calculate fuselage compressibility drag
    FuselageCompressDragCoeff = CD2 .* (FuseArea/WingArea * (1.0/FuselageLenToDiamRatio^2));
    
    CompressDragCoeff = CompressDragCoeff + FuselageCompressDragCoeff;
end

CdcSub = CompressDragCoeff;
end