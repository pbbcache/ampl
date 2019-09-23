/*********************************************
 * AMPL cachepart Model
 * Authors: Jose Luis Risco Martin, Adrian Garcia Garcia
 *********************************************/
 
/* Parameters */
/* Constants: */
set APPS; /* Applications */
param N = card(APPS);
param K > 0 integer;
param rK {1..K};
/* Curves from sim CSV */
param IPCk {APPS,1..K}; # IPC curve for each app 
param Bak {APPS,1..K}; # Bandwidth
param Stk {APPS,1..K}; # stalls_total
param Smk {APPS,1..K}; # stalls_mem 

/* Computed params */
# IPC alone of each app with all ways available
param IPCa {a in APPS} = IPCk[a,K];
# Slowdown curve for each app
param Sck {a in APPS, k in 1..K} = (IPCa[a] / IPCk[a,k]);

# Model variables
var Ba {APPS};
var Bs {APPS};
var Sc {APPS};
var Sb {APPS};
var St {APPS};
var Sm {APPS};
var S {APPS};
# Boolean matrix of assigned ways (default 0 -> Way not assigned)
var W {APPS, k in 1..K} binary;
# Sum of Ba of each app
var T;
#var Smax;
#var Smin;

/*Optimization goal: minimize Unfairness*/
minimize Unfairness:
	sum{a in APPS} S[a];


/* Linear equations*/
subject to TotalBandwidth:
  T = sum {a in APPS, k in 1..K} Bs[a];

subject to all_W {a in APPS, k in 1..K}:
  0<= W[a,k] <= 1;

subject to AllAppsHaveWay {a in APPS}: 
  sum{k in 1..K} W[a,k] = 1;

subject to AllWaysAssigned:
  sum {a in APPS, k in 1..K} k * W[a,k] = K;

subject to AssignedWays {a in APPS}:
  1 <= sum {k in 1..K} k * W[a,k] <= K - N + 1;

#subject to minS {a in APPS}:
#  Smin <= S[a];

#subject to maxS {a in APPS}:
#  Smax >= S[a];

subject to all_Ba {a in APPS}:
  Ba[a] = sum {k in 1..K} Bak[a,k] * W[a,k];

subject to all_Sc {a in APPS}:
  Sc[a] = sum {k in 1..K} Sck[a,k] * W[a,k];

subject to all_St {a in APPS}:
  St[a] = sum {k in 1..K} Stk[a,k] * W[a,k];

subject to all_Sm {a in APPS}:
  Sm[a] = sum {k in 1..K} Smk[a,k] * W[a,k];

/* Non-linear equations */
subject to morad {a in APPS}: 
  (Bs[a]*Bs[a]*Ba[a]*T)-(Bs[a]*Bs[a]*T+Bs[a]*Ba[a]*T)-(Bs[a]*T-Bs[a]*Ba[a]+Bs[a]) = Ba[a] - Ba[a]*T;

subject to Slowdown_bandwidth {a in APPS}:
  Sb[a]*St[a]*Ba[a] = St[a]*Ba[a] + Sm[a]*Bs[a]-Sm[a]*Ba[a];

subject to Slowdown_combined {a in APPS}:
  S[a] = Sc[a] * Sb[a];
