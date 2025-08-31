function defect(obj)
    arguments
        obj (1,1) directcollocation.Trapezoidal;
    end
    N = obj.NumIntervals;
    h = diff(obj.Mesh)*(obj.FinalTime - obj.InitialTime);

    for k = 1:N
        xk = obj.States(:,k);
        xkp1 = obj.States(:,k + 1);
        uk = obj.Controls(:,k);
        ukp1 = obj.Controls(:,k + 1);

        if obj.NumParameters > 0
            pk = obj.Parameters(:, k);
            pkp1 = obj.Parameters(:, k+1);
        else
            pk   = casadi.DM([]);
            pkp1 = casadi.DM([]);
        end

        fk = obj.Plant(xk,uk,pk);
        fkp1 = obj.Plant(xkp1,ukp1,pkp1);

        obj.Problem.subject_to(xkp1 - xk == (1/2)*h(k)*(fk + fkp1));
    end
end