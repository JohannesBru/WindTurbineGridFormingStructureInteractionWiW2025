% This Skript creates a plot from each measurement in the simulation and
% compares the nonlinear with the linear model
%
% Select Variable k to change the test scenario

%%
clc
clear

%% Load Results Data
load v0_0.8_parInvP0_0.4_Tc1bis5.mat

%% Select Data to plot
% 1: Phase Jump
% 2: Sine Frequency Angle
% 3: Sine Frequency Angle
% 4: Sine Frequency Angle
% 5: FNN
k = 3;

%% Plot Data
ax = myplot_CompareSimulationsV2(simData(k).data);
