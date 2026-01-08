function [Aircraft] = RegionalTurbopropPropulsion(Aircraft, iarch)
%
% [Aircraft] = RegionalTurbopropPropulsion(Aircraft, iarch)
% written by Paul Mokotoff, prmoko@umich.edu
% last updated: 08 jan 2026
%
% define the propulsion system architectures and power management
% strategies for a regional turboprop aircraft.
%
% INPUTS:
%     Aircraft - data structure with information about the aircraft.
%                size/type/units: 1-by-1 / struct / []
%
%     iarch    - propulsion system architecture to be defined. the power
%                management strategy remains fixed for this sizing study.
%                the following system architectures are available:
%
%                    a) 0 = architecture to be defined later.
%
%                    b) 1 = turboelectric architecture - one gas turbine
%                           engine powering two electric motors (one per
%                           wing).
%
%                    c) 2 = hybrid turboelectric architecture - one gas
%                           turbine engine powering two electric motors
%                           one per wing). the electric motor output power
%                           is supplemented by a battery.
%
%                    d) 3 = distributed turboelectric architecture - one
%                           gas turbine engine powers six electric motors
%                           (three per wing).
%
%                size/type/units: 1-by-1 / integer / []
%
% OUTPUTS:
%     Aircraft - data structure with information about the propulsion
%                system and its operation added.
%                size/type/units: 1-by-1 / struct / []
%

% check if a propulsion system should be made
if (iarch == 0)
    return
end


%% COMPONENT EFFICIENCY DEFINITIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% assume fixed component efficiencies for this study
EtaProp = 0.87; % propeller
EtaEG   = 0.96; % electric generator
EtaEM   = 0.96; % electric motor


%% PROPULSION SYSTEM AND POWER MANAGEMENT STRATEGY DEFINITION %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define a custom propulsion system architecture
Aircraft.Specs.Propulsion.PropArch.Type = "O";

% assume one gas turbine engine in each propulsion system
Aircraft.Specs.Propulsion.NumEngines = 1;

