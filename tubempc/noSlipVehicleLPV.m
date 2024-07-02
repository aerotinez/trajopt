function sys = noSlipVehicleLPV(x,p)
    arguments
        x (4,1) double;
        p (3,1) double;
    end
    %noSlipVehicleLPV
    %
    %   states = [d xi v_x omega_z]
    %   params = [I_zz kappa m]
    %
    A = noSlipVehicleStateMatrix(x,p);
    B = noSlipVehicleInputMatrix(x,p);
    c = noSlipVehicleMeasuredDisturbance(x,p);
    sys = linearSys(A,B,c);
end