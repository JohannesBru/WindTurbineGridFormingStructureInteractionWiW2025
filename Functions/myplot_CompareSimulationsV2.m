%   myplot_CompareSimulationsV2 - compare the data of multiple simulation runs                               
%
%   Syntax:  axes = myplot_CompareSimulationsV2(data,p)
%
%   Inputs:
%       data        SimulationOutput data struct with simulation data
%       p           parameter struct to define plot parameters
%
%   This function plots simulation results from matlab simulink. It takes
%   SimulatioOutput structs from one ore more simulations. The parameter
%   struct p allows to specify addtional options and inputs explained below
%   V2 looks for the same struct names in the data from the different
%   simulations provided and only plots these
% ______________________________________________________________________
%   paramter struct input:
%
%   p.structsToRemove       structure field names which should not be
%                           plotted
%   p.ylabels               ylabels which are defined additionally as by
%                           default no ylabels are added
%   p.plotInSamePlot        Define if the data from multiple
%                           SimulationOutput Data should be plotted in 
%                           the same plot i.e. From two sim runs 
% ______________________________________________________________________
%   (C) Johannes Brunner, 2025-07-01

function axes = myplot_CompareSimulationsV2(data,p)

if nargin < 2
    p = [];
end

if ~isfield(p,"structsToRemove")
    p.structsToRemove = [];
end

if ~isfield(p,"ylabels") % TODO
    p.ylabels = [];
end

if ~isfield(p,"xlabels") % TODO
    p.xlabels = [];
end

if ~isfield(p,"plotInSamePlot")
    p.plotInSamePlot = false;
end

if ~isfield(p,"tRange")
    p.tRange = [];
end

tRange = p.tRange;
plotInSamePlot = p.plotInSamePlot;
structsToRemove = ["tout",p.structsToRemove];

Nr = numel(data);


% Get the structnames from the data 
d1 = data(1,1);
structnames1 = string(d1.get);

% Remove the tout string from structnames1
for l = 1:length(structsToRemove)
    indxtout = find(strcmp(structnames1,structsToRemove(l))); % Index of tout struct
    structnames1(indxtout) = [];
end


% Find the structnames that should be plotted 
% Only the structnames that are equal to structnames1 are plotted
structnamesToPlot = structnames1;
for i = 1:Nr
    d = data(1,i);

    % Read the structnames from current SimulationOutput data
    structnames = string(d.get);
    structnamesToPlot = intersect(structnames, structnamesToPlot);

end


k = 0;
q = 0;
% for j=1:Nr
%     q = q + 1; % If data is to be plotted in same plot this is used 
%     d = data(1,j);
% 
% 
%     % Define how many plots are to be plotted
%     n = length(structnamesToPlot);
% 
%     for i = 1:n
%         k = k + 1;
% 
%         % Different size of subplot defined by trigger plotInSamePlot
%         if ~plotInSamePlot
%             axes(k) = subplot(Nr,n,k);
%         else
%             axes(k) = subplot(1,n,k);
%             hold on
%             if k == n
%                 k = 0;
%             end
%         end
%         plotData(d.(structnamesToPlot(i)),tRange)
%         title(structnamesToPlot(i))
%     end
% 
% 
% end

maxCols = 3; % Maximum number of columns per row

for j = 1:Nr
    q = q + 1; % If data is to be plotted in same plot this is used 
    d = data(1,j);

    % Define how many plots are to be plotted
    n = length(structnamesToPlot);

    % Determine subplot grid size
    numCols = min(n, maxCols);
    numRows = ceil(n / maxCols);

    for i = 1:n
        k = k + 1;

        % Different size of subplot defined by trigger plotInSamePlot
        if ~plotInSamePlot
            axes(k) = subplot(numRows, numCols, i);
        else
            axes(k) = subplot(numRows, numCols, k);
            hold on
            if k == n
                k = 0;
            end
        end

        plotData(d.(structnamesToPlot(i)), tRange);
        title(structnamesToPlot(i));
    end
end


end



function plotData(datastruct,tRange)

t = datastruct.time;
data = datastruct.signals.values;

data = squeeze(data);

if isempty(tRange)
    tRange = [t(1),t(end)];
end

% Find index of t start and t end of desired plot range
t0 = tRange(1);                     % tstart
tend = tRange(2);                   % tend
[~, idxt0] = min(abs(t - t0));      % index of the closest value
[~, idxtend] = min(abs(t - tend));

% Plot the desired data range
plot(t(idxt0:idxtend),data(idxt0:idxtend,:))

end