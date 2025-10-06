% This skript generates a number of linear model matrices which
% can be used for linear analysis and are saved as .mat files.
%
% Each generated subsystem can be used for analysis of the operating point
%

clc
clear

% Time Steps Turbine is simulated at in triggered subsystem
parSim.Ts_WT = 1e-04;

InvParStr = ["parInvP0_0.4.mat","parInvP0_0.8.mat","parInvP0_0.6.mat"];
vWindPu = [0.8,0.9,1.4];

% Init Turbine
load parWT.mat
load parWT_Init.mat


for i = 1:length(vWindPu)
    v_wind_pu0 = vWindPu(i);
    for j = 1:length(InvParStr)
    load(InvParStr(j));
    PrefInv0 = parInvLinMdl.PrefPu0;
    
    parWT_Init = calcInitWTV2(parWT_Init,parWT,PrefInv0,v_wind_pu0);
    parWT.Pmax = parWT.WT.TSmdl.LTI(end-numel(parWT.WT.TSmdl.deltaP)+1).u0(2)*parWT.WT.TSmdl.LTI(end-numel(parWT.WT.TSmdl.deltaP)+1).x0(8);
    
    % Init DC Link
    parDC.uDC0 = 1300;
    parDC.C = 5e-2;
    parDC.Prated = 5000000;
    parWT.DTD.DTDActive = 1;
    parDC.KpuDC = 53;
    parDC.KiuDC = 33;
    
    % 
    p.LTIAngleGen.A = [0, 1; -0 -0];
    p.LTIAngleGen.Bw = [0,0;20,-20];
    p.LTIAngleGen.Cz = [1,0.2;0,0];
    p.LTIAngleGen.Dzw = [0,0;0,0];
    
    [A,Bu,Bd,Cx,Cu,Cd,x0,a0,KuDC] = GenerateFullStateSpaceMdl(p,parDC,parInvLinMdl,parWT,parWT_Init);
    
    A_WT_Act_DC_Inv = A;
    B_WT_Act_DC_Inv = Bu;
    Bd_WT_Act_DC_Inv = Bd;
    Cx_WT_Act_DC_Inv = Cx;
    Cu_WT_Act_DC_Inv = Cu;
    Cd_WT_Act_DC_Inv = Cd;
    xInit_WT_Act_DC_Inv = x0;
    a0_WT_Act_DC_Inv = a0;
    
    Cag = p.LTIAngleGen.Cz(1,:);
    
    savename = strcat("sys","P0Inv",string(PrefInv0),"v0",string(v_wind_pu0),".mat");
    save(savename)
    
    end
end








