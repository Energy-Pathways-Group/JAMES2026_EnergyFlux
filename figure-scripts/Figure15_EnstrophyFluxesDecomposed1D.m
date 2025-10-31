% basedir = "/Users/Shared/CimRuns_June2025/output/";
basedir = "/Users/jearly/Dropbox/CimRuns_June2025/output/";
% basedir = "/Volumes/Samsung_T7/CimRuns_June2025/output/";
% basedir = '/Users/cwortham/Documents/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns/output/';
% basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_June2025_v2/output/';

figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
    mkdir(figureFolder)
end

runNumber=18;
wvd = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");
timeIndices = 51:251;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Figure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

shouldShowQuadraticFluxes = false;

style = "pseudoradial";
% style = "radial";

fig = figure('Units', 'points', 'Position', [50 50 800 300]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');
tl = tiledlayout(1,1,TileSpacing="compact",Padding="compact");

if wvd.diagnosticsHasExplicitAntialiasing
    wvt = wvd.wvt_aa;
else
    wvt = wvd.wvt;
end

if style == "pseudoradial"
    kRadial = wvd.kPseudoRadial;
    filter = @(v) wvd.transformToPseudoRadialWavenumber(EnergyReservoir.geostrophic_mda,v);
    xaxislabel = "pseudo-wavelength (km)";
else
    kRadial = wvd.kRadial;
    filter = @(v) sum(v,1);
    xaxislabel = "horizontal wavelength (km)";
end

enstrophy_fluxes = wvd.exactEnstrophyFluxesTemporalAverage(timeIndices =timeIndices);
enstrophy_fluxes_quadratic = wvd.quadraticEnstrophyFluxesTemporalAverage(timeIndices =timeIndices);

% rename quadratic bottom friction for legend
enstrophy_fluxes([enstrophy_fluxes.name]=="quadratic_bottom_friction").fancyName = "bottom friction";
enstrophy_fluxes([enstrophy_fluxes.name]=="adaptive_damping").fancyName = "damping";
enstrophy_fluxes([enstrophy_fluxes.name]=="nonlinear_advection").fancyName = "u{\nabla}u";

enstrophy_fluxes([enstrophy_fluxes_quadratic.name]=="quadratic_bottom_friction").fancyName = "bottom friction";
enstrophy_fluxes([enstrophy_fluxes_quadratic.name]=="adaptive_damping").fancyName = "damping";
enstrophy_fluxes([enstrophy_fluxes_quadratic.name]=="nonlinear_advection").fancyName = "u{\nabla}u";

% wavelength axis
radialWavelength = 2*pi./kRadial/1000;
radialWavelength(1) = 1.5*radialWavelength(2);

radialWavelengthLimits = [min(radialWavelength) max(radialWavelength)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% collect spectrum rate of change
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%energyChange_g =  ;

% initial
% wvd.iTime=timeIndices(1);
% TZ_A0_j_kl = wvt.A0_TZ_factor .* abs(wvt.A0).^2; % m^2/s^3
% TZ_A0_j_kR_initial = wvt.transformToRadialWavenumber(TZ_A0_j_kl);
%
% % final
% wvd.iTime=timeIndices(end);
% TZ_A0_j_kl = wvt.A0_TZ_factor .* abs(wvt.A0).^2; % m^2/s^3
% TZ_A0_j_kR_final = wvt.transformToRadialWavenumber(TZ_A0_j_kl);
%
% % change over time
% ddt_TZ_A0 = (TZ_A0_j_kR_final - TZ_A0_j_kR_initial)/(wvd.t_wv(timeIndices(end)) - wvd.t_wv(timeIndices(1)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Figure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

C = orderedcolors("gem");
col.waveBold = C(5,:);
col.geoBold = C(6,:);

yl = [-3.2,2.5];

% line widths
options.triadLW = 2; % triad
options.forcingLW = 1.5; % forcing

% forcing/damping scales
lambdaMeanFlow = [84,140];
lambdaFrictionGeo = [420,radialWavelength(1)];
lambdaDamp = [radialWavelength(end),2*pi/wvt.forcingWithName('adaptive damping').k_damp/1000];

% forcing/damping colors
colorMeanFlow = C(3,:);
colorInertial = C(4,:);
colorM2 = C(5,:);
colorFriction = C(1,:);
colorDamp = C(2,:);
% forcing/damping alpha
patchAlpha = .3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Fluxes (geostrophic)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ax = nexttile(tl);
box(ax,"on")
yline(ax,0,'HandleVisibility','off',Color=[.5,.5,.5],LineWidth=0.5)
options.filter = @(v) cumsum(v);
% options.filter = @(v) flip(cumsum(flip(v)));

% plot(radialWavelength,zeros(size(radialWavelength)),LineWidth=1,Color=0*[1 1 1]), hold on

% accumlator for net flux line

if shouldShowQuadraticFluxes
    idx = [enstrophy_fluxes_quadratic.name] == "nonlinear_advection";
    v = filter(enstrophy_fluxes_quadratic(idx).Z0);
    plot(ax,radialWavelength,options.filter(v/wvd.z_flux_scale),LineWidth=options.triadLW,Color=0*[1 1 1],LineStyle="--",DisplayName="nonlinear advection"), hold on
end

idx = [enstrophy_fluxes.name] == "nonlinear_advection";
v = filter(enstrophy_fluxes(idx).Z0);
plot(ax,radialWavelength,options.filter(v/wvd.z_flux_scale),LineWidth=options.triadLW,Color=0*[1 1 1],LineStyle="-",DisplayName="nonlinear advection"), hold on



geostrophic_forcings = ["quadratic_bottom_friction","adaptive_damping","geostrophic_mean_flow"];
n = 1;
for i=1:length(geostrophic_forcings)
    if shouldShowQuadraticFluxes
        set(gca,'ColorOrderIndex',n)
        idx = [enstrophy_fluxes_quadratic.name] == geostrophic_forcings(i);
        v = filter(enstrophy_fluxes_quadratic(idx).Z0);
        plot(ax,radialWavelength,options.filter(v/wvd.z_flux_scale),LineWidth=options.forcingLW,LineStyle="--",DisplayName=enstrophy_fluxes_quadratic(idx).fancyName)
    end

    set(gca,'ColorOrderIndex',n)
    idx = [enstrophy_fluxes.name] == geostrophic_forcings(i);
    v = filter(enstrophy_fluxes(idx).Z0);
    plot(ax,radialWavelength,options.filter(v/wvd.z_flux_scale),LineWidth=options.forcingLW,DisplayName=enstrophy_fluxes(idx).fancyName)

    n = n+1;
end

% ddt of spectrum and net flux
% v = wvd.transformToPseudoRadialWavenumber(EnergyReservoir.geostrophic_mda,ddt_TZ_A0);
% plot(ax,radialWavelength,options.filter(v/wvd.z_flux_scale),'c',LineWidth=options.forcingLW,DisplayName='d/dt potential enstrophy')

% lgd1.NumColumns = 2;

set(gca,'XDir','reverse')
set(gca,'XScale','log')
xlim(radialWavelengthLimits)
ylim(yl)

% forcing/damping patches
% yl = ylim;
patch(ax,[lambdaMeanFlow,flip(lambdaMeanFlow)],[0,0,yl(2),yl(2)],colorMeanFlow,'FaceAlpha',patchAlpha,'EdgeColor','none','HandleVisibility','off')
patch(ax,[lambdaFrictionGeo,flip(lambdaFrictionGeo)],[yl(1),yl(1),0,0],colorFriction,'FaceAlpha',patchAlpha,'EdgeColor','none','HandleVisibility','off')
patch(ax,[lambdaDamp,flip(lambdaDamp)],[yl(1),yl(1),0,0],colorDamp,'FaceAlpha',patchAlpha,'EdgeColor','none','HandleVisibility','off')
% Put patches on bottom
% g=get(gca,'Children');
% g=g(flip(1:length(g)));
% set(gca,'children',g)


lgd1 = legend('location','southwest');
ylabel(gca,{"potential enstrophy flux (" + wvd.z_flux_scale_units + ")"})
xlabel(gca,xaxislabel);
text(ax,max(xlim)*.95,max(ylim),'b)','FontSize',14,'HorizontalAlignment','left','VerticalAlignment','top')


exportgraphics(fig,figureFolder + "/" + "enstrophy_flux1D.png",Resolution=300)