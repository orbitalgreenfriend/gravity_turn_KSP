function dv = stage_dv(soln, Isp)
	rho0 = get_rho_from_y(0);
	g0 = 9.81;
	
	dv = 0;
	for i = 2:length(soln.x)
		rho = get_rho_from_y(soln.y(4,i));
		Ispnow  = Isp(2) - (rho/rho0)*(Isp(2)-Isp(1));
		dv = dv + Ispnow*g0 * log(soln.y(1,i-1)/soln.y(1,i));
	end
end
