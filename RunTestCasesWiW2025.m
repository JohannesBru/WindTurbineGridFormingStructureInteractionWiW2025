% This Skript runs a set of Testcases consecutively and saves all the data
% in the struct simData
%
%   Care: The simData Struct can get quite large 
%
% Test cases are selected based on function selectTestCasePaper
% see function for more informations
%
% The test cases are loaded from function loadTestCasesWiW2025
%
% see also: selectTestCasePaper; loadTestCasesWiW20205

clc
clear

% Time Steps Turbine is simulated at in triggered subsystem
parSim.Ts_WT = 1e-04;

% Load Turbine
load parWT.mat
load parWT_Init.mat

% Load Parameters for DC Link
parDC.uDC0 = 1300;
parDC.C = 5e-2;
parDC.Prated = 5000000;
parWT.DTD.DTDActive = 1;
parDC.KpuDC = 53;
parDC.KiuDC = 33;

% load Parameters for DC Link Controller
load('parPIDDCV3.mat')


%InverterMdls = ["parInvP0_0.4.mat","parInvP0_0.8.mat"];
%v_wind_pu = [0.8,1.4]; % Test case Operating points for Wind speed

InverterMdls = ["parInvP0_0.4.mat"];
v_wind_pu = [0.8];


NrTestcases = numel(v_wind_pu)*numel(InverterMdls)*5;

k = 0;
for l = 1:length(v_wind_pu)
    % Iterate over wind speeds
    v_wind_pu0 = v_wind_pu(l);

    for j = 1:length(InverterMdls)
        % Iterate over power operating point
        load(InverterMdls(j))

        % Calculate Initial condition Turbine
        PrefInv0 = parInvLinMdl.PrefPu0;
        parWT_Init = calcInitWTV2(parWT_Init,parWT,PrefInv0,v_wind_pu0);
        parWT.Pmax = parWT.WT.TSmdl.LTI(end-numel(parWT.WT.TSmdl.deltaP)+1).u0(2)*parWT.WT.TSmdl.LTI(end-numel(parWT.WT.TSmdl.deltaP)+1).x0(8);

        % Set Angle Gen Dynamics
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
        
        % Iterate over testcases 1 to 5
        for i = 1:5
            k = k + 1;
            fprintf("Running Simulation %s/%s\n",string(k),string(NrTestcases))
            
            % Test case selection for paper
            p = selectTestCasePaper(p,i);

            % Load Test cases from Test case database
            p = loadTestCasesWiW2025(p);

            % Run simulation with current Test Case
            simData(k).data = sim("mdlWiW2025.slx");
            simData(k).p = p;
            simData(k).v_wind_pu0 = v_wind_pu0;
            simData(k).PrefInv0 = PrefInv0;
            simData(k).parWT_Init = parWT_Init;
        end

    end

end

%%
savename = strcat('simData/v0_',string(v_wind_pu),'_',erase(InverterMdls,'.mat'),'_Tc1bis',string(i),'.mat');
save(savename,"simData")




function p = selectTestCase(p,Nr)

    switch Nr
        case 1
            % +- 2 Hz/s f Ramps
            p.TestCase.Nr = 7; 
            p.TestCase.direction = "neg";
        case 2
            p.TestCase.Nr = 7; 
            p.TestCase.direction = "pos";
        case 3
            % +- 2 degree angle + ramp 1Hz/s
            p.TestCase.Nr = 4; 
            p.TestCase.direction = "neg";
        case 4
            p.TestCase.Nr = 4; 
            p.TestCase.direction = "pos";
        case 5
            % +- 2 degree angle 
            p.TestCase.Nr = 1; 
            p.TestCase.direction = "neg";
        case 6
            p.TestCase.Nr = 1; 
            p.TestCase.direction = "pos";
        case 7
            % Angle Oscillation 
            p.TestCase.Nr = 14; 
            p.TestCase.direction = "neg";
        case 8
            p.TestCase.Nr = 8; 
            p.TestCase.direction = "neg";
        case 9
            p.TestCase.Nr = 8; 
            p.TestCase.direction = "pos";
        case 10
            % Angle f Sweep
            p.TestCase.Nr = 98; 
            p.TestCase.direction = "neg";
    end

end