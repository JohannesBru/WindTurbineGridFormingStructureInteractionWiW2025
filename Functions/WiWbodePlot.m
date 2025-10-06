function [ax, mag, phase, wout] = WiWbodePlot(A,B,OutputStates)

l = OutputStates;
Cout = zeros(width(l),height(A));

for p = 1:length(l)
    Cout(p,l(p)) = 1;
end

sys = ss(A,B,Cout,zeros(height(Cout),width(B)));

opts = bodeoptions; % Begrenzung der Phase möglich durch bodeoptions
opts.Title.FontSize = 15;
%opts.Title.String = title;
opts.FreqUnits = 'Hz';

% Bei den Optionen kann man nochmal was mit Normierungen machen
% -> Das mal anschauen
bodeplot(sys,opts)
ax = gca;

[mag, phase, wout] = bode(sys);

end