% check for the selected architecture
if     (iarch == +1)

    % define the architecture matrix, flow paths include: 
    %     1) fuel --> gas turbine engine --> electric generator --> electric motors --> propellers --> sink
    Arch = [ ...
      0, 1, 0, 0, 0, 0, 0, 0; ... % fuel to gas turbine engine
      0, 0, 1, 0, 0, 0, 0, 0; ... % gas turbine engine to electric generator
      0, 0, 0, 1, 1, 0, 0, 0; ... % electric generator to electric motors
      0, 0, 0, 0, 0, 1, 0, 0; ... % electric motor 1 to propeller 1
      0, 0, 0, 0, 0, 0, 1, 0; ... % electric motor 2 to propeller 2
      0, 0, 0, 0, 0, 0, 0, 1; ... % propeller 1 to the sink
      0, 0, 0, 0, 0, 0, 0, 1; ... % propeller 2 to the sink
      0, 0, 0, 0, 0, 0, 0, 0; ... % no connections past the sink
    ];

    % upstream operational matrix, utilize a 50% power split from the
    % electric generator to each electric motor
    OperUps = @() [ ...
      0, 1, 0, 0  , 0  , 0, 0, 0; ... % fuel to gas turbine engine
      0, 0, 1, 0  , 0  , 0, 0, 0; ... % gas turbine engine to electric generator
      0, 0, 0, 1/2, 1/2, 0, 0, 0; ... % electric generator to electric motors
      0, 0, 0, 0  , 0  , 1, 0, 0; ... % electric motor 1 to propeller 1
      0, 0, 0, 0  , 0  , 0, 1, 0; ... % electric motor 2 to propeller 2
      0, 0, 0, 0  , 0  , 0, 0, 1; ... % propeller 1 to the sink
      0, 0, 0, 0  , 0  , 0, 0, 1; ... % propeller 2 to the sink
      0, 0, 0, 0  , 0  , 0, 0, 0; ... % no connections past the sink
    ];

    % downstream operational matrix, utilize a 50% power split from the
    % sink to each propeller
    OperDwn = @() [ ...
        0, 0, 0, 0, 0, 0  , 0  , 0; ... % no connections past the fuel
        1, 0, 0, 0, 0, 0  , 0  , 0; ... % gas turbine engine requests fuel
        0, 1, 0, 0, 0, 0  , 0  , 0; ... % electric generator requests power from the gas turbine engine
        0, 0, 1, 0, 0, 0  , 0  , 0; ... % electric motor 1 requests power from the electric generator
        0, 0, 1, 0, 0, 0  , 0  , 0; ... % electric motor 2 requests power from the electric generator
        0, 0, 0, 1, 0, 0  , 0  , 0; ... % propeller 1 requests power from electric motor 1
        0, 0, 0, 0, 1, 0  , 0  , 0; ... % propeller 2 requests power from electric motor 2
        0, 0, 0, 0, 0, 1/2, 1/2, 0; ... % sink requests power from the propellers
    ];

    % upstream efficiency matrix (if two components are connected, use the
    % component efficiency from the one in the column)
    EtaUps = [ ...
      1, 1, 1    , 1    , 1    , 1      , 1      , 1; ... % fuel to gas turbine engine
      1, 1, EtaEG, 1    , 1    , 1      , 1      , 1; ... % gas turbine engine to electric generator
      1, 1, 1    , EtaEM, EtaEM, 1      , 1      , 1; ... % electric generator to electric motors
      1, 1, 1    , 1    , 1    , EtaProp, 1      , 1; ... % electric motor 1 to propeller 1
      1, 1, 1    , 1    , 1    , 1      , EtaProp, 1; ... % electric motor 2 to propeller 2
      1, 1, 1    , 1    , 1    , 1      , 1      , 1; ... % propeller 1 to the sink
      1, 1, 1    , 1    , 1    , 1      , 1      , 1; ... % propeller 2 to the sink
      1, 1, 1    , 1    , 1    , 1      , 1      , 1; ... % no connections past the sink
    ];

    % downstream efficiency matrix (if two components are connected, use
    % the component efficiency from the one in the row)
    EtaDwn = [ ...
        1, 1    , 1    , 1      , 1      , 1, 1, 1; ... % no connections past the fuel
        1, 1    , 1    , 1      , 1      , 1, 1, 1; ... % gas turbine engine requests fuel
        1, EtaEG, 1    , 1      , 1      , 1, 1, 1; ... % electric generator requests power from the gas turbine engine
        1, 1    , EtaEM, 1      , 1      , 1, 1, 1; ... % electric motor 1 requests power from the electric generator
        1, 1    , EtaEM, 1      , 1      , 1, 1, 1; ... % electric motor 2 requests power from the electric generator
        1, 1    , 1    , EtaProp, 1      , 1, 1, 1; ... % propeller 1 requests power from electric motor 1
        1, 1    , 1    , 1      , EtaProp, 1, 1, 1; ... % propeller 2 requests power from electric motor 2
        1, 1    , 1    , 1      , 1      , 1, 1, 1; ... % sink requests power from the propellers
    ];

    % declare the source type (1 = fuel, 0 = battery)
    SrcType = 1;
    
    % declare the transmitter type (1 = engine, 0 = electric motor, 2 = propeller/fan, 3 = electric generator, 4 = cables)
    TrnType = [1, 3, 0, 0, 2, 2];
    
    % define the downstream power management strategy (none because there
    % are no inputs to the downstream operational matrix)
    LamDwnSLS = 0;
    LamDwnTko = 0;
    LamDwnClb = 0;
    LamDwnCrs = 0;
    LamDwnDes = 0;
    LamDwnLnd = 0;
    
    % define the upstream power management strategy (none because there are
    % no inputs to the upstream operational matrix)
    LamUpsSLS = 0;
    LamUpsTko = 0;
    LamUpsClb = 0;
    LamUpsCrs = 0;
    LamUpsDes = 0;
    LamUpsLnd = 0;
    
