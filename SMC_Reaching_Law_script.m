function smc_simulation()
    % 파라미터
    c = 15;
    k = 10;
    N = 0.5;
    b = 133;

    % 시뮬레이션 시간
    tspan = [0 10];
    x0 = [-0.15; 0.15];

    % 기준 입력
    xd  = @(t) sin(1 * t);                     % 기준 입력
    dx1 = @(t) 1 * cos(1 * t);
    dx2 = @(t) -sin(1 * t);

    % 외란
    d_func = @(t) 10.1;

    % 시뮬레이션
    [t, x] = ode45(@(t, x) speed_tracking(t, x, xd, dx1, dx2, d_func, c, k, N, b), tspan, x0);

    % 결과 그래프
    figure;
    subplot(3,1,1);
    plot(t, x(:,1), 'b', t, arrayfun(xd, t), 'r--');
    legend('x_1 (position)', 'x_d');
    title('Position Tracking');
    grid on;

    subplot(3,1,2);
    plot(t, x(:,2), 'b', t, arrayfun(dx1, t), 'r--');
    legend('x_2 (Speed)', 'dx1');
    title('Speed Tracking');
    grid on;

    subplot(3,1,3);
    u = arrayfun(@(ti, xi1, xi2) control_input(ti, [xi1; xi2], xd, dx1, dx2, c, k, N, b), t, x(:,1), x(:,2));
    plot(t, u, 'k');
    title('Control Input');
    xlabel('Time (s)');
    grid on;
end

function dx = speed_tracking(t, x, xd, dx1, dx2, d_func, c, k, N, b)
    x1 = x(1);
    x2 = x(2);

    x_d = xd(t);
    d_x1 = dx1(t);
    d_x2 = dx2(t);
    d = d_func(t);

    e = x_d - x1;
    de = d_x1 - x2;
    s = c*e + de;

    u = (1/b) * (d_x2 + 25*x2 + k*s + N*sign(s));

    dx = zeros(2,1);
    dx(1) = x2;
    dx(2) = -25*x2 + b*u + d;
end

function u = control_input(t, x, xd, dx1, dx2, c, k, N, b)
    x1 = x(1); x2 = x(2);
    x_d = xd(t);
    d_x1 = dx1(t);
    d_x2 = dx2(t);

    e = x_d - x1;
    de = d_x1 - x2;
    s = c*e + de;

    u = (1/b) * (d_x2 + 25*x2 + k*s + N*sign(s));
end
