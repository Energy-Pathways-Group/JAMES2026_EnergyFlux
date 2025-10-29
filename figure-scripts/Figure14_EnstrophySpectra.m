basedir = "/Users/Shared/CimRuns_June2025/output/";
basedir = "/Users/jearly/Dropbox/CimRuns_June2025/output/";
% basedir = "/Volumes/Samsung_T7/CimRuns_June2025/output/";
% basedir = '/Users/cwortham/Documents/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns/output/';
% basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_June2025/output/';

% runNumber=1; runName = "hydrostatic: geostrophic";
% runNumber=9; runName = "hydrostatic: geostrophic + waves";
% runNumber=18; runName = "non-hydrostatic: geostrophic + waves";
% wvd = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");
% wvd = WVDiagnostics("/Volumes/Samsung_T7/CimRuns_June2025/output/run1_icR_iner0_tide0_lat32_geo0065_N0052_hydrostatic_res512_duplicate.nc");

figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
       mkdir(figureFolder)
end

runNumber=1; runName = "hydrostatic: geostrophic";
wvd1 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

runNumber=18; runName = "non-hydrostatic: geostrophic + waves";
wvd18 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% enstrophy spectrum figure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

shouldShowPseudoRadialPlot = true;

if shouldShowPseudoRadialPlot
    fig = figure('Units', 'points', 'Position', [50 50 900 500]);
    set(gcf,'PaperPositionMode','auto')
    set(gcf, 'Color', 'w');
    tl = tiledlayout(2,3,TileSpacing="tight");
else
    fig = figure('Units', 'points', 'Position', [50 50 700 500]);
    set(gcf,'PaperPositionMode','auto')
    set(gcf, 'Color', 'w');
    tl = tiledlayout(2,2,TileSpacing="tight");
end

n = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% run 01
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.clim = [-11 -7.4];
options.jlim = [0 40];
options.klim = [5 500];


wvd = wvd1;
wvd.pseudoRadialBinning = "adaptive";
if wvd.diagnosticsHasExplicitAntialiasing
    wvt = wvd.wvt_aa;
else
    wvt = wvd.wvt;
end

% wvt.addOperation(EtaTrueOperation());
% wvt.addOperation(APEOperation(wvt));
% wvt.addOperation(APVOperation());

% create radial wavelength vector
radialWavelength = 2*pi./wvt.kRadial/1000;
radialWavelength(1) = 2*radialWavelength(2);

pseudoRadialWavelength = 2*pi./wvd.kPseudoRadial/1000;
pseudoRadialWavelength(1) = 1.5*pseudoRadialWavelength(2);

function [TZ_Error_kR,TZ_Error_j,TZ_Error_kPseudo] = errorSpectra(wvd,pvA,pvB)
if wvd.diagnosticsHasExplicitAntialiasing
    wvt = wvd.wvt_aa;
else
    wvt = wvd.wvt;
end
error = pvA - pvB;
error = error - mean(mean(error,1),2);
TZ_Error_j_kl = wvd.spectrumWithFgTransform(error,useExplicitAntialiasedWVT=wvd.diagnosticsHasExplicitAntialiasing);
TZ_Error_j_kR = wvt.transformToRadialWavenumber(TZ_Error_j_kl);
TZ_Error_kR = sum(TZ_Error_j_kR,1);
TZ_Error_j = sum(TZ_Error_j_kR,2);
TZ_Error_kPseudo = wvd.transformToPseudoRadialWavenumberA0(TZ_Error_j_kR);
end

[TZ_APV_kR,TZ_APV_j,TZ_APV_kPseudo] = errorSpectra(wvd,wvt.apv,0);
[TZ_A0_kR,TZ_A0_j,TZ_A0_kPseudo] = errorSpectra(wvd,wvt.qgpv,0);
[TZ_Error_kR,TZ_Error_j,TZ_Error_kPseudo] = errorSpectra(wvd,wvt.apv,wvt.qgpv);


APV_no_rv = wvt.zeta_z - wvt.f .* wvt.diffZG(wvt.eta_true);
[TZ_ErrorNoRV_kR,TZ_ErrorNoRV_j,TZ_ErrorNoRV_kPseudo] = errorSpectra(wvd,wvt.apv,APV_no_rv);

APV_x = wvt.zeta_x .* wvt.diffX(wvt.eta_true);
APV_y = wvt.zeta_y .* wvt.diffY(wvt.eta_true);
APV_z = wvt.zeta_z .* wvt.diffY(wvt.eta_true) + wvt.f .* wvt.diffZG(wvt.eta);
APV_no_eta = wvt.zeta_z - APV_x - APV_y - APV_z;
[TZ_ErrorNoETA_kR,TZ_ErrorNoETA_j,TZ_ErrorNoETA_kPseudo] = errorSpectra(wvd,wvt.apv,APV_no_eta);

