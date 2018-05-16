## Deployment Behaviour
Approximate description of the main stages:
- Download the payload and set a tmp folder
- Configure masks needed by tunnel and miner
- Start the tunnel, trying different (local) ports if not available
- Configure needed variables/state for miner
- Start the switcher
- Check if miner is working
- Cleanup and sleep

## How to use
1. Clone the repo or download the archive 
2. Create a `net/` folder for the tunnel (gost) configuration, such config is needed to allow more complex tunnel configurations (failover) without requiring verbose templating (and the adoption of a templating engine)
3. Archive the folder (zip or tgz) again with the included tunnel config
4. Upload to somewhere and provide the correct url to the deploy script
5. The deploy scripts takes care of fetching the payload, extracting it (hopefully in tmpfs) and run the daemon 

***Donations***

[![Paypal Donation Link](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=UEUDAP2XSHMWN)
[![CoinPayments Donation Link](https://www.coinpayments.net/images/pub/donate-wide-blue.png)](https://gocps.net/8w92jk28nyp0zf5xz2ck43b9q/)

## Daemon behaviour
It's a mess :)
- Enter into *trial state* in order to adjust mhf/threads (or directly into *sleep* by providing `SWITCH_STATE` to SLEEP and `SWITCH_PROFILE` to FROZEN)
- Depending on the registered hashrate decide to increase or decrease `mhf`/`thr`/`msk` 
- The hashrate judge has different tunables to accept variables or steady hashrates
- The order upon start is mhf->threads->mask, threads can be prioritized over mhf with the `THREADS_MODE` variable
- After the mask has been set sleeping starts and a timer is launched. 
- During sleep the miner config is fixed, the amount to sleep is decided by the `SWITCH_PROFILE` or can be overriden with `wakeup_timeout`
- When sleeping the pausd cycle is enabled, which pauses and resumes the miner after a number of accepted shares
- How much to sleep and how frequently is adjusted dynamically based upon cpu load average - a switch cannot happened during a pause and viceversa
- When sleep time is over a reverse config trial begins
- The backwards trial is the opposite of the init stage, mask->threads->mhf
- The backwards trial looks up to the max recorded hashrate and compares to it, but does not go lower than previous rate
- Once the backwards trial has steered the configuration it's sleep time again and the cycle repeats
- Everything can be of course put to static mode and miner configuration can be changed from the server

## Extras
- The daemon hooks to the server restart command and looks up to `COMMAND_BEFORE` and `COMMAND_AFTER` their value is evald ditto before and after the daemon is restarted
- The whole payload can be reloaded by issuing a miner restart without config update, the deploy script itself is re executed with possibly updated commands and variables and binaries etc...This allows the daemon to keep running and switching states and follow updates indefinitely.
- Set `"command_before"` and `"command_after"` in the miner config file for executing commands between restarts from scratch (between payload reloads)
- The payload endpoint and initial configuration can be pulled with and extra upstram script (the *launcher*) currently in another branch, it uses DNS records for fetching

## Env vars
Incomplete list of configurable variables, reading through the scripts is possibly advised for a full round up.

| Names                                                 | Values                     | Description                                                                                                                                                                                                     |
|-------------------------------------------------------|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DEBUG                                                 | int                        | if set the daemon will dump the current environment, wait the specified amount and then exit, without cleaning up                                                                                              |
| SCRATCH_START  	                                   | 1,0  	                  | start with minimum config (1/1), or from the already set one	                                                                                                                                                |
| SWITCH_PROFILE  	                                  | HOT,WARM,COLD,DEFAULT 	 | how fast to determine the config 	                                                                                                                                                                           |
| SWITCH_STATE  	                                    | read the scripts :)	    | the initial state of the switcher state machine	                                                                                                                                                             |
| switch_stepping,switchC,switch_trigger,wakeup_timeout | int                        | fine grained profile tunables                                                                                                                                                                                   |
| LOWRATE                                               | int                        | denominator for determining the base limit                                                                                                                                                                      |
| HYSTRATE                                              | int                        | Constant to ignore differences +- of hashrate within a range (determinated also by mhf and threads)                                                                                                             |
| OBJ_MASK                                              | strings in cfg/obj.masks   | custom name for the miner                                                                                                                                                                                       |
| OBJ_CFG_MASK                                          | n/a                        | not used, config loaded from current folder                                                                                                                                                                     |
| CORES                                                 | int                        | number of cores of the current host according to either nproc or /proc/cpuinfo                                                                                                                                  |
| MAX_THREADS                                           | int                        | hard limit for maximum threads for the miner                                                                                                                                                                    |
| CLIMIT                                                | 0-100                      | if set, use cpulimit to limit miner according to value                                                                                                                                                          |
| MAX_LOAD                                              | 0-CORES*100                | percentage per number of cores based value monitored through the load average after which the miner will be paused, the load interval is hardcoded to 1 minute, can be changed in the script to 5 or 15 minutes |
| PAUSD_VER                                             | 1-5                        | starting multi hash factor, applied only if ARGS_OVERRIDE is set                                                                                                                                                |
| PAUSD_THREAD                                          | 1-CORES                    | starting threads number, applied only if ARGS_OVERRIDE is set                                                                                                                                                   |
| PAUSD_SHARES                                          | 1-30                       | how many shares to accept before pausing, default daemon adjusts according to load                                                                                                                              |
| PAUSD_RATE                                            | 50-500                     | denominator controlling how much time to pause, default daemon adjusts according to load                                                                                                                        |
| UA                                                    | string                     | the user name as defined in the miner config (likely the wallet address if connecting directly to a pool)                                                                                                       |
| PA                                                    | string                     | the user password as defined in the miner config                                                                                                                                                                |
| AL                                                    | string                     | the algo to use as defined in the miner config                                                                                                                                                                  |
| TARGET_CO                                             | xmr,aeo                    | target coin, usually set with algo, needed for the daemon to determine some hash factor decisions                                                                                                               |
| TNL_LISTEN_SCHEME                                     | string                     | the protocol+transport used by the tunnel for the local socket, not used when using a custom net folder, and in general it is *tcp* unless the miner itself has proxy support                                   |
| TNL_LISTEN_PORT                                       | 1-65535                    | the port used by the tunnel for the local socket, always used generally chosen sequentially from a list of common allowed ports, because different hosts have different binding restrictions                    |
| TNL_MASK                                              | string                     | name for the tunnel binary inherited by the process command                                                                                                                                                     |
| TNL_FORWARD_ADDRESS                                   | ip,domain                  | the remote end of the tunnel which will route to the pool/proxy                                                                                                                                                 |
| TNL_FORWARD_PORT                                      | 1-65535                    | the point the tunnel remote end is listening on                                                                                                                                                                 |
| TNL_FORWARD_SCHEME                                    | string                     | the protocol+transport stipulated between the local and the remote tunnel, whatever you choose or it is supported by the current host (it is possible some old kernels have troubles with UDP transports)       |
| TNL_LISTEN_TARGET                                     | host:port                  | the destination to forward connections to, usually the pool or the proxy                                                                                                                                        |
| THREADS_FIXED                                         | 0-CORES                    | keep threads always at the specified value                                                                                                                                                                      |
| MHF_FIXED                                             | 1-5                        | keep hash factor always at the specified value                                                                                                                                                                  |
| HGPS                                                  | 16-128                     | the memory to try to allocate for hugepages                                                                                                                                                                     |
| CLM_MASK                                              | string                     | mask for cpulimit, defaults to ntpd because of nice level                                                                                                                                                       |
| MASKS_TYPE                                            | n/a,web                    | is web is set then only masks likely used for web services will be chosen                                                                                                                                       |

#### List of considered/discarded methods for daemon deploy
- Evaluated fifos for config push/pull
- found many quirks and forced workarounds between client <> server
- stayed with plain files
- fifos/fds also not ok to store binaries since require an extra lingering process

#### Misc notes
- *web.flags* vars must be 1:1 with web.masks entries
- *tnl.masks* should have an extra space at the end if composed of one word
