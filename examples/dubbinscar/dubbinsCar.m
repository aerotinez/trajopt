function x_dot = dubbinsCar(x,u,p)
px = x(1,:);
py = x(2,:);
yaw = x(3,:);
yaw_rate = x(4,:);
vx = p(1,:);

x_dot = [
    vx.*cos(yaw);
    -vx.*sin(yaw);
    yaw_rate;
    u
    ];