elseif (iarch == +2)
    
    % define the architecture matrix, flow paths include: 
    %     1) fuel --> gas turbine engine --> electric generator --> electric motors --> propellers --> sink
    %     2) battery --> cables --> electric motors --> propellers --> sink
    Arch = [ ...
      0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0; ... % fuel to gas turbine engine
      0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0; ... % battery to the cables
      0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0; ... % gas turbine engine to electric generator
      0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0; ... % electric generator to electric motors
      0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0; ... % cable 1 to electric motor 1
      0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0; ... % cable 2 to electric motor 2
      0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0; ... % electric motor 1 to propeller 1
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0; ... % electric motor 2 to propeller 2
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1; ... % propeller 1 to the sink
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1; ... % propeller 2 to the sink
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; ... % no connections past the sink
    ];

    % upstream operational matrix, define two power splits:
    %     1) LamBatt: flag to turn the battery on (1) or off (0). decimal
    %                 values can also be used to provide partial power from
    %                 the battery to each electric motor.
    %     2) assume 50% power split from the electric generator to the
    %        electric motors and from the battery to the cables.
    OperUps = @(LamBatt) [ ...
      0, 0, 1, 0, 0  , 0  , 0      , 0      , 0, 0, 0; ... % fuel to gas turbine engine
      0, 0, 0, 0, 1/2, 1/2, 0      , 0      , 0, 0, 0; ... % battery to the cables
      0, 0, 0, 1, 0  , 0  , 0      , 0      , 0, 0, 0; ... % gas turbine engine to electric generator
      0, 0, 0, 0, 0  , 0  , 1/2    , 1/2    , 0, 0, 0; ... % electric generator to electric motors
      0, 0, 0, 0, 0  , 0  , LamBatt, 0      , 0, 0, 0; ... % cable 1 to electric motor 1
      0, 0, 0, 0, 0  , 0  , 0      , LamBatt, 0, 0, 0; ... % cable 2 to electric motor 2
      0, 0, 0, 0, 0  , 0  , 0      , 0      , 1, 0, 0; ... % electric motor 1 to propeller 1
      0, 0, 0, 0, 0  , 0  , 0      , 0      , 0, 1, 0; ... % electric motor 2 to propeller 2
      0, 0, 0, 0, 0  , 0  , 0      , 0      , 0, 0, 1; ... % propeller 1 to the sink
      0, 0, 0, 0, 0  , 0  , 0      , 0      , 0, 0, 1; ... % propeller 2 to the sink
      0, 0, 0, 0, 0  , 0  , 0      , 0      , 0, 0, 0; ... % no connections past the sink
    ];

    % downstream operational matrix, define two power splits:
    %     1) LamBatt: power split from the electric motor to the battery/
    %                 cables, with the remainder going to the electric
    %                 generator. set to 0 to request all power from the
    %                 electric generators. set to 1 to request all power
    %                 from the battery. use decimal values accordingly.
    %     2) assume 50% power split from the sink to the propellers.
    OperDwn = @(LamBatt) [ ...
        0, 0, 0, 0          , 0      , 0      , 0, 0, 0  , 0  , 0; ... % no connections past the fuel
        0, 0, 0, 0          , 0      , 0      , 0, 0, 0  , 0  , 0; ... % no connections past the battery
        1, 0, 0, 0          , 0      , 0      , 0, 0, 0  , 0  , 0; ... % gas turbine engine requests fuel
        0, 0, 1, 0          , 0      , 0      , 0, 0, 0  , 0  , 0; ... % electric generator requests power from the gas turbine engine
        0, 1, 0, 0          , 0      , 0      , 0, 0, 0  , 0  , 0; ... % cable 1 requests power from the battery
        0, 1, 0, 0          , 0      , 0      , 0, 0, 0  , 0  , 0; ... % cable 2 requests power from the battery
        0, 0, 0, 1 - LamBatt, LamBatt, 0      , 0, 0, 0  , 0  , 0; ... % electric motor 1 requests power from the electric generator or battery
        0, 0, 0, 1 - LamBatt, 0      , LamBatt, 0, 0, 0  , 0  , 0; ... % electric motor 2 requests power from the electric generator or battery
        0, 0, 0, 0          , 0      , 0      , 1, 0, 0  , 0  , 0; ... % propeller 1 requests power from electric motor 1
        0, 0, 0, 0          , 0      , 0      , 0, 1, 0  , 0  , 0; ... % propeller 2 requests power from electric motor 2
        0, 0, 0, 0          , 0      , 0      , 0, 0, 1/2, 1/2, 0; ... % sink requests power from the propellers
    ];

    % upstream efficiency matrix (if two components are connected, use the
    % component efficiency from the one in the column)
    EtaUps = [ ...
      1, 1, 1, 1    , 1, 1, 1    , 1    , 1      , 1      , 1; ... % fuel to gas turbine engine
      1, 1, 1, 1    , 1, 1, 1    , 1    , 1      , 1      , 1; ... % battery to the cables
      1, 1, 1, EtaEG, 1, 1, 1    , 1    , 1      , 1      , 1; ... % gas turbine engine to electric generator
      1, 1, 1, 1    , 1, 1, EtaEM, EtaEM, 1      , 1      , 1; ... % electric generator to electric motors
      1, 1, 1, 1    , 1, 1, EtaEM, 1    , 1      , 1      , 1; ... % cable 1 to electric motor 1
      1, 1, 1, 1    , 1, 1, 1    , EtaEM, 1      , 1      , 1; ... % cable 2 to electric motor 2
      1, 1, 1, 1    , 1, 1, 1    , 1    , EtaProp, 1      , 1; ... % electric motor 1 to propeller 1
      1, 1, 1, 1    , 1, 1, 1    , 1    , 1      , EtaProp, 1; ... % electric motor 2 to propeller 2
      1, 1, 1, 1    , 1, 1, 1    , 1    , 1      , 1      , 1; ... % propeller 1 to the sink
      1, 1, 1, 1    , 1, 1, 1    , 1    , 1      , 1      , 1; ... % propeller 2 to the sink
      1, 1, 1, 1    , 1, 1, 1    , 1    , 1      , 1      , 1; ... % no connections past the sink
    ];

    % downstream efficiency matrix (if two components are connected, use
    % the component efficiency from the one in the row)
    EtaDwn = [ ...
        1, 1, 1    , 1    , 1    , 1    , 1      , 1      , 1, 1, 1; ... % no connections past the fuel
        1, 1, 1    , 1    , 1    , 1    , 1      , 1      , 1, 1, 1; ... % no connections past the battery
        1, 1, 1    , 1    , 1    , 1    , 1      , 1      , 1, 1, 1; ... % gas turbine engine requests fuel
        1, 1, EtaEG, 1    , 1    , 1    , 1      , 1      , 1, 1, 1; ... % electric generator requests power from the gas turbine engine
        1, 1, 1    , 1    , 1    , 1    , 1      , 1      , 1, 1, 1; ... % cable 1 requests power from the battery
        1, 1, 1    , 1    , 1    , 1    , 1      , 1      , 1, 1, 1; ... % cable 2 requests power from the battery
        1, 1, 1    , EtaEM, EtaEM, 1    , 1      , 1      , 1, 1, 1; ... % electric motor 1 requests power from the electric generator or battery
        1, 1, 1    , EtaEM, 1    , EtaEM, 1      , 1      , 1, 1, 1; ... % electric motor 2 requests power from the electric generator or battery
        1, 1, 1    , 1    , 1    , 1    , EtaProp, 1      , 1, 1, 1; ... % propeller 1 requests power from electric motor 1
        1, 1, 1    , 1    , 1    , 1    , 1      , EtaProp, 1, 1, 1; ... % propeller 2 requests power from electric motor 2
        1, 1, 1    , 1    , 1    , 1    , 1      , 1      , 1, 1, 1; ... % sink requests power from the propellers
    ];

    % declare the source type (1 = fuel, 0 = battery)
    SrcType = [1, 0];
    
    % declare the transmitter type (1 = engine, 0 = electric motor, 2 = propeller/fan, 3 = electric generator, 4 = cables)
    TrnType = [1, 3, 4, 4, 0, 0, 2, 2];
    
    % define the downstream power management strategy: value is the power
    % split between the electric motor and battery (fraction of power
    % diverted to the battery)
    LamDwnSLS = 0.08; % (8% to battery for sizing cables)
    LamDwnTko = 0.08; % (8% to battery during takeoff)
    LamDwnClb = 0.02; % (2% to battery during any climb segment)
    LamDwnCrs = 0.00; % (no battery during cruise)
    LamDwnDes = 0.00; % (no battery during descent)
    LamDwnLnd = 0.00; % (no battery during landing)
    
    % define the upstream power management strategy: value is the fraction
    % of battery power provided with respect to the amount available
    LamUpsSLS = 1; % (allow the maximum battery power to be provided, if needed)
    LamUpsTko = 1; % (allow the maximum battery power to be provided, if needed)
    LamUpsClb = 1; % (allow the maximum battery power to be provided, if needed)
    LamUpsCrs = 0; % (no battery power used)
    LamUpsDes = 0; % (no battery power used)
    LamUpsLnd = 0; % (no battery power used)
    
