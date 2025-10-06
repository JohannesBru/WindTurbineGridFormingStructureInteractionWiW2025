%   loadTestCases - Load GFOR Inverter Test Cases
%
%   Syntax:  p = loadTestCases(p)
% 
%   Inputs: p           parameter struct with already specified parameters
%                       and test cases see below for list of parameters one
%                       can specify
%   This function Loads the base Testcase for frequency, angle and
%   amplitude changes of the analytical GFOR model defined by the TestCase
%   Input 
%
%   !!! At the end the p.TestCase.direction is set to +-1 to avoid conflict
%   with struct types given to simulink m-Functions
% ______________________________________________________________________
%   A comprehenisce overview of Testcases is below:
%
%   !!! All Testcases can be changed in direction by p.TestCase.direction
%_________________________________________________________________________
%       | Angle Step | Amplitude Step | Frequency Ramp  | Angle Sine Sweep
%       |    deg     |   PCC p.u.     |      Hz/s       |     f in Hz
% ______|____________|________________|_________________|_________________
%                           Angle Steps
%_________________________________________________________________________
%   1   |     2      |       /        |        /        |       /
%   2   |     4      |       /        |        /        |       /
%   3   |     8      |       /        |        /        |       /
%_______|____________|________________|_________________|_________________
%                        Angle Step + Frequency Ramp
%_________________________________________________________________________
%   4   |     2      |       /        |        1        |       /
%   5   |     4      |       /        |        2        |       /
%_______|____________|________________|_________________|_________________
%                           Frequency Ramps
%_________________________________________________________________________
%   6   |     /      |       /        |        1        |       /
%   7   |     /      |       /        |        2        |       /
%   8   |     /      |       /        |       FNN       |       /
%   9   |     /      |       /        |      Custom     |       /
%_______|____________|________________|_________________|_________________
%                           Voltage Amplitude
%_________________________________________________________________________
%   10  |     /      |       0.1      |        /        |       /
%   11  |     /      |       0.2      |        /        |       /
%   12  |     /      |       0.5      |        /        |       /
%   13  |     /      |       0.9      |        /        |       /
%_______|____________|________________|_________________|_________________
%                           Angle Oscillations
%_________________________________________________________________________
%   14  |     /      |       /        |        /        |       0.2
%   15  |     /      |       /        |        /        |       0.326
%   16  |     /      |       /        |        /        |       0.4
%_______|____________|________________|_________________|_________________
%                          Custom
%_________________________________________________________________________
%  98  |               Angle Frequency Sweep
%  99  |               Complete Custom
%_________________________________________________________________________
%
%_________________________________________________________________________
% Test Case Parameterization description 
% Frequency Ramp can be defined by p.FrequencyRamp
%
% 1: Angle Step 
% 2: Frequency Ramp +Hz/s for 1 Second -> 1 Second -> -Hz/s for 1 Second 
% 3: Ramp Hz/s @ 2s
% 4: Angle Step + Hz/s Ramp for 1 Second
% 5: No change
% 6: Frequency Sweep over 4s from 0.1 to 4 Hz
% 7: Sine Input on Delta Angle

% p.deltaPhiSelect = 3;       % Test Case selection 
% p.AngleStepDeg = -10;        % degree
% p.FrequencyRamp = 2;        % Hz/s
% p.AmplitudeSineInput = 1;   % degree
% p.FrequencySineInput = 1;   % Hz

% Amplitude Variation of absolute voltage amplitude at pcc
% 1: No Change
% 2: Step Change @ 2s
% 3: -0.1 p.u./s @ 2s for 1 Second 
% 4: 
% 5: 

% p.deltaUpccSelect = 1; 
% p.UpccStepPu = -0.5;

function p = loadTestCasesWiW2025(p)

TestCaseNr = p.TestCase.Nr;
direction =  p.TestCase.direction;

if strcmp(direction,"pos")
    PosNegMultiplier = 1;
elseif strcmp(direction,"neg")
    PosNegMultiplier = -1;
else
    fprintf("Wrong string for p.TestCase.direction, setting default: pos\n")
    PosNegMultiplier = 1;
