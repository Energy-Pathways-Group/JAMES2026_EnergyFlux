% To run this script from the command line, launch Matlab
% /Applications/MATLAB_R2025a.app/bin/matlab -nojvm -nodisplay -nosplash
% 

addpath(genpath("/Users/jearly/Documents/ProjectRepositories/chebfun"));
addpath(genpath("/Users/jearly/Documents/ProjectRepositories/GLOceanKit/Matlab"));
addpath(genpath("/Users/jearly/Documents/ProjectRepositories/wave-vortex-model-diagnostics"));

basedir = "/Users/Shared/CimRuns_June2025/output/";
runNumber = 1;
shouldRestartDoubledRun = false;
addMooringAfterDays = Inf;
% additionalDays = 23278;
additionalDays = [];
totalDays = 3000;

[runName,runNameQG,addInitialCondition,addInertialForcing,addTidalForcing,lat,addGeostrophicFlow,resolution,transform,GMAmplitude,uTide,u0,N0,spinupTimeHyd] = getRunParameters(runNumber);
if shouldRestartDoubledRun
    runName = replace(runName,string(resolution),string(2*resolution));
end
filepath = basedir + runName + ".nc";

model = WVModel.modelFromFile(filepath);

if ~isinf(addMooringAfterDays)
    mooringFieldNames = {"u","v","w","eta","u_g","v_g","eta_g","u_w","v_w","w_w","eta_w","u_io","v_io"};
    moorings = WVMooring(model,nMoorings=4,trackedFieldNames=mooringFieldNames);

    mooringStartTime = model.wvt.t + addMooringAfterDays*86400;
    mooringsOutputInterval = floor( 2*pi/sqrt(max(model.wvt.N2))/2 );

    mooringOutputGroup = model.outputFiles(1).addNewEvenlySpacedOutputGroup("mooring",outputInterval=mooringsOutputInterval,initialTime=mooringStartTime);
    mooringOutputGroup.addObservingSystem(moorings);
end

if isempty(additionalDays)
    additionalDays = totalDays - model.wvt.t/86400;
end

disp("restarting model " + string(runNumber) + " at day " + string(round(model.wvt.t/86400)) + " and running " + string(additionalDays) + " additional days.");
model.integrateToTime(model.wvt.t + additionalDays*86400);

disp("model run finished. Appending new diagnostics.")
wvd = WVDiagnostics(filepath);
wvd.createDiagnosticsFile();

disp("diagnostics finished; clearing variables.")

clear model
clear wvd