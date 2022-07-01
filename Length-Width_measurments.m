% this scripts extract length(nm) and width (nm) values from Morphometrics segmentations
% load first Morphometrics MESH file
clear all
close all


% load pill mesh data from Morphometrics
mat_name='ftsL-SPOR_017_23-Apr-2021_CONTOURS_pill_MESH';
load(mat_name);
i = 1;

% important parameters
% j= 1;%"an object in your frame"
myObjects = [];
pixelLength = [];
nmLength = [];
pixelWidth = [];
nmWidth = [];

for j=1:length(frame(i).object);
%     if j == 23;
%         disp('jojo');
%     else
    myObject = frame(i).object(j);
    myLength = myObject.length;  
    if myLength < 32 || myLength > 95;
        disp('skip');
    else
    pixelLength(end+1) = myLength;
    widthAll = myObject.width;
    myWidth = mean(widthAll);
    pixelWidth(end+1)=myWidth;
    
    myObjects(end+1) = j;
    
    end
%     end
end

nmLength = pixelLength*65;
nmWidth = pixelWidth*65;

%%
% frameLength = length(frame);
% rangeFrames = 1:frameLength;
% chosenFrames = rangeFrames(1:10:frameLength);
round = 1;
subround = 1;
% get frames
for j=1:length(frame(i).object);
%     index = chosenFrames(i);
    frameNumber = frame(i);
    disp(['frame ', num2str(i)]);
    myFinalTable(round,1) = i;
    
    for j=1:frameNumber.num_objs;
        objectValue = frameNumber.object(j);
%         myFinalTable(subround,1) = i;
        if length(fieldnames(objectValue))< 1;
            disp(['mierda, haz bien tu puñetero trabajo!']); % to exclude objects that have no circularity field
        else
             
            myFinalTable(subround,2)= j; % got object value
            disp(['object ', num2str(j)]);
            if isnan(objectValue.bw_label) == true;% | objectValue.bw_label == 13 | objectValue.bw_label == 64 | objectValue.bw_label == 65 | objectValue.bw_label == 82;
                disp('not a NaN');
            else
            % get bw_label
            myFinalTable(subround,3)=objectValue.bw_label;
            %if objectValue.bw_label == 6
            % get cellID
            myFinalTable(subround,4)=objectValue.cellID;
            %get length in nm
            lengthPixel = objectValue.length;
            if 30 > lengthPixel;
                disp(['exclude ', objectValue.bw_label]);
            else
            lengthNm = lengthPixel*65;
            if isempty(lengthNm) == true;% | objectValue.bw_label == 13 | objectValue.bw_label == 64 | objectValue.bw_label == 65 | objectValue.bw_label == 82;
                disp('not a NaN');
            else
               
            myFinalTable(subround,5)=lengthNm;
            %get width nm
            widthAll = objectValue.width;
            widthMedianPix = median(widthAll);
            disp(['width median raw ', widthMedianPix]);
            widthMAD = mad(widthAll);
            rangeTop = widthMedianPix+widthMAD;
            rangeBot = widthMedianPix-widthMAD;
            excludeT = find(rangeBot<widthAll>rangeTop);
      
            widthAll(excludeT) = [];
            widthTrueMedianPix = median(widthAll);
            widthNm = widthTrueMedianPix*65;
            myFinalTable(subround,6) = widthNm;
            disp(['width median final ', widthNm]);
            end
            end
            end
          
        end
       
        subround = subround+1;
    end
    round = round+1;
end

