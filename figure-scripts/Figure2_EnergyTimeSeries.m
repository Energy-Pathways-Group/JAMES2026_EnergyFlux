loadFigureDefaults;

wvd22_256 = WVDiagnostics(basedir + getRunParameters(22) + ".nc");
wvd18_256 = WVDiagnostics(basedir + getRunParameters(18) + ".nc");

%%
[E22, t22] = wvd22_256.exactEnergyOverTime();
[E18, t18] = wvd18_256.exactEnergyOverTime();

[E22_2x, t22_2x] = wvd22.exactEnergyOverTime();
[E18_2x, t18_2x] = wvd18.exactEnergyOverTime();

Z22 = wvd22_256.exactEnstrophyOverTime();
Z18 = wvd18_256.exactEnstrophyOverTime();

Z22_2x = wvd22.exactEnstrophyOverTime();
Z18_2x = wvd18.exactEnstrophyOverTime();

figPos = [50 50 600 400];
fig = figure(Units='points',Position=figPos);
set(gcf,'PaperPositionMode','auto')
tl = tiledlayout(2,1,TileSpacing="tight");

nexttile

x1 = 3050; x2 = 3250;
yLimits = [0 5];
fill([x1 x2 x2 x1], [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
    [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.7); hold on;

plot(t22/wvd22_256.tscale,E22/wvd22_256.escale,LineWidth=2), hold on
plot(t18/wvd22_256.tscale,E18/wvd22_256.escale,LineWidth=2)

set(gca,'ColorOrderIndex',1)
plot(t22_2x/wvd22_256.tscale,E22_2x/wvd22_256.escale,LineWidth=2), hold on
plot(t18_2x/wvd22_256.tscale,E18_2x/wvd22_256.escale,LineWidth=2)

ylabel("energy (" + wvd22_256.escale_units + ")")
set(gca,'XTick',[])
ylim(yLimits)
xlim([0 3250])

plot([1 1]*t22_2x(1)/wvd22_256.tscale,ylim,LineWidth=1,Color=0*[1 1 1],LineStyle="--");
plot([1 1]*3050,ylim,LineWidth=1,Color=0*[1 1 1]);



nexttile

yLimits = [0 4.5];
fill([x1 x2 x2 x1], [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
    [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.7); hold on;

p1 = plot(t22/wvd22_256.tscale,Z22/wvd22_256.zscale,LineWidth=2,DisplayName='MF'); hold on
p3 = plot(t18/wvd18_256.tscale,Z18/wvd18_256.zscale,LineWidth=2,DisplayName="MFW");

set(gca,'ColorOrderIndex',1)
plot(t22_2x/wvd22_256.tscale,Z22_2x/wvd22_256.zscale,LineWidth=2,DisplayName='MF'), hold on
plot(t18_2x/wvd18_256.tscale,Z18_2x/wvd18_256.zscale,LineWidth=2,DisplayName="MFW")

ylabel("potential enstrophy (" + wvd22_256.zscale_units + ")")
ylim(yLimits)
xlim([0 3250])

xlabel("time (" + wvd22_256.tscale_units + ")")

p4 = plot([1 1]*t22_2x(1)/wvd22_256.tscale,ylim,LineWidth=1,Color=0*[1 1 1],LineStyle="--",DisplayName='doubling');
p5 = plot([1 1]*3050,ylim,LineWidth=1,Color=0*[1 1 1],DisplayName='start of analysis');

legend([p1,p3,p4,p5],Location='southwest')

exportgraphics(fig,figureFolder + "/" + "Figure02_energy_time_series.png",Resolution=300)