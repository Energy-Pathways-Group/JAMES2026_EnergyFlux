basedir = '/Volumes/SanDiskExtremePro/research/Energy-Pathways-Group/garrett-munk-spin-up/CimRuns_November2025/output/';
basedir = "/Users/Shared/CimRuns_June2025/output/";

addpath("../ModelSpinUp/");

figureFolder = "./figures";
if ~exist(figureFolder, 'dir')
       mkdir(figureFolder)
end

if ~exist("wvd22","var")
    wvd22 = WVDiagnostics(basedir + replace(getRunParameters(22),"256","512") + ".nc");
end
if ~exist("wvd18","var")
    wvd18 = WVDiagnostics(basedir + replace(getRunParameters(18),"256","512") + ".nc");
end