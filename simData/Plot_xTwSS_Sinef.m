% compare the Tower Side to Side movement for different frequency inputs of
% grid angle to see if resonance from bode diagram is valid
% 
% Also generates PGF plot files

clc
clear
load v0_0.8_parInvP0_0.4_Tc1bis5.mat

[xTwSS1,t1,dPhiGrid1] = getdata(2,simData);
[xTwSS2,t2,dPhiGrid2] = getdata(3,simData);
[xTwSS3,t3,dPhiGrid3] = getdata(4,simData);


%%
dataRange = 1:300:length(t1);

figure(1)
clf
hold on
plot(t1(dataRange),xTwSS1(dataRange,:))
plot(t2(dataRange),xTwSS2(dataRange,:))
plot(t3(dataRange),xTwSS3(dataRange,:))

figure(2)
clf
hold on
plot(t1,dPhiGrid1)
plot(t2,dPhiGrid2)
plot(t3,dPhiGrid3)
legend("f1","f2","f3")

%% Bode Diagram
% Only input is angle of grid as disturbance
load sysP0Inv0.4v00.8.mat
Bd_WT_Act_DC_Inv_Angle = Bd_WT_Act_DC_Inv(:,1);

OutputStates = 5; % State 5 is xTwSS

figure()
[axBode, mag, phase, wout] = WiWbodePlot(A_WT_Act_DC_Inv,Bd_WT_Act_DC_Inv_Angle,OutputStates);
% Create data struct for export
phaseSqueezed = squeeze(phase);
magSqueezed = squeeze(mag);
magSqueezeddB=20*log10(magSqueezed);
fout = wout/(2*pi);
data = [fout,magSqueezeddB,phaseSqueezed];

%% Export Data to PGF
% Set export options for plot
template = 4;                               % Select the template
parameter.datapath = "PGFPlots";    % Set the datapath (The path where the pgfplot will search for the data of the plot)
%parameter.xylabel = ["myxlabel","mylabel"]; % x and y label can be specified
filename = "xTwSSBode";
% parameter.savepath = [];                    % path the generated .tex file should be saved (default is current folder)

% Generate the latex code and data files
myPGF_buildLaTeXPGFplotCode(data,filename,template,parameter)


% Set export options for Bode Diagram
data = [t1(dataRange),xTwSS1(dataRange,:),xTwSS2(dataRange,:),xTwSS3(dataRange,:)];
template = 2;                               % Select the template
parameter.datapath = "PGFPlots";    % Set the datapath (The path where the pgfplot will search for the data of the plot)
parameter.xylabel = ["xTwSS","t in s"]; % x and y label can be specified
filename = "xTwssVarf";
myPGF_buildLaTeXPGFplotCode(data,filename,template,parameter)



%% Helper functions
function [xTwSS,t,dPhiGrid] = getdata(n,simData)
xTwSS = simData(n).data.xTwSSm.signals.values;
t = simData(n).data.dthetaDTrad.time;
dPhiGrid = simData(n).data.dPhiGrid.signals.values;
end