% plot horizontal wavenumber spectrum
axK = nexttile(n); n = n+1;
plot(radialWavelength,TZ_APV_kR,LineWidth=1.5), hold on
plot(radialWavelength,TZ_A0_kR,LineWidth=1.5),
plot(radialWavelength,TZ_Error_kR,Color=0*[1 1 1],LineWidth=1.5)
plot(radialWavelength,TZ_ErrorNoRV_kR ,Color=0*[1 1 1],LineWidth=1.5,LineStyle=":");
plot(radialWavelength,TZ_ErrorNoETA_kR,Color=0*[1 1 1],LineWidth=1.5,LineStyle="--");
set(gca,'XDir','reverse')
xscale('log'); yscale('log')
axis tight
% title('Radial Wavenumber Spectrum')
ylabel({'HS-G';'potential enstrophy (m s^{-2})'});
% xlabel('wavelength (km)')
set(gca,'XTick',[])
ylim(10.^options.clim);

rw = [3e2 1e1];
slope = (3.3e-12)*rw.^(1.5); % 3.5e-10 @ 1e2
plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
text(30,10e-10,"\lambda^{1.5}")

% plot vertical mode spectrum
axJ = nexttile(n); n = n+1;
p(1) = plot(wvt.j,TZ_APV_j,LineWidth=1.5); hold on
p(2) = plot(wvt.j,TZ_A0_j,LineWidth=1.5);
p(3) = plot(wvt.j,TZ_Error_j,Color=0*[1 1 1],LineWidth=1.5);
p(4) = plot(wvt.j,TZ_ErrorNoRV_j ,Color=0*[1 1 1],LineWidth=1.5,LineStyle=":");
p(5) = plot(wvt.j,TZ_ErrorNoETA_j,Color=0*[1 1 1],LineWidth=1.5,LineStyle="--");
yscale('log')
ylim(10.^options.clim);
axis tight
% ylabel('enstrophy (m s^{-2})');
% xlabel('vertical mode j');
% title('Vertical Mode Spectrum')
set(gca,'XTick',[])
set(gca,'YTick',[])

ja = [5 30];
% slope_j = 20/(log(TZ_APV_j(31))-log(TZ_APV_j(11)));
slope_j = -10;
plot(ja,(18e-10)*exp(ja/slope_j),LineStyle="--",Color=0*[1 1 1])
text(18,5e-10,"e^{-j/10}")

legend(p,'apv','qgpv','total error','relative vorticity error', 'vortex stretching error')

set(axJ,'xlim',options.jlim)
set(axJ,'ylim',10.^options.clim)
set(axK,'xlim',options.klim)
set(axK,'ylim',10.^options.clim)

if shouldShowPseudoRadialPlot
    axKP = nexttile(n); n = n+1;
    plot(pseudoRadialWavelength,TZ_APV_kPseudo,LineWidth=1.5), hold on
    plot(pseudoRadialWavelength,TZ_A0_kPseudo,LineWidth=1.5),
    plot(pseudoRadialWavelength,TZ_Error_kPseudo,Color=0*[1 1 1],LineWidth=1.5)
    % plot(radialWavelength,TZ_ErrorNoRV_kR ,Color=0*[1 1 1],LineWidth=1.5,LineStyle=":");
    % plot(radialWavelength,TZ_ErrorNoETA_kR,Color=0*[1 1 1],LineWidth=1.5,LineStyle="--");
    set(gca,'XDir','reverse')
    xscale('log'); yscale('log')
    axis tight
    % title('Radial Wavenumber Spectrum')
    % ylabel({'HS-G';'potential enstrophy (m s^{-2})'});
    % xlabel('wavelength (km)')
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    ylim(10.^options.clim);

    rw = [100 7];
    slope = (10e-12)*rw.^(1.5); % 3.5e-10 @ 1e2
    plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
    text(30,25e-10,"\lambda^{1.5}")
end

wvd = wvd18;
wvd.pseudoRadialBinning = "adaptive";
if wvd.diagnosticsHasExplicitAntialiasing
    wvt = wvd.wvt_aa;
else
    wvt = wvd.wvt;
end

[TZ_APV_kR,TZ_APV_j,TZ_APV_kPseudo] = errorSpectra(wvd,wvt.apv,0);
[TZ_A0_kR,TZ_A0_j,TZ_A0_kPseudo] = errorSpectra(wvd,wvt.qgpv,0);
[TZ_Error_kR,TZ_Error_j,TZ_Error_kPseudo] = errorSpectra(wvd,wvt.apv,wvt.qgpv);


APV_no_rv = wvt.zeta_z - wvt.f .* wvt.diffZG(wvt.eta_true);
[TZ_ErrorNoRV_kR,TZ_ErrorNoRV_j,TZ_ErrorNoRV_kPseudo] = errorSpectra(wvd,wvt.apv,APV_no_rv);

