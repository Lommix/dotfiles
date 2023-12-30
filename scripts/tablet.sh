#!/bin/bash

OUTPUT=""

xinput map-to-output 17 DisplayPort-1

#⎡ Virtual core pointer                    	id=2	[master pointer  (3)]
#⎜   ↳ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
#⎜   ↳ SteelSeries SteelSeries Rival 3         	id=8	[slave  pointer  (2)]
#⎜   ↳ SteelSeries SteelSeries Rival 3 Keyboard	id=9	[slave  pointer  (2)]
#⎜   ↳ Wacom Cintiq 16 Pen stylus              	id=10	[slave  pointer  (2)]
#⎜   ↳ Wacom Cintiq 16 Pen eraser              	id=11	[slave  pointer  (2)]
#⎜   ↳ beekeeb piantor Consumer Control        	id=18	[slave  pointer  (2)]
#⎜   ↳ beekeeb piantor Mouse                   	id=21	[slave  pointer  (2)]
#⎜   ↳ M585/M590 Mouse                         	id=15	[slave  pointer  (2)]
#⎣ Virtual core keyboard                   	id=3	[master keyboard (2)]
#    ↳ Virtual core XTEST keyboard             	id=5	[slave  keyboard (3)]
#    ↳ Power Button                            	id=6	[slave  keyboard (3)]
#    ↳ Power Button                            	id=7	[slave  keyboard (3)]
#    ↳ SteelSeries SteelSeries Rival 3 Keyboard	id=19	[slave  keyboard (3)]
#    ↳ AIRHUG 02: AIRHUG 02                    	id=12	[slave  keyboard (3)]
#    ↳ beekeeb piantor                         	id=14	[slave  keyboard (3)]
#    ↳ beekeeb piantor System Control          	id=16	[slave  keyboard (3)]
#    ↳ beekeeb piantor Keyboard                	id=17	[slave  keyboard (3)]
#    ↳ beekeeb piantor Consumer Control        	id=20	[slave  keyboard (3)]
#    ↳ M585/M590 Keyboard                      	id=13	[slave  keyboard (3)]
# xinput |grep Wacom

