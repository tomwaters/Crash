# Crash
A simple random drum machine for Norns

Plays a drum sample from the 606 folder every 'event'

![screenshot](/crash.jpg)

### Controls
#### ENC1 - Busyness:
Number of events per beat

#### ENC2 - Everything:
Chance of an event triggering a 'fill'

#### ENC3 - Nothing:
Chance of not playing a sample on an event

#### KEY3:
Start/Stop

### Custom Samples
To use a different set of samples, change the following line to point to a different folder (up to 8 samples will be used):<br />
*local sample_path = _path.dust.."audio/common/606"*