elseif (iarch == +3)
    
    % get the number of propulsors
    ndte = Aircraft.Specs.Propulsion.NumDTE;
    
    % define the architecture matrix: 
    %     1) fuel --> gas turbine engine --> electric generator --> electric motors --> propellers --> sink
    Arch = [ ...
      0, 1, 0,        zeros(   1, ndte), zeros(   1, ndte),             0 ; ... % fuel to gas turbine engine
      0, 0, 1,        zeros(   1, ndte), zeros(   1, ndte),             0 ; ... % gas turbine engine to electric generator
      0, 0, 0,        ones(    1, ndte), zeros(   1, ndte),             0 ; ... % electric generator to electric motors
      zeros(ndte, 3), zeros(ndte, ndte), eye(  ndte, ndte), zeros(ndte, 1); ... % electric motors to propellers
      zeros(ndte, 3), zeros(ndte, ndte), zeros(ndte, ndte), ones( ndte, 1); ... % propellers to the sink
      0, 0, 0,        zeros(   1, ndte), zeros(   1, ndte),             0 ; ... % no connections past the sink
    ];

    % upstream operational matrix, assume an even power distribution among
    % the electric motors/propellers
    OperUps = @() [ ...
      0, 1, 0,        zeros(           1, ndte), zeros(   1, ndte),             0 ; ... % fuel to gas turbine engine
      0, 0, 1,        zeros(           1, ndte), zeros(   1, ndte),             0 ; ... % gas turbine engine to electric generator
      0, 0, 0,        repmat(1 / ndte, 1, ndte), zeros(   1, ndte),             0 ; ... % electric generator to electric motors
      zeros(ndte, 3), zeros(     ndte,    ndte), eye(  ndte, ndte), zeros(ndte, 1); ... % electric motors to propellers
      zeros(ndte, 3), zeros(     ndte,    ndte), zeros(ndte, ndte), ones( ndte, 1); ... % propellers to the sink
      0, 0, 0,        zeros(           1, ndte), zeros(   1, ndte),             0 ; ... % no connections past the sink
    ];

    % downstream operational matrix, assume an even power distribution
    % among the electric motors/propellers
    OperDwn = @() [ ...
      0, 0,                       0 , zeros(   1, ndte), zeros(           1, ndte),             0 ; ... % no connections past the fuel
      1, 0,                       0 , zeros(   1, ndte), zeros(           1, ndte),             0 ; ... % gas turbine requests fuel
      0, 1,                       0 , zeros(   1, ndte), zeros(           1, ndte),             0 ; ... % electric generator requests power from the gas turbine engine
      zeros(ndte, 2), ones( ndte, 1), zeros(ndte, ndte), zeros(     ndte,    ndte), zeros(ndte, 1); ... % electric motors request power from the electric generator
      zeros(ndte, 2), zeros(ndte, 1), eye(  ndte, ndte), zeros(     ndte,    ndte), zeros(ndte, 1); ... % propellers request power from electric motors
      0, 0,                       0 , zeros(   1, ndte), repmat(1 / ndte, 1, ndte),             0 ; ... % no connections past the sink
    ];

    % upstream efficiency matrix (if two components are connected, use the
    % component efficiency from the one in the column)
    EtaUps = [ ...
        1, 1, 1      , ones(            1, ndte), ones(   1, ndte)                                  ,            1 ; ... % fuel to gas turbine engine
        1, 1, EtaEG  , ones(            1, ndte), ones(   1, ndte)                                  ,            1 ; ... % gas turbine engine to electric generator
        1, 1, 1      , repmat(EtaEM,    1, ndte), ones(   1, ndte)                                  ,            1 ; ... % electric generator to electric motors
        ones(ndte, 3), ones(         ndte, ndte), ones(ndte, ndte) - (1 - EtaProp) * eye(ndte, ndte), ones(ndte, 1); ... % electric motors to propellers
        ones(ndte, 3), ones(         ndte, ndte), ones(ndte, ndte)                                  , ones(ndte, 1); ... % propellers to the sink
        1, 1, 1      , ones(            1, ndte), ones(   1, ndte)                                  ,            1 ; ... % sink requests power from the propellers
    ];

    % downstream efficiency matrix (if two components are connected, use
    % the component efficiency from the one in the row)
    EtaDwn = [ ...
        1, 1         ,                     1 , ones(   1, ndte)                                  , ones(   1, ndte),            1 ; ... % no connections past the fuel
        1, 1         ,                     1 , ones(   1, ndte)                                  , ones(   1, ndte),            1 ; ... % gas turbine requests fuel
        1, EtaEG     ,                     1 , ones(   1, ndte)                                  , ones(   1, ndte),            1 ; ... % electric generator requests power from the gas turbine engine
        ones(ndte, 2), repmat(EtaEM, ndte, 1), ones(ndte, ndte)                                  , ones(ndte, ndte), ones(ndte, 1); ... % electric motors request power from the electric generator
        ones(ndte, 2), ones(         ndte, 1), ones(ndte, ndte) - (1 - EtaProp) * eye(ndte, ndte), ones(ndte, ndte), ones(ndte, 1); ... % propellers request power from electric motors
        1, 1         ,                     1 , ones(   1, ndte)                                  , ones(   1, ndte),            1 ; ... % no connections past the sink
    ];

    % declare the source type (1 = fuel, 0 = battery)
    SrcType = 1;
    
    % declare the transmitter type (1 = engine, 0 = electric motor, 2 = propeller/fan, 3 = electric generator, 4 = cables)
    TrnType = [1, 3, zeros(1, ndte), repmat(2, 1, ndte)];
    
    % define the downstream power management strategy (none because there
    % are no inputs to the downstream operational matrix)
    LamDwnSLS = 0;
    LamDwnTko = 0;
    LamDwnClb = 0;
    LamDwnCrs = 0;
    LamDwnDes = 0;
    LamDwnLnd = 0;
    
    % define the upstream power management strategy (none because there are
    % no inputs to the upstream operational matrix)
    LamUpsSLS = 0;
    LamUpsTko = 0;
    LamUpsClb = 0;
    LamUpsCrs = 0;
    LamUpsDes = 0;
    LamUpsLnd = 0;
    
