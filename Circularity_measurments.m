% this scripts extracts circularity values from Morphometrics segmentations
% load first Morphometrics MESH file first

clear myFinalTable;
myFinalTable=[];
frameLength = length(frame);
rangeFrames = 1:frameLength;
chosenFrames = rangeFrames(1:10:frameLength);



for i=1:length(chosenFrames);
    index = chosenFrames(i);
    frameNumber = frame(i);
    disp(['frame ', num2str(i)]);
    myFinalTable(1,end+1) = frameNumber;
end
    if frameNumber.num_objs == 0; % to exclude frames without objects(=no cells were detected) 
        disp('NO OBJECTS');
    else
        
        for j=1:frameNumber.num_objs;
            objectValue = frameNumber.object(j);
            if length(fieldnames(objectValue))< 10;
                disp(['no cirucularity value found']); % to exclude objects that have no circularity field
            else
            valueCircularity = objectValue.circularity;
            if size(valueCircularity) == 0; % to exclued fields with cirularity values = 0
                disp('NO CIRCULARITY VALUE');
            else
           
            %collecting circularity values
            disp(['object ', num2str(j), ' value for circularity ',num2str(valueCircularity)]);
            circularityValues(end+1)=valueCircularity;
        
            end
            end
            
        end
    end
end



