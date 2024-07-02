classdef PrettyEquations
    properties (GetAccess = public, SetAccess = private)
        Equations;
        q;
        v;
        a;
        j;
        s;
        params;
    end
    properties (Access = private)
        eq_in;
        q_in;
        v_in;
        a_in;
        j_in;
        s_in;
    end
    methods (Access = public)
        function obj = PrettyEquations(eqs)
            obj.eq_in = eqs;
            obj.params = extractParameters(obj);
            obj.q_in = extractDynamicVariables(obj);
            obj.v_in = diff(obj.q_in);
            obj.a_in = diff(obj.v_in);
            obj.j_in = diff(obj.a_in);
            obj.s_in = diff(obj.j_in);
            
            obj.q = dynamicVariableToSym(obj);

            f = @(dstr)arrayfun(@(x)diffToDot(obj,x,dstr),obj.q);
            obj.v = f("dot");
            obj.a = f("ddot");
            obj.j = f("tdot");
            obj.s = f("qddot");

            ovars = [
                obj.s_in;
                obj.j_in;
                obj.a_in;
                obj.v_in;
                obj.q_in;
                ];

            nvars = [
                obj.s;
                obj.j;
                obj.a;
                obj.v;
                obj.q;
                ];

            obj.Equations = subs(obj.eq_in,ovars,nvars);
        end
    end
end