% basedir = "/Users/Shared/CimRuns_June2025/output/";
basedir = "/Users/jearly/Dropbox/CimRuns_June2025/output/";
% basedir = "/Volumes/Samsung_T7/CimRuns_June2025/output/";
% basedir = '/Users/cwortham/Documents/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns/output/';
% basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_June2025_v2/output/';

% runNumber=18; runName = "non-hydrostatic: geostrophic + waves";
% wvd18 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");
% analysisIndices = 51:251;

runNumber=9; runName = "non-hydrostatic: geostrophic + waves";
wvd = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","256") + ".nc");
analysisIndices = 2751:3001;

figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
       mkdir(figureFolder)
end



%%

energy_fluxes = wvd.quadraticEnergyFluxesTemporalAverage(timeIndices=analysisIndices);
[inertial_fluxes_g, inertial_fluxes_w, ks, js] = wvd.quadraticEnergyPrimaryTriadFluxesTemporalAverage2D(timeIndices=analysisIndices);

[J,K] = ndgrid(wvd.jWavenumber,wvd.kRadial);
[Js,Ks] = ndgrid(js,ks);
% flux_interp = @(v) diff(diff( cat(2,zeros(length(js)+1,1),cat(1,zeros(1,length(ks)),interpn(J,K,cumsum(cumsum(v,1),2),Js,Ks))), 1,1 ),1,2);
flux_interp = @(v) diff(diff( cat(2,zeros(length(wvd.jWavenumber)+1,1),cat(1,zeros(1,length(wvd.kRadial)),interpn(Js,Ks,cumsum(cumsum(v,1),2),J,K,'spline'))), 1,1 ),1,2);

C = orderedcolors("gem"); 
colorDictionary = dictionary("geostrophic_mean_flow",{C(3,:)});
colorDictionary{"quadratic_bottom_friction"} = C(1,:);
colorDictionary{"adaptive_damping"} = C(2,:);
colorDictionary{"inertial_forcing"} = C(4,:);
colorDictionary{"M2_tidal_forcing"} = C(5,:);

%%

fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction","adaptive_damping","inertial_forcing","M2_tidal_forcing"};
fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction"};

% forcing_fluxes(length(fluxesOfInterest)) = struct("name","placeholder");
clear forcing_fluxes;
reservoirName = "te_gmda";
for i=1:length(fluxesOfInterest)
    forcing_fluxes(i).color=colorDictionary{fluxesOfInterest{i}};
    forcing_fluxes(i).flux = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).(reservoirName)/wvd.flux_scale;
    forcing_fluxes(i).relativeAmplitude = 1.0;
    forcing_fluxes(i).alpha = 1.0;
    forcing_fluxes(i).fancyName = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).fancyName;
end
forcing_fluxes(i+1).flux = flux_interp(inertial_fluxes_g([inertial_fluxes_g.name] == "tx-wwg").flux)/wvd.flux_scale;
forcing_fluxes(i+1).color = 0.5*[1 1 1];
forcing_fluxes(i+1).relativeAmplitude = 0.5;
forcing_fluxes(i+1).alpha = 0.25;
forcing_fluxes(i+1).fancyName = "wwg";

% maxAmplitude = max(arrayfun( @(v) abs(sum(v.flux(:))), forcing_fluxes));
% maxAmplitude = max(arrayfun( @(v) max(abs(Kh(:).*v.flux(:))), forcing_fluxes));
maxAmplitude = max(arrayfun( @(v) max(abs(v.flux(:))), forcing_fluxes));
for i=1:length(forcing_fluxes)
    % forcing_fluxes(i).relativeAmplitude = abs(sum(forcing_fluxes(i).flux(:)))/maxAmplitude;
    % forcing_fluxes(i).relativeAmplitude = max(abs(Kh(:).*(forcing_fluxes(i).flux(:))))/maxAmplitude;
    forcing_fluxes(i).relativeAmplitude = max(abs((forcing_fluxes(i).flux(:))))/maxAmplitude;
end

flux_advective = energy_fluxes(1).te_quadratic/wvd.flux_scale;

fig = figure('Units', 'points', 'Position', [50 50 400 400]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');
clear ggg
ggg.flux = flux_interp(inertial_fluxes_g([inertial_fluxes_g.name] == "ggg").flux)/wvd.flux_scale;
fig = wvd.plotPoissonFlowOverContours(figureHandle=fig,vectorDensityLinearTransitionWavenumber=10^(-3.9),quiverScale=3,jmax=2e-3,kmax=2e-3,forcingFlux=forcing_fluxes,inertialFlux=ggg,addKEPEContours=true);
title("ggg")
% exportgraphics(fig,figureFolder + "/" + "energy_flux_quadratic_2D_flow_geostrophic.png",Resolution=300)
return
%%

fluxesOfInterest = {"adaptive_damping","inertial_forcing","M2_tidal_forcing","quadratic_bottom_friction"};

clear forcing_fluxes;
reservoirName = "te_wave";
for i=1:length(fluxesOfInterest)
    forcing_fluxes(i).color=colorDictionary{fluxesOfInterest{i}};
    forcing_fluxes(i).flux = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).(reservoirName)/wvd.flux_scale;
    forcing_fluxes(i).fancyName = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).fancyName;
    forcing_fluxes(i).relativeAmplitude = 1.0;
    forcing_fluxes(i).alpha = 1.0;
end
forcing_fluxes(i).alpha = 0.25;

% forcing_fluxes(i+1).flux = -inertial_fluxes(4).te_gmda/wvd.flux_scale;
forcing_fluxes(i+1).flux = flux_interp(inertial_fluxes_w([inertial_fluxes_w.name] == "tx-wwg").flux)/wvd.flux_scale;
forcing_fluxes(i+1).color = 0.5*[1 1 1];
forcing_fluxes(i+1).relativeAmplitude = 0.5;
forcing_fluxes(i+1).alpha = 1.0;
forcing_fluxes(i+1).fancyName = "wwg";

maxAmplitude = max(arrayfun( @(v) max(abs(v.flux(:))), forcing_fluxes));
for i=1:length(forcing_fluxes)
    forcing_fluxes(i).relativeAmplitude = max(abs((forcing_fluxes(i).flux(:))))/maxAmplitude;
end


fig = figure('Units', 'points', 'Position', [50 50 400 400]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');
wwg.flux = flux_interp(inertial_fluxes_w([inertial_fluxes_w.name] == "wwg").flux)/wvd.flux_scale;
fig = wvd.plotPoissonFlowOverContours(figureHandle=fig,vectorDensityLinearTransitionWavenumber=10^(-3.9),quiverScale=3,jmax=2e-3,kmax=2e-3,forcingFlux=forcing_fluxes,inertialFlux=wwg,addFrequencyContours=true);
title("wwg")
% exportgraphics(fig,figureFolder + "/" + "energy_flux_quadratic_2D_flow_wave_wwg.png",Resolution=300)


%%
fig = figure('Units', 'points', 'Position', [50 50 400 400]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');
fig = wvd.plotPoissonFlowOverContours(figureHandle=fig,vectorDensityLinearTransitionWavenumber=10^(-3.9),quiverScale=3,jmax=2e-3,kmax=2e-3,forcingFlux=forcing_fluxes,inertialFlux=www,addFrequencyContours=true);
title("www")
% exportgraphics(fig,figureFolder + "/" + "energy_flux_quadratic_2D_flow_wave_www.png",Resolution=300)
