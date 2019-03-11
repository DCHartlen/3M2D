function WriteDriverCurves(filename,curveStruct,target)

fid = fopen(filename,'r+');     % Open the test deck

for i=1:target-1      % Fast forward to paramter card line in file
    fgetl(fid);
end

fseek(fid,0,'cof');         % Set cursor at right spot on line

for iCurve = 1:9
    fprintf(fid,'*DEFINE_CURVE\n');
    fprintf(fid,['         ' num2str(iCurve, '% 10d') '         0       1.0       1.0       0.0       0.0\n']);
    for iPt = 1:length(curveStruct(iCurve).Curve)
        fprintf(fid,[blanks(20-length(num2str(curveStruct(iCurve).Curve(iPt,1), '% 10.4g'))),...
                     num2str(curveStruct(iCurve).Curve(iPt,1), '% 10.4g'),...
                     blanks(20-length(num2str(curveStruct(iCurve).Curve(iPt,2), '% 10.4g'))),...
                     num2str(curveStruct(iCurve).Curve(iPt,2), '% 10.4g') '\n']);
    end
end
% Rewrite the *END command in the deck
fprintf(fid,'$\n$\n*END');
fclose(fid);
end
