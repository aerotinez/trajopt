classdef lgps < trajopt.trajectory.Trajectory
    methods (Access = public)
        function obj = lgps(varargin)
            obj@trajopt.trajectory.Trajectory(varargin{:});
            nu = size(obj.Controls,2);
            np = size(obj.Parameters,2);
            switch size(obj.States,1) - size(obj.Controls,1)
                case 1
                    switch varargin{1}.IncludedEndPoint
                        case -1
                            obj.Controls = [
                                obj.Controls;
                                nan(1,nu)
                                ];
        
                            obj.Parameters = [
                                obj.Parameters;
                                nan(1,np)
                                ];
                        case 1
                            obj.Controls = [
                                nan(1,nu);
                                obj.Controls
                                ];
        
                            obj.Parameters = [
                                nan(1,np);
                                obj.Parameters
                                ];
                    end
                case 2
                    obj.Controls = [
                        nan(1,nu);
                        obj.Controls;
                        nan(1,nu)
                        ];

                    obj.Parameters = [
                        nan(1,np);
                        obj.Parameters;
                        nan(1,np)
                        ];
            end
        end
    end
    methods (Access = protected)
        T = transposeTimeDomain(obj,t);
        x = interpolateStates(obj,t);
        u = interpolateControls(obj,t);
    end
end