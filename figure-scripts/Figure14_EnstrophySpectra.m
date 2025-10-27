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



fig = figure('Units', 'points', 'Position', [50 50 700 500]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');

tl = tiledlayout(2,2,TileSpacing="tight");
n = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% run 01
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.clim = [-11 -7];
options.jlim = [0 40];
options.klim = [5 500];


wvt = wvd1.wvt;
wvd = wvd1;

% wvt.addOperation(EtaTrueOperation());
% wvt.addOperation(APEOperation(wvt));
% wvt.addOperation(APVOperation());

% create radial wavelength vector
radialWavelength = 2*pi./wvt.kRadial/1000;
radialWavelength(1) = 2*radialWavelength(2);

pseudoRadialWavelength = 2*pi./wvd.kPseudoRadial/1000;
pseudoRadialWavelength(1) = 1.5*pseudoRadialWavelength(2);

% radiusOfDeformation = 2*pi

prefactorJ = wvt.h_0; prefactorJ(1) = wvt.Lz;
prefactorK = 2*ones(1,wvt.Nkl); prefactorK(1) = 1;
prefactor = prefactorJ * prefactorK;
qgpv_bar = wvt.transformFromSpatialDomainWithFg(wvt.transformFromSpatialDomainWithFourier(wvt.qgpv));
% Remove the mean---why? Because in this case, the mean is a different
% background state--the one we should have referenced.
qgpv_bar(:,1) = 0;
apv_bar = wvt.transformFromSpatialDomainWithFg(wvt.transformFromSpatialDomainWithFourier(wvt.apv));
error_bar = apv_bar-qgpv_bar;
TZ_A0_j_kl = prefactor.*abs(qgpv_bar).^2;
TZ_APV_j_kl = prefactor.*abs(apv_bar).^2;
TZ_Error_j_kl = prefactor.*abs(error_bar).^2;
TZ_A0_j_kR = wvt.transformToRadialWavenumber(TZ_A0_j_kl);
TZ_A0_kR = sum(TZ_A0_j_kR,1);
TZ_A0_j = sum(TZ_A0_j_kR,2);
% TZ_A0_kPseudo = wvd.transformToPseudoRadialWavenumberA0(TZ_A0_j_kR);
TZ_APV_j_kR = wvt.transformToRadialWavenumber(TZ_APV_j_kl);
TZ_APV_kR = sum(TZ_APV_j_kR,1);
TZ_APV_j = sum(TZ_APV_j_kR,2);
% TZ_APV_kPseudo = wvd.transformToPseudoRadialWavenumberA0(TZ_APV_j_kR);
TZ_Error_j_kR = wvt.transformToRadialWavenumber(TZ_Error_j_kl);
TZ_Error_kR = sum(TZ_Error_j_kR,1);
TZ_Error_j = sum(TZ_Error_j_kR,2);
% TZ_Error_kPseudo = wvd.transformToPseudoRadialWavenumberA0(TZ_Error_j_kR);

APV_no_rv = wvt.zeta_z - wvt.f .* wvt.diffZG(wvt.eta_true);

APV_x = wvt.zeta_x .* wvt.diffX(wvt.eta_true);
APV_y = wvt.zeta_y .* wvt.diffY(wvt.eta_true);
APV_z = wvt.zeta_z .* wvt.diffY(wvt.eta_true) + wvt.f .* wvt.diffZG(wvt.eta);
APV_no_eta = wvt.zeta_z - APV_x - APV_y - APV_z;

APV_no_rv_bar = wvt.transformFromSpatialDomainWithFg(wvt.transformFromSpatialDomainWithFourier(APV_no_rv));
APV_no_rv_bar(:,1) = 0;
error_bar_no_rv = apv_bar-APV_no_rv_bar;
TZ_ErrorNoRV_j_kl = prefactor.*abs(error_bar_no_rv).^2;
TZ_ErrorNoRV_j_kR = wvt.transformToRadialWavenumber(TZ_ErrorNoRV_j_kl);
TZ_ErrorNoRV_kR = sum(TZ_ErrorNoRV_j_kR,1);
TZ_ErrorNoRV_j = sum(TZ_ErrorNoRV_j_kR,2);

APV_no_eta_bar = wvt.transformFromSpatialDomainWithFg(wvt.transformFromSpatialDomainWithFourier(APV_no_eta));
APV_no_eta_bar(:,1) = 0;
error_bar_no_eta = apv_bar-APV_no_eta_bar;
TZ_ErrorNoETA_j_kl = prefactor.*abs(error_bar_no_eta).^2;
TZ_ErrorNoETA_j_kR = wvt.transformToRadialWavenumber(TZ_ErrorNoETA_j_kl);
TZ_ErrorNoETA_kR = sum(TZ_ErrorNoETA_j_kR,1);
TZ_ErrorNoETA_j = sum(TZ_ErrorNoETA_j_kR,2);

% plot horizontal wavenumber spectrum
axK = nexttile(n); n = n+1;
plot(radialWavelength,TZ_APV_kR,LineWidth=1.5), hold on
plot(radialWavelength,TZ_A0_kR,LineWidth=1.5),
plot(radialWavelength,TZ_Error_kR,Color=0*[1 1 1],LineWidth=1.5)
plot(radialWavelength,TZ_ErrorNoRV_kR ,Color=0*[1 1 1],LineWidth=2.0,LineStyle=":");
plot(radialWavelength,TZ_ErrorNoETA_kR,Color=0*[1 1 1],LineWidth=2.0,LineStyle="--");
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

wvt = wvd18.wvt;

qgpv_bar = wvt.transformFromSpatialDomainWithFg(wvt.transformFromSpatialDomainWithFourier(wvt.qgpv));
qgpv_bar(:,1) = 0;
apv_bar = wvt.transformFromSpatialDomainWithFg(wvt.transformFromSpatialDomainWithFourier(wvt.apv));
error_bar = apv_bar-qgpv_bar;
TZ_A0_j_kl = prefactor.*abs(qgpv_bar).^2;
TZ_APV_j_kl = prefactor.*abs(apv_bar).^2;
TZ_Error_j_kl = prefactor.*abs(error_bar).^2;
TZ_A0_j_kR = wvt.transformToRadialWavenumber(TZ_A0_j_kl);
TZ_A0_kR = sum(TZ_A0_j_kR,1);
TZ_A0_j = sum(TZ_A0_j_kR,2);
% TZ_A0_kPseudo = wvd.transformToPseudoRadialWavenumberA0(TZ_A0_j_kR);
TZ_APV_j_kR = wvt.transformToRadialWavenumber(TZ_APV_j_kl);
TZ_APV_kR = sum(TZ_APV_j_kR,1);
TZ_APV_j = sum(TZ_APV_j_kR,2);
% TZ_APV_kPseudo = wvd.transformToPseudoRadialWavenumberA0(TZ_APV_j_kR);
TZ_Error_j_kR = wvt.transformToRadialWavenumber(TZ_Error_j_kl);
TZ_Error_kR = sum(TZ_Error_j_kR,1);
TZ_Error_j = sum(TZ_Error_j_kR,2);
% TZ_Error_kPseudo = wvd.transformToPseudoRadialWavenumberA0(TZ_Error_j_kR);

APV_no_rv = wvt.zeta_z - wvt.f .* wvt.diffZG(wvt.eta_true);

APV_x = wvt.zeta_x .* wvt.diffX(wvt.eta_true);
APV_y = wvt.zeta_y .* wvt.diffY(wvt.eta_true);
APV_z = wvt.zeta_z .* wvt.diffY(wvt.eta_true) + wvt.f .* wvt.diffZG(wvt.eta);
APV_no_eta = wvt.zeta_z - APV_x - APV_y - APV_z;

APV_no_rv_bar = wvt.transformFromSpatialDomainWithFg(wvt.transformFromSpatialDomainWithFourier(APV_no_rv));
APV_no_rv_bar(:,1) = 0;
error_bar_no_rv = apv_bar-APV_no_rv_bar;
TZ_ErrorNoRV_j_kl = prefactor.*abs(error_bar_no_rv).^2;
TZ_ErrorNoRV_j_kR = wvt.transformToRadialWavenumber(TZ_ErrorNoRV_j_kl);
TZ_ErrorNoRV_kR = sum(TZ_ErrorNoRV_j_kR,1);
TZ_ErrorNoRV_j = sum(TZ_ErrorNoRV_j_kR,2);

APV_no_eta_bar = wvt.transformFromSpatialDomainWithFg(wvt.transformFromSpatialDomainWithFourier(APV_no_eta));
APV_no_eta_bar(:,1) = 0;
error_bar_no_eta = apv_bar-APV_no_eta_bar;
TZ_ErrorNoETA_j_kl = prefactor.*abs(error_bar_no_eta).^2;
TZ_ErrorNoETA_j_kR = wvt.transformToRadialWavenumber(TZ_ErrorNoETA_j_kl);
TZ_ErrorNoETA_kR = sum(TZ_ErrorNoETA_j_kR,1);
TZ_ErrorNoETA_j = sum(TZ_ErrorNoETA_j_kR,2);

% plot horizontal wavenumber spectrum
axK = nexttile(n); n = n+1;
plot(radialWavelength,TZ_APV_kR,LineWidth=1.5), hold on
plot(radialWavelength,TZ_A0_kR,LineWidth=1.5),
plot(radialWavelength,TZ_Error_kR,Color=0*[1 1 1],LineWidth=1.5)
plot(radialWavelength,TZ_ErrorNoRV_kR ,Color=0*[1 1 1],LineWidth=2.0,LineStyle=":");
plot(radialWavelength,TZ_ErrorNoETA_kR,Color=0*[1 1 1],LineWidth=2.0,LineStyle="--");
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

exportgraphics(fig,figureFolder + "/" + "enstrophy_spectrum1D_simple.png",Resolution=300)