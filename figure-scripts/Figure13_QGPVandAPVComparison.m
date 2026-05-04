loadFigureDefaults
wvd = wvd18;
wvt = wvd.wvt;
wvt.shouldUseTrueNoMotionProfile = true;
shouldShowDifference = true;

if shouldShowDifference
    nCols = 3;
    figSize = [50 50 800 300];
else
    nCols = 2;
    figSize = [50 50 600 300];
end

zeta_limits = [-1 1]*0.5;
cmDivRWB = wvd.cmocean('balance'); % diverging positive-negative

fig = figure(Units='points',Position=figSize,Visible = "on");
set(gcf,'PaperPositionMode','auto')

tl = tiledlayout(1,nCols,TileSpacing="tight");

index = length(wvt.z);

% APV
ax = nexttile;
val = wvt.apv(:,:,index)/wvt.f;
pcolor(wvt.x/1e3,wvt.y/1e3,val.'), shading flat
axis square
colormap(ax, cmDivRWB);
set(gca,'Layer','top','TickLength',[0.015 0.015])
clim(ax, zeta_limits);

xlabel('x-distance (km)')
ylabel('y-distance (km)')
title(ax, "apv")

% QGPV
ax = nexttile;
val = wvt.qgpv(:,:,index)/wvt.f;
pcolor(wvt.x/1e3,wvt.y/1e3,val.'), shading flat
axis square
colormap(ax, cmDivRWB);
set(gca,'Layer','top','TickLength',[0.015 0.015])
clim(ax, zeta_limits);

xlabel('x-distance (km)')
yticklabels([])
title(ax, "qgpv")


if shouldShowDifference
    % APV
    ax = nexttile;
    val = (wvt.apv(:,:,index) - wvt.qgpv(:,:,index))/wvt.f;
    pcolor(wvt.x/1e3,wvt.y/1e3,val.'), shading flat
    axis square
    colormap(ax, cmDivRWB);
    set(gca,'Layer','top','TickLength',[0.015 0.015])
    clim(ax, zeta_limits);

    xlabel('x-distance (km)')
    yticklabels([])
    title(ax, "apv-qgpv")
end

cb = colorbar("eastoutside");
cb.Label.String = "($f$)";
cb.Label.Interpreter = 'latex';

exportgraphics(fig,figureFolder + "/" + "Figure13_qgpv-apv-comparison.png",Resolution=300)