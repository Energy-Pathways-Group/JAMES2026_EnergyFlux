% basedir = "/Users/Shared/CimRuns_June2025/output/";
% basedir = '/Users/cwortham/Documents/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns/output/';
% basedir = "/Volumes/Samsung_T7/CimRuns_June2025/output/";
basedir = "/Users/jearly/Dropbox/CimRuns_June2025/output/";

resolution = 256;

wvd1 = WVDiagnostics(basedir + replace(getRunParameters(1),"256",string(resolution)) + ".nc");
wvd9 = WVDiagnostics(basedir + replace(getRunParameters(9),"256",string(resolution)) + ".nc");
wvd18 = WVDiagnostics(basedir + replace(getRunParameters(18),"256",string(resolution)) + ".nc");

%%

wvdArray{1} = wvd1;
wvdArray{2} = wvd9;
wvdArray{3} = wvd18;

figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
    mkdir(figureFolder)
end

% cmap = wvd.cmocean('deep',length(z));

C = orderedcolors("gem");
purple = [0.4940, 0.1840, 0.5560]; % extra color for labels
% Colours (from box plot)
col.sources = [191 191 250]/255;
col.geo     = [205 253 254]/255; % basically pale 'cyan'
col.geoBold = [205/10 253 254]/255;
col.wave    = [205 253 197]/255; % basically pale 'green'
col.waveBold= [205/10 253 197/10]/255;
col.sinks   = [245 194 193]/255;

depths = [-2500 -100];
depthIndices = zeros(size(depths));
z = wvd1.wvfile.readVariables('mooring/mooring_z');
for iDepth=1:length(depths)
    [~,depthIndices(iDepth)] = min(abs(z - depths(iDepth)));
end

%%

figPos = [50 50 700 300];
fig = figure(Units='points',Position=figPos);
tl = tiledlayout(1,2,"TileSpacing","tight");

for i=1:3
    wvd = wvdArray{i};

    t = wvd.wvfile.readVariables('mooring/t');
    u = wvd.wvfile.readVariables('mooring/mooring_u');
    v = wvd.wvfile.readVariables('mooring/mooring_v');
    u = u(depthIndices,:,:);
    v = v(depthIndices,:,:);

    cv_mooring = shiftdim( u + sqrt(-1)*v, 2);
    [PSI,LAMBDA] = sleptap(length(t),5);
    [omega_p, Spp, Snn, Spn] = mspec(t(2)-t(1),cv_mooring,PSI);
    Spp = mean(Spp,3);
    Snn = mean(Snn,3);

    ax1 = nexttile(tl,1);
    set(ax1,'xdir','reverse')
    set(ax1,'XScale','log')
    set(ax1,'YScale','log')
    axis tight
    box on
    hold on

    ax2 = nexttile(tl,2);
    set(ax2,'XScale','log')
    set(ax2,'YScale','log')
    axis tight
    box on
    hold on

    % plot model spectrum
    set(ax1,'ColorOrderIndex',i)
    set(ax2,'ColorOrderIndex',i)
    % set(ax1,'ColorOrder',cmap)
    % set(ax2,'ColorOrder',cmap)
    % negative
    plt1 = loglog(ax1,omega_p*86400/2/pi,fliplr(Snn(:,2)),Color=C(i,:),LineWidth=2);
    plt1 = loglog(ax1,omega_p*86400/2/pi,fliplr(Snn(:,1)),Color=C(i,:),LineWidth=1);
    % set(plt1,{'DisplayName'},legendCell)
    % positive
    plt2 = loglog(ax2,omega_p*86400/2/pi,fliplr(Spp(:,2)),Color=C(i,:),LineWidth=2);
    plt2 = loglog(ax2,omega_p*86400/2/pi,fliplr(Spp(:,1)),Color=C(i,:),LineWidth=1);
    % set(plt2,{'DisplayName'},legendCell)

end

legend(ax2,{"HS-G 100m","HS-G 2500m","HS-GW 100m","HS-GW 2500m","NHS-GW 100m","NHS-GW 2500m"},'location','best')

M2Period = 12.420602*3600; % M2 tidal period, s

wvt = wvd1.wvt;

