% basedir = "/Users/Shared/CimRuns_June2025/output/";
basedir = "/Users/jearly/Dropbox/CimRuns_June2025/output/";
% basedir = "/Volumes/Samsung_T7/CimRuns_June2025/output/";
% basedir = '/Users/cwortham/Documents/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns/output/';
% basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_June2025_v2/output/';

runNumber=1; runName = "hydrostatic: geostrophic";
wvd1 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

runNumber=18; runName = "non-hydrostatic: geostrophic + waves";
wvd18 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
       mkdir(figureFolder)
end

%%

wvd = wvd1;
enstrophy_fluxes = wvd.exactEnstrophyFluxesTemporalAverage(timeIndices=51:251);
quiverScale = 1;

C = orderedcolors("gem"); 
colorDictionary = dictionary("geostrophic_mean_flow",{C(3,:)});
colorDictionary{"quadratic_bottom_friction"} = C(1,:);
colorDictionary{"adaptive_damping"} = C(2,:);
colorDictionary{"inertial_forcing"} = C(4,:);
colorDictionary{"M2_tidal_forcing"} = C(5,:);


% fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction","adaptive_damping"};
fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction"};
clear forcing_fluxes1;
for i=1:length(fluxesOfInterest)
    forcing_fluxes1(i).color=colorDictionary{fluxesOfInterest{i}};
    forcing_fluxes1(i).flux = enstrophy_fluxes([enstrophy_fluxes.name] == fluxesOfInterest{i}).Z0/wvd.z_flux_scale;
    forcing_fluxes1(i).relativeAmplitude = 1.0;
    forcing_fluxes1(i).alpha = .8;%1.0;
    forcing_fluxes1(i).fancyName = enstrophy_fluxes([enstrophy_fluxes.name] == fluxesOfInterest{i}).fancyName;
end

clear flux_advective
flux_advective.flux = enstrophy_fluxes(1).Z0/wvd.z_flux_scale;

maxAmplitude = max(arrayfun( @(v) max(abs(v.flux(:))), forcing_fluxes1));
for i=1:length(forcing_fluxes1)
    forcing_fluxes1(i).relativeAmplitude = max(abs((forcing_fluxes1(i).flux(:))))/maxAmplitude;
end

fig = figure('Units', 'points', 'Position', [50 50 400 400]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');
fig = wvd.plotPoissonFlowOverContours(nLevels=20,figureHandle=fig,vectorDensityLinearTransitionWavenumber=10^(-3.9),quiverScale=quiverScale,jmax=2e-3,kmax=2e-3,forcingFlux=forcing_fluxes1,inertialFlux=flux_advective,addFrequencyContours=false,addKEPEContours=true);
ax = gca;
ax.Title.String = "potential enstrophy flux: HS-G";
exportgraphics(fig,figureFolder + "/" + "enstrophy_flux_exact_2D_flow_run1.png",Resolution=300)


%%

wvd = wvd18;
enstrophy_fluxes = wvd.exactEnstrophyFluxesTemporalAverage(timeIndices=51:251);
quiverScale = 1;

C = orderedcolors("gem"); 
colorDictionary = dictionary("geostrophic_mean_flow",{C(3,:)});
colorDictionary{"quadratic_bottom_friction"} = C(1,:);
colorDictionary{"adaptive_damping"} = C(2,:);
colorDictionary{"inertial_forcing"} = C(4,:);
colorDictionary{"M2_tidal_forcing"} = C(5,:);


% fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction","adaptive_damping","inertial_forcing","M2_tidal_forcing"};
fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction"};
clear forcing_fluxes18;
for i=1:length(fluxesOfInterest)
    forcing_fluxes18(i).color=colorDictionary{fluxesOfInterest{i}};
    forcing_fluxes18(i).flux = enstrophy_fluxes([enstrophy_fluxes.name] == fluxesOfInterest{i}).Z0/wvd.z_flux_scale;
    forcing_fluxes18(i).relativeAmplitude = 1.0;
    forcing_fluxes18(i).alpha = .8;%1.0;
    forcing_fluxes18(i).fancyName = enstrophy_fluxes([enstrophy_fluxes.name] == fluxesOfInterest{i}).fancyName;
end

clear flux_advective
flux_advective.flux = enstrophy_fluxes(1).Z0/wvd.z_flux_scale;

maxAmplitude = max(arrayfun( @(v) max(abs(v.flux(:))), forcing_fluxes18));
for i=1:length(forcing_fluxes18)
    forcing_fluxes18(i).relativeAmplitude = max(abs((forcing_fluxes18(i).flux(:))))/maxAmplitude;
end

fig = figure('Units', 'points', 'Position', [50 50 400 400]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');
fig = wvd.plotPoissonFlowOverContours(nLevels=20,figureHandle=fig,vectorDensityLinearTransitionWavenumber=10^(-3.9),quiverScale=quiverScale,jmax=2e-3,kmax=2e-3,forcingFlux=forcing_fluxes18,inertialFlux=flux_advective,addFrequencyContours=false,addKEPEContours=true);
set(gca,'YTickLabel',[]);
set(gca,'YLabel',[]);
ax = gca;
ax.Title.String = "potential enstrophy flux: NHS-GW";
exportgraphics(fig,figureFolder + "/" + "enstrophy_flux_exact_2D_flow_run18.png",Resolution=300)
