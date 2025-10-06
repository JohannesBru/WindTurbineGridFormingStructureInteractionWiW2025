%   alc_linear_Model_TSWT - Calculates the linear dynamics for the TS model
%   based on current operation point dP0 v0 using triangular membership
%
%   Syntax:  
%       [A,B] = calc_linear_Model_TSWT(TS,dP0,v0)
% 
%   Inputs:     TS                  struct - TS with LTI systems, membership
%                                   vectors etc. 
%                                   varibales of v
%               dP0                 double - Initial dP of WT
%               v0                  double - Initial wind speed
%
%   Outputs:    A                   A Matrix of system at operating point          
%               B                   B Matrix of system at operating point
%
%
% ______________________________________________________________________
%   Input specifications:
% ---------------------------------------------------------------------               
%
% ______________________________________________________________________
%   (C) Johannes Brunner, 2025-05-09

function [A,B,K] = calc_linear_Model_TSWT(parWT,dP0,v0)

TS = parWT.WT.TSmdl;
TSc = parWT.CTRL.TSmdl;
% Determine number of LTI systems of TS Model
Nr = max(size(TS.LTI)); 

z = [v0,dP0];

h = calc_TriangMemFcn(z,TS.LinPoints.z1,TS.LinPoints.z2);

A = zeros(size(TS.LTI(1).A));
B = zeros(size(TS.LTI(1).B));
K = zeros(size(TSc.LTI_c(1).K));
for i = 1 : Nr 
    if h(i) > 0
        A = A + h(i)*TS.LTI(i).A;
        B = B + h(i)*TS.LTI(i).B;
        K = K + h(i)*TSc.LTI_c(i).K;
    end
end

end

function[h] = calc_TriangMemFcn(z,LinPointsWind,LinPointsPRM)
% calculate weighting functions
wv = zeros(numel(LinPointsWind),1);
wPRM = zeros(numel(LinPointsPRM),1);

for idim = 1 : 2
    switch idim
        case 1
            lps = LinPointsWind;
            if z(idim) <= lps(1)
                wv(1) = 1;
            else
                for iLP = 2 : numel(lps)
                    if z(idim) < lps(iLP)
                        wv(iLP-1) = 1-(z(idim)-lps(iLP-1))/(lps(iLP)-lps(iLP-1));
                        wv(iLP) = (z(idim)-lps(iLP-1))/(lps(iLP)-lps(iLP-1));
                        break
                    end
                    if z(idim) >= lps(numel(lps))
                        wv(numel(lps)) = 1;
                    end
                end
            end
        case 2
            lps = LinPointsPRM;
            if z(idim) <= lps(1)
                wPRM(1) = 1;
            else
                for iLP = 2 : numel(lps)
                    if z(idim) < lps(iLP)
                        wPRM(iLP-1) = 1-(z(idim)-lps(iLP-1))/(lps(iLP)-lps(iLP-1));
                        wPRM(iLP) = (z(idim)-lps(iLP-1))/(lps(iLP)-lps(iLP-1));
                        break
                    end
                    if z(idim) >= lps(numel(lps))
                        wPRM(numel(lps)) = 1;
                    end
                end
            end
    end
end
h = wv*wPRM';
h = h';
h = h(:);    


end

