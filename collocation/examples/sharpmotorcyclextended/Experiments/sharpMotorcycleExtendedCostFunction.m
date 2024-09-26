function f = sharpMotorcycleExtendedCostFunction(plant,params)
    arguments
        plant (1,1) function_handle;
        params (1,1) BikeSimMotorcycleParameters;
    end
    JY = lateralForce(plant);
    Ja = slip(params);
    Ju = control();
    f = @(x,u,p)0.*(JY(x,u,p) + Ja(x,u,p)) + Ju(x,u,p);
end

function JY = lateralForce(plant)
    f8 = @(x)x(8,:);
    f9 = @(x)x(9,:);
    JYr = @(x,u,p)f8(plant(x,u,p));
    JYf = @(x,u,p)f9(plant(x,u,p));
    JY = @(x,u,p)sum(1E-09.*(JYr(x,u,p).^2 + JYf(x,u,p).^2));
end

function Ja = slip(params)
    p = bikeSimToSharp(params);
    a = p.a;
    an = p.an;
    b = p.b;
    caster = p.varepsilon;
    c = cos(caster);
    l = (a - an)./c;
    ar = @(x)(1./x(6,:)).*(b.*x(5,:) - x(7,:));
    af = @(x)-(1./x(6,:)).*(x(7,:) + l.*x(5,:) - an.*x(9,:) + x(4,:)).*c;
    Ja = @(x,u,p)sum(1E05.*(ar(x) - af(x)).^2);
end

function Ju = control()
    frr = @roadRelativeKinematics; 
    fr = @(x,p)frr([0.*x(1,:);x(1:2,:)],x([6,7,5],:),p);
    ds = @(x,p)[1,0,0]*fr(x,p);
    Ju = @(x,u,p)sum(sum(u(1:2,:).^2,1)./ds(x,p));
end