else
    
    % throw an error
    error("ERROR - RegionalTurbopropPropulsion: invalid propulsion system architecture selected.");

end


%% REMEMBER THE ARCHITECTURE AND POWER MANAGEMENT STRATEGY %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remember the architecture matrix
Aircraft.Specs.Propulsion.PropArch.Arch = Arch;

% remember the operational matrices
Aircraft.Specs.Propulsion.PropArch.OperUps = OperUps;
Aircraft.Specs.Propulsion.PropArch.OperDwn = OperDwn;

% remember the efficiency matrices
Aircraft.Specs.Propulsion.PropArch.EtaUps = EtaUps;
Aircraft.Specs.Propulsion.PropArch.EtaDwn = EtaDwn;

% remember the source and transmitter types
Aircraft.Specs.Propulsion.PropArch.SrcType = SrcType;
Aircraft.Specs.Propulsion.PropArch.TrnType = TrnType;

% remember the downstream power management strategy
Aircraft.Specs.Power.LamDwn.SLS = LamDwnSLS;
Aircraft.Specs.Power.LamDwn.Tko = LamDwnTko;
Aircraft.Specs.Power.LamDwn.Clb = LamDwnClb;
Aircraft.Specs.Power.LamDwn.Crs = LamDwnCrs;
Aircraft.Specs.Power.LamDwn.Des = LamDwnDes;
Aircraft.Specs.Power.LamDwn.Lnd = LamDwnLnd;

% remember the upstream power management strategy
Aircraft.Specs.Power.LamUps.SLS = LamUpsSLS;
Aircraft.Specs.Power.LamUps.Tko = LamUpsTko;
Aircraft.Specs.Power.LamUps.Clb = LamUpsClb;
Aircraft.Specs.Power.LamUps.Crs = LamUpsCrs;
Aircraft.Specs.Power.LamUps.Des = LamUpsDes;
Aircraft.Specs.Power.LamUps.Lnd = LamUpsLnd;

% ----------------------------------------------------------

end