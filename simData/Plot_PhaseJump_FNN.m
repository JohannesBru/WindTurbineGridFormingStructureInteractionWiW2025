% This Skript plots figure 4 from the Paper

clc
clear

%% Load data 
load v0_0.8_parInvP0_0.4_Tc1bis5.mat
shouldCreatePGF = false; % Doesnt work without Toolbox

%% Select Plot to generate
% 1: Phase Jump
% 5: FNN


%% Plot Phase Jump
k = 1;

ylabelstr = ["Angle in deg", "P in p.u.", "uDC in V","delta Theta in rad" , ...
     "xTwSS in m"];

dataRange = 1:200:length(simData(k).data.dthetaDTrad.time);
[xTwSS,t,dPhiGrid,~,dThetaDT,wr,wg,f] = getdata(k,simData,dataRange);

tP = simData(k).data.PWTpu.time(1:20:end);
PWTpu = simData(k).data.PWTpu.signals.values(1:20:end,:);
PinvPu = simData(k).data.PinvPu.signals.values(1:20:end,:);
deltaPhiInv = simData(k).data.deltaPhiInv.signals.values(1:20:end,:);
deltaPhiInvDeg = rad2deg(deltaPhiInv);
uDC = simData(k).data.uDC.signals.values(1:20:end,:);

dataRangeP = [1:400:1999,2000:1:3000,3001:800:8001];

figure(2)
clf
subplot(5,1,1)
hold on
plot(t,dPhiGrid)
plot(tP,rad2deg(deltaPhiInv))
ylabel(ylabelstr(1))

subplot(5,1,2)
hold on
plot(tP(dataRangeP),PWTpu(dataRangeP,:))
plot(tP(dataRangeP),PinvPu(dataRangeP,:))
ylabel(ylabelstr(2))

subplot(5,1,3)
plot(tP,uDC)
ylabel(ylabelstr(3))


subplot(5,1,4)
plot(t,dThetaDT)
ylabel(ylabelstr(4))

subplot(5,1,5)
plot(t,xTwSS)
ylabel(ylabelstr(5))
xlabel("t in s")

if shouldCreatePGF
    data = [t,dPhiGrid,dThetaDT,xTwSS];
    template = 2;                               % Select the template
    parameter.datapath = "PGFPlots";    % Set the datapath (The path where the pgfplot will search for the data of the plot)
    parameter.xylabel = ["x","y"]; % x and y label can be specified
    filename = "PhaseJump1";
    myPGF_buildLaTeXPGFplotCode(data,filename,template,parameter)
    
    data = [tP(dataRangeP),deltaPhiInvDeg(dataRangeP,:),PWTpu(dataRangeP,:),PinvPu(dataRangeP,:),uDC(dataRangeP,:)];
    template = 2;                               % Select the template
    parameter.datapath = "PGFPlots";    % Set the datapath (The path where the pgfplot will search for the data of the plot)
    parameter.xylabel = ["x","y"]; % x and y label can be specified
    filename = "PhaseJump2";
    myPGF_buildLaTeXPGFplotCode(data,filename,template,parameter)
end




%% Plot FNN
k = 5;

ylabelstr = ["f in Hz", "P in p.u.", "uDC in V", "wg in rad/s", ...
    "delta Theta in rad", "xTwSS in m"];

dataRange = 1:400:length(simData(k).data.dthetaDTrad.time);
[xTwSS,t,dPhiGrid,uDC,dThetaDT,wr,wg,f] = getdata(k,simData,dataRange);

l = 20;

tP = simData(k).data.PWTpu.time(1:l:end);
PWTpu = simData(k).data.PWTpu.signals.values(1:l:end,:);
PinvPu = simData(k).data.PinvPu.signals.values(1:l:end,:);
deltaPhiInv = simData(k).data.deltaPhiInv.signals.values(1:l:end,:);
deltaPhiInvDeg = rad2deg(deltaPhiInv);

dataRangeP = [1:800:1999,2000:100:7000,7001:800:10001];

figure(3)
clf
subplot(6,1,1)
hold on
plot(t,50-f)
ylabel(ylabelstr(1))

subplot(6,1,2)
hold on
plot(tP(dataRangeP),PWTpu(dataRangeP,:))
plot(tP(dataRangeP),PinvPu(dataRangeP,:))
ylim([0.3,0.55])
ylabel(ylabelstr(2))

subplot(6,1,3)
plot(t,uDC)
ylabel(ylabelstr(3))

subplot(6,1,4)
plot(t,wg)
ylabel(ylabelstr(4))

subplot(6,1,5)
plot(t,dThetaDT)
ylabel(ylabelstr(5))

subplot(6,1,6)
plot(t,xTwSS)
ylabel(ylabelstr(6))
xlabel("t in s")

if shouldCreatePGF
    data = [t,-f,dThetaDT,xTwSS,uDC,wg];
    template = 2;                               % Select the template
    parameter.datapath = "PGFPlots";    % Set the datapath (The path where the pgfplot will search for the data of the plot)
    parameter.xylabel = ["x","y"]; % x and y label can be specified
    filename = "FNN1";
    myPGF_buildLaTeXPGFplotCode(data,filename,template,parameter)
    
    data = [tP(dataRangeP),deltaPhiInvDeg(dataRangeP,:),PWTpu(dataRangeP,:),PinvPu(dataRangeP,:)];
    template = 2;                               % Select the template
    parameter.datapath = "PGFPlots";    % Set the datapath (The path where the pgfplot will search for the data of the plot)
    parameter.xylabel = ["x","y"]; % x and y label can be specified
    filename = "FNN2";
    myPGF_buildLaTeXPGFplotCode(data,filename,template,parameter)
end












function [xTwSS,t,dPhiGrid,uDC,dThetaDT,wr,wg,f] = getdata(n,simData,range)

f = [];

xTwSS = simData(n).data.xTwSSm.signals.values(range,:);
uDC = simData(n).data.uDC.signals.values(range,:);
t = simData(n).data.dthetaDTrad.time(range,:);
dPhiGrid = simData(n).data.dPhiGrid.signals.values(range,:);
dThetaDT = simData(n).data.dthetaDTrad.signals.values(range,:);
wr = simData(n).data.wr.signals.values(range,:);
wg = simData(n).data.wg.signals.values(range,:);
if n == 5
    f = simData(n).data.deltaf.signals.values(range,:);
end


end