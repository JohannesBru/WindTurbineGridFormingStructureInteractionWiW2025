%   calc_Init_TS_membership_WT_Split - Calculates the inital
%   conditions of a TS struct using triangular membership functions
%
%   Syntax:  
%       TS = calc_Init_TS_membership_WT_Posytyf(TS,dP_fieldname,v_fieldname,dP0,v0)
% 
%   Inputs:     TS                  struct - TS with LTI systems, membership
%                                   vectors etc. 
%               dP_fieldname        string - name of field with lineraization
%                                   variables of dP
%               v_fieldname         string - name of field with lineraization
%                                   varibales of v
%               dP0                 double - Initial dP of WT
%               v0                  double - Initial wind speed
%
%   Outputs:    x0                  vector with initial states of model           
%               u0                  [beta0, Tg0] vector with initial states of actuators
%
%
% ______________________________________________________________________
%   Input specifications:
% ---------------------------------------------------------------------               
%
% ______________________________________________________________________
%   (C) Johannes Brunner, 2025-05-09

function [x0,u0] = calc_init_TS(TS,dP0,v0)


% Determine number of LTI systems of TS Model
Nr = max(size(TS.LTI)); 

z = [v0,dP0];

h = calc_TriangMemFcn(z,TS.LinPoints.z1,TS.LinPoints.z2);

x0 = zeros(size(TS.LTI(1).x0));
u0 = zeros(size(TS.LTI(1).u0));

for i = 1 : Nr 
    if h(i) > 0
        x0 = x0 + h(i)*TS.LTI(i).x0;
        u0 = u0 + h(i)*TS.LTI(i).u0;
    end
end

TS.Init.x0 = x0;
TS.Init.u0 = u0;

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