% define run parameters for GMSpinUpExperiment and callGMSpinUpExperiment. 

function [runName,runNameQG,addInitialCondition,addInertialForcing,addTidalForcing,lat,addGeostrophicFlow,resolution,transform,GMAmplitude,uTide,u0,N0,spinupTimeHyd] = getRunParameters(runNumber)
    if runNumber==1
        % geostrophic only, no PSI
        addInitialCondition = "R";     % "R" rest, "GM" Garrett-Munk initial wave flow
        addInertialForcing = 0;        % near-inertial forcing
        addTidalForcing = 0;           % M2 tidal forcing
        lat = 32;                      % PSI for M2 tide and inertial allowed equatorward of 28.8
        addGeostrophicFlow = 1;        % geostrophic background flow
        resolution = 256;              % Nx and Ny
        transform = "hydrostatic";     % "hydrostatic" or "boussinesq"
        GMAmplitude = 0.7;             % amplitude for inertial forcing and GM initial condition
        uTide = 0.014;                 % amplitude for tidal forcing
        u0 = .005*1.3;               % amplitude for geostrophic forcing
        N0 = 3*2*pi/3600;              % stratification
        qgRunNumber = 2;               % this has to match the parameters (lat, u0, N0) from QG run
        spinupTimeHyd = 1000*86400;    % run duration
    elseif runNumber==9
        % BASELINE RUN
        addInitialCondition = "R";     % "R" rest, "GM" Garrett-Munk initial wave flow
        addInertialForcing = 1;        % near-inertial forcing
        addTidalForcing = 1;           % M2 tidal forcing
        lat = 32;                      % PSI for M2 tide and inertial allowed equatorward of 28.8
        addGeostrophicFlow = 1;        % geostrophic background flow
        resolution = 256;              % Nx and Ny
        transform = "hydrostatic";     % "hydrostatic" or "boussinesq"
        GMAmplitude = 0.7;             % amplitude for inertial forcing and GM initial condition
        uTide = 0.014;                 % amplitude for tidal forcing
        u0 = .005*1.3;               % amplitude for geostrophic forcing
        N0 = 3*2*pi/3600;              % stratification
        qgRunNumber = 2;
        spinupTimeHyd = 1000*86400;    % run duration
    elseif runNumber==18
        % boussinesq
        addInitialCondition = "R";     % "R" rest, "GM" Garrett-Munk initial wave flow
        addInertialForcing = 1;        % near-inertial forcing
        addTidalForcing = 1;           % M2 tidal forcing
        lat = 32;                      % PSI for M2 tide and inertial allowed equatorward of 28.8
        addGeostrophicFlow = 1;        % geostrophic background flow
        resolution = 256;              % Nx and Ny
        transform = "boussinesq";      % "hydrostatic" or "boussinesq"
        GMAmplitude = 0.7;             % amplitude for inertial forcing and GM initial condition
        uTide = 0.014;                 % amplitude for tidal forcing
        u0 = .005*1.3;               % amplitude for geostrophic forcing
        N0 = 3*2*pi/3600;              % stratification
        qgRunNumber = 2;
        spinupTimeHyd = 1000*86400;    % run duration
    elseif runNumber==999
        % testing run
        addInitialCondition = "R";     % "R" rest, "GM" Garrett-Munk initial wave flow
        addInertialForcing = 1;        % near-inertial forcing
        addTidalForcing = 1;           % M2 tidal forcing
        lat = 32;                      % PSI for M2 tide and inertial allowed equatorward of 28.8
        addGeostrophicFlow = 1;        % geostrophic background flow
        resolution = 128;              % Nx and Ny
        transform = "hydrostatic";     % "hydrostatic" or "boussinesq"
        GMAmplitude = 0.7;             % amplitude for inertial forcing and GM initial condition
        uTide = 0.014;                 % amplitude for tidal forcing
        u0 = .005*1.3;               % amplitude for geostrophic forcing
        N0 = 3*2*pi/3600;              % stratification
        qgRunNumber = 2;
        spinupTimeHyd = 10*86400;    % run duration
    else
        error("Invalid run number.")
    end
    
    % construct run name
    if ~addInertialForcing; inerStr='0'; else, inerStr=strip(strip(num2str(GMAmplitude/10,2),'left','0'),'left','.'); end
    if ~addTidalForcing; tideStr='0'; else, tideStr=strip(strip(num2str(uTide,2),'left','0'),'left','.'); end
    if ~addGeostrophicFlow; geoStr='0'; else, geoStr=strip(strip(num2str(u0,2),'left','0'),'left','.'); end
    runName = sprintf("run%d_ic%s_iner%s_tide%s_lat%d_geo%s_N%s_%s_res%d",...
                    runNumber,...
                    addInitialCondition,...
                    inerStr,...
                    tideStr,...
                    lat,...
                    geoStr,...
                    strip(strip(num2str(N0,2),'left','0'),'left','.'),...
                    transform,...
                    resolution);

    % QG run name
    runNameQG = sprintf("QGSpinUp%d_lat-%d_u0-%s_N0-%s_res%d.nc",qgRunNumber,lat,strip(strip(num2str(u0,2),'left','0'),'left','.'),strip(strip(num2str(N0,2),'left','0'),'left','.'),resolution);

end