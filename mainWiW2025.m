% This is the main skript to run a comparison simulation between the
% nonlinear GFR Windturbine Model and the linear Model generated for the
% analysis.
%
% Skript runs a single simulation:
%
%   Opearting point can be selected by:     parInvP0_0.X.mat
%   Windspeed can be selected by:           v_wind_pu0
%   Testcase can be selected by:            p.TestCase.Nr
%                                           p.TestCase.direction
%   See below for more information 
%%
clc
clear

shouldRunAndSave = false;

%% Load Inverter parameters p.u. operating points
%load parInvP0_0.2.mat
%load parInvP0_0.4.mat
%load parInvP0_0.6.mat
load parInvP0_0.8.mat

%% Select windspeed operating point
v_wind_pu0 = 1.4;

%% Load Turbine Parameters
load parWT.mat
load parWT_Init.mat

%% Select Testcase
% 1: 2 degree angle jump
% 4: 2 degree angle + ramp 1Hz/s
% 6: 1 Hz/s f ramp
% 7: 2 Hz/s f ramp
% 8: FNN f Ramp
% 14: 0.15 Hz Oscillation of Angle with 0.2 degree amplitude
% 98: Sine Sweep
p.TestCase.Nr = 1;
p.TestCase.direction = "pos";
p = loadTestCasesWiW2025(p);

%% Init and run Simulation
% Time Steps Turbine is simulated at in triggered subsystem
parSim.Ts_WT = 1e-04; % do not change above 1e-04

% Initialize Wind turbine operating point based on Inverter Power
PrefInv0 = parInvLinMdl.PrefPu0;
parWT_Init = calcInitWTV2(parWT_Init,parWT,PrefInv0,v_wind_pu0);
parWT.Pmax = parWT.WT.TSmdl.LTI(end-numel(parWT.WT.TSmdl.deltaP)+1).u0(2)*parWT.WT.TSmdl.LTI(end-numel(parWT.WT.TSmdl.deltaP)+1).x0(8);

% Load DC Link Parameters
parDC.uDC0 = 1300;
parDC.C = 5e-2;
parDC.Prated = 5000000;
parDC.KpuDC = 53;
parDC.KiuDC = 33;

% Set Angle generation dynamics for Grid forming inverter
p.LTIAngleGen.A = [0, 1; -0 -0];
p.LTIAngleGen.Bw = [0,0;20,-20];
p.LTIAngleGen.Cz = [1,0.2;0,0];
p.LTIAngleGen.Dzw = [0,0;0,0];

% Generate the Full State Space model with 17 States 
[A,Bu,Bd,Cx,Cu,Cd,x0,a0,KuDC] = GenerateFullStateSpaceMdl(p,parDC,parInvLinMdl,parWT,parWT_Init);

% Set Variables for simulation
A_WT_Act_DC_Inv = A;
B_WT_Act_DC_Inv = Bu;
Bd_WT_Act_DC_Inv = Bd;
Cx_WT_Act_DC_Inv = Cx;
Cu_WT_Act_DC_Inv = Cu;
Cd_WT_Act_DC_Inv = Cd;
xInit_WT_Act_DC_Inv = x0;
a0_WT_Act_DC_Inv = a0;
Cag = p.LTIAngleGen.Cz(1,:);

% Open Simulink Model
open("mdlWiW2025.slx")

% Run the simulation and save the data in simData and workspace
if shouldRunAndSave
    k = 1;
    simData(k).data = sim("mdlWiW2025.slx");
    simData(k).p = p;
    simData(k).v_wind_pu0 = v_wind_pu0;
    simData(k).PrefInv0 = PrefInv0;
    simData(k).parWT_Init = parWT_Init;
    
    savename = strcat('v0_',string(v_wind_pu0),'_P0_',string(PrefInv0),'_Tc',string(p.TestCase.Nr),'.mat');
    save(savename,"simData")
end