% reference frequency lines
plt4 = plot(ax1,[wvt.f,wvt.f]*86400/2/pi,ylim,'k--','DisplayName','f','HandleVisibility','off');
plt5 = plot(ax2,[wvt.f,wvt.f]*86400/2/pi,ylim,'k--','DisplayName','f','HandleVisibility','off');
plt6 = plot(ax1,[2*pi/M2Period,2*pi/M2Period]*86400/2/pi,ylim,'k--','DisplayName','M2','HandleVisibility','off');
plt7 = plot(ax2,[2*pi/M2Period,2*pi/M2Period]*86400/2/pi,ylim,'k--','DisplayName','M2','HandleVisibility','off');
plt8 = plot(ax1,[2*pi/M2Period+wvt.f,2*pi/M2Period+wvt.f]*86400/2/pi,ylim,'k--','DisplayName','f+M2','HandleVisibility','off');
plt9 = plot(ax2,[2*pi/M2Period+wvt.f,2*pi/M2Period+wvt.f]*86400/2/pi,ylim,'k--','DisplayName','f+M2','HandleVisibility','off');
plt10 = plot(ax1,sqrt(wvt.N2(depthIndices(1)))*86400/2/pi*[1,1],ylim,'k--','DisplayName','N(-2500m)','HandleVisibility','off');
plt11 = plot(ax2,sqrt(wvt.N2(depthIndices(1)))*86400/2/pi*[1,1],ylim,'k--','DisplayName','N(-2500m)','HandleVisibility','off');
% plt12 = plot(ax1,[max(sqrt(wvt.N2)),max(sqrt(wvt.N2))]*86400/2/pi,ylim,'k--','DisplayName','max N(z)','HandleVisibility','off');
% plt13 = plot(ax2,[max(sqrt(wvt.N2)),max(sqrt(wvt.N2))]*86400/2/pi,ylim,'k--','DisplayName','max N(z)','HandleVisibility','off');

% reference frequency labels
% textY = .5*max(ax2.YLim);
textY = 2*min(ax2.YLim);
text(ax2,wvt.f*86400/2/pi,textY,'f','Color','k','HorizontalAlignment','right','FontWeight','bold')
text(ax2,2*pi/M2Period*86400/2/pi,textY,'M2','Color','k','HorizontalAlignment','right','FontWeight','bold')
text(ax2,(2*pi/M2Period+wvt.f)*86400/2/pi,textY,'f+M2','Color','k','HorizontalAlignment','left','FontWeight','bold')
text(ax2,sqrt(wvt.N2(depthIndices(1)))*86400/2/pi,textY,'N(2500m)','Color','k','HorizontalAlignment','left','FontWeight','bold')
text(ax1,wvt.f*86400/2/pi,textY,'f','Color','k','HorizontalAlignment','left','FontWeight','bold')
text(ax1,2*pi/M2Period*86400/2/pi,textY,'M2','Color','k','HorizontalAlignment','left','FontWeight','bold')
text(ax1,(2*pi/M2Period+wvt.f)*86400/2/pi,textY,'f+M2','Color','k','HorizontalAlignment','right','FontWeight','bold')
text(ax1,sqrt(wvt.N2(depthIndices(1)))*86400/2/pi,textY,'N(2500m)','Color','k','HorizontalAlignment','right','FontWeight','bold')

xlabel(tl,'frequency (cycles per day)')
ylabel(tl,'power (m^2/s)')
ax2.YTickLabels={};


exportgraphics(fig,figureFolder + "/" + "moorings_total_velocity_" + resolution + ".png",Resolution=300)

% fig1 = wvd1.plotMooringRotarySpectrum(shouldShowLegend=false,title="hydrostatic: geostrophic",shouldShowSpectralTitles=false);
% fig9 = wvd9.plotMooringRotarySpectrum(shouldShowLegend=false,title="hydrostatic: geostrophic + waves",shouldShowSpectralTitles=false);
% fig18 =wvd18.plotMooringRotarySpectrum(shouldShowLegend=false,title="non-hydrostatic: geostrophic + waves",shouldShowSpectralTitles=false);
%
% exportgraphics(fig1,figureFolder + "/" + "mooring_run1.png",Resolution=300)
% exportgraphics(fig9,figureFolder + "/" + "mooring_run9.png",Resolution=300)
% exportgraphics(fig18,figureFolder + "/" + "mooring_run18.png",Resolution=300)