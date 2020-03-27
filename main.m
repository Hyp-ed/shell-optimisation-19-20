%% Genetic algorithm for minimizing drag of shell crossection
%  @author Rafael Anderka, Ewan Shek HypED 2019
clc; clear; close all; figure(2);

%% Setup
% Import LiveLink modules
import com.comso.model.*
import com.comso.model.util.*

% Parameters
params.n             = 5;                 % Number of control points
params.head          = -1000;             % Fixed head point where y = 0
params.tail          = 1000;              % Fixed tail point where y = 0
params.baseY         = 0;                 % Y displacement of head and tail points
params.maxY          = 400;               % Maximum height (constrained). Height: 375, Width: 330
params.chassisLength = 1500;               % Chassis length + 2 cm spiel
params.maxY          = 450;               % Maximum height (constrained). Height: 375, Width: 330
params.chassisLength = 1500;              % Chassis length + 2 cm spiel
params.chassisHeight = 151;               % Chassis height (Height: 251 (chassis height) - 130 (rail) + 30 (safety) = 151, Width: 260 (inner width) + 19 (shell thickness) + 20 (safety) - 70 (rail opening) = 229
params.chassisStart  = params.head + 200; % Chassis start point
params.chassisEnd    = params.chassisStart + params.chassisLength; % Chassis end point

params.mountingHeight = params.chassisHeight + 150; % Battery top module height
params.mountingStart  = params.chassisStart + 50;   % Battery top module start
params.mountingLength = 1200;                       % Baterry top module length
params.mountingEnd    = params.mountingStart + params.mountingLength; % Battery top module end

%% COMSOL LiveLink
% Establish the MATLAB & COMSOL server connection
%
fprintf("Establishing COMSOL Server LiveLink...\n")
HOME = pwd;                                       % Store home directory
cd('/usr/local/comsol55/multiphysics/mli'); 
% mli = MATLAB LiveLink Interface
try % Catch error if COMSOL Server is already connected
    mphstart('localhost', 2036, 'hyped', 'breakapod');  % Server is running at localhost:2036, also passing credentials
catch ME
    if strcmp(ME.message, 'Already connected to a server')
        fprintf('COMSOL Server already connected\n');
    else
        error(ME.message);
    end
end
cd(HOME); % Return current folder to wd

% Load COMSOL model
fprintf("\nLoading COMSOL model...\n")
model = mphload('2D_CFD_Bezier_Curve.mph');
%}

%% Genetic algorithm
% Formulate optimization problem
fprintf("Formulating GA problem...\n")
problem.solver = 'ga';                                      % Set solver to genetic algorithm
problem.fitnessfcn = @(x)computeAndReturn(x,model,params);  % Fitness function
problem.nvars = 6;                                          % Number of variables
problem.nonlcon = @(x)constraints(x,params);                % Non-linear constraints via constraints function

% Side profile bounds
problem.lb = [      -1000        0       0   -1000         0                0           ]; % Lower bound
problem.ub = [         0        1000  1000   500        params.tail         400          ]; % Upper bound

% Set problem options
problem.options.PopulationSize = 300;                           % Number of parameter sets in population
problem.options.MutationFcn = @mutationadaptfeasible;           % Set mutation function for constrained optimization
problem.options.PlotFcns = {@gaplotbestf, @gaplotmaxconstr};    % Add plot
problem.options.Display = 'iter';                               % Print iterations in command window
%problem.options.OutFunc = optimoptions('ga','OutputFcn',@gaoutfun);

% Run the GA and store final values in x and fval
fprintf("Starting GA...");
[x, fval] = ga(problem);


%% Results
% Print results
fprintf('\nParameters = %s\n', num2str(x));
fprintf('\nf_total = %s\n', num2str(fval));
