% basedir = "/Users/Shared/CimRuns_June2025/output/";
% basedir = "/Users/jearly/Dropbox/CimRuns_June2025/output/";
% basedir = "/Volumes/Samsung_T7/CimRuns_June2025/output/";
% basedir = '/Users/cwortham/Documents/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns/output/';
basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_November2025/output/';

figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
       mkdir(figureFolder)
end

runNumber=1;
wvd1 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

runNumber=18;
wvd18 = WVDiagnostics(basedir + replace(getRunParameters(runNumber),"256","512") + ".nc");

wvdArray = {wvd1,wvd18};
runNames = {"MF","MFW"};

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

% colors
C = orderedcolors("gem"); 
colorDictionary = dictionary("APV",{C(4,:)});
colorDictionary{"QGPV"} = C(3,:);
colorDictionary{"error"} = [0 0 0];
colorDictionary{"slope"} = [0 0 0];

n = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% run 01
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.clim = [-11 -7.0];
options.jlim = [0 40];
options.klim = [5 500];

units_scale = 1/(wvd18.wvt.f*wvd18.wvt.f);

for iWVD=1:length(wvdArray)

    wvd = wvdArray{iWVD};
    wvd.pseudoRadialBinning = "adaptive";
    if wvd.diagnosticsHasExplicitAntialiasing
        wvt = wvd.wvt_aa;
    else
        wvt = wvd.wvt;
    end

