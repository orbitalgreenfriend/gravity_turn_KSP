% contains routines for reading standard atmospheric data
% and extracting useful values based on height

1;
global atm; 
atm = load("atmosphere_data.mat");

function rho = get_rho_from_y(y)
  global atm;
  rho = atm.rhofunc(y,atm.rhofit);
  below_0 = find(y < 0);
  rho(below_0) = atm.rhofunc(0,atm.rhofit);
  above_atm = find(y > 70000);
  rho(above_atm) = 0;
end

function temp = get_temp_from_y(y)
  global atm;
  temp = interp1(atm.Tmodel_alts, atm.T_modeled, y);
  below_0 = find(y < 0);
  temp(below_0) = interp1(atm.Tmodel_alts, atm.T_modeled, 0);
end

function pseudoRe = get_pseudoRe(y,v)
  global atm;
  neg = find(y<0);
  y(neg) = 0;
  rho = get_rho_from_y(y);

  % horrendously klugey way of getting drag to kind of work
  mach      = abs(v) ./ interp1(atm.Tmodel_alts, atm.c, y);
  p         = [     16.7,       6.5,        1,        2.8,     -3.9];
  pseudoRe  = (tanh(p(1)*mach-2*p(2))+2) - (p(3)*tanh(p(4)*mach+p(5))+p(3));

  rhowgt    = 0.67;
  machwgt   = 0.33;
  rhofrac   = rho/get_rho_from_y(0);
  pseudoRe .*= (rhofrac*rhowgt + mach*machwgt/3) / (rhowgt+machwgt);

  % set anything in vacuum to zero
  nodrag = find(y >= 70000);
  pseudoRe(nodrag) = 0;
end
