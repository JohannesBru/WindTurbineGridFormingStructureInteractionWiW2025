function [A,Bu,Bd,Cx,Cu,Cd,x0,a0,KuDC] = GenerateFullStateSpaceMdl(p,parDC,parInvLinMdl,parWT,parWT_Init)

% Create Full State Space model

% Linear Model Matrices for operating point for Wind Turbine and Actuators
% of Wind Turbine 
%
% x = [pitchR, Tg, xTwFA, dxTwFA, xTwSS, dxTwSS, xBooP, dxBooP, wr, wg, dthetaDT]
%
[AWT,BWT,KWT] = calc_linear_Model_TSWT(parWT,1-parWT_Init.dPin0,parWT_Init.v_wind_pu0*11.6);
tauPitchR = parWT.WT.tauPitchR;
tauTg = parWT.WT.tauTg;
AAct = [-1/tauPitchR, 0;
            0, -1/tauTg];
BAct = [1/tauPitchR, 0;
            0, 1/tauTg];

AWTuAct = [AAct,zeros(2,9);
        BWT,AWT];

BWTuAct = [BAct;
            zeros(9,2)];

% Linear Model of DC Link

ADC = 0;

Tg0 = parWT_Init.xu0(2);
wg0 = parWT_Init.x0WT(8);
% dqdTg = 1/(parDC.uDC0*parDC.C)*wg0;
% dqdwg = 1/(parDC.uDC0*parDC.C)*Tg0;
PowerScale = 5e6/parWT.Pmax;
dqdTg = 1/(parDC.uDC0*parDC.C)*PowerScale*wg0;
dqdwg = 1/(parDC.uDC0*parDC.C)*PowerScale*Tg0;

B_WT_P_DC = zeros(1,11);
B_WT_P_DC(2) = dqdTg;
B_WT_P_DC(10) = dqdwg;

% Model with 2 Actuator states, 9 WT states, DC Link voltage state
A_WT_Act_DC = [AWTuAct, zeros(11,1);
                B_WT_P_DC, 0];

% Inputs u = [pitch_ref, Tg_ref]
B_WT_Act_DC = [BWTuAct;
                zeros(1,2)];

Bd_WT_Act_DC = zeros(12,1);
Bd_WT_Act_DC(12) = -1/(parDC.uDC0*parDC.C);


xInit_WT_Act_DC = [parWT_Init.xu0; parWT_Init.x0WT; parDC.uDC0];

% Add Inverter dynamics
% parInvLinMdl.A
Ainv = parInvLinMdl.A;
Buinv = parInvLinMdl.Bu;%*[1;-1]; % Bu*u must be multiplied by [1;-1] -> error not yet found why
Bdinv = parInvLinMdl.Bd;
Cxinv = parInvLinMdl.Cx;
Cdinv = parInvLinMdl.Cd;
Cuinv = parInvLinMdl.Cu;

A_WT_Act_DC_Inv = [A_WT_Act_DC, zeros(height(A_WT_Act_DC),width(Ainv));
                        zeros(width(Ainv),height(A_WT_Act_DC)), Ainv];

% inputs u = [pitch_ref,Tg_ref,udinv, uqinv, deltaPhiInv]'
B_WT_Act_DC_Inv = zeros(height(A_WT_Act_DC_Inv),5);

% Add Acutator dynamics input time constant
B_WT_Act_DC_Inv(1:12,1:2) = B_WT_Act_DC; 

% Add inputs to inverter states
B_WT_Act_DC_Inv(13:14,3:5) = Buinv;

% disturbances = [Pinv, deltaPhiGrid; deltaUpcc]
Bd_WT_Act_DC_Inv = zeros(height(A_WT_Act_DC_Inv),3);
Bd_WT_Act_DC_Inv(1:12,1) = Bd_WT_Act_DC;
Bd_WT_Act_DC_Inv(13:14,2:3) = Bdinv;

% Output equations
% outputs y = [Pinv, Qinv]
Cx_WT_Act_DC_Inv = zeros(2,height(A_WT_Act_DC_Inv));
Cx_WT_Act_DC_Inv(:,end-1:end) = Cxinv;

Cu_WT_Act_DC_Inv = zeros(2,width(B_WT_Act_DC_Inv));
Cu_WT_Act_DC_Inv(:,end-2:end) = Cuinv;

Cd_WT_Act_DC_Inv = zeros(2,width(Bd_WT_Act_DC_Inv));
Cd_WT_Act_DC_Inv(:,end-1:end) = Cdinv;


% Initial states
xInit_WT_Act_DC_Inv = [parWT_Init.xu0; parWT_Init.x0WT; ...
                        parDC.uDC0; parInvLinMdl.x0];

% Anpassungen für Leistungseingang als Störung für DC Link
CdInvP = Cdinv(1,:);
CxInvP = Cxinv(1,:);
CuInvP = Cuinv(1,:);

PS = parDC.Prated/p.SInvRated; % Power Scaling

% Reduce disturbance matrix as deltaP will become calculation of states and
% inputs
Bd_WT_Act_DC_Inv(:,1) = [];
Bd_WT_Act_DC_Inv(end-2,:) = -PS/(parDC.uDC0*parDC.C).*CdInvP;

% Add Input Matrix 
B_WT_Act_DC_Inv(end-2,3:end) = -PS/(parDC.uDC0*parDC.C).*CuInvP;

