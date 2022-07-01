% Measuring constriction curvature from Morphometrics v1.103:
% Script finds two angles at division site
% creator: Paula Navarro
% email: ppnavarro@molbio.mgh.harvard.edu
% HMS / MGH
% data comes from Morphometrics software
% cite as:

clear all
close all
% data file, change name accordingly
mat_name='ftsL-SPOR_017_23-Apr-2021_CONTOURS_pill_MESH.mat';
load(mat_name);

% important parameters
i= 1; %"a frame in your stack"
% j= 1;%"an object in your frame"
radWTkappa1 = [];
radWTkappa2 = [];
indexes = [];

for j=1:length(frame(i).object);
%     if j == 23;
%         disp('jojo');
%     else
   
    %get object
    myObject = frame(i).object(j);
    
    % get width: sort segments based on widht to identify invagination
    widthObject = myObject.width;
    lengthTotal = length(widthObject);
    indx1=lengthTotal/4;
    index1=round(indx1);
    top = 1:index1;
    widthObject(top) = [];
    bot1=length(widthObject);
    bot2=bot1-index1;
    bot3=bot2:bot1;
    widthObject(bot3)=[];
    [valuemin,indx2] = min(widthObject(widthObject>0));
    
    % get all kappa
    kappa1 = myObject.side1_kappa;
    kappa2 = myObject.side2_kappa;
    
    % get specific kappa for invaginating segments
    kappa1(top)=[];
    kappa1(bot3)=[];
    kappa1Angle = kappa1(indx2);
    kappa2(top)=[];
    kappa2(bot3)=[];
    kappa2Angle = kappa2(indx2);
    
    % only get angles when both kappa are negative (both sides of the cell): invagination
    if kappa1Angle < 0 && kappa2Angle < 0;
        % results in radians
        radWTkappa1(end+1) = kappa1Angle;
        radWTkappa2(end+1) = kappa2Angle;
        % link to objects
        indexes(end+1)=j;
%     end
    end
end

%result in degrees
degWTkappa1 = radtodeg(radWTkappa1);
degWTabskappa1 = abs(degWTkappa1);
degWTkappa2 = radtodeg(radWTkappa2);
degWTabskappa2 = abs(degWTkappa2);