function [ f_total ] = computeAndReturn(controlpoints, model, params)
    % Input the polynomial parameters to comsol, compute the study, and return
    % the drag coeffificient.

    % Console output
    fprintf("\nTrying: [ %.0f  %.0f ; %.0f  %.0f ; %.0f  %.0f ]\n", ...
            controlpoints(1), controlpoints(2), controlpoints(3), controlpoints(4), controlpoints(5), controlpoints(6));
    
    %{
    %% Set COMSOL parameters 
    % Arguments: 'parameter name', parameter value

    % Fix starting and end points
    model.param.set('x0',  params.head);
    model.param.set('y0',  params.baseY);
    model.param.set('x4',  params.tail);
    model.param.set('y4',  params.baseY);

    % Set GA controled points
    model.param.set('x1',  controlpoints(1));
    model.param.set('y1',  controlpoints(2));
    model.param.set('x2',  controlpoints(3));
    model.param.set('y2',  controlpoints(4));
    model.param.set('x3',  controlpoints(5));
    model.param.set('y3',  controlpoints(6));

    % Run the study and catch errors
    try
        model.study('std1').run;

        % Get the results line integral and return total force (pressure + viscous)
        forces = model.result.numerical('int2').getReal();
        f_total = forces(2);

        figure(1);
        mphplot(model, 'pg2');
        ylim([-100 1500]);
        drawnow;

        % Print total force
        fprintf("  => %.2f N/m\n", f_total);
    catch ME
        % Set drag ridiculously high if we get an error
        f_total = 999999;

        % Print total force
        fprintf("  => ERROR");
    end
    

    

    %}
    % Calculate faux fitness score (as close to x-axis as possible)
    % alternatively: f_total = max(bezierY);

    % Calculate bezier curve for given interval
    [bezierX,bezierY,~,~] = bezier(controlpoints,params);
    
    f_total = 0;
    [~,indexStart] = min(abs(bezierX-params.chassisStart));
    [~,indexEnd] = min(abs(bezierX-params.chassisEnd));
    for i = 1 : indexStart
        f_total = f_total + bezierY(i);
    end
    for i = indexEnd : length(bezierX)
        f_total = f_total + bezierY(i);
    end
    title(f_total);
    fprintf("  => %.0f\n", f_total);
    
end
