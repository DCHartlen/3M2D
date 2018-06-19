%% 3M2D Dual Execution Script.
% Based heavily on the main execution script, this script executes to MMD
% operations. This makes it somewhat simplier to compare to material
% models. 
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
StrainVector = -([ 1.0, -0.5, -0.5, 0.0, 0.0, 0.0]*10^-1)';
% Combine into one variable to allow for writing to file.
params = [paramNames,num2cell(StrainVector)];

%% Enter file save information
fileName = 'MAT_015.k';
% write parameters to file
copyfile(fileName,'temp.k')
WriteDynaParams('temp.k',params,36);

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

% % clear temp variables
% clear i a time OutputList paramNames tableNames ans params

%% Enter file save information
fileName = 'MAT_015+EOS_016.k';
% write parameters to file
copyfile(fileName,'temp.k')
write_ls_param('temp.k',params,36);

% Execute MMD using a batch script
dos('MMD_RUN_V2.bat');

%% Parse output information
OutputList = dir('out_*');
dataEOS = zeros(201,length(OutputList));
for i=1:length(OutputList)
    [~,a] = ParseMMDOutput(OutputList(i).name);
    if isempty(a)
        continue
    end
    iFunc = i;
    dataEOS(:,i) = a;
end
[time,~] = ParseMMDOutput(OutputList(iFunc).name);
dataEOS = [time,dataEOS];

tableNames = {'time',...
              'StressXX','StressYY','StressZZ',...
              'StressXY','StressYZ','StressZX',...
              'StressHydro','StressVM',...
              'StrainXX','StrainYY','StrainZZ',...
              'StrainXY','StrainYZ','StrainZX',...
              'StrainHydro','StrainVM'...
              'Strain_Vol','RelVol'};
dataEOS = array2table(dataEOS,'VariableNames',tableNames);

%% Clean up in preperation for the next run
% delete files
delete out_*
delete d3*
delete messag
delete temp.k

% clear temp variables
clear i a time OutputList paramNames tableNames ans params
