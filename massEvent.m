function [value, isterminal, direction] = massEvent(t,x,m1)
	value = x(1) - m1;
	isterminal = 1;
	direction = 0;
end
