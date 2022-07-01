%% MSD analysis from TrackMate (v5.2.0) tracks export

addpath('/Applications/Fiji.app/scripts'); %adding fiji scripts to MATLAB for reading in TrackMate files etc.
% run dynamo
run /Users/andreavettiger/Desktop/tools/dynamo/dynamo-v-1.1.509_MCR-9.6.0_GLNXA64_withMCR/dynamo_activate.m
%% creat ma object and add files
% navigate to folder
xmlfiles = dregexp2files('wt-*.xml'); %reading files in here: wt, adapt file names
for k = 1:length(xmlfiles);
    [tracks, md] = importTrackMateTracks(xmlfiles{k}, 'clipz');
    md; %this is to get metadata
    
    % define space and time units
    SPACE_UNITS = 'µm';
    TIME_UNITS = 's';
    if k == 1
        ma = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
        ma = ma.addAll(tracks);
    else
        ma = ma.addAll(tracks);
    end    
end
%% do MSD calculations
% plot individual MSD curves
figure
set(axes,'FontSize',14,'LineWidth',1);
ma.plotMSD

% compute MSD
ma = ma.computeMSD;

% plot mean +/- SDp
figure
set(axes,'FontSize',14,'LineWidth',1);
ma.plotMeanMSD(gca, true);

% Calcualte diffusion coefficient and flow velocity
A = ma.getMeanMSD;
t = A(:, 1); % delay vector
msd = A(:,2); % msd
std_msd = A(:,3); % we will use inverse of the std as weights for the fit
std_msd(1) = std_msd(2); % avoid infinity weight

ft = fittype('a*x + c*x^2'); % this is the formula
[fo, gof] = fit(t, msd, ft, 'Weights', 1./std_msd, 'StartPoint', [0 0]);

hold on
plot(fo)
legend off
ma.labelPlotMSD

Dfit = fo.a / 4; % Diffusion coefficient
Vfit = sqrt(fo.c); % Flow velocity

ci = confint(fo);
Dci = ci(:,1) / 4; %Diffusion coefficient confidence interval
Vci = sqrt(ci(:,2)); % Flow velocity confidence interval 

%% calculate the LogLog fit to determine type of movement
% 1 = brownian diffusion, > 1 = transported, < 1 = contrained motion
% checks over all 120 timepoints (adjust if different)
% default would only take first 25% into account, here we have 80%
ma = ma.fitLogLogMSD(0.8)

%retain only fits with r^2 value > 0.95 (high quality)
valid = ma.loglogfit.r2fit > 0.95;
fprintf('Retained %d fits over %d.\n', sum(valid), numel(valid))
Loglogfits = ma.loglogfit.alpha(valid);

% plot valid LogLog fits
figure
histogram(ma.loglogfit.alpha( valid ), 'Normalization', 'probability')
box off
xlabel('Slope of the log-log fit.')
ylabel('p')
yl = ylim;
line( [ 1 1 ], [ yl(1) yl(2) ], 'Color', 'k', 'LineWidth', 2)

% mean slope tells you whether overall you have a restricted, diffusive or
% transported particles if statistically different for 1 (diffusive).
fprintf('Mean slope in the log-log fit: alpha = %.2f +/- %.2f (N = %d).\n', ...
mean( ma.loglogfit.alpha(valid) ), std( ma.loglogfit.alpha(valid)), sum(valid))
[h, p] = ttest( ma.loglogfit.alpha(valid), 1, 'tail', 'left');
    if (h)
    fprintf('The mean of the distribution IS significantly lower than 1 with P = %.2e.\n', p)
    elsefprintf('The mean of the distribution is NOT significantly lower than 1. P = %.2f.\n', p)
    end
  
% this will give you the number of curves for each class (= CI slope >1, 1, >1)   
cibelow = ma.loglogfit.alpha_uci(valid) < 1;
ciin = ma.loglogfit.alpha_uci(valid) >= 1 & ma.loglogfit.alpha_lci(valid) <= 1;
ciabove = ma.loglogfit.alpha_lci(valid) > 1;
fprintf('Found %3d particles over %d with a confidence interval for the slope value below 1.\n', ...
sum(cibelow), numel(cibelow))
fprintf('Found %3d particles over %d with a slope of 1 inside the confidence interval.\n', ...
sum(ciin), numel(ciin))
fprintf('Found %3d particles over %d with a confidence interval for the slope value above 1.\n', ...
sum(ciabove), numel(ciabove))

%% summary and export
% these lines give you the answer from fprintf in a table, so i can copy the results into Prism for plotting  
rest = cibelow .* ma.loglogfit.alpha(valid);
restPos = rest > 0;
restricted = rest(restPos);
restrictedL = length(restricted); % gives resticted particles (ci < 1) 
dif = ciin .* ma.loglogfit.alpha(valid);
difPos = dif > 0;
diffusive = dif(difPos);
diffusiveL = length(diffusive); % gives diffusive particles (ci = 1)
trans = ciabove .* ma.loglogfit.alpha(valid);
transPos = trans > 0;
transported = trans(transPos);
transportedL = length(transported); % gives transported partilces (ci > 1)
total = transportedL + diffusiveL + restrictedL;

% getting % of particles 
restLfract = (restrictedL / total) * 100;
difLfract = (diffusiveL / total) * 100;
transLfract = (transportedL / total) * 100;
results = table(restrictedL, diffusiveL, transportedL, total, restLfract, difLfract, transLfract) %final results table 

% getting a table with log-logfits above 1
Loglogfits = ma.loglogfit.alpha(valid); % these are all valid log-log fits
LLfitsone = Loglogfits > 1; 
Llfit1 = Loglogfits(LLfitsone);

