function parWT_Init = calcInitWTV2(parWT_Init,parWT,Pinv0pu,v_wind_pu0)

TS = parWT.WT.TSmdl;
parWT_Init.v_wind_pu0 = v_wind_pu0;

% Calculate if Turbine can meet the demanded power of Inverter Power
% Setpoint at given wind speed

[x0,u0] = calc_init_TS(TS,0,parWT_Init.v_wind_pu0*11.6);

P0 = x0(8)*u0(2);
PratedWT = 5.2986e+06;

if P0 < PratedWT*Pinv0pu
    fprintf(2,"Turbine can not reach Power of inverter\n")
    return

else
    dPin0 = 0;
    P0 = 0;
    while P0 < PratedWT*Pinv0pu
        dPin0 = dPin0+0.0005;
        [x0,u0] = calc_init_TS(TS,1-dPin0,parWT_Init.v_wind_pu0*11.6);
        P0 = x0(8)*u0(2);
    end
end

parWT_Init.dPin0 = dPin0;
parWT_Init.v_wind_pu0 = v_wind_pu0;

[x0,u0] = calc_init_TS(TS,1-parWT_Init.dPin0,parWT_Init.v_wind_pu0*11.6); 

parWT_Init.x0WT  = x0;
parWT_Init.xu0   = u0;
parWT_Init.x0obs = [x0(7),v_wind_pu0*11.6];



end

