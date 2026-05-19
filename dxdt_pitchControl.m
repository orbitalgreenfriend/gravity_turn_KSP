function xdot = dxdt_pitchControl(t,x,u,params)
  m     = x(1);
  v     = x(2);
  h     = x(3);
  theta = x(4);

  beta  = interp1(u(2,:),u(1,:), t);

  Fmax = [params(1) params(2)];
  Isp  = [params(3) params(4)];
  A    =  params(5);
  g0   =  params(6);
  r0   =  params(7);
  rho0 =  params(8);
  Cd0  =  params(9);

  rho = get_rho_from_y(h);
  Cd  = Cd0*get_pseudoRe(h,v);
  Fmaxnow = Fmax(2) - (rho/rho0)*(Fmax(2)-Fmax(1));
  Ispnow  = Isp(2) - (rho/rho0)*(Isp(2)-Isp(1));
  Fdrag = 0.5*rho*A*Cd*v^2;
  g = g0 * (r0 / (r0+h))^2;

  tdot = (v*sin(beta)) / (r0 + h);
  mdot = -(Fmaxnow) / (Ispnow*g0);
  vdot = (Fmaxnow - Fdrag)/m - g*cos(beta);
  hdot = v*cos(beta);

  xdot = [mdot; vdot; hdot; tdot];
end