APV_x = wvt.zeta_x .* wvt.diffX(wvt.eta_true);
APV_y = wvt.zeta_y .* wvt.diffY(wvt.eta_true);
APV_z = wvt.zeta_z .* wvt.diffY(wvt.eta_true) + wvt.f .* wvt.diffZG(wvt.eta);
APV_no_eta = wvt.zeta_z - APV_x - APV_y - APV_z;
[TZ_ErrorNoETA_kR,TZ_ErrorNoETA_j,TZ_ErrorNoETA_kPseudo] = errorSpectra(wvd,wvt.apv,APV_no_eta);

% plot horizontal wavenumber spectrum
axK = nexttile(n); n = n+1;
plot(radialWavelength,TZ_APV_kR,LineWidth=1.5), hold on
plot(radialWavelength,TZ_A0_kR,LineWidth=1.5),
plot(radialWavelength,TZ_Error_kR,Color=0*[1 1 1],LineWidth=1.5)
plot(radialWavelength,TZ_ErrorNoRV_kR ,Color=0*[1 1 1],LineWidth=1.5,LineStyle=":");
plot(radialWavelength,TZ_ErrorNoETA_kR,Color=0*[1 1 1],LineWidth=1.5,LineStyle="--");
set(gca,'XDir','reverse')
xscale('log'); yscale('log')
axis tight
% title('Radial Wavenumber Spectrum')
ylabel({'NHS-GW';'potential enstrophy (m s^{-2})'});
xlabel('horizontal wavelength (km)')
ylim(10.^options.clim);

rw = [3e2 1e1];
slope = (3.3e-12)*rw.^(1.5); % 3.5e-10 @ 1e2
plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
text(30,10e-10,"\lambda^{1.5}")

% text(radialWavelength(1)*2,5,'Phase I','FontWeight','bold','FontSize',n_size+5,'FontName','times','Rotation',90)

% plot vertical mode spectrum
axJ = nexttile(n); n = n+1;
p(1) = plot(wvt.j,TZ_APV_j,LineWidth=1.5); hold on
p(2) = plot(wvt.j,TZ_A0_j,LineWidth=1.5);
p(3) = plot(wvt.j,TZ_Error_j,Color=0*[1 1 1],LineWidth=1.5);
p(4) = plot(wvt.j,TZ_ErrorNoRV_j ,Color=0*[1 1 1],LineWidth=1.5,LineStyle=":");
p(5) = plot(wvt.j,TZ_ErrorNoETA_j,Color=0*[1 1 1],LineWidth=1.5,LineStyle="--");
yscale('log')
ylim(10.^options.clim);
axis tight
% ylabel('enstrophy (m s^{-2})');
xlabel('vertical mode (j)');
% title('Vertical Mode Spectrum')
set(gca,'YTick',[])

ja = [5 30];
% slope_j = 20/(log(TZ_APV_j(31))-log(TZ_APV_j(11)));
slope_j = -7;
plot(ja,(3e-9)*exp(ja/slope_j),LineStyle="--",Color=0*[1 1 1])
text(18,5e-10,"e^{-j/7}")

% legend(p,'apv','qgpv','total error','relative vorticity error', 'stretching error')

set(axJ,'xlim',options.jlim)
set(axJ,'ylim',10.^options.clim)
set(axK,'xlim',options.klim)
set(axK,'ylim',10.^options.clim)

if shouldShowPseudoRadialPlot
    axKP = nexttile(n); n = n+1;
    plot(pseudoRadialWavelength,TZ_APV_kPseudo,LineWidth=1.5), hold on
    plot(pseudoRadialWavelength,TZ_A0_kPseudo,LineWidth=1.5),
    plot(pseudoRadialWavelength,TZ_Error_kPseudo,Color=0*[1 1 1],LineWidth=1.5)
    % plot(radialWavelength,TZ_ErrorNoRV_kR ,Color=0*[1 1 1],LineWidth=1.5,LineStyle=":");
    % plot(radialWavelength,TZ_ErrorNoETA_kR,Color=0*[1 1 1],LineWidth=1.5,LineStyle="--");
    set(gca,'XDir','reverse')
    xscale('log'); yscale('log')
    axis tight
    % title('Radial Wavenumber Spectrum')
    % ylabel({'HS-G';'potential enstrophy (m s^{-2})'});
    xlabel('pseudo-wavelength (km)')
    % set(gca,'XTick',[])
    set(gca,'YTick',[])
    ylim(10.^options.clim);

    rw = [100 7];
    slope = (1.5e-11)*rw.^(1.5); % 3.5e-10 @ 1e2
    plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
    text(30,35e-10,"\lambda^{1.5}")
end

% exportgraphics(fig,figureFolder + "/" + "enstrophy_spectrum1D_simple.png",Resolution=300)