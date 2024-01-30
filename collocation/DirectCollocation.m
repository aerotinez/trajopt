classdef DirectCollocation
    properties (GetAccess = public, SetAccess = private)
        Defect function_handle;
        MeshSize (1,1) double;
        IsInitialTimeFree (1,1) logical = true;
        IsFinalTimeFree (1,1) logical = true;
    end
    properties (Access = private)
        InitialTime;
        FinalTime;
        NumStates;
        NumControls;
    end
    methods (Access = public)
        function obj = DirectCollocation(method,ocp,mesh_size)
            arguments
                method function_handle;
                ocp OptimalControlProblem;
                mesh_size (1,1) double = 20;
            end
            f = ocp.DynamicConstraints.Dynamics;
            obj.Defect = @(x0,u0,xf,uf,h)method(f,x0,u0,xf,uf,h);
            obj.MeshSize = mesh_size;
            obj.IsInitialTimeFree = isequal(class(ocp.InitialTime),"sym");
            obj.IsFinalTimeFree = isequal(class(ocp.FinalTime),"sym");
            if ~obj.IsInitialTimeFree
                obj.InitialTime = ocp.InitialTime;
            end
            if ~obj.IsFinalTimeFree
                obj.FinalTime = ocp.FinalTime;
            end
            obj.NumStates = ocp.DynamicConstraints.NumStates;
            obj.NumControls = ocp.DynamicConstraints.NumControls;
        end
    end
    methods (Access = private)
        function t0 = unpackInitialTime(obj,z)
            t0 = obj.InitialTime;
            if obj.IsInitialTimeFree
                t0 = z(1);
            end
        end
        function tf = unpackFinalTime(obj,z)
            tf = obj.FinalTime;
            if obj.IsInitialTimeFree && obj.IsFinalTimeFree
                tf = z(2);
                return
            end
            if obj.IsFinalTimeFree && ~obj.IsInitialTimeFree
                tf = z(1);
            end
        end
        function y = unpackDefects(obj,z)
            N = obj.MeshSize;
            nx = obj.NumStates;
            nu = obj.NumControls;
            y = reshape(z(end - (nx + nu)*N + 1:end),[],N);
        end
        function x = unpackStates(obj,z)
            y = obj.unpackDefects(z);
            x = y(1:obj.NumStates,:);
        end
        function u = unpackControls(obj,z)
            y = obj.unpackDefects(z);
            u = y(obj.NumStates + 1:end,:);
        end
        function Ceq = defectConstraints(obj,z)
            t0 = obj.unpackInitialTime(z);
            tf = obj.unpackFinalTime(z);
            x = obj.unpackStates(z);
            u = obj.unpackControls(z);
        end
    end
end