%% Fitness function
%  This function is minimized by the GA
%  @author Rafael Anderka, HypED 2018

function y = fitnessFunction (x)
    %  Replace with drag function
    y = 100 * (x(1)^2 - x(2)) ^2 + (1 - x(1))^2;
end