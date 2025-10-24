% basedir = "/Users/Shared/CimRuns_June2025/output/";
basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_June2025_v2/output/';

wvd1 = WVDiagnostics(basedir + replace(getRunParameters(1),"256","512") + ".nc");
wvd9 = WVDiagnostics(basedir + replace(getRunParameters(9),"256","512") + ".nc");
wvd18 = WVDiagnostics(basedir + replace(getRunParameters(18),"256","512") + ".nc");

figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
       mkdir(figureFolder)
end

%%
fig = PlotThreeSimComparison3D(wvd1,wvd9,wvd18,yForXZSlice1=430e3,yForXZSlice2=120e3,yForXZSlice3=110e3);

exportgraphics(fig,figureFolder + "/" + "three_sim_comparison_3D.png",Resolution=300)