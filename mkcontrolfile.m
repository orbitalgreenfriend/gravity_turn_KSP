clear;

load("pitchcontrols.mat");
interval = 2; % in sec; how much time should be between control points

outfile = fopen("controls.ks","w");

fprintf(outfile, "// generated on %s for %s.\n", date, ves_name);
fprintf(outfile, "set tgt_ap to %.0f.\n", tgt_ap);
fprintf(outfile, "set y to list(%.1f",alts(1));
for i = 2:interval/step_size:length(alts)
	fprintf(outfile,",%.1f",alts(i));
end

fprintf(outfile, ").\nset beta to list(%.1f",betas(1));
for i = 2:interval/step_size:length(betas)
	fprintf(outfile,",%.1f",betas(i));
end
fprintf(outfile,").");

fclose(outfile);
