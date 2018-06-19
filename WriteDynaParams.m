function WriteDynaParams(filename, vars, param_target, ID_target, ID)
%  Write LS-DYNA parameters to any k file
%  Targets are the line of the file which is to be replaced
%  ID altering is currently not enabled
%  
%  Created By:     Devon C. Hartlen
%  Date:           13-May-2016
%  Updated By:     Devon C. Hartlen, EIT
%  Date:           19-Jun-2018
%
%  Includes the LS-Dyna parameter organizer
% 
%  Input variable cell array of name-value pair arguments
%  Example
%   vars = {'PARAM1', 12;
%           'PARAM2', 1232;
%           'PARAM3', 3232}
%  To Do:
%  - Make Keyword ID general (needs another input argument)

% Parameters
max_len = 10;       % Max characters per entry
max_param = 4;      % Max parameters per line
line = 1;           % Initialize line counter for LS-Dyna Parameters
% param_target = 33;  % Set line where parameter card starts
% ID_target = 16;     % Set ID line location

% Determine lengths of variables
vars_len = length(vars);

% Format numeric variables to strings with formatting
for i=1:vars_len
    vars{i,2} = num2str(vars{i,2}, '% 10.4g');
end

% Create Dyna Parameter Entries
rows = ceil(vars_len/max_param); % Calculates required number of rows
dyna_str = cell(rows,1);        % Initializes output cell array

%Write parameters to Dyna parameter format
for i=1:vars_len
    if i>line*max_param
        line = line+1;
    end
    
    dyna_str{line,1} = [dyna_str{line,1}, 'R', blanks(max_len-length(vars{i,1})-1), vars{i,1}...
        blanks(max_len-length(vars{i,2})), vars{i,2}];
end

% Write Parameters to dyna file
fid = fopen(filename,'r+');     % Open the test deck

for i=1:param_target-1      % Fast forward to paramter card line in file
    fgetl(fid);
end

fseek(fid,0,'cof');         % Set cursor at right spot on line

% Write cell array of dyna parameters line by line
for i=1:length(dyna_str)
    fprintf(fid,dyna_str{i,1});
    fprintf(fid,'\n');
end

% ID writing is currently disabled for this function
if nargin >= 6
    % Change the run ID (used for iteration count)
    frewind(fid);       % Reset to top of dyna input deck
    
    % Set run name (include iteration counter?)    
    name_format = ['        DYNA_TESTING          MATLAB_RUN                               TRIAL_'];
    name_format = [name_format num2str(3,'%03d')];
    
    for i = 1:ID_target-1       % Fast forward to keyword target
        fgetl(fid);
    end
    
    fseek(fid,0,'cof');         % Set cursor position on line
    fprintf(fid,name_format);   % Print the new name to location
end

% Close the file and return
fclose(fid);
end
