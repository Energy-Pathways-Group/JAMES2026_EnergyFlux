% calls QGSpinUp.m with different parameters. 


runs = 2;

% run simulation
for ii=1:length(runs)
    runNumber = runs(ii);
    [runName,lat,N0,u0] = getRunParameters(runNumber);

    fprintf('runName: %s\n',runName)
    fprintf('lat: %d\n',lat)
    fprintf('u0: %d\n',u0)
    fprintf('N0: %d\n',N0)

    fprintf('Running runNumber %d\n',runNumber)
    run QGSpinUp.m

    close all
end


%% Define run parameters

function [runName,lat,N0,u0] = getRunParameters(runNumber)
    if runNumber==1
        % PSI
        lat = 27;
        u0 = .005;
        N0 = 3*2*pi/3600;
    elseif runNumber==2
        % baseline, no PSI
        lat = 32;
        u0 = .005*1.3; % stronger forcing at higher latitude to get same final energy.
        N0 = 3*2*pi/3600;
    else
        error("Invalid run number.")
    end
    runName = sprintf("QGSpinUp%d_lat-%d_u0-%s_N0-%s_res",runNumber,lat,strip(strip(num2str(u0,2),'left','0'),'left','.'),strip(strip(num2str(N0,2),'left','0'),'left','.'));

end

