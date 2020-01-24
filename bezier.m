function [x, y, x_controlpoints, y_controlpoints] = bezier(p,params)
% BEZIER Calculates x and y coordinates of bezier curve
% Input: n x 2 matrix of control points (x,y)

%% Params
n = params.n;                           % Number of control points
sigma = zeros(1,n);                       % Initialize sigma array to calculate factorials

p = [[params.head params.baseY], ...    % Fix start and end points
     p, ...
     [params.tail params.baseY]];    

p = transpose(reshape(p,[2,n]));        % Convert list of parameters to control point x-y-pairs

%% Caluclate factorials
%  and store in sigma
for i = 1 : n
    sigma(i) = factorial(n - 1) / (factorial(i - 1) * factorial(n - i));  % For calculating (x!/(y!(x-y)!)) values 
end

%% Calculate coordinate arrays
l = [];
UB = [];

for u = 0 : 0.005 : 1
    for d = 1 : n
        UB(d) = sigma(d) * ((1 - u)^(n - d)) * (u^(d - 1));
    end
    l=cat(1,l,UB);
end

P = l * p;

% Plot curve
%line(P(:,1),P(:,2))
%line(p(:,1),p(:,2))

x = P(:,1);
y = P(:,2);
x_controlpoints = p(:,1);
y_controlpoints = p(:,2);

end

