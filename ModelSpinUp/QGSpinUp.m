%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Overview
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cim's spin-up runs preparing for AOFD 2024 meeting. 
% Here, spinning up forced-dissipative QG turbulence (mesoscale) field.

% lat = 27; % PSI for M2 tide and inertial allowed equatorward of 28.8
% lat = 32; % PSI for M2 tide and inertial allowed equatorward of 28.8

% runName = 'QGSpinUp'+string(lat);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Universal settings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fix seed for random number generator
rng(0,"twister")

% Stratification
% N0 = 3*2*pi/3600; % now setting this in callQGSpinUp.m
L_gm = 1300;
N2 = @(z) N0*N0*exp(2*z/L_gm);

% Domain (m)
Lx = 500e3;
Ly = 500e3;
Lz = 4000; 

% Dimensions. Start with half the desired resolution, and will double after spinup.
Nx = 64;
Ny = 64;
Nz = WVStratification.verticalResolutionForHorizontalResolution(Lx,Lz,Nx,N2=N2,latitude=lat);

% Tidal forcing period; use wave band M2Period +/- dPeriod
M2Period = 12.420602*3600; % M2 tidal period, s
dPeriod = 300;

% spinup and output times (seconds)
spinupTimeQG1 = 30000*86400; % initial spinup at Nxy
spinupTimeQG2 = 500*86400; % continue spinup at 2*Nxy
spinupTimeQG3 = 500*86400; % continue spinup at 4*Nxy
% outputTimeQG = 500*86400; % duration of output for QG phase


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Initialize model
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize WVTransform for QG run
wvt = WVTransformStratifiedQG([Lx, Ly, Lz],[Nx, Nx, Nz], N2=N2,latitude=lat);

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
figFolder = fullfile('figures',sprintf('QGSpinUp%d',lat));
if ~exist(figFolder, 'dir')
       mkdir(figFolder)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Setup model
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set geostrophic forcing modes
% First barolinic plus barotropic modes so that the bottom velocity is zero.
% u0 = 0.005; % now setting this in callQGSpinUp.m Different for latitudes.
wvt.setGeostrophicModes(k=0,l=5,j=1,phi=0,u=u0);
wvt.setGeostrophicModes(k=0,l=5,j=0,phi=0,u=max(max(wvt.u(:,:,1))));
force = WVFixedAmplitudeForcing(wvt,name="geostrophic-mean-flow");
force.setGeostrophicForcingCoefficients(wvt.A0);
wvt.addForcing(force);
% wvt.addForcing(WVBottomFrictionLinear(wvt,r=1/(200*86400)));
wvt.addForcing(WVBottomFrictionQuadratic(wvt,Cd=1e-3));
wvt.addForcing(WVAdaptiveDamping(wvt));
wvt.addForcing(WVVerticalDiffusivity(wvt,shouldForceMeanDensityAnomaly=false,kappa_z=1e-5));
% wvt.addForcing(WVAdaptiveViscosity(wvt));
% wvt.addForcing(WVAdaptiveDiffusivity(wvt));

% Now add some noise
wvt.addRandomFlow('geostrophic',uvMax=0.005);

% Plot initial condition
Ekj_w = wvt.transformToRadialWavenumber(wvt.A0_TE_factor .* (abs(wvt.A0).^2));
figure, tl = tiledlayout(1,2); title(tl,sprintf('%d days',round(wvt.t/86400)));
nexttile, plot(wvt.kRadial,sum(Ekj_w,1)), xlog, ylog, xlabel('k'), ylabel('energy')
nexttile, plot(100*sqrt(squeeze(mean(mean(wvt.u.^2 + wvt.v.^2,1),2))),wvt.z), xlabel('z (m)'), ylabel('velocity variance (cm/s)')

% initialize model
model = WVModel(wvt);

% initial statistics
tRecord = wvt.t;
totalEnergy = wvt.totalEnergy;
totalEnstrophy = wvt.totalEnstrophy/wvt.f/wvt.f;
sshVariance = sqrt(mean(wvt.ssh(:).^2));
uvVariance = sqrt(mean(wvt.u(:).^2 + wvt.v(:).^2));
uvMax = wvt.uvMax;
zetaMax = max(abs(wvt.zeta_z(:)))/wvt.f;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Run the model, plot as the fluid goes unstable
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n Initial spin-up with Nxy. \n \n')

figure(name="Forced baroclinic instability: surface vorticity during spinup")
tl = tiledlayout(3,3,TileSpacing="compact");
title(tl,'surface vorticity')

