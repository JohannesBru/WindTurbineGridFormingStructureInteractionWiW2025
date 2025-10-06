% Script compares the influence of the TS feedback controller which might
% be zero for wr control depending on the opearational region of the
% turbine. i.e. Pitch feedback control is inactive in partial load region
% and generates bode diagrams for each important state of the system from
% grid angle disturbance to state

clc
clear


pars = ["sysP0Inv0.6v00.9.mat","sysP0Inv0.8v00.9.mat",...
    "sysP0Inv0.6v01.4.mat","sysP0Inv0.8v01.4.mat"];
outputs = [3 5 7
           9 10 11
           12 0 0
           13 14 0
           1 2 0];
outputDescription = ["TwFA","TwSS","BooP";
                    "wr","wg","dtheta";
                    "DCVoltage","","";
                    "id0","iq0","";
                    "pitchR","Tg",""];
titleStrings = ["Tower and Blade","Drivetrain","DC Voltage",...
    "Inverter Currents","Actuator States"];

for q = 1:height(outputs)
    disp(q)

    % Initialize Figure
    f = figure(q);
    clf
    hold on

    % Initialize OutputStates vector
    OutputStates = [];
    OutputStrings = string([]);

    % Initialize legend string
    legstring = [];

    % Check for zeros and only assign outputs that are states to current
    % OutputStates vector
    for k = 1:width(outputs)

        y = outputs(q,k);
        if y ~= 0
          OutputStates(1,k) =  y;
        end

        OutputString = outputDescription(q,k);
        if ~strcmp(OutputString,"")
            OutputStrings(1,k) = OutputString;
        end
            
    end

    for j = 1:length(pars)
        load(pars(j))

        % Only input is angle of grid as disturbance
        Bd_WT_Act_DC_Inv_Angle = Bd_WT_Act_DC_Inv(:,1);

        % Plot Bode diagram
        [axBode, mag, phase, wout] = WiWbodePlot(A_WT_Act_DC_Inv,Bd_WT_Act_DC_Inv_Angle,OutputStates);
        leg = strcat("P0 p.u.: ",string(PrefInv0),"|","v0 p.u.: ",string(v_wind_pu0));
        legstring = [legstring,leg];
    end
    axBode.OutputLabels.String = OutputStrings;
    axBode.OutputLabels.FontSize = 20;
    axBode.InputLabels.String = "Delta Phi Grid";
    axBode.InputLabels.Visible = "on";
    axBode.InputLabels.FontSize = 20;
    grid on
    title(titleStrings(q));
    disp(q)
    legend(legstring)
    set(gcf,'Position',[100 100 1000 1200])
    %saveas(gcf,strcat("bode",titleStrings(q)),'fig')
    %saveas(gcf,strcat("bode",titleStrings(q)),'png')

    
end