% Add State Matrix
A_WT_Act_DC_Inv(end-2,13:end) = -PS/(parDC.uDC0*parDC.C).*CxInvP;
%parInvLinMdl.a0= parInvLinMdl.a0+parInvLinMdl.c0;

% Change output matrix to accomadate the new dimension of d -> 3x1 to 2x1
Cd_WT_Act_DC_Inv(:,1) = [];


% Start adding controllers into the state matrix

% Add Pitch and Torque rotor speed controller
% AwrCntrl = [-KWT(1,1)/tauPitchR;
%  -KWT(2,1)/tauTg];
% A_WT_Act_DC_Inv_cmp = A_WT_Act_DC_Inv;
% A_WT_Act_DC_Inv_cmp(1:2,9) = AwrCntrl;

% For the 4 inputs that are the proportional part
BStateCntrlIntegration = B_WT_Act_DC_Inv(:,1:4);

% Integrate linear wr controller from TS KWT
KpitchTg = [zeros(2,8),[KWT(1,1);KWT(2,1)],zeros(2,2),...
    [0;0],zeros(2,2)];
A_WT_Act_DC_Inv = A_WT_Act_DC_Inv-BStateCntrlIntegration(:,1:2)*KpitchTg;

% Integrate current damping controller into A Matrix
Kud0uq0 = [zeros(2,12),[p.sysLin.K;0,0]];
A_WT_Act_DC_Inv = A_WT_Act_DC_Inv-BStateCntrlIntegration(:,3:4)*Kud0uq0;

% Integrate Integral state uDC controller into A Matrix
KpuDC = parDC.KpuDC;
KiuDC = parDC.KiuDC;

A_WT_Act_DC_Inv = [A_WT_Act_DC_Inv,zeros(height(A_WT_Act_DC_Inv),1);
                    zeros(1,width(A_WT_Act_DC_Inv)),0];
A_WT_Act_DC_Inv(end,12) = -1;
B_WT_Act_DC_Inv = [B_WT_Act_DC_Inv;
                    zeros(1,width(B_WT_Act_DC_Inv))];
Bd_WT_Act_DC_Inv = [Bd_WT_Act_DC_Inv;
                    zeros(1,width(Bd_WT_Act_DC_Inv))];
Cx_WT_Act_DC_Inv = [Cx_WT_Act_DC_Inv, ...
                    zeros(height(Cx_WT_Act_DC_Inv),1)];
% Cu_WT_Act_DC_Inv = [Cu_WT_Act_DC_Inv, ...
%                     zeros(height(Cu_WT_Act_DC_Inv),1)];
% Cd_WT_Act_DC_Inv = [Cd_WT_Act_DC_Inv, ...
%                     zeros(height(Cd_WT_Act_DC_Inv),1)];

xInit_WT_Act_DC_Inv = [parWT_Init.xu0; parWT_Init.x0WT; ...
                        parDC.uDC0; parInvLinMdl.x0; 0];

a0_WT_Act_DC_Inv = [zeros(12,1);parInvLinMdl.a0;0];

KuDC = [zeros(1,11),KpuDC,zeros(1,2),-KiuDC];

A_WT_Act_DC_Inv = A_WT_Act_DC_Inv-B_WT_Act_DC_Inv(:,2)*KuDC;

%% Ab hier ist Irgendwo der Fehler
% Integration of angle generation dynamics into the state space model

% Scaling for deltaP and sign change
sc = -1/p.SInvRated;

% Output matrices -> Only active power as output and only angle input which has
% influence on output in linearized form 
Cx = Cx_WT_Act_DC_Inv(1,:);
Cudphi = Cu_WT_Act_DC_Inv(1,end);
Cd = Cd_WT_Act_DC_Inv(1,:);

bag = [0;abs(p.LTIAngleGen.Bw(2,1))*sc];

Aag = p.LTIAngleGen.A;
Cag = p.LTIAngleGen.Cz(1,:);

A_WT_Act_DC_Inv = [A_WT_Act_DC_Inv, zeros(15,2);
                    bag*Cx, Aag-bag*Cudphi*Cag];
Bd_WT_Act_DC_Inv = [Bd_WT_Act_DC_Inv;
                        bag*Cd];

B_WT_Act_DC_Inv = [B_WT_Act_DC_Inv;
                    zeros(2,width(B_WT_Act_DC_Inv))];

xInit_WT_Act_DC_Inv = [xInit_WT_Act_DC_Inv;0;0];

Cx_WT_Act_DC_Inv = [Cx_WT_Act_DC_Inv,zeros(2,2)];

%-parInvLinMdl.PrefPu0*abs(p.LTIAngleGen.Bw(2,1))*sc
a0_WT_Act_DC_Inv = [a0_WT_Act_DC_Inv;0;0];

% Add angle gen output -> deltaPhi to the state space matrix thorugh input
% channel of the system

A_WT_Act_DC_Inv = A_WT_Act_DC_Inv-B_WT_Act_DC_Inv(:,5)*[zeros(1,15),Cag];
B_WT_Act_DC_Inv(12,5) = 0;



A = A_WT_Act_DC_Inv;
Bu = B_WT_Act_DC_Inv;
Bd = Bd_WT_Act_DC_Inv;
Cx = Cx_WT_Act_DC_Inv;
Cu = Cu_WT_Act_DC_Inv;
Cd = Cd_WT_Act_DC_Inv;
x0 = xInit_WT_Act_DC_Inv;
a0 = a0_WT_Act_DC_Inv;

end

