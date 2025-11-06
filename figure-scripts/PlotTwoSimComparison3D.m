
function fig = PlotTwoSimComparison3D(wvd1,wvd18,options)
arguments
    wvd1
    wvd18
    options.yForXZSlice1 = 50e3;
    options.yForXZSlice2 = 50e3;
    options.visible = "on";
    options.title = "none";
end
wvt = wvd18.wvt;


cmDivRWB = WVDiagnostics.cmocean('balance'); % diverging positive-negative

% set limits
zeta_limits = [-0.2 0.2];

% location for x-z section
if ~isfield(options,"yForXZSlice1")
    iY1 = round(wvt.Nx/2);
else
    iY1 = round(options.yForXZSlice1/(wvt.y(2)-wvt.y(1)));
end
if ~isfield(options,"yForXZSlice2")
    iY2 = round(wvt.Nx/2);
else
    iY2 = round(options.yForXZSlice2/(wvt.y(2)-wvt.y(1)));
end

nColumns = 2; nRows = 1;
% nColumns = 1; nRows = 2;
if nColumns == 2 && nRows==1
    figPos = [50 50 850 350];
elseif nColumns ==1 && nRows==2
    figPos = [50 50 425 600];
else
    figPos = [50 50 600 615];
end

fig = figure(Units='points',Position=figPos,Visible = options.visible);
set(gcf,'PaperPositionMode','auto')


tl = tiledlayout(nRows,nColumns,TileSpacing="tight");

if options.title ~= "none"
    title(tl, options.title, 'Interpreter', 'none')
end

    function makeVorticityXYZPlot(zeta_z,iY)
        val = circshift(zeta_z/wvt.f,-iY,2);
        s = slice(ax,wvt.x/1e3, wvt.y/1e3, wvt.z/1e3, val, 0,0,wvt.z(end)/1e3); shading interp;
        xlim([0,wvt.Lx/1e3])
        ylim([0,wvt.Ly/1e3])
        zlim([-wvt.Lz/1e3,0])
        % axis tight
        % axis square
        daspect([1,1,.02])
        view(-60,20)
        colormap(ax, cmDivRWB);
        set(gca,'Layer','top','TickLength',[0.015 0.015])
        clim(ax, zeta_limits);
        % add lighting
        camlight(20,30);
        s(1).AmbientStrength = .5;
        s(2).AmbientStrength = .5;
        s(3).AmbientStrength = .5;
        % s(1).DiffuseStrength = 0.8;
        % s(1).SpecularStrength = 0.9;
        % s(1).SpecularExponent = 25;
        % s(1).BackFaceLighting = 'unlit';
    end

% geostrophic vorticity section
ax = nexttile(tl,1);
makeVorticityXYZPlot(wvd1.wvt.zeta_z,iY1);
xlabel('distance (km)')
% ylabel('distance (km)')
zlabel('depth (km)')
title(ax, "mean flow forcing")

ax = nexttile(tl,2);
makeVorticityXYZPlot(wvd18.wvt.zeta_z,iY2);
xticklabels([])
yticklabels([])
zticklabels([])
title(ax, "mean flow & wave forcing")
if nRows==1
    cb = colorbar
    cb.Layout.Tile = 'south';
else
    cb = colorbar("southoutside");
end
cb.Label.String = "vertical vorticity $(f)$";
cb.Label.Interpreter = 'latex';

end