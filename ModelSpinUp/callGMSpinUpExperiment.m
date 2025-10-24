%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Overview
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Simple script to define the run parameters, execute model runs, and make figures.
% Calls GMSpinUpExperiment.m and Figures.m
%
% If redoing runs, might restrict inertial forcing to
%    wvt.Ap(wvt.Kh > 2*wvt.dk) = 0;
%    wvt.Am(wvt.Kh > 2*wvt.dk) = 0;
    
% set root directory 
% basedir = '/Users/cwortham/Documents/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns/output/';
basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_June2025_v2/output/';

% add some stuff to path
addpath(genpath('~/Documents/research/Energy-Pathways-Group/GLOceanKit/'))
addpath(genpath('~/Documents/research/Energy-Pathways-Group/wave-vortex-model-diagnostics/'))
addpath(genpath('~/Documents/research/matlab_tools/'))


%% List of runs to integrate

runs = [1,9,18];

%% Loop through list and integrate run

% run simulation and generate diagnostics
for ii=1:length(runs)
    runNumber = runs(ii);
    [runName,runNameQG,addInitialCondition,addInertialForcing,addTidalForcing,lat,addGeostrophicFlow,resolution,transform,GMAmplitude,uTide,u0,N0,spinupTimeHyd] = getRunParameters(runNumber);

    fprintf('\n')
    fprintf('runName: %s\n',runName)
    fprintf('addInitialCondition: %s\n',addInitialCondition)
    fprintf('addInertialForcing: %d\n',addInertialForcing)
    fprintf('addTidalForcing: %d\n',addTidalForcing)
    fprintf('lat: %d\n',lat)
    fprintf('addGeostrophicFlow: %d\n',addGeostrophicFlow)
    fprintf('Resolution: %d\n',resolution)
    fprintf('transform: %s\n',transform)
    fprintf('GMAmplitude: %g\n',GMAmplitude)
    fprintf('uTide: %g\n',uTide)
    fprintf('spinupTimeHyd: %d days\n',spinupTimeHyd/86400)
    fprintf('\n')

    % run simulation
    fprintf('Running runNumber %d\n\n',runNumber)
    run GMSpinUpExperiment.m

    % create energy diagnostics
    fprintf('Creating energy diagnostics for runNumber %d\n\n',runNumber)
    filename = fullfile(basedir,runName+'.nc');
    wvd = WVDiagnostics(filename);
    wvd.createDiagnosticsFile();

    % Append mirror fluxes to diagnostics
    fprintf('Creating mirror fluxes for runNumber %d\n\n',runNumber)
    filename = fullfile(basedir,runName+'.nc');
    wvd = WVDiagnostics(filename);
    wvd.create1DMirrorFluxes();

    close all
end
