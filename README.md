## Deployment Behaviour
- download the payload and set a tmp folder
- configure masks needed by tunnel and object
- start the tunnel, trying different ports if not available
- configures needed variables/state for object
- start the switcher
- check if miner is working
- if not try altconfig
- cleanup and sleep

## Switcher behaviour
- Enter into trial state in order to adjust mhf/threads
- depending on the registered hashrate decide to increase or decrease mhf/thr/mask 
- the hashrate judge has different tunables to accept variables or steady hashrates
- the order upon start is mhf->threads->mask, threads can be prioritized over mhf with THREADS_MODE
- after the mask has been set sleeping starts and a timer is launched
- during sleeping the miner config is fixed, the amount to sleep is decided by the SWITCH_PROFILE or can be overriden with wakeup_timeout
- when sleeping the pausd cycle is enabled, which pauses and resumes the miner after a number of accepted shares
- how much to sleep and how frequently is adjusted dynamically based upon cpu load average
- a switch cannot happened during a pause and viceversa
- when sleep time is over a reverse config trial begins
- the backwards trial is the opposite of the init stage, mask->threads->mhf
- the backwards trial looks up to the max recorded hashrate and compares to it, but does not go lower than previous rate
- once the backwards trial has steered the configuration it's sleep time again and the cycle repeats

## Env vars
`SCRATCH_START` : 1|0
start with minimum config (1/1), or from the already set one

`SWITCH_PROFILE` : HOT|WARM|COLD|DEFAULT
how fast to determine the config

`SWITCH_STATE` : all available states...
the initial state of the switcher state machine

`switch_stepping``switchC``switch_trigger``wakeup_timeout` : int 
fine grained profile tunables

`LOWRATE` : int 2..
denominator for determining the base limit

`HYSTRATE` : int 1..
Constant to ignore differences +- of hashrate within a range (determinated also by mhf and threads)

`OBJ_MASK` : strings in cfg/obj.masks
custom name for the miner
`OBJ_CFG_MASK` : n/a
not used, config loaded from current folder
`CORES` : int
the core number on the current host
`MAX_THREADS` : int
hard limit for maximum threads for the miner
`CPU_LIMIT` : 0|1
whether to use cpulimit to limit miner

`PAUSD_VER` : int 1..5
the mhf to use

`PAUSD_THREADS` : int
applied only if ARGS

`PAUSD_SHARES` : int 1..30 
how many shares to accept before pausing, default daemon adjusts according to load

`PAUSD_RATE` : int 50..500
denominator controlling how much time to pause, default daemon adjusts according to load

`ID` : string
id of the current miner

`AL` : cryptonight|cryptonight-light 
algo for the miner

`PA` : string
the wal address

`ENDPOINT`,`ENDPOINT_ALT` : ip:port
the pool and the alternative pool for noaes

`TARGET_CO` : xmr|aeo
coin

`TNL_LISTEN_SCHEME` : string
protocol/transport for the local tunnel 

`TNL_LISTEN_PORT` : port
the starting port for local forwarding to pool

`TNL_MASK` : string
name for the tnl bin

`TNL_FORWARD_ADDRESS` : ip
the remote address for the tunnel

`TNL_FORWARD_PORT` : port
the remote port for the tunnel

`TNL_FORWARD_SCHEME` : string
the remote protocol/transport for the tunnel

`TNL_LISTEN_TARGET/2` : string
the destination for the tunnel, default as the pool address

`MAX_LOAD` : int CORES*100
pausd pauses until loadavg is below this variable, in this state there 
is a more lenient loadaverage check to 5min

`THREADS_FIXED` : int
don't steer threads

`MHF_FIXED` : int
don't steer mhf

`HGPS` : int
MBs of huge page tables

`CLM_MASK` : mask for cpulimit, defaults to ntpd because of nice level

`MASKS_TYPE` : web for only web masks

#### 
set `"command_before"` and `"command_after"` in config file for executing commands between restarts from scratch

####
- Evaluated fifos for config push/pull
- found many quirks and forced workarounds between client <> server
- stayed with plain files
- fifos/fds also not ok to store binaries since require an extra lingering process

####
web.flags vars must be 1:1 with web.masks entries
tnl.masks should have an extra space at the end if composed of one word
