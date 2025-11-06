% basedir = "/Users/Shared/CimRuns_June2025/output/";
% basedir = "/Users/jearly/Dropbox/CimRuns_June2025/output/";
basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_November2025/output/';

wvd1 = WVDiagnostics(basedir + getRunParameters(1) + ".nc");
% wvd9 = WVDiagnostics(basedir + getRunParameters(9) + ".nc");
wvd18 = WVDiagnostics(basedir + getRunParameters(18) + ".nc");

%%
wvd1_2x = WVDiagnostics(basedir + replace(getRunParameters(1),"256","512") + ".nc");
% wvd9_2x = WVDiagnostics(basedir + replace(getRunParameters(9),"256","512") + ".nc");
wvd18_2x = WVDiagnostics(basedir + replace(getRunParameters(18),"256","512") + ".nc");

figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
       mkdir(figureFolder)
end

%%
[E1, t1] = wvd1.exactEnergyOverTime();
% [E9, t9] = wvd9.exactEnergyOverTime();
[E18, t18] = wvd18.exactEnergyOverTime();

[E1_2x, t1_2x] = wvd1_2x.exactEnergyOverTime();
% [E9_2x, t9_2x] = wvd9_2x.exactEnergyOverTime();
[E18_2x, t18_2x] = wvd18_2x.exactEnergyOverTime();

Z1 = wvd1.exactEnstrophyOverTime();
% Z9 = wvd9.exactEnstrophyOverTime();
Z18 = wvd18.exactEnstrophyOverTime();

Z1_2x = wvd1_2x.exactEnstrophyOverTime();
% Z9_2x = wvd9_2x.exactEnstrophyOverTime();
Z18_2x = wvd18_2x.exactEnstrophyOverTime();

figPos = [50 50 600 400];
fig = figure(Units='points',Position=figPos);
set(gcf,'PaperPositionMode','auto')
tl = tiledlayout(2,1,TileSpacing="tight");

nexttile

x1 = 3050; x2 = 3250;
yLimits = [0 5];
fill([x1 x2 x2 x1], [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
    [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.7); hold on;

plot(t1/wvd1.tscale,E1/wvd1.escale,LineWidth=2), hold on
% plot(t9/wvd1.tscale,E9/wvd1.escale,LineWidth=2)
plot(t18/wvd1.tscale,E18/wvd1.escale,LineWidth=2)

set(gca,'ColorOrderIndex',1)
plot(t1_2x/wvd1.tscale,E1_2x/wvd1.escale,LineWidth=2), hold on
% plot(t9_2x/wvd1.tscale,E9_2x/wvd1.escale,LineWidth=2)
plot(t18_2x/wvd1.tscale,E18_2x/wvd1.escale,LineWidth=2)

ylabel("energy (" + wvd1.escale_units + ")")
set(gca,'XTick',[])
ylim(yLimits)
xlim([0 3250])

plot([1 1]*t1_2x(1)/wvd1.tscale,ylim,LineWidth=1,Color=0*[1 1 1],LineStyle="--");
plot([1 1]*3050,ylim,LineWidth=1,Color=0*[1 1 1]);



nexttile

yLimits = [0 4.5];
fill([x1 x2 x2 x1], [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
    [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.7); hold on;

p1 = plot(t1/wvd1.tscale,Z1/wvd1.zscale,LineWidth=2,DisplayName='mean flow forcing'); hold on
% p2 = plot(t9/wvd1.tscale,Z9/wvd1.zscale,LineWidth=2,DisplayName="mean flow & wave forcing, hydrostatic");
p3 = plot(t18/wvd1.tscale,Z18/wvd1.zscale,LineWidth=2,DisplayName="mean flow & wave forcing");

set(gca,'ColorOrderIndex',1)
plot(t1_2x/wvd1.tscale,Z1_2x/wvd1.zscale,LineWidth=2,DisplayName='mean flow forcing'), hold on
% plot(t9_2x/wvd1.tscale,Z9_2x/wvd1.zscale,LineWidth=2,DisplayName="mean flow & wave forcing, hydrostatic")
plot(t18_2x/wvd1.tscale,Z18_2x/wvd1.zscale,LineWidth=2,DisplayName="mean flow & wave forcing")

ylabel("potential enstrophy (" + wvd1.zscale_units + ")")
ylim(yLimits)
xlim([0 3250])

xlabel("time (" + wvd1.tscale_units + ")")

p4 = plot([1 1]*t1_2x(1)/wvd1.tscale,ylim,LineWidth=1,Color=0*[1 1 1],LineStyle="--",DisplayName='doubling');
p5 = plot([1 1]*3050,ylim,LineWidth=1,Color=0*[1 1 1],DisplayName='start of analysis');

% legend([p1,p2,p3,p4,p5],{'hydrostatic, geostrophic (HS-G)','hydrostatic, geostrophic + wave (HS-GW)','non-hydrostatic, geostrophic + wave (NHS-GW)','doubling','start of analysis'},Location='southwest')
legend([p1,p3,p4,p5],Location='southwest')

exportgraphics(fig,figureFolder + "/" + "energy_time_series.png",Resolution=300)