%% 3M2D Main Execution Script
% Matlab script designed to write, execute, and parse the LS-DYNA MMD. This
% script relies heavily on a batch script to enter the appropriate commands
% into the MMD.
%
% Created By:     Devon C. Hartlen, EIT
% Date:           19-Jun-2018
% Updated By:     
% Date:          

%% Initialization
close all
fclose all
clear
clc

%% Enter Deformation Gradient
% Deformation gradient is vectorized. DO NOT ALTER.
paramNames = {'epsxx','epsyy','epszz','epsxy','epsyz','epszx'}';
% Values of deformation (strain). Alter this vector.
DeformationVector = -([ 1.0, -0.5, -0.5, 0.0, 0.0, 0.0]*10^-1)';
% Combine into one variable to allow for writing to file.
params = [paramNames,num2cell(DeformationVector)];

%% Enter file save information
fileName = 'MAT_015.k';
% Copy deck to prevent overwriting template
copyfile(fileName,'temp.k')
% write parameters to the copied deck. Insert into line 36.
WriteDynaParams('temp.k',params,36);
% Execute MMD using a batch script
dos('MMD_RUN_V2.bat');

%% Parse output information
% Create list of all ouptut files
OutputList = dir('out_*');
% Initialize an array for the output. This array is based on 201 points
% outputed by the MMD. If you alter the number of output points in the *.k
% file with the PlotOut parameter, the length of this array will need to be
% updated as well.
data = zeros(201,length(OutputList));

% Go through each file and retreive the requested outpt data.
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
% Write time to data array.
[time,~] = ParseMMDOutput(OutputList(iFunc).name);
data = [time,data];

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
