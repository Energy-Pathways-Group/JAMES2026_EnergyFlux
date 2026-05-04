loadFigureDefaults
wvd = wvd18;

analysisIndices = 51:251;

%%

energy_fluxes = wvd.quadraticEnergyFluxesTemporalAverage(timeIndices=analysisIndices);

% edit fancyName
energy_fluxes([energy_fluxes.fancyName]=="geostrophic-mean-flow").fancyName = "mean flow forcing";
energy_fluxes([energy_fluxes.fancyName]=="M2-tidal-forcing").fancyName = "M_2 tidal forcing";
energy_fluxes([energy_fluxes.fancyName]=="inertial-forcing").fancyName = "near-inertial forcing";
energy_fluxes([energy_fluxes.fancyName]=="adaptive damping").fancyName = "damping";
energy_fluxes([energy_fluxes.fancyName]=="quadratic bottom friction").fancyName = "bottom friction";

[inertial_fluxes_g, inertial_fluxes_w, ks, js] = wvd.quadraticEnergyPrimaryTriadFluxesTemporalAverage2D(timeIndices=analysisIndices,outputGrid="full");

C = orderedcolors("gem"); 
colorDictionary = dictionary("geostrophic_mean_flow",{C(3,:)});
colorDictionary{"quadratic_bottom_friction"} = C(1,:);
colorDictionary{"adaptive_damping"} = C(2,:);
colorDictionary{"inertial_forcing"} = C(4,:);
colorDictionary{"M2_tidal_forcing"} = C(5,:);

%%

% fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction","adaptive_damping","inertial_forcing","M2_tidal_forcing"};
fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction"};

% forcing_fluxes(length(fluxesOfInterest)) = struct("name","placeholder");
clear forcing_fluxes;
reservoirName = "te_gmda";
for i=1:length(fluxesOfInterest)
    forcing_fluxes(i).color=colorDictionary{fluxesOfInterest{i}};
    forcing_fluxes(i).flux = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).(reservoirName)/wvd.flux_scale;
    forcing_fluxes(i).relativeAmplitude = 1.0;
    forcing_fluxes(i).alpha = 0.6;%1.0;
    forcing_fluxes(i).fancyName = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).fancyName;
end
forcing_fluxes(i+1).flux = inertial_fluxes_g([inertial_fluxes_g.name] == "tx-wwg").flux/wvd.flux_scale;
forcing_fluxes(i+1).color = 0.0*[1 1 1];
forcing_fluxes(i+1).relativeAmplitude = 1;
forcing_fluxes(i+1).alpha = 0.6;
forcing_fluxes(i+1).fancyName = "wwg transfer";

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
ggg.flux = inertial_fluxes_g([inertial_fluxes_g.name] == "ggg").flux/wvd.flux_scale;
fig = wvd.plotPoissonFlowOverContours(figureHandle=fig,vectorDensityLinearTransitionWavenumber=10^(-3.9),quiverScale=3,jmax=50,kmax=2e-3,forcingFlux=forcing_fluxes,inertialFlux=ggg,addKEPEContours=true);
title("ggg cascade")
exportgraphics(fig,figureFolder + "/" + "Figure11_energy_flux_quadratic_2D_flow_geostrophic.png",Resolution=300)
%%

% fluxesOfInterest = {"adaptive_damping","inertial_forcing","M2_tidal_forcing","quadratic_bottom_friction"};
fluxesOfInterest = {"inertial_forcing","M2_tidal_forcing","quadratic_bottom_friction"};

clear forcing_fluxes;
reservoirName = "te_wave";
for i=1:length(fluxesOfInterest)
    forcing_fluxes(i).color=colorDictionary{fluxesOfInterest{i}};
    forcing_fluxes(i).flux = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).(reservoirName)/wvd.flux_scale;
    forcing_fluxes(i).fancyName = energy_fluxes([energy_fluxes.name] == fluxesOfInterest{i}).fancyName;
    forcing_fluxes(i).relativeAmplitude = 1.0;
    forcing_fluxes(i).alpha = 1.0;
end
forcing_fluxes(i).alpha = 0.7;

% forcing_fluxes(i+1).flux = -inertial_fluxes(4).te_gmda/wvd.flux_scale;
forcing_fluxes(i+1).flux = inertial_fluxes_w([inertial_fluxes_w.name] == "tx-wwg").flux/wvd.flux_scale;
forcing_fluxes(i+1).color = 0.0*[1 1 1];
forcing_fluxes(i+1).relativeAmplitude = 1;
forcing_fluxes(i+1).alpha = 0.6;
forcing_fluxes(i+1).fancyName = "wwg transfer";

maxAmplitude = max(arrayfun( @(v) max(abs(v.flux(:))), forcing_fluxes));
for i=1:length(forcing_fluxes)
    forcing_fluxes(i).relativeAmplitude = max(abs((forcing_fluxes(i).flux(:))))/maxAmplitude;
end


fig = figure('Units', 'points', 'Position', [50 50 400 400]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');
wwg.flux = inertial_fluxes_w([inertial_fluxes_w.name] == "wwg").flux/wvd.flux_scale;
wwg.flux(isnan(wwg.flux)) = 0; % not sure why there are NaNs in this wwg...
fig = wvd.plotPoissonFlowOverContours(figureHandle=fig,vectorDensityLinearTransitionWavenumber=10^(-3.9),quiverScale=3,jmax=50,kmax=2e-3,forcingFlux=forcing_fluxes,inertialFlux=wwg,addFrequencyContours=true);
title("wwg cascade")
exportgraphics(fig,figureFolder + "/" + "Figure12a_energy_flux_quadratic_2D_flow_wave_wwg.png",Resolution=300)


%%
fig = figure('Units', 'points', 'Position', [50 50 400 400]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');
www.flux = inertial_fluxes_w([inertial_fluxes_w.name] == "www").flux/wvd.flux_scale;
fig = wvd.plotPoissonFlowOverContours(figureHandle=fig,vectorDensityLinearTransitionWavenumber=10^(-3.9),quiverScale=3,jmax=50,kmax=2e-3,forcingFlux=forcing_fluxes,inertialFlux=www,addFrequencyContours=true);
set(gca,'YTickLabel',[]);
set(gca,'YLabel',[]);
title("www cascade")
exportgraphics(fig,figureFolder + "/" + "Figure12b_energy_flux_quadratic_2D_flow_wave_www.png",Resolution=300)

combinePngsHorizontally(figureFolder + "/" + "Figure12a_energy_flux_quadratic_2D_flow_wave_wwg.png", figureFolder + "/" + "Figure12b_energy_flux_quadratic_2D_flow_wave_www.png", figureFolder + "/" + "Figure12_energy_flux_quadratic_2D_flow_wave.png", HorizontalSpacing=40)