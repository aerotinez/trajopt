classdef SharpMotorcycleParameters < handle
properties (Access = public)
Cdelta
Cf1
Cf2
Cr1
Cr2
Crxz
Ifx
Ifz
Irx
Irz
Zf
a
an
b
e
f
g
h
ify
iry
mf
mr
rf
rr
sigma
varepsilon
end
properties (Access = private)
j
k
end
methods (Access = public)
function params = list(obj)
obj.j = sin(obj.varepsilon)*obj.a - cos(obj.varepsilon)*obj.f + sin(obj.varepsilon)*obj.e;
obj.k = obj.a*cos(obj.varepsilon) + obj.f*sin(obj.varepsilon) + cos(obj.varepsilon)*obj.e;
params = [
obj.Cdelta;
obj.Cf1;
obj.Cf2;
obj.Cr1;
obj.Cr2;
obj.Crxz;
obj.Ifx;
obj.Ifz;
obj.Irx;
obj.Irz;
obj.Zf;
obj.a;
obj.an;
obj.b;
obj.e;
obj.g;
obj.h;
obj.ify;
obj.iry;
obj.j;
obj.k;
obj.mf;
obj.mr;
obj.rf;
obj.rr;
obj.sigma;
obj.varepsilon
];
end
end
end