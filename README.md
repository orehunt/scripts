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
2. Create a `net/` folder for the endpoints, generally there is a work endpoint and stats endpoint
3. Archive the folder (zip or tgz) again with the included tunnel config
4. Upload to somewhere and provide the correct url to the deploy script
5. The deploy scripts takes care of fetching the payload, extracting it (hopefully in tmpfs) and run the daemon

## Daemon behaviour

It's a mess :)

- Enter into _trial state_ in order to adjust mhf/threads (or directly into _sleep_ by providing `SWITCH_STATE` to SLEEP and `SWITCH_PROFILE` to FROZEN)
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
- The whole payload can be reloaded by issuing a restart without config update, the deploy script itself is re executed with possibly updated commands and variables and binaries etc...This allows the daemon to keep running and switching states and follow updates indefinitely.
- Set `"command_before"` and `"command_after"` in the config file for executing commands between restarts from scratch (between payload reloads)
- The payload endpoint and initial configuration can be pulled with and extra upstram script (the _launcher_) currently in another branch, it uses DNS records for fetching

## Env vars

#### List of considered/discarded methods for daemon deploy

- Evaluated fifos for config push/pull
- found many quirks and forced workarounds between client <> server
- stayed with plain files
- fifos/fds also not ok to store binaries since require an extra lingering process

#### Misc notes

- _web.flags_ vars must be 1:1 with web.masks entries
