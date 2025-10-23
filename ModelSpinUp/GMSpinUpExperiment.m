%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Overview
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cim's spin-up runs preparing for AOFD 2024 meeting. 
% Don't execute this script directly.
% Use callGMSpinUpExperiment.m to define run parameters and run.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Universal settings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fix seed for random number generator
rng(0,"twister")

% Stratification
% N0 = 3*2*pi/3600;
L_gm = 1300;
N2 = @(z) N0*N0*exp(2*z/L_gm);

% Domain (m)
Lx = 500e3;
Ly = 500e3;
Lz = 4000; 

% Dimensions
% Nx = 128;
% Ny = 128;
% Nx = 64;
% Ny = 64;
Nx = resolution;
Ny = resolution;
Nz = WVStratification.verticalResolutionForHorizontalResolution(Lx,Lz,Nx,N2=N2,latitude=lat);

% if doubleResolution
%     Nx = 2*Nx;
%     Ny = 2*Ny;
%     Nz = WVStratification.verticalResolutionForHorizontalResolution(Lx,Lz,Nx,N2=N2,latitude=lat);
% end

% Tidal forcing period; use wave band M2Period +/- dPeriod
M2Period = 12.420602*3600; % M2 tidal period, s
dPeriod = 300;

% spinup and output times (seconds)
% spinupTimeHyd = 1000*86400; % initial spinup at Nxy
% spinupTimeQGDoubleResolution = 1000*86400;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Initialize model, and figure options
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize WVTransform for run
% Can also use wvt.boussinesqTransform switch a hydrostatic transform to boussinesq.
if strcmp(transform,'hydrostatic')
    wvt = WVTransformHydrostatic([Lx, Ly, Lz],[Nx, Nx, Nz], N2=N2,latitude=lat);
elseif strcmp(transform,"boussinesq")
    wvt = WVTransformBoussinesq([Lx, Ly, Lz],[Nx, Nx, Nz], N2=N2,latitude=lat);
else
    error("Invalid transform. Must be hydrostatic or boussinesq.")
end

% check that N>f
% min(sqrt(wvt.N2))>wvt.f
% check first baroclinic mode phase speed
% sqrt(wvt.g.*wvt.h_0(2))
% return

% add bottom friction, viscosity, and diffusivity
wvt.addForcing(WVBottomFrictionQuadratic(wvt,Cd=1e-3));
wvt.addForcing(WVAdaptiveDamping(wvt));
wvt.addForcing(WVVerticalDiffusivity(wvt,shouldForceMeanDensityAnomaly=false,kappa_z=1e-5));
% wvt.addForcing(WVAdaptiveViscosity(wvt));
% wvt.addForcing(WVAdaptiveDiffusivity(wvt));

% Build a few useful tools for making PSD plots
cmPar = colormap("parula");
cmPar(1,:) = 1; % I want white for zero
cmDel = cmocean('delta');
cmBal = cmocean('balance');

% The dk/2 shift accounts for pcolor's weirdness
% Then convert from radians/m to cycles/km
kAxis = (wvt.kAxis - (wvt.dk)/2)*1e3/(2*pi);
lAxis = (wvt.lAxis - (wvt.dl)/2)*1e3/(2*pi);
kLim = [min(kAxis) max(kAxis)];
xLim = [min(wvt.x) max(wvt.x)]/1e3;

% create figure folder
figFolder = fullfile('figures',sprintf('runNumber%d',runNumber));
if ~exist(figFolder, 'dir')
       mkdir(figFolder)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Short GM spindown run to use as reference
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wvtGM = wvt;
wvtGM.initWithGMSpectrum(GMAmplitude=GMAmplitude);

% % % % would like to do very short spin-down GM run here to equilibrate. 
% % % wvtGM.addForcing(WVBottomFrictionQuadratic(wvtGM,Cd=1e-3));
% % % wvtGM.addForcing(WVAdaptiveViscosity(wvtGM));
% % % wvtGM.addForcing(WVAdaptiveDiffusivity(wvtGM));
% % % 
% % % % initialize model
% % % modelGM = WVModel(wvtGM);
% % % 
% % % % run for a short time
% % % model.integrateToTime(15*86400)

