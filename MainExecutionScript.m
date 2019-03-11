%% 3M2D Main Execution Script
% Matlab script designed to write, execute, and parse the LS-DYNA MMD. This
% script relies heavily on a batch script to enter the appropriate commands
% into the MMD.
%
% Created By:     Devon C. Hartlen, EIT
% Date:           19-Jun-2018
% Updated By:     Devon C. Hartlen, EIT
% Date:           11-Mar-2019

%% Initialization
close all;
fclose all;
clear;
clc;

%% Control Parameters
driverDeck = 'MAT_015+EOS_016.k';
controlParamTarget = 33;    % Line in input deck to write control parameters
strainCurveTarget = 137;    % Line in deck to write curves (at the bottom)
% Define simulation time (in time units) and number of output points to
% generate. 
simTime = 1.0;
nSimPts = 200;
% See driver deck for appropriate units. 
controlParamNames =  {'ENDTIME', 'ASCIIOUT',       'PLOTOUT', 'BLANK'}';
controlParamValues = [  simTime, simTime/10, simTime/nSimPts,       0]';
% Combine into one variable to allow for writing to file.
controlParams = [controlParamNames,num2cell(controlParamValues)];

%% Strain Input Curves 
% Nine curves required to run the matlab MMD. Refer to the Name entry of
% the structure for the specific loading condition. Curves do not need to
% be of the same length. However, time portion should extend beyound
% simulation time to be safe. 
strainCurves(1).Name = 'du/dx';
strainCurves(1).Curve = ...
    [            0,     0;
           simTime,   0.5;
        simTime*10,   0.5];
strainCurves(2).Name = 'dv/dy';
strainCurves(2).Curve = ...
    [            0,     0;
           simTime,     0;
        simTime*10,     0];
strainCurves(3).Name = 'dw/dz';
strainCurves(3).Curve = ...
    [            0,     0;
           simTime,     0;
        simTime*10,     0];
strainCurves(4).Name = 'du/dy';
strainCurves(4).Curve = ...
    [            0,     0;
           simTime,     0;
        simTime*10,     0];
strainCurves(5).Name = 'dv/dx';
strainCurves(5).Curve = ...
    [            0,     0;
           simTime,     0;
        simTime*10,     0];
strainCurves(6).Name = 'du/dz';
strainCurves(6).Curve = ...
    [            0,     0;
           simTime,     0;
        simTime*10,     0];
strainCurves(7).Name = 'dw/dx';
strainCurves(7).Curve = ...
    [            0,     0;
           simTime,     0;
        simTime*10,     0];
strainCurves(8).Name = 'dv/dz';
strainCurves(8).Curve = ...
    [            0,     0;
           simTime,     0;
        simTime*10,     0];
strainCurves(9).Name = 'dw/dy';
strainCurves(9).Curve = ...
    [            0,     0;
           simTime,     0;
        simTime*10,     0];

%% Enter file save information
% Copy deck to prevent overwriting template
copyfile(driverDeck,'temp.k')
% write control parameters (line 33 in the driver deck)
WriteDynaParams('temp.k',controlParams,controlParamTarget);
% write strain curves to deck.
WriteDriverCurves('temp.k',strainCurves,strainCurveTarget+1);
% Execute MMD using a batch script
dos('MMD_RUN_V2.bat');

%% Parse output information
% Create list of all ouptut files
OutputList = dir('out_*');
% Initialize an array for the output. This array is based on 201 points
% outputed by the MMD. If you alter the number of output points in the *.k
% file with the PlotOut parameter, the length of this array will need to be
% updated as well.
data = zeros(nSimPts+1,length(OutputList));

% Go through each file and retreive the requested outpt data.
iFunc = nan;
for i=1:length(OutputList)
    [~,a] = ParseMMDOutput(OutputList(i).name);
    % If file is empty, skip it
    if isempty(a)
        continue
    end
    % Because time is common to all outputs, remember one file index to
    % take time from. Cannot gaurentee first file will have something
    % written to it.
    iFunc = i;
    data(:,i) = a;
end
if ~isnan(iFunc)
    % Write time to data array.
    [time,~] = ParseMMDOutput(OutputList(iFunc).name);
    data = [time,data];
else
    warning('No data written to output files')
    data = [zeros(nSimPts+1,1),data];
end

% If the MMD_CMD file is updated, the list of table names must also be
% updated with the new/changed requested outputs. Otherwise, the below line
% will throw an error.
tableNames = {'time',...
              'StressXX','StressYY','StressZZ',...
              'StressXY','StressYZ','StressZX',...
              'StressHydro','StressVM',...
              'StrainXX','StrainYY','StrainZZ',...
              'StrainXY','StrainYZ','StrainZX',...
              'StrainHydro','StrainVM'...
              'Strain_Vol','RelVol'};
data = array2table(data,'VariableNames',tableNames);

%% Clean up in preperation for the next run
% delete files
delete out_*
delete d3*
delete messag
delete temp.k

% clear temp variables
clear i a time OutputList paramNames tableNames ans params
