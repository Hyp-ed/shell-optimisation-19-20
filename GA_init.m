% Establish the MATLAB & COMSOL server connection
HOME = pwd;                                       % Store home directory
cd('/Applications/COMSOL54/Multiphysics/mli');    % mli = MATLAB LiveLink Interface
mphstart(2036);                                   % Port 2036
cd(HOME);                                         % Return COMSOL server window to home

% Import COMSOL classes
import com.comso.model.*
import com.comso.model.util.*

% Load COMSOL model
model = mphload('ShellTopCurve_2D_CFD.mph');
