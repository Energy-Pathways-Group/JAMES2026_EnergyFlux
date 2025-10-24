% To run this script from the command line, launch Matlab
% /Applications/MATLAB_R2025a.app/bin/matlab -nojvm -nodisplay -nosplash
% 

addpath(genpath("/Users/jearly/Documents/ProjectRepositories/chebfun"));
addpath(genpath("/Users/jearly/Documents/ProjectRepositories/GLOceanKit/Matlab"));
addpath(genpath("/Users/jearly/Documents/ProjectRepositories/wave-vortex-model-diagnostics"));

basedir = "/Users/Shared/CimRuns_June2025/output/";
runNumber = 18;
addMooringAfterDays = 50;
additionalDays = 250;

[runName,runNameQG,addInitialCondition,addInertialForcing,addTidalForcing,lat,addGeostrophicFlow,resolution,transform,GMAmplitude,uTide,u0,N0,spinupTimeHyd] = getRunParameters(runNumber);

filepath_original = basedir + runName + ".nc";
filepath_highres = replace(filepath_original,string(resolution),string(2*resolution));
if exist(filepath_highres,'dir')
    error('File already exists!')
end

wvt = WVTransform.waveVortexTransformFromFile(filepath_original,iTime=Inf);
wvt = wvt.waveVortexTransformWithDoubleResolution;
model = WVModel(wvt);
model.createNetCDFFileForModelOutput(filepath_highres,outputInterval=86400);

if ~isinf(addMooringAfterDays)
    mooringFieldNames = {"u","v","w","eta","u_g","v_g","eta_g","u_w","v_w","w_w","eta_w","u_io","v_io"};
    moorings = WVMooring(model,nMoorings=4,trackedFieldNames=mooringFieldNames);

    mooringStartTime = model.wvt.t + addMooringAfterDays*86400;
    mooringsOutputInterval = floor( 2*pi/sqrt(max(model.wvt.N2))/2 );

    mooringOutputGroup = model.outputFiles(1).addNewEvenlySpacedOutputGroup("mooring",outputInterval=mooringsOutputInterval,initialTime=mooringStartTime);
    mooringOutputGroup.addObservingSystem(moorings);
end

disp("starting model at day " + string(round(model.wvt.t/86400)) + " and running " + string(additionalDays) + " additional days.");
model.integrateToTime(model.wvt.t + additionalDays*86400);

disp("model run finished. Appending new diagnostics.")
wvd = WVDiagnostics(filepath_highres);
wvd.createDiagnosticsFile();

disp("diagnostics finished; clearing variables.")

clear model
clear wvd