gmf = wvt.forcingWithName("geostrophic-mean-flow");
forcingIndex = gmf.A0_indices(2);
Kh2 = wvt.K(forcingIndex).^2 + wvt.L(forcingIndex).^2;
Kp2 = Kh2 + 1/wvt.Lr2(wvt.J(forcingIndex)+1);
forcingPseudoWavelength = 2*pi/sqrt(Kp2)/1000;

    % create radial wavelength vector
    radialWavelength = 2*pi./wvt.kRadial/1000;
    radialWavelength(1) = 2*radialWavelength(2);

    pseudoRadialWavelength = 2*pi./wvd.kPseudoRadial/1000;
    pseudoRadialWavelength(1) = 1.5*pseudoRadialWavelength(2);

    radiusOfDeformation = 2*pi*sqrt(wvt.Lr2)/1000;
    radiusOfDeformation(1) = 1.5*radiusOfDeformation(2);

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
    p(1) = plot(radialWavelength,units_scale*TZ_APV_kR,Color=colorDictionary{'APV'},LineWidth=1.5); hold on
    p(2) = plot(radialWavelength,units_scale*TZ_A0_kR,Color=colorDictionary{'QGPV'},LineWidth=1.5);
    p(3) = plot(radialWavelength,units_scale*TZ_Error_kR,Color=colorDictionary{'error'},LineWidth=1.5);
    p(4) = plot(radialWavelength,units_scale*TZ_ErrorNoRV_kR,Color=colorDictionary{'error'},LineWidth=1.5,LineStyle=":");
    p(5) = plot(radialWavelength,units_scale*TZ_ErrorNoETA_kR,Color=colorDictionary{'error'},LineWidth=1.5,LineStyle="--");
    set(gca,'XDir','reverse')
    xscale('log'); yscale('log')
    axis tight
    % title('Radial Wavenumber Spectrum')
    ylabel({runNames{iWVD};'potential enstrophy (m f^2)'});
    % xlabel('wavelength (km)')
    ylim(units_scale*10.^options.clim);

    rw = [3e2 1e1];
    slope = (3.3e-12)*rw.^(1.5); % 3.5e-10 @ 1e2
    plot(rw,units_scale*slope,LineStyle="--",Color=colorDictionary{'slope'})
    text(30,units_scale*10e-10,"\lambda^{1.5}")

    % rw = [40 150];
    % slope = (1.5e-12)*rw.^(2); % 3.3e-8 @ 150
    % plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
    % text(60,10e-9,"\lambda^{2}")
    % 
    % rw = [40 6];
    % slope = (4.0e-11)*rw.^(1); % 1e-10 @  7
    % plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
    % text(10,60e-11,"\lambda^{1}")


    if iWVD == 1
        legend(p,'apv','qgpv','total error','relative vorticity error', 'vortex stretching error')
    end

    % plot vertical mode spectrum

    if true
        jAxis = radiusOfDeformation;
    else
        jAxis = wvt.j;
    end

    axJ = nexttile(n); n = n+1;
    plot(jAxis,units_scale*TZ_APV_j,Color=colorDictionary{'APV'},LineWidth=1.5); hold on
    plot(jAxis,units_scale*TZ_A0_j,Color=colorDictionary{'QGPV'},LineWidth=1.5);
    plot(jAxis,units_scale*TZ_Error_j,Color=colorDictionary{'error'},LineWidth=1.5);
    plot(jAxis,units_scale*TZ_ErrorNoRV_j,Color=colorDictionary{'error'},LineWidth=1.5,LineStyle=":");
    plot(jAxis,units_scale*TZ_ErrorNoETA_j,Color=colorDictionary{'error'},LineWidth=1.5,LineStyle="--");
    yscale('log'); xscale('log');
    set(gca,'XDir','reverse')
    ylim(units_scale*10.^options.clim);
    axis tight
    % ylabel('enstrophy (m s^{-2})');
    % xlabel('vertical mode j');
    % title('Vertical Mode Spectrum')
    set(gca,'YTick',[])

    rw = [30 150];
    slope = (1.5e-12)*rw.^(2); % 3.3e-8 @ 150
    plot(rw,units_scale*slope,LineStyle="--",Color=colorDictionary{'slope'})
    text(60,units_scale*10e-9,"\lambda^{2}")

    rw = [40 6];
    slope = (4.0e-11)*rw.^(1); % 1e-10 @  7
    plot(rw,units_scale*slope,LineStyle="--",Color=colorDictionary{'slope'})
    text(10,units_scale*60e-11,"\lambda^{1}")

    % ja = [5 30];
    % % slope_j = 20/(log(TZ_APV_j(31))-log(TZ_APV_j(11)));
    % slope_j = -10;
    % plot(ja,(18e-10)*exp(ja/slope_j),LineStyle="--",Color=0*[1 1 1])
    % text(18,5e-10,"e^{-j/10}")

    % set(axJ,'xlim',options.jlim)
    set(axJ,'xlim',[options.klim(1) radiusOfDeformation(1)])
    set(axJ,'ylim',units_scale*10.^options.clim)
    set(axK,'xlim',options.klim)
    set(axK,'ylim',units_scale*10.^options.clim)

    if shouldShowPseudoRadialPlot
        axKP = nexttile(n); n = n+1;
        plot(pseudoRadialWavelength,units_scale*TZ_APV_kPseudo,Color=colorDictionary{'APV'},LineWidth=1.5), hold on
        plot(pseudoRadialWavelength,units_scale*TZ_A0_kPseudo,Color=colorDictionary{'QGPV'},LineWidth=1.5),
        plot(pseudoRadialWavelength,units_scale*TZ_Error_kPseudo,Color=colorDictionary{'error'},LineWidth=1.5)
        plot(pseudoRadialWavelength,units_scale*TZ_ErrorNoRV_kPseudo,Color=colorDictionary{'error'},LineWidth=1.5,LineStyle=":");
        plot(pseudoRadialWavelength,units_scale*TZ_ErrorNoETA_kPseudo,Color=colorDictionary{'error'},LineWidth=1.5,LineStyle="--");
        set(gca,'XDir','reverse')
        xscale('log'); yscale('log')
        axis tight
        % title('Radial Wavenumber Spectrum')
        % ylabel({'HS-G';'potential enstrophy (m s^{-2})'});
        % xlabel('wavelength (km)')
        set(gca,'YTick',[])
        ylim(units_scale*10.^options.clim);

        % rw = [100 7];
        % slope = (10e-12)*rw.^(1.5); % 3.5e-10 @ 1e2
        % plot(rw,slope,LineStyle="--",Color=0*[1 1 1])
        % text(30,25e-10,"\lambda^{1.5}")

        rw = [30 150];
        slope = (1.5e-12)*rw.^(2); % 3.3e-8 @ 150
        plot(rw,units_scale*slope,LineStyle="--",Color=colorDictionary{'slope'})
        text(60,units_scale*10e-9,"\lambda^{2}")

        rw = [40 6];
        slope = (4.0e-11)*rw.^(1); % 1e-10 @  7
        plot(rw,units_scale*slope,LineStyle="--",Color=colorDictionary{'slope'})
        text(10,units_scale*60e-11,"\lambda^{1}")
    end

    if iWVD == 1
        set(axK,'XTick',[])
        set(axJ,'XTick',[])
        set(axKP,'XTick',[])
    elseif iWVD == 2
        xlabel(axK, 'horizontal wavelength (km)');
        % xlabel(axJ,'vertical mode (j)');
        xlabel(axJ,'deformation wavelength (km)');
        xlabel(axKP,'pseudo-wavelength (km)')
    end

end

exportgraphics(fig,figureFolder + "/" + "enstrophy_spectrum1D_simple.png",Resolution=300)


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

