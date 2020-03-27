%% Constraint function
%  Output:
%        cineq ... values of inequality constraints (<= 0)
%        ceq   ... values of equality constraints
%  NOTE: Inequality constraints are evaluated for <= 0
%        e.g. the inequality x(1) * x(2) >= 10
%             becomes        -x(1) * x(2) + 10 <= 0
%  @author Rafael Anderka, Ewan Shek HypED 2019

function [cineq, ceq, clear, max_heightClear] = constraints(controlpoints,params)
    %% Params
    numberOfCineqChassis = 5;  % Number of inequality constraints for chassis (may affect accuracy)
    numberOfCineqMounting = 5; % Number of inequality constraints for mounting brackets
    
    startToBattery = params.mountingStart - params.chassisStart;
    batteryToEnd = params.chassisEnd - params.mountingEnd;
    ratio = startToBattery / batteryToEnd;
    numberOfCineqStart = floor(ratio * numberOfCineqChassis);
    numberOfCineqEnd = numberOfCineqChassis - numberOfCineqStart;
    
    plotMaxX = params.tail + 200;    % Plot axis dimensions
    plotMinX = params.head - 200;
    plotMaxY = params.tail + 200;
    plotMinY = params.head - 200;
    
    % Calculate bezier curve for given interval
    [bezierX,bezierY,bezierCPX,bezierCPY] = bezier(controlpoints,params);
    
    
    %% Equality constraints
    
    ceq = []; % None because start and end points are fixed
    
    %% Inequality constraints
    % Set up loop and pre-allocate memory for inequality constraints
    cineqX = zeros(1,(numberOfCineqChassis + numberOfCineqMounting + 2));
    cineq  = zeros(1,(numberOfCineqChassis + numberOfCineqMounting + 2));

    % Populate intermediate inequality constraints for start
    %{
    dx = startToBattery / numberOfCineqStart;
    x = params.chassisStart;
    for i = 1:(numberOfCineqStart)
        % Find closest index to given x
        [~, index] = min(abs(bezierX-x));
        cineq(i) = - (bezierY(index) - params.chassisHeight);   % Inequality constraint voilated if greater than 0
        cineqX(i) = bezierX(index);
        x = x + dx;
    end
    %}
    
        % Populate intermediate inequality constraints for mounting
    dx = params.mountingLength / (numberOfCineqMounting-1);
    x = params.mountingStart;
    for i = 1:(numberOfCineqMounting)
        % Find closest index to given x
        [~, index] = min(abs(bezierX-x));
        cineq(i) = -(bezierY(index) - params.mountingHeight);
        cineqX(i) = bezierX(index);
        x = x + dx;
    end
    
    x = x - (dx);
    
    % Populate intermediate inequality constraints for end
    dx = batteryToEnd / (numberOfCineqEnd);
    x = x + 1;
    for i = (numberOfCineqMounting + 1):(numberOfCineqMounting + numberOfCineqChassis)
        % Find closest index to given x
        [~, index] = min(abs(bezierX-x));
        cineq(i) = - (bezierY(index) - params.chassisHeight);
        cineqX(i) = bezierX(index);
        x = x + dx;
    end
    
    % Calculate vertical distance between chassis end and pod
    [~, index] = min(abs(bezierX-params.chassisEnd));
    clear = bezierY(index) - params.chassisHeight;
    
    max_heightClear = max(bezierY) - params.mountingHeight;
    
    %{
    % Populate intermediate inequality constraints for mounting
    dx = params.mountingLength / (numberOfCineqMounting-1);
    x = params.mountingStart;
    for i = (numberOfCineqChassis + 1):(numberOfCineqChassis + numberOfCineqMounting)
        % Find closest index to given x
        [~, index] = min(abs(bezierX-x));
        cineq(i) = -(bezierY(index) - params.mountingHeight);
        cineqX(i) = bezierX(index);
        x = x + dx;
    end
       %}
    
    
    % Constrain maximum pod height
    cineq((numberOfCineqChassis + numberOfCineqMounting + 1)) = (max(bezierY) - params.maxY);
    
    % Constrain max height to mounting height
   cineq((numberOfCineqChassis + numberOfCineqMounting + 2)) = -(max(bezierY) - params.mountingHeight);
   
    %{
    % Stay close to chassis at start and reinforce start
    [~, chassisStartIndex] = min(abs(bezierX - params.chassisStart)); % Find closest index to chassis end
    cineq((numberOfCineqChassis + numberOfCineqMounting + 2)) = - (bezierY(chassisStartIndex) - (params.mountingHeight));
    cineq((numberOfCineqChassis + numberOfCineqMounting + 3)) = - (bezierY(chassisStartIndex-1) - params.mountingHeight); % Also consider point to the left of the start position since bezier can be inaccurate
    %{
    
    % Stay close to chassis at end and reinforce end
    [~, chassisEndIndex] = min(abs(bezierX - params.chassisEnd)); % Find closest index to chassis end
    cineq((numberOfCineqChassis + numberOfCineqMounting + 2)) = bezierY(chassisEndIndex) - (params.chassisHeight + 15);
    cineq((numberOfCineqChassis + numberOfCineqMounting + 3)) = - (bezierY(chassisEndIndex+1) - params.chassisHeight); % Also consider point to the right of the end position since bezier can be inaccurate
    
    %
    % Stay close to baterry module at start
    [~, mountingStartIndex] = min(abs(bezierX - params.mountingStart)); % Find closest index to chassis end
    cineq((numberOfCineqChassis + numberOfCineqMounting + 6)) = bezierY(mountingStartIndex) - (params.mountingHeight + 15);
    
    % Stay close to baterry module at end
    [~, mountingEndIndex] = min(abs(bezierX - params.mountingEnd)); % Find closest index to chassis end
    cineq((numberOfCineqChassis + numberOfCineqMounting + 7)) = bezierY(mountingEndIndex) - (params.mountingHeight + 50);
%}
    %}
    %% Plot
    currentfig = gcf;
    if currentfig.Number ~= 2
        figure(2);
    end
    clf; hold on; grid on;
    
    % Plot bezier curve and control points
    plot(bezierX, bezierY, 'Color','blue');
    plot(bezierCPX, bezierCPY, 'Color', 'blue','LineStyle','--');
    
    % Plot limits
    line([params.head params.tail],[0 0],'Color','black');
    line([params.head params.tail],[params.maxY params.maxY],'Color','red');
    line([params.chassisStart params.chassisEnd],[params.chassisHeight params.chassisHeight],'Color','black');
    line([params.chassisStart params.chassisStart],[0 params.chassisHeight],'Color','black');
    line([params.chassisEnd params.chassisEnd],[0 params.chassisHeight],'Color','black');
    
    line([params.mountingStart params.mountingEnd],[params.mountingHeight params.mountingHeight],'Color','black');
    line([params.mountingStart params.mountingStart],[params.chassisHeight params.mountingHeight],'Color','black');
    line([params.mountingEnd params.mountingEnd],[params.chassisHeight params.mountingHeight],'Color','black');
    
    % Set axis
    xlim([plotMinX plotMaxX]);
    ylim([plotMinY plotMaxY]);
    
    % Plot inequality constraint values
    plot(cineqX(1:5),cineq(1:5),'Color','red','LineStyle','--');
    plot(cineqX(6:11),cineq(6:11),'Color','red','LineStyle','--');
    %plot(params.chassisStart,cineq(12),'*','Color','red','LineStyle','--');
    %plot(cineqX((numberOfCineqChassis +1):(numberOfCineqChassis + numberOfCineqMounting)),cineq((numberOfCineqChassis +1):(numberOfCineqChassis + numberOfCineqMounting)),'Color','red','LineStyle','--');
    
    % Draw plot while running
    drawnow;
end