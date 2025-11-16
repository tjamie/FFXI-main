# Easy STF
This addon allows you to report bots and RMT spammers to Square Enix's Special Task Force directly from FFXI.

## Installation
Copy this addon's folder to Windower's addons directory. This addon can be loaded with:
```
lua load easystf
```

## Commands
#### report
```
stf report [player] [area] [reason]
```
Reports the specified player to the Special Task Force. The area argument must be the truncated version of the respective area's name (e.g., BastokMark and not Bastok Markets). Reports submitted to the Special Task Force also require a date and server, but these items are collected automaitcally when the above command is executed.

Multiple characters can be reported at once by delimiting each name with a comma (no spaces). For example,
```
stf report Johnfinalfantasy,Janefinalfantasy BastokMark rmt
```
Additional commands to list implemented areas and reporting justifications are detailed further below.

#### help
```
stf help
```
Displays a list and brief description of every command available in this addon.

#### listareas
```
stf listareas
```
Displays a list of areas and their truncated names that are currently implemented.

#### listreasons
```
stf listreasons
```
Displays a list of reasons that can be used to justify reporting a player.