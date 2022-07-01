% Extracting Polar curvature values from Morphometrics
% creator: Paula Navarro
% email: ppnavarro@molbio.mgh.harvard.edu
% HMS / MGH
% data comes from Morphometrics software
% cite as: paper

% get data
mat_name='AV116_phase_5_12-Apr-2021_CONTOURS_pill_MESH.mat';
load(mat_name);
i= 1;%"a frame in your stack"

clear round;
clear radWT;
clear degWT;
radWT = [];
round = 1;
for j=1:length(frame(i).object);
    %get pole index
    pole1Indx = frame(i).object(j).pole1;
    pole2Indx = frame(i).object(j).pole2;
    
    % % get pole XY coordinates
    % X1 = frame(i).object(j).Xcont(pole1Indx);
    % Y1 = frame(i).object(j).Ycont(pole1Indx);
    % X2 = frame(i).object(j).Xcont(pole2Indx);
    % Y2 = frame(i).object(j).Ycont(pole2Indx);
    
    %get kappa_smooth
    kappaPole1 = frame(i).object(j).kappa_smooth(pole1Indx);
    radWT(round) = kappaPole1;
    kappaPole2 = frame(i).object(j).kappa_smooth(pole2Indx);
    radWT(end+1) = kappaPole2;
    
    round = round+2;
end

degWT = radtodeg(radWT);
Aodd = radWT(1:2:end);
Aeven = radWT(2:2:end);