%% LS-DYNA Material Model Driver Driver
% Matlab script designed to write, execute, and parse the LS-DYNA MMD. This
% script relies heavily on a batch script to enter the appropriate commands
% into the MMD.
%
% Created By:     D.C. Hartlen, EIT
% Date:           12-Jun-2018
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
DeformationVector = [ 0.0, 0.0, 0.0, 0.05, 0.0, 0.0]';
% Combine into one variable to allow for writing to file.
params = [paramNames,num2cell(DeformationVector)];

%% Enter file save information
fileName = 'MAT_015.k';
% write parameters to file
copyfile(fileName,'temp.k')
write_ls_param('temp.k',params,36);

% Execute MMD using a batch script
dos('MMD_RUN_V2.bat');

%% Parse output information
OutputList = dir('out_*');
data = zeros(201,length(OutputList));
for i=1:length(OutputList)
    [~,a] = ParseMMDOutput(OutputList(i).name);
    if isempty(a)
        continue
    end
    iFunc = i;
    data(:,i) = a;
end
[time,~] = ParseMMDOutput(OutputList(iFunc).name);
data = [time,data];

tableNames = {'time',...
              'StressXX','StressYY','StressZZ',...
              'StressXY','StressYZ','StressZX',...
              'Stress_Hydro','Stress_VM',...
              'StrainXX','StrainYY','StrainZZ',...
              'StrainXY','StrainYZ','StrainZX',...
              'Strain_Hydro','Strain_VM'...
              'Strain_Vol','RelVol'};
data = array2table(data,'VariableNames',tableNames);

%% Clean up
% delete files
delete out_*
delete d3*
delete messag
delete temp.k

% clear temp variables
clear i a time OutputList paramNames tableNames ans params

