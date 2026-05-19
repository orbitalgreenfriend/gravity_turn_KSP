% runs a stage's powered and unpowered phase of flight
% boolean orbitable states whether the stage was found
%   capable of reaching target altitude

function [orbitable, pwrsoln, coastsoln] = test_gTurn(params, state0, burn_time, tgt_ap,m1,step)
	% define solver parameters
	opts2 = odeset('Events', @(t,x) massEvent(t,x,m1), ...
		       'MaxStep', step, ...
		       'InitialStep', step);
	opts3 = odeset('Events', @(t,x) tgtAltReached(t,x,tgt_ap), ...
		       'MaxStep', step, ...
		       'InitialStep', step);

  clear pwrsoln coastsoln;
	% integrate for powered phase
	pwrsoln   = ode45(@(t,x) dxdt(t,x,1,params), [0:burn_time], state0, opts2);
	% integrate for coast phase
	coastsoln = ode45(@(t,x) dxdt(t,x,0,params), [0:400], pwrsoln.y(:,end), opts3);
  % checking pwrsoln state is necessary, since it is possible for a stage to fly
  % ... powered through the target apoapsis
	if isempty(coastsoln.xe) && all(pwrsoln.y(4,:) < tgt_ap)
		orbitable = false;
	else
		orbitable = true;
	end
end