figure(name="Forced baroclinic instability: spinup metrics")
tl_metrics = tiledlayout(6,1,TileSpacing="compact");

% This particular example goes unstable in less than 900 days, and by about
% 1500 days is is a pretty stable two eddy configuration (so run this
plotTime = linspace(0,spinupTimeQG1,9);
ti = wvt.t;
for tf=plotTime
    model.integrateToTime(ti+tf);

    tRecord(end+1) = wvt.t;
    totalEnergy(end+1) = wvt.totalEnergy;
    totalEnstrophy(end+1) = wvt.totalEnstrophy/wvt.f/wvt.f;
    sshVariance(end+1) = sqrt(mean(wvt.ssh(:).^2));
    uvVariance(end+1) = sqrt(mean(wvt.u(:).^2 + wvt.v(:).^2));
    uvMax(end+1) = wvt.uvMax;
    zetaMax(end+1) = max(abs(wvt.zeta_z(:)))/wvt.f;

    nexttile(tl_metrics,1)
    plot(tRecord/86400,totalEnergy)
    ylabel('energy')
    nexttile(tl_metrics,2)
    plot(tRecord/86400,totalEnstrophy)
    ylabel('enstrophy')
    nexttile(tl_metrics,3)
    plot(tRecord/86400,sshVariance)
    ylabel('ssh-rms')
    nexttile(tl_metrics,4)
    plot(tRecord/86400,uvVariance)
    ylabel('uv-rms')
    nexttile(tl_metrics,5)
    plot(tRecord/86400,uvMax)
    ylabel('uv-max')
    nexttile(tl_metrics,6)
    plot(tRecord/86400,zetaMax)
    ylabel('zeta_z-max')
       
    nexttile(tl)
    pcolor(wvt.x/1e3, wvt.y/1e3, wvt.zeta_z(:,:,end).'), shading interp
    colormap("gray")
    title(sprintf('%d days',round(wvt.t/86400)))
    xtick([]), ytick([])
    pause(1.0);
end

Ekj_w = wvt.transformToRadialWavenumber(wvt.A0_TE_factor .* (abs(wvt.A0).^2));
figure(name="Baroclinic instability: energy spectra"), tiledlayout(1,2)
nexttile, plot(wvt.kRadial,sum(Ekj_w,1)), xlog, ylog, xlabel('k'), ylabel('energy')
nexttile, plot(100*sqrt(squeeze(mean(mean(wvt.u.^2 + wvt.v.^2,1),2))),wvt.z), xlabel('velocity variance (cm/s)'), ylabel('z (m)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Increase resolution to 2*Nxy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n Restart with  2*Nxy. \n \n')

Nx = 2*Nx;
Ny = 2*Ny;
Nz = WVStratification.verticalResolutionForHorizontalResolution(Lx,Lz,Nx,N2=N2,latitude=lat);

wvt1 = wvt;
wvt = wvt1.waveVortexTransformWithResolution([Nx,Ny,Nz]);
model = WVModel(wvt);

clear wvt1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Run for a bit longer at 2*Nxy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
tl2 = tiledlayout(3,3,TileSpacing="compact");
title(tl2,'surface vorticity')
pause(0.1);

% this appears to fill out pretty well in 100 days
plotTime = linspace(0,spinupTimeQG2,9);
ti = wvt.t;
for tf=plotTime
    model.integrateToTime(ti+tf);

    tRecord(end+1) = wvt.t;
    totalEnergy(end+1) = wvt.totalEnergy;
    totalEnstrophy(end+1) = wvt.totalEnstrophy/wvt.f/wvt.f;
    sshVariance(end+1) = sqrt(mean(wvt.ssh(:).^2));
    uvVariance(end+1) = sqrt(mean(wvt.u(:).^2 + wvt.v(:).^2));
    uvMax(end+1) = wvt.uvMax;
    zetaMax(end+1) = max(abs(wvt.zeta_z(:)))/wvt.f;

    nexttile(tl_metrics,1)
    plot(tRecord/86400,totalEnergy)
    ylabel('energy')
    nexttile(tl_metrics,2)
    plot(tRecord/86400,totalEnstrophy)
    ylabel('enstrophy')
    nexttile(tl_metrics,3)
    plot(tRecord/86400,sshVariance)
    ylabel('ssh-rms')
    nexttile(tl_metrics,4)
    plot(tRecord/86400,uvVariance)
    ylabel('uv-rms')
    nexttile(tl_metrics,5)
    plot(tRecord/86400,uvMax)
    ylabel('uv-max')
    nexttile(tl_metrics,6)
    plot(tRecord/86400,zetaMax)
    ylabel('zeta_z-max')
       
    nexttile(tl2)
    pcolor(wvt.x/1e3, wvt.y/1e3, wvt.zeta_z(:,:,end).'), shading interp
    colormap("gray")
    title(sprintf('%d days',round(wvt.t/86400)))
    xtick([]), ytick([])
    pause(0.1);
end

Ekj_w = wvt.transformToRadialWavenumber(wvt.A0_TE_factor .* (abs(wvt.A0).^2));
figure(name="Forced baroclinic instability: energy spectra"), tl = tiledlayout(1,2); title(tl,sprintf('%d days',round(wvt.t/86400)));
nexttile, plot(wvt.kRadial,sum(Ekj_w,1)), xlog, ylog, xlabel('k'), ylabel('energy')
nexttile, plot(100*sqrt(squeeze(mean(mean(wvt.u.^2 + wvt.v.^2,1),2))),wvt.z), ylabel('z (m)'), xlabel('rms velocity (cm/s)')

% save final output
ncfile = model.createNetCDFFileForModelOutput(fullfile('output',sprintf("%s%d.nc",runName,Nx)),outputInterval=1,shouldOverwriteExisting=false);
model.integrateToTime(wvt.t+1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Increase resolution to 4*Nxy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n Restart with  4*Nxy. \n \n')

Nx = 2*Nx;
Ny = 2*Ny;
Nz = WVStratification.verticalResolutionForHorizontalResolution(Lx,Lz,Nx,N2=N2,latitude=lat);

wvt1 = wvt;
wvt = wvt1.waveVortexTransformWithResolution([Nx,Ny,Nz]);
model = WVModel(wvt);

clear wvt1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Run for a bit longer at 4*Nxy
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
tl3 = tiledlayout(3,3,TileSpacing="compact");
title(tl3,'surface vorticity')
pause(0.1);

% this appears to fill out pretty well in 100 days
plotTime = linspace(0,spinupTimeQG2,9);
ti = wvt.t;
for tf=plotTime
    model.integrateToTime(ti+tf);

    tRecord(end+1) = wvt.t;
    totalEnergy(end+1) = wvt.totalEnergy;
    totalEnstrophy(end+1) = wvt.totalEnstrophy/wvt.f/wvt.f;
    sshVariance(end+1) = sqrt(mean(wvt.ssh(:).^2));
    uvVariance(end+1) = sqrt(mean(wvt.u(:).^2 + wvt.v(:).^2));
    uvMax(end+1) = wvt.uvMax;
    zetaMax(end+1) = max(abs(wvt.zeta_z(:)))/wvt.f;

    nexttile(tl_metrics,1)
    plot(tRecord/86400,totalEnergy)
    ylabel('energy')
    nexttile(tl_metrics,2)
    plot(tRecord/86400,totalEnstrophy)
    ylabel('enstrophy')
    nexttile(tl_metrics,3)
    plot(tRecord/86400,sshVariance)
    ylabel('ssh-rms')
    nexttile(tl_metrics,4)
    plot(tRecord/86400,uvVariance)
    ylabel('uv-rms')
    nexttile(tl_metrics,5)
    plot(tRecord/86400,uvMax)
    ylabel('uv-max')
    nexttile(tl_metrics,6)
    plot(tRecord/86400,zetaMax)
    ylabel('zeta_z-max')
       
    nexttile(tl3)
    pcolor(wvt.x/1e3, wvt.y/1e3, wvt.zeta_z(:,:,end).'), shading interp
    colormap("gray")
    title(sprintf('%d days',round(wvt.t/86400)))
    xtick([]), ytick([])
    pause(0.1);
end

Ekj_w = wvt.transformToRadialWavenumber(wvt.A0_TE_factor .* (abs(wvt.A0).^2));
figure(name="Forced baroclinic instability: energy spectra"), tl = tiledlayout(1,2); title(tl,sprintf('%d days',round(wvt.t/86400)));
nexttile, plot(wvt.kRadial,sum(Ekj_w,1)), xlog, ylog, xlabel('k'), ylabel('energy')
nexttile, plot(100*sqrt(squeeze(mean(mean(wvt.u.^2 + wvt.v.^2,1),2))),wvt.z), ylabel('z (m)'), xlabel('rms velocity (cm/s)')

% save final output
ncfile = model.createNetCDFFileForModelOutput(fullfile('output',sprintf("%s%d.nc",runName,Nx)),outputInterval=1,shouldOverwriteExisting=false);
model.integrateToTime(wvt.t+1);










