loadFigureDefaults
%%

wvd = wvd22;

energy_fluxes = wvd.exactEnergyFluxesTemporalAverage(timeIndices=51:251);

% edit fancyName
energy_fluxes([energy_fluxes.fancyName]=="geostrophic-mean-flow").fancyName = "mean flow forcing";
% energy_fluxes([energy_fluxes.fancyName]=="M2-tidal-forcing").fancyName = "M2 tidal forcing";
% energy_fluxes([energy_fluxes.fancyName]=="inertial-forcing").fancyName = "near-inertial forcing";
energy_fluxes([energy_fluxes.fancyName]=="adaptive damping").fancyName = "damping";
energy_fluxes([energy_fluxes.fancyName]=="quadratic bottom friction").fancyName = "bottom friction";

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
    forcing_fluxes1(i).flux = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).te/wvd.flux_scale;
    forcing_fluxes1(i).relativeAmplitude = 1.0;
    forcing_fluxes1(i).alpha = 1.0;
    forcing_fluxes1(i).fancyName = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).fancyName;
end

clear flux_advective
flux_advective.flux = energy_fluxes(1).te/wvd.flux_scale;

maxAmplitude = max(arrayfun( @(v) max(abs(v.flux(:))), forcing_fluxes1));
for i=1:length(forcing_fluxes1)
    forcing_fluxes1(i).relativeAmplitude = max(abs((forcing_fluxes1(i).flux(:))))/maxAmplitude;
end

fig = figure('Units', 'points', 'Position', [50 50 400 400]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');
fig = wvd.plotPoissonFlowOverContours(figureHandle=fig,vectorDensityLinearTransitionWavenumber=10^(-3.9),quiverScale=3,jmax=50,kmax=2e-3,forcingFlux=forcing_fluxes1,inertialFlux=flux_advective,addFrequencyContours=false,addKEPEContours=false);
ax = gca;
ax.Title.String = "energy flux, MF: mean flow forcing";
exportgraphics(fig,figureFolder + "/" + "energy_flux_exact_2D_flow_run22.png",Resolution=300)

%%

wvd = wvd18;

energy_fluxes = wvd.exactEnergyFluxesTemporalAverage(timeIndices=51:251);

% edit fancyName
energy_fluxes([energy_fluxes.fancyName]=="geostrophic-mean-flow").fancyName = "mean flow forcing";
energy_fluxes([energy_fluxes.fancyName]=="M2-tidal-forcing").fancyName = "M_2 tidal forcing";
energy_fluxes([energy_fluxes.fancyName]=="inertial-forcing").fancyName = "near-inertial forcing";
energy_fluxes([energy_fluxes.fancyName]=="adaptive damping").fancyName = "damping";
energy_fluxes([energy_fluxes.fancyName]=="quadratic bottom friction").fancyName = "bottom friction";

C = orderedcolors("gem"); 
colorDictionary = dictionary("geostrophic_mean_flow",{C(3,:)});
colorDictionary{"quadratic_bottom_friction"} = C(1,:);
colorDictionary{"adaptive_damping"} = C(2,:);
colorDictionary{"inertial_forcing"} = C(4,:);
colorDictionary{"M2_tidal_forcing"} = C(5,:);


% fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction","adaptive_damping","inertial_forcing","M2_tidal_forcing"};
fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction","inertial_forcing","M2_tidal_forcing"};
clear forcing_fluxes18;
for i=1:length(fluxesOfInterest)
    forcing_fluxes18(i).color=colorDictionary{fluxesOfInterest{i}};
    forcing_fluxes18(i).flux = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).te/wvd.flux_scale;
    forcing_fluxes18(i).relativeAmplitude = 1.0;
    forcing_fluxes18(i).alpha = 1.0;
    forcing_fluxes18(i).fancyName = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).fancyName;
end

clear flux_advective
flux_advective.flux = energy_fluxes(1).te/wvd.flux_scale;

maxAmplitude = max(arrayfun( @(v) max(abs(v.flux(:))), forcing_fluxes18));
for i=1:length(forcing_fluxes18)
    forcing_fluxes18(i).relativeAmplitude = max(abs((forcing_fluxes18(i).flux(:))))/maxAmplitude;
end

fig = figure('Units', 'points', 'Position', [50 50 400 400]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');
fig = wvd.plotPoissonFlowOverContours(figureHandle=fig,vectorDensityLinearTransitionWavenumber=10^(-3.9),quiverScale=3,jmax=50,kmax=2e-3,forcingFlux=forcing_fluxes18,inertialFlux=flux_advective,addFrequencyContours=false,addKEPEContours=false);
set(gca,'YTickLabel',[]);
set(gca,'YLabel',[]);
ax = gca;
ax.Title.String = "energy flux, MFW: mean flow & wave forcing";
exportgraphics(fig,figureFolder + "/" + "energy_flux_exact_2D_flow_run18.png",Resolution=300)


combinePngsHorizontally(figureFolder + "/" + "energy_flux_exact_2D_flow_run22.png", figureFolder + "/" + "energy_flux_exact_2D_flow_run18.png", figureFolder + "/" + "Figure05_energy_flux_exact_2D_flow.png", HorizontalSpacing=40)