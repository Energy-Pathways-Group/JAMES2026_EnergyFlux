% basedir = "/Users/Shared/CimRuns_June2025/output/";
% basedir = "/Users/jearly/Dropbox/CimRuns_June2025/output/";
% basedir = "/Volumes/Samsung_T7/CimRuns_June2025/output/";
basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_November2025/output/';

% runNumber=1; runName = "hydrostatic: geostrophic";
% runNumber=9; runName = "hydrostatic: geostrophic + waves";
% runNumber=18; runName = "non-hydrostatic: geostrophic + waves";
% wvd = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");
% wvd = WVDiagnostics("/Volumes/Samsung_T7/CimRuns_June2025/output/run1_icR_iner0_tide0_lat32_geo0065_N0052_hydrostatic_res512_duplicate.nc");

figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
       mkdir(figureFolder)
end

% runNumber=1; runName = "hydrostatic: geostrophic";
% wvd1 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

% runNumber=9; runName = "hydrostatic: geostrophic + waves";
% wvd = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");
% analysisTimes = 51:251;
% analysisTimes = 2751:3000;

runNumber=18; runName = "non-hydrostatic: geostrophic + waves";
wvd = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

%%
analysisTimes = 51:251;

shouldSaveFigure = true;

wvd.pseudoRadialBinning = "k2+j2";


C = orderedcolors("gem"); 
colorDictionary = dictionary("geostrophic_mean_flow",{C(3,:)});
colorDictionary{"quadratic_bottom_friction"} = C(1,:);
colorDictionary{"adaptive_damping"} = C(2,:);
colorDictionary{"inertial_forcing"} = C(4,:);
colorDictionary{"M2_tidal_forcing"} = C(5,:);

fluxesOfInterest = {"geostrophic_mean_flow","quadratic_bottom_friction","adaptive_damping","inertial_forcing","M2_tidal_forcing"};

clear forcing_fluxes;
for i=1:length(fluxesOfInterest)
    forcing_fluxes(i).name = fluxesOfInterest{i};
    forcing_fluxes(i).color=colorDictionary{fluxesOfInterest{i}};
end
forcing_fluxes([forcing_fluxes.name] == "geostrophic_mean_flow").fancyName = "mean flow";
forcing_fluxes([forcing_fluxes.name] == "quadratic_bottom_friction").fancyName = "bottom friction";
forcing_fluxes([forcing_fluxes.name] == "adaptive_damping").fancyName = "damping";
forcing_fluxes([forcing_fluxes.name] == "inertial_forcing").fancyName = "near-inertial forcing";
forcing_fluxes([forcing_fluxes.name] == "M2_tidal_forcing").fancyName = "$M_2$ tidal forcing";

fig = wvd.plotEnergyFluxes1D(timeIndices=analysisTimes,forcingFluxAttributes=forcing_fluxes);

if shouldSaveFigure
    exportgraphics(fig,figureFolder + "/" + "energy_flux_1D_simple.png",Resolution=300)
end