function data = parse_rbr_duet(f_in)
  data = struct();
%  [rbr,dbid] = RSKopen(f_in); % This line crashed on Duet 82492
%  SUNRISE22, fixing with the line below - AJM
  rbr = RSKopen(f_in);
  tmp = RSKreaddata(rbr);
  data.dn = tmp.data.tstamp;
  data.T = tmp.data.values(:,1); % Changed to upper case T for code to work - AJM
  data.P = tmp.data.values(:,2); % Changed to upper case P for code to work - AJM 22-06-22
end