function [value, isterminal, direction] = tgtAltReached(t,x,tgt_ap)
	value = x(4) - tgt_ap;
	isterminal = 1;
	direction = 0;
end