end

% Load default parameters so every teset case has parameters even if not
% selected
p = setDefaults(p);

switch TestCaseNr
    case 1
        p.deltaPhiSelect =          1;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 2;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 0;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 8;
    case 2
        p.deltaPhiSelect =          1;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 4;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 0;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 8;
    case 3
        p.deltaPhiSelect =          1;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 8;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 0;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 8;
    case 4
        p.deltaPhiSelect =          4;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 2;       % degree
        p.FrequencyRamp =           -PosNegMultiplier * 1;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 8;
    case 5
        p.deltaPhiSelect =          4;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 4;       % degree
        p.FrequencyRamp =           -PosNegMultiplier * 2;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 8;
    case 6
        p.deltaPhiSelect =          3;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 1;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 8;
    case 7
        p.deltaPhiSelect =          3;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 2;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 8;
    case 8
        % FNN Frequency Ramp
        p.deltaPhiSelect =          8;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 2;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 10;
    case 9
        p.deltaPhiSelect =          2;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 1;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 8;
    case 10
        p.deltaPhiSelect =          5;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 0;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         2; 
        p.UpccStepPu =              PosNegMultiplier * 0.1;
        p.simTime = 8;
    case 11
        p.deltaPhiSelect =          5;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 0;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         2; 
        p.UpccStepPu =              PosNegMultiplier * 0.2;
        p.simTime = 8;
    case 12
        p.deltaPhiSelect =          5;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 0;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         2; 
        p.UpccStepPu =              PosNegMultiplier * 0.5;
        p.simTime = 8;
    case 13
        p.deltaPhiSelect =          5;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 0;       % Hz/s
        p.AmplitudeSineInput =      PosNegMultiplier * 0;       % degree
        p.FrequencySineInput =      PosNegMultiplier * 0;       % Hz
        p.deltaUpccSelect =         2; 
        p.UpccStepPu =              PosNegMultiplier * 0.9;
        p.simTime = 8;
    case 14
        p.deltaPhiSelect =          7;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 0;       % Hz/s
        p.AmplitudeSineInput =      2;                          % degree
        p.FrequencySineInput =      0.2;                       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 30;
    case 15
        p.deltaPhiSelect =          7;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 0;       % Hz/s
        p.AmplitudeSineInput =      2;                          % degree
        p.FrequencySineInput =      0.326;                       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 30;
    case 16
        p.deltaPhiSelect =          7;                          % Test Case selection 
        p.AngleStepDeg =            PosNegMultiplier * 0;       % degree
        p.FrequencyRamp =           PosNegMultiplier * 0;       % Hz/s
        p.AmplitudeSineInput =      2;                        % degree
        p.FrequencySineInput =      0.4;                       % Hz
        p.deltaUpccSelect =         1; 
        p.UpccStepPu =              PosNegMultiplier * 0;
        p.simTime = 30;
    case 98
        p.deltaPhiSelect =          6;                          % Test Case selection 
        p.tStartSineSweep =         5;     % cant be zero!
        p.RampTime =                80;
        p.initialf =                0;
        p.targetfOfRamp =           5;
        p.AmplitudeGrad =           1;
        p.simTime = p.tStartSineSweep + p.RampTime;
    case 99
        % Case 99 Loads Parameters given in funciton loadCustomTestcase.m
        




end

% Set Direction to multiplier
p.TestCase.direction = PosNegMultiplier;
p.TestCase.t0 = 2;
end



function p = setDefaults(p)


    p.deltaPhiSelect =          0;                          % Test Case selection 
    p.AngleStepDeg =            0;       % degree
    p.FrequencyRamp =           0;       % Hz/s
    p.AmplitudeSineInput =      0;       % degree
    p.FrequencySineInput =      0;       % Hz
    p.deltaUpccSelect =         0; 
    p.UpccStepPu =              0;
    p.tStartSineSweep =         100;     % cant be zero!
    p.RampTime =                1;
    p.initialf =                0;
    p.targetfOfRamp =           5;
    p.AmplitudeGrad =           1;

end
