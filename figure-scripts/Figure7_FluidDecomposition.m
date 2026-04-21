% basedir = "/Users/Shared/CimRuns_June2025/output/";
basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_November2025/output/';

wvd = WVDiagnostics(basedir + replace(getRunParameters(18),"256","512") + ".nc");


figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
       mkdir(figureFolder)
end

%%
fig = wvd.plotFluidDecompositionMultipanel(yForXZSlice=110e3,title="none",visible="on");
exportgraphics(fig,figureFolder + "/" + "fluid_decomposition.png",Resolution=300)