TEGM = wvtGM.Apm_TE_factor .* (abs(wvtGM.Ap).^2 + abs(wvtGM.Am).^2);
TEGM_KLAxes = wvtGM.transformToKLAxes(TEGM);
TEGM_radial = wvtGM.transformToRadialWavenumber(TEGM);
clear wvtGM % not needed anymore

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Forcing and initial conditions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Near inertial forcing
if addInertialForcing
    % clear wvt amplitudes
    wvt.removeAll; 
    % get GM-level amplitudes of near-inertial modes
    wvt.initWithGMSpectrum(GMAmplitude=GMAmplitude)
    wvt.Ap(wvt.Kh > 3*wvt.dk) = 0;
    wvt.Am(wvt.Kh > 3*wvt.dk) = 0;
    fprintf('Found %d modes near inertial modes.\n',sum(~abs(wvt.Ap(:))==0));
    % prevent any forcing at damped scales. Use wvt.summarizeForcing to get active forcing.
    % k_damp = wvt.forcingWithName('adaptive svv').k_damp;
    k_damp = wvt.forcingWithName('adaptive damping').k_damp;
    j_damp = wvt.forcingWithName('adaptive damping').j_damp;
    wvt.Ap(wvt.Kh > k_damp) = 0;
    wvt.Am(wvt.Kh > k_damp) = 0;
    wvt.Ap(wvt.J > j_damp) = 0;
    wvt.Am(wvt.J > j_damp) = 0;
    % setup forcing
    force = WVFixedAmplitudeForcing(wvt,name="inertial-forcing");
    force.setWaveForcingCoefficients(wvt.Ap,wvt.Am);
    wvt.addForcing(force);
    % plot inertial forcing
    TE = wvt.Apm_TE_factor .* (abs(wvt.Ap).^2 + abs(wvt.Am).^2);
    TE_KLAxes = wvt.transformToKLAxes(TE);
    figure(Position = [100 100 800 350]); tl=tiledlayout(1,2,TileSpacing="compact");
    title(tl,"Garrett-Munk at near-inertial wavenumbers")
    sp1 = nexttile; 
    pcolor(kAxis,lAxis,log10(sum(TE_KLAxes,3))'), colormap(sp1,cmPar); shading flat; clim( max(log10(TE(:)))-[5 0])
    axis equal; xlim(kLim); ylim(kLim); xlabel('k (cycles/km)'); ylabel('l (cycles/km)'); cb=colorbar('eastoutside'); cb.Label.String='energy spectrum (log_{10}(m^3 s^{-2}))'; %title('energy spectrum (log10(m^3 s^{-2}))');
    hold on
    plot([0 0],ylim,Color=[0 0 0]),plot(xlim,[0 0],Color=[0 0 0])
    sp2 = nexttile; 
    pcolor(wvt.x/1e3, wvt.y/1e3, wvt.ssh'), shading interp, colormap(sp2,cmBal)
    axis equal; xlim(xLim); ylim(xLim); xlabel('x (km)'); ylabel('y (km)'); cb=colorbar('eastoutside'); cb.Label.String='SSH (m)'; %title('ssh (m)');
else
    % clear wvt amplitudes
    wvt.removeAllWaves;
    wvt.removeAllInertialMotions;
end

% Tidal forcing
% should generalize this, to sum over multiple tidal modes.
if addTidalForcing
    % identify M2 frequency modes
    omega_min =2*pi/(M2Period+dPeriod);
    omega_max =2*pi/(M2Period-dPeriod);
    Omega = wvt.Omega;
    omega_M2 = Omega > omega_min & Omega < omega_max;
    fprintf('Found %d modes within +/- %d seconds of the semi-diurnal period.\n',sum(omega_M2(:)),dPeriod);
    % clear wvt amplitudes
    wvt.removeAll;
    % get GM-level amplitudes of M2 modes
    wvt.initWithGMSpectrum(GMAmplitude=GMAmplitude);
    wvt.Ap(~omega_M2) = 0;
    wvt.Am(~omega_M2) = 0;
    % prevent any forcing at damped scales. Use wvt.summarizeForcing to get active forcing.
    % k_damp = wvt.forcingWithName('adaptive svv').k_damp;
    k_damp = wvt.forcingWithName('adaptive damping').k_damp;
    j_damp = wvt.forcingWithName('adaptive damping').j_damp;
    wvt.Ap(wvt.Kh > k_damp) = 0;
    wvt.Am(wvt.Kh > k_damp) = 0;
    wvt.Ap(wvt.J > j_damp) = 0;
    wvt.Am(wvt.J > j_damp) = 0;
    % restrict forcing to narrower range in l
    kWidth = 4*wvt.dk;
    lWidth = 2*wvt.dk;
    taper = exp(-( (wvt.L/lWidth).^2)/2); %exp(-((K/kWidth).^2 + (L/lWidth).^2)/2);
    wvt.Ap = taper .* wvt.Ap;
    wvt.Am = taper .* wvt.Am;
    % tune amplitude of tidal forcing
    ratio = uTide/wvt.uvMax;
    wvt.Ap = ratio*wvt.Ap;
    wvt.Am = ratio*wvt.Am;
    fprintf('Tidal amplitudes are umax: %.1f cm/s and ssh_max: %.1f cm\n',wvt.uvMax*100,100*max(abs(wvt.ssh(:))));
    % setup forcing
    force = WVFixedAmplitudeForcing(wvt,name="M2-tidal-forcing");
    force.setWaveForcingCoefficients(wvt.Ap,wvt.Am);
    wvt.addForcing(force);
    % plot tidal forcing
    TE = wvt.Apm_TE_factor .* (abs(wvt.Ap).^2 + abs(wvt.Am).^2);
    TE_KLAxes = wvt.transformToKLAxes(TE);
    figure(Position = [100 100 800 350]); tl=tiledlayout(1,2,TileSpacing="compact");
    title(tl,"Garrett-Munk at semi-diurnal wavenumbers");
    sp1 = nexttile; 
    pcolor(kAxis,lAxis,log10(sum(TE_KLAxes,3))'); colormap(sp1,cmPar); shading flat; clim( max(log10(TE(:)))-[5 0]);
    axis equal; xlim(kLim); ylim(kLim); xlabel('k (cycles/km)'); ylabel('l (cycles/km)'); cb=colorbar('eastoutside'); cb.Label.String='energy spectrum (log_{10}(m^3 s^{-2}))'; %title('energy spectrum (log_{10}(m^3 s^{-2}))');
    hold on
    plot([0 0],ylim,Color=[0 0 0]);plot(xlim,[0 0],Color=[0 0 0])
    sp2 = nexttile; 
    pcolor(wvt.x/1e3, wvt.y/1e3, wvt.ssh'); shading interp; colormap(sp2,cmBal);
    axis equal; xlim(xLim); ylim(xLim); xlabel('x (km)'); ylabel('y (km)'); cb=colorbar('eastoutside'); cb.Label.String='SSH (m)'; %title('ssh (m)');
    % print(sprintf('%s/SSHday%d_run%d.png',figFolder,round(wvt.t*86400/86400),runNumber),'-dpng') 
    Ekj_w = wvt.transformToRadialWavenumber(TE);
    figure, 
    plot(wvt.kRadial,sum(Ekj_w,1)), xlog, ylog, title('energy spectrum, radial wavenumber (log_{10}(m^3 s^{-2}))')
    hold on; plot(wvt.kRadial,sum(TEGM_radial,1), linewidth=2,Color=[0,0,0]+.8)
else
    % Don't add tidal forcing
    % clear wvt amplitudes
    wvt.removeAllWaves;
    wvt.removeAllInertialMotions;
end

% Geostrophic flow
if addGeostrophicFlow
    % load ncfile for QGSpinUp run
    % ncfile = NetCDFFile(fullfile('output',sprintf('QGSpinup%d.nc',lat)));
    ncfile = NetCDFFile(fullfile('output',runNameQG));
    % Add geostrophic flow
    wvtQG = WVTransform.waveVortexTransformFromFile(ncfile.path, iTime=Inf);
    % wvtQG = wvtQG.waveVortexTransformWithResolution([Nx,Ny,Nz]); % force it to match resolution
    % spinup at double resolution
    % if doubleResolution
    %     fprintf('\n Running geostrophic model to spinup at double resolution. This might take a while. \n \n')
    %     wvtQG = wvtQG.waveVortexTransformWithResolution([Nx,Ny,Nz]);
    %     modelQG = WVModel(wvtQG);
    %     modelQG.integrateToTime(wvtQG.t+spinupTimeQGDoubleResolution);
    % end
    wvt.A0 = wvtQG.A0;
    % setup forcing, copied from wvtQG
    forcing = wvtQG.forcingWithName("geostrophic-mean-flow");
    forcing = forcing.forcingWithResolutionOfTransform(wvt); % make it compatible with hydrostatic wvt
    wvt.addForcing(forcing);
    ncfile.close
else
    % No geostrophic flow or forcing
    wvt.removeAllGeostrophicMotions;
end

% Internal wave initial condition
if addInitialCondition == "R"
    % No internal wave field
    wvt.removeAllWaves;
    wvt.removeAllInertialMotions;
    % wvt.initWithGMSpectrum(.05,'shouldRandomizeAmplitude',1);
elseif addInitialCondition == "GM"
    % Add GM internal wave field
    wvt.initWithGMSpectrum(GMAmplitude=GMAmplitude);
else
    error('Invalid initial condition input. Choose [R,GM].')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Setup model and run
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize model
model = WVModel(wvt);

% create igw+io (internal gravity wave plus inertial oscillation) flow
% component to track total wave component.
flowComponent = wvt.flowComponentWithName("wave") + wvt.flowComponentWithName("inertial");
wvt.addFlowComponent(flowComponent);
wvt.addOperation(wvt.operationForKnownVariable('u','v','w','eta','p',flowComponent=flowComponent));

% set options for mooring output
mooringFieldNames = {"u","v","w","eta","u_g","v_g","w_g","eta_g","u_w_io","v_w_io","w_w_io","eta_w_io","rho_e"};
moorings = WVMooring(model,nMoorings=4,trackedFieldNames=mooringFieldNames);
mooringsOutputInterval = floor( 2*pi/sqrt(max(wvt.N2))/2 ); % Nyquist sampling for max buoyancy frequency
initialTime = spinupTimeHyd-100*86400;
finalTime = spinupTimeHyd;

% setup output
outputFile = model.createNetCDFFileForModelOutput(fullfile('output',runName+'.nc'),outputInterval=86400,shouldOverwriteExisting=false);
mooringOutputGroup = outputFile.addNewEvenlySpacedOutputGroup("mooring",initialTime=initialTime,finalTime=finalTime,outputInterval=mooringsOutputInterval);
mooringOutputGroup.addObservingSystem(moorings);

% setup progress figure
figure
tl = tiledlayout(3,3,TileSpacing="compact");
% title(tl,'surface vorticity')
title(tl,'SSH')

% profile on
% model.integrateToTime(spinupTimeHyd)
% profile viewer

% integrate and show progress
ti = wvt.t;
plotTime = linspace(0,spinupTimeHyd,9);
for tf=plotTime
    model.integrateToTime(ti+tf);

    nexttile(tl)
    % pcolor(wvt.x/1e3, wvt.y/1e3, wvt.zeta_z(:,:,end).'), shading interp, title(sprintf('%d days',round(wvt.t/86400)))
    pcolor(wvt.x/1e3, wvt.y/1e3, wvt.ssh'); shading interp; colormap(cmBal); title(sprintf('%d days',round(wvt.t/86400)))
    xtick([]), ytick([])
    pause(0.1);
end
% save
exportgraphics(gcf,fullfile(figFolder,sprintf('SSHday%d_run%d.png',round(wvt.t/86400),runNumber)), 'BackgroundColor','white', 'Padding','figure')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Figures
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figures to add:
% - k_h,j energy plot
% - evolution of energy spectrum over time

TE = wvt.Apm_TE_factor .* (abs(wvt.Ap).^2 + abs(wvt.Am).^2);
TE_KLAxes = wvt.transformToKLAxes(TE);

figure(Position = [100 100 800 350]); tl=tiledlayout(2,2,TileSpacing="compact");
% title(tl,sprintf("t = %.1f days",wvt.t/86400))
% ssh
sp1 = nexttile;
pcolor(wvt.x/1e3, wvt.y/1e3, wvt.ssh'); shading interp; colormap(sp1,cmBal)
axis equal; xlim(xLim); ylim(xLim); xlabel('x (km)'); ylabel('y (km)'); cb=colorbar('eastoutside'); cb.Label.String='SSH (m)'; %title('ssh (m)');
clim([-max(abs(cb.Limits)),max(abs(cb.Limits))]);
% u
sp2 = nexttile;
pcolor(wvt.x/1e3, wvt.z, squeeze(wvt.u(:,1,:))'); shading interp; colormap(sp2,cmDel);
xlim(xLim); xlabel('x (km)'); ylabel('z (m)'); cb=colorbar('eastoutside'); cb.Label.String='u (m s^{-1})';
clim([-max(abs(cb.Limits)),max(abs(cb.Limits))]);
% energy spectrum
sp3 = nexttile; 
pcolor(kAxis,lAxis,log10(sum(TE_KLAxes,3))'), colormap(sp3,cmPar); shading flat; clim( max(log10(TE(:)))-[5 0])
axis equal; xlim(kLim); ylim(kLim); xlabel('k (cycles/km)'); ylabel('l (cycles/km)'); cb=colorbar('eastoutside'); cb.Label.String='energy spectrum (log_{10}(m^3 s^{-2}))'; %title('energy spectrum (log10(m^3 s^{-2}))');
hold on
plot([0 0],ylim,Color=[0 0 0]),plot(xlim,[0 0],Color=[0 0 0])
% radial energy spectrum
sp4 = nexttile; 
Ekj_w = wvt.transformToRadialWavenumber(TE);
plot(wvt.kRadial*1e3/(2*pi),sum(Ekj_w,1)), xlog, ylog
hold on; plot(wvt.kRadial*1e3/(2*pi),sum(TEGM_radial,1), linewidth=2,Color=[0,0,0]+.8)

hold on; plot(wvt.kRadial*1e3/(2*pi),sum(TEGM_radial,1), linewidth=2,Color='b')

xlabel('k_{radial} (cycles/km)'); ylabel('energy (m^3 s^{-2})');

% save
exportgraphics(gcf,fullfile(figFolder,sprintf('Summary_run%d.png',runNumber)), 'BackgroundColor','white', 'Padding','figure')


% useful wvt.summarive... functions
% wvt.summarizeFlowComponents
% wvt.summarizeEnergyContent
% wvt.summarizeModeEnergy
% wvt.summarizeForcing
% wvt.summarizeDegreesOfFreedom
% wvt.summarizeVariables


