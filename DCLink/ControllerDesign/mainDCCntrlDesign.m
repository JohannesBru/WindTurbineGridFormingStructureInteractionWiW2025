clc
clear


load parWT.mat
load parDC5MW.mat

P0pu = 0.8;

% Define Jacobian Matrices for DC Bus
Dfx = @(uDC0,u0,d0,C) -1/(uDC0^2*C) * (u0-d0); 
Dfu = @(uDC0,C) 1/(uDC0*C);
Dfd = @(uDC0,C) -1/(uDC0*C);

% Calculate state space from lin point
uDC0 = parDC.uDC0;
u0 = parDC.Prated;
d0 = parDC.Prated;
C = parDC.C;

ADC = Dfx(uDC0,u0,d0,C);
BuDC = Dfu(uDC0,C);
BdDC = Dfd(uDC0,C);
CDC = 1;
DDC = 0;

sysDC = ss(ADC,BuDC,CDC,DDC);

GDC = tf(sysDC);

% load drive train dynamics
Nr = 900;

ADT = parWT.WT.TSmdl.LTI(Nr).A(end-2:end,end-2:end);
BuDT = parWT.WT.TSmdl.LTI(Nr).B(end-2:end,2);
x0DT = parWT.WT.TSmdl.LTI(Nr).x0(end-2:end);
u0DT = parWT.WT.TSmdl.LTI(Nr).u0(2);

x20DT = x0DT(2);

Dhx = @(u0DT) [0, u0DT, 0];
Dhu = @(x20DT) [x20DT];

CDT = Dhx(u0DT);
DDT = Dhu(x20DT);

sysDT = ss(ADT,BuDT,CDT,DDT);

GDT = tf(sysDT);

% Combine DC Link and Drive Train transfer function
% Das ist Führungsübertragungsverhalten nicht Störverhalten
Gsys = GDT*GDC;
[C_pi,info] = pidtune(Gsys,'PIDF',50);
%C_pi
T_pi = feedback(C_pi*Gsys,1);
step(T_pi)


parPIDDC.Kp = C_pi.Kp;
parPIDDC.Ki = C_pi.Ki;
parPIDDC.Kd = C_pi.Kd;
%%
%save("parPIDDCV2","parPIDDC")



%% From CHATGPT

%% === User models (replace with your own) ===
close all
s   = tf('s');
G_DC = 1/(s*uDC0*C);       % plant 
G_DT = GDT;                % actuator 
ku   = 1/(uDC0*C);         % control input gain (yours)
kd   = -ku;                % given

%% === Effective plant seen by the controller ===
P = ku*G_DT*G_DC;             % what pidtune will see

%% === Tuning targets (edit to taste) ===
% Goal: reject step/low-freq disturbances up to wr (rad/s)
wr = 5;                       % desired rejection frequency (example)
% Rule of thumb: crossover wc ≈ 3–5× wr, but don't exceed actuator bandwidth
wa = 1/(0.02);                % actuator “bandwidth” ~ 1/tau (rough)
wc = min(4*wr, wa/3);         % pick a safe crossover
pm = 60;                      % target phase margin for robustness

opts = pidtuneOptions('CrossoverFrequency', wc*0.1, 'PhaseMargin', pm+10);

%% === Start with PI (good for input disturbances, zero steady-state error) ===
[Cpi, infoPI] = pidtune(P, 'PI', opts);

%% === Loop analysis ===
L   = Cpi*P;
S   = feedback(1, L);                 % sensitivity  = 1/(1+L)
Tcl = feedback(L, 1);                 % setpoint→output
Tdy = kd*G_DC*S;                      % disturbance→output (your structure)

fprintf('--- PI tune ---\n');
fprintf('wc (target)= %.2f rad/s, achieved wc ≈ %.2f rad/s\n', wc, infoPI.CrossoverFrequency);
fprintf('Phase margin (reported): %.1f deg\n', infoPI.PhaseMargin);

%% === Quick checks ===
figure; margin(L); grid on; title('Loop margin (PI)');

% Disturbance rejection magnitude (|Tdy|) over frequency
w = logspace(-2, 2, 400);
figure; bodemag(Tdy, w); grid on; title('|T_{dy}(j\omega)| (PI)  — disturbance → output');

% Sensitivity shaping view (want |S| small at low freq)
figure; bodemag(S, w); grid on; title('|S(j\omega)| (PI)  — lower is better at low \omega');

% Time-domain: step disturbance (unit step on disturbance input)
figure; step(Tdy, 5); grid on; title('Output to step disturbance (PI)');

% Also check setpoint tracking if relevant
figure; step(Tcl); grid on; title('Setpoint response (PI)');

%% === If you need more attenuation: increase wc carefully or switch to PIDF ===
% WARNING: Don’t push wc close to actuator bandwidth; keep robust PM.
wc2 = min(6*wr, wa/2);                          % slightly higher target
opts2 = pidtuneOptions('CrossoverFrequency', wc2*0.01, 'PhaseMargin', pm+10);

% PID with filtered derivative (helps phase near wc without noise blow-up)
[CPIDF, infoPIDF] = pidtune(P, 'PIDF', opts2);

L2   = CPIDF*P;
S2   = feedback(1, L2);
Tdy2 = kd*G_DC*S2;

fprintf('\n--- PIDF tune ---\n');
fprintf('wc (target)= %.2f rad/s, achieved wc ≈ %.2f rad/s\n', wc2, infoPIDF.CrossoverFrequency);
fprintf('Phase margin (reported): %.1f deg\n', infoPIDF.PhaseMargin);

figure; margin(L2); grid on; title('Loop margin (PIDF)');
figure; bodemag(Tdy, Tdy2, w); grid on;
legend('PI','PIDF'); title('|T_{dy}(j\omega)| — PI vs PIDF');
figure; step(Tdy, Tdy2, 5); grid on;
legend('PI','PIDF'); title('Output to step disturbance — PI vs PIDF');

%% === Notes / tips ===
% 1) Integral action is essential for rejecting constant (step) input disturbances.
% 2) For dominant input disturbances, PI often suffices; use PIDF if you need
%    extra phase near wc to raise bandwidth while keeping good margins.
% 3) Choose wc well below the actuator corner (e.g., <= ~1/3 to 1/2 of its bw).
% 4) Verify:  (a) |S| small below your disturbance band; (b) PM >= ~55–60 deg;
%             (c) actuator effort (u) is acceptable (check with closed-loop sims).
% 5) If measurement noise is an issue, prefer PI or keep derivative filter coefficient

%%
parPIDDC.Kp = CPIDF.Kp
parPIDDC.Ki = CPIDF.Ki
parPIDDC.Kd = CPIDF.Kd

save("parPIDDCV3","parPIDDC")