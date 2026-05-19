% pre-run cleanup
clear; close all; rehash;

% =========================  %
% USER:                      %
%      enter vehicle data    %
% =========================  %
vehicle_datafile = "toucan1a.m";

% =========================  %
% USER:                      %
%      targets and settings  %
% =========================  %
tgt_ap      = 85000; % desired orbit altitude (m)
pitch_start = 5;  % when to start active pitchover (s)
gturn_start = 20; % how long active pitchover should take (s)
beta0       = 5;  % initial pitchover angle
step_size   = 1;  % solver stepsize


% ========================= %
% run setup tasks           %
% ========================= %
% attempt to load vehicle data
type = exist(vehicle_datafile,"file");
if type == 2
  run(vehicle_datafile);
else
  printf("Invalid vehicle datafile specified. Exiting.\n");
end
% load atmosphere-related routines
atmosphere;
% set body constants (Kerbin)
g0   = 9.81;
r0   = 600e3;
mu   = 3.5316e12;
rho0 = get_rho_from_y(0);
% perform unit conversions
beta0 = beta0*pi/180; % convert to rads
m0 = m0*1e3;
m1 = m1*1e3;
Fmax = Fmax*1e3;
% construct pitchover controls profile
pitch_control = [ 0 0           beta0;         % times
		              0 pitch_start gturn_start ]; % commanded pitches
% set solver step size
opts1 = odeset('MaxStep',step_size);
% ========================= %
% launch/initial ascent     %
% ========================= %
% assemble and define vehicle parameters
stages = rows(m0);
params = zeros(stages, 9);
for i = 1:stages
	params(i,:) = [ Fmax(i,:), Isp(i,:), A(i), g0, r0, rho0, Cd0(i) ];
end
v0     = 0.01;
theta0 = 0;

% begin flying the vehicle straight-up according to active pitch controls
asc = ode45(@(t,x) dxdt_pitchControl(t,x,pitch_control,params(1,:)), ...
            [0:step_size:gturn_start], ...
            [m0(1),v0,h0,theta0], ...
            opts1);
asc.y = [ asc.y(1,:);
    	  asc.y(2,:);
    	  interp1(pitch_control(2,:),pitch_control(1,:),asc.x);
    	  asc.y(3,:);
    	  asc.y(4,:)   ];


% ========================== %
% gravity turn determination %
% ========================== %
% collect state vector from end of straight-up phase
%                  m                v     beta      h         theta
gturn_state0 = asc.y(:,end);

% load active phase's end state as initial conditions
% set up iteration thru stages
burnout_state0 = gturn_state0;
for i = 1:stages

	% estimate length of burn by taking max efficiency figures
	mdot_best = Fmax(i,2) / (Isp(i,2)*g0);
	tburn = ceil((m0(i)-m1(i))/mdot_best) + 10; % 10 seconds added for margin (who knows)

	% attempt an iteration at max burn time to determine whether a trajectory that reaches target altitude is even feasible
	[is_orbitable, pwr(i), cst] = test_gTurn(params(i,:), burnout_state0, tburn, tgt_ap, m1(i), step_size);
	if is_orbitable
    % set up a binary search for lowest burn duration to target altitude
		possible_ts = 0:step_size:tburn;
		ub = length(possible_ts); lb = 1;
		while ub-lb > 1
			search_ind = floor(mean([ub,lb]));
			[is_orbitable, pwr(i), cst] = test_gTurn(params(i,:), burnout_state0, possible_ts(search_ind), tgt_ap, m1(i), step_size);
			if !is_orbitable
				lb = search_ind;
			else
				ub = search_ind;
			end
		end
		[is_orbitable, pwr(i), cst] = test_gTurn(params(i,:), burnout_state0, possible_ts(ub), tgt_ap, m1(i), step_size);
		break;
	elseif !is_orbitable && i < stages
    % load end conditions into initial conditions for next stage's run
		burnout_state0 = [ m0(i+1), pwr(i).y(2,end), pwr(i).y(3,end), pwr(i).y(4,end), pwr(i).y(5,end) ];
	else
		printf("No orbitable solution found.\n");
	end

end

% concatenate all phases of flight
stages = length(pwr); % update number of stages to reflect those used
for i = 1:stages
	if i == 1
		pwr(i).x = pwr(i).x + asc.x(end);
	else
		pwr(i).x = pwr(i).x + pwr(i-1).x(end);
	end
end
cst.x = cst.x + pwr(end).x(end);


% ============================ %
% post-processing/presentation %
% ============================ %
mkplots;

% don't bother with anything else
if !is_orbitable
	return;
end

% assemble delta v information
dv(1) = stage_dv(asc, Isp(1,:))+stage_dv(pwr(1), Isp(1,:));
for i = 1:stages
	dv(i) = stage_dv(pwr(i), Isp(i,:));
end
dv_remaining = Isp(stages,2)*g0*log(pwr(stages).y(1,end)/m1(stages));
% display some simulation outcomes
printf("Found orbitable solution.\n");
printf("  Stage %i: expended %.0f m/s delta v.\n", 1, dv(1));
for i = 2:stages
	printf("  Stage %i: expended %.0f m/s delta v.\n", i, dv(i));
end
printf("           %.0f m/s remains (%.0f percent propellant).\n", dv_remaining, 100 - (m0(stages)-pwr(stages).y(1,end))/(m0(stages)-m1(stages))*100);
circ_dv =  sqrt(mu/(tgt_ap + r0)) - cst.y(2,end);
printf("           %.0f m/s are required for orbital circularization.\n", circ_dv);
printf("             This leaves %.0f m/s available following circularization.\n", dv_remaining-circ_dv);
printf("  Forecasted total of %.0f m/s delta v required for orbit.\n", circ_dv + sum(dv));

% format altitude and pitch angle data into one place
alts = [ asc.y(4,:) ]; betas = [ asc.y(3,:) ];
for i = 1:stages
	alts  = [ alts  pwr(i).y(4,:) ];
	betas = [ betas pwr(i).y(3,:) ];
end
alts  = [ alts  cst.y(4,:) ]; betas = [ betas cst.y(3,:) ]*180/pi; % convert to degrees for controller
% write that data
save("pitchcontrols.mat","alts","betas","step_size","tgt_ap","ves_name");

% write a .ks file containing pitch schedule
% output is "controls.ks"
mkcontrolfile;
