% basedir = "/Users/Shared/CimRuns_June2025/output/";
basedir = "/Users/jearly/Dropbox/CimRuns_June2025/output/";
% basedir = "/Volumes/Samsung_T7/CimRuns_June2025/output/";


figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
       mkdir(figureFolder)
end

runNumber=1; runName = "hydrostatic: geostrophic";
wvd1 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

runNumber=9; runName = "hydrostatic: geostrophic + waves";
wvd9 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

runNumber=18; runName = "non-hydrostatic: geostrophic + waves";
wvd18 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

wvdArray = {wvd1,wvd9,wvd18};

%%
% 
% TE_A0_j_kR = wvt.transformToRadialWavenumber(wvt.A0_TZ_factor ./ wvt.A0_TE_factor);
% TE_A0_kR = sum(TE_A0_j_kR,1);
% TE_A0_j = sum(TE_A0_j_kR,2);
% TE_A0_kPseudo = wvd.transformToPseudoRadialWavenumberA0(TE_A0_j_kR);
% 
% figure,
% plot(radialWavelength,TE_A0_kR)
% % plot(radialWavelength,TE_A0_j_kR(2,:))
% set(gca,'XDir','reverse')
% xscale('log'); yscale('log')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% enstrophy spectrum figure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



fig = figure('Units', 'points', 'Position', [50 50 700 350]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');

tl = tiledlayout(1,2,TileSpacing="compact");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% run 01
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.clim = [-7 2];
options.jlim = [0 40];

wvd = wvd18;

for i=1:length(wvdArray)
    n = 1;
    wvd = wvdArray{i};

if wvd.diagnosticsHasExplicitAntialiasing
    wvt = wvd.wvt_aa;
else
    wvt = wvd.wvt;
end


% create radial wavelength vector
radialWavelength = 2*pi./wvt.kRadial/1000;
radialWavelength(1) = 1.5*radialWavelength(2);

pseudoRadialWavelength = 2*pi./wvd.kPseudoRadial/1000;
pseudoRadialWavelength(1) = 1.5*pseudoRadialWavelength(2);

radiusOfDeformation = 2*pi*sqrt(wvt.Lr2)/1000;
radiusOfDeformation(1) = 1.5*radiusOfDeformation(2);

A0 = wvt.A0;
A0(:,1) = 0;

TE_A0_j_kl = wvt.A0_TE_factor .* abs(A0).^2;
TE_A0_j_kR = wvt.transformToRadialWavenumber(TE_A0_j_kl);
TE_A0_kR = sum(TE_A0_j_kR,1);
TE_A0_j = sum(TE_A0_j_kR,2);
TE_A0_kPseudo = wvd.transformToPseudoRadialWavenumberA0(TE_A0_j_kR);

TE_Apm_j_kl = wvt.Apm_TE_factor .* (abs(wvt.Ap).^2 + abs(wvt.Am).^2);
TE_Apm_j_kR = wvt.transformToRadialWavenumber(TE_Apm_j_kl);
TE_Apm_kR = sum(TE_Apm_j_kR,1);
TE_Apm_j = sum(TE_Apm_j_kR,2);
TE_Apm_kPseudo = wvd.transformToPseudoRadialWavenumberApm(TE_Apm_j_kR);
% TE_Apm_kPseudo = wvd.transformToPseudoRadialWavenumberA0(TE_Apm_j_kR);


% plot horizontal wavenumber spectrum
axK = nexttile(n); n = n+1;
set(gca,'ColorOrderIndex',i)
p(2*i-1) = plot(radialWavelength,TE_A0_kR,LineWidth=2); hold on
set(gca,'ColorOrderIndex',i)
p(2*i) = plot(radialWavelength,TE_Apm_kR,LineWidth=2,LineStyle="--");
set(gca,'XDir','reverse')
xscale('log'); yscale('log')
axis tight
% title('Radial Wavenumber Spectrum')
ylabel('energy (m^{3} s^{-2})');
xlabel('wavelength (km)')
ylim(10.^options.clim);



% plot vertical mode spectrum
axJ = nexttile(n); n = n+1;
set(gca,'ColorOrderIndex',i)
plot(radiusOfDeformation,TE_A0_j,LineWidth=2); hold on
set(gca,'ColorOrderIndex',i)
plot(radiusOfDeformation,TE_Apm_j,LineWidth=2,LineStyle="--")
set(gca,'XDir','reverse')
yscale('log'); xscale('log');
axis tight
xlabel('wavelength of deformation (km)');
% title('Vertical Mode Spectrum')
ylim(10.^options.clim);
% set(gca,'XTick',[])
set(gca,'YTick',[])

% axJ = nexttile(n); n = n+1;
% set(gca,'ColorOrderIndex',i)
% p(2) = plot(wvt.j,TE_A0_j); hold on
% set(gca,'ColorOrderIndex',i)
% plot(wvt.j,TE_Apm_j,LineStyle="--")
% % set(gca,'XDir','reverse')
% yscale('log');% xscale('log');
% axis tight
% xlabel('mode (j)');
% title('Vertical Mode Spectrum')
% ylim(10.^options.clim);
% % set(gca,'XTick',[])
% set(gca,'YTick',[])


end



nexttile(1)
rw = [2e2 7e0];
slope = (0.2e-7)*rw.^(3); % 3.5e-10 @ 1e2
plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
text(50,1e-3,"\lambda^{3}")

rw = [3e1 7e0];
slope = (2e-4)*rw.^(2); % 3.5e-10 @ 1e2
plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
text(10,3e-2,"\lambda^{2}")

nexttile(2)
rw = [2e2 7e0];
slope = (0.2e-7)*rw.^(3); % 3.5e-10 @ 1e2
plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
text(50,1e-3,"\lambda^{3}")

rw = [50 7e0];
slope = (1e-3)*rw.^(2); % 3.5e-10 @ 1e2
plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
text(10,1e-1,"\lambda^{2}")


nexttile(1)

legend([p(1), p(2) p(3) p(4) p(5) p(6)],'HS-G: geostrophic','HS-G: wave','HS-GW: geostrophic','HS-GW: wave','NHS-GW: geostrophic','NHS-GW: wave')

exportgraphics(fig,figureFolder + "/" + "energy_spectrum_simple.png",Resolution=300)

% nexttile(2)
% rw = [2e2 7e0];
% slope = (0.7e-6)*rw.^(3); % 3.5e-10 @ 1e2
% plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
% text(50,3e-1,"\lambda^{3}")
% 
% rw = [6e1 7e0];
% slope = (1e-4)*rw.^(2); % 3.5e-10 @ 1e2
% plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
% text(10,3e-1,"\lambda^{2}")


% ja = [5 30];
% slope_j = 20/(log(TZ_APV_j(31))-log(TZ_APV_j(11)));
% slope_j = -10;
% plot(ja,(18e-10)*exp(ja/slope_j),LineStyle="--",Color=0*[1 1 1])
% text(18,5e-10,"e^{-j/10}")

% axJ = nexttile(n); n = n+1;
% p(3) = plot(pseudoRadialWavelength,TE_A0_kPseudo); hold on
% plot(pseudoRadialWavelength,TE_Apm_kPseudo)
% set(gca,'XDir','reverse')
% yscale('log'); xscale('log');
% axis tight
% xlabel('pseudo radius of deformation (km)');
% title('Pseudo Radial Wavenumber Spectrum')
% ylim(10.^options.clim);
% % set(gca,'XTick',[])
% set(gca,'YTick',[])
% 
% rw = [2e2 7e0];
% slope = (0.7e-6)*rw.^(3); % 3.5e-10 @ 1e2
% plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
% text(50,3e-1,"\lambda^{3}")
% 
% rw = [6e1 7e0];
% slope = (1e-4)*rw.^(2); % 3.5e-10 @ 1e2
% plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
% text(10,3e-1,"\lambda^{2}")