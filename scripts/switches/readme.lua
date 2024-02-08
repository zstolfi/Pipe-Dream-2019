--[[

		-- DOCUMENTATION --

Animated :
	If this is checked the game will animate, or the camera plugin is ran.
	Otherwise Everything is static. (no marbles)

AnimatedFPS :
	FPS the animaiton is quantized to

AnimatedMidi :
	This links to the StringValue containing the Midi to be animated. (Base64 encoded)
	workspace.MIDIs

AnimatedRealTime :
	If enabled it renders at a constant pace
	Otherwise the animtor renders every frame one after another
	Only works if camera plugin isn't running

AnimatedRealTime.Speed :
	Speed multiplier if RealTime is set
	(ex: 1.0 is normal speed, 0.5 is half speed, 2 is twice as fast, etc.)

AnimatedRealTime.StartTime :
	Starting position of the song in seconds if RealTime is set
	(ex: 6 starts the song 6 seconds in)

Build quality : 
	0		-	no build scripts are run
	10		-	everything is built, no lighting or decals
	20		-	no lights
	30		-	most lights but no room / wall lights
	40		-	full lights, no post-processing
	50		-	full rendering

KeyframeTrack :
	Links to the folder containing the keyframe information, both for the animation
	to read and for the camera plugin to copy from.
	workspace.Camera.tracks

RunCameraEditor :
	If set the camera plugin will run instead of the animation playing
	(This must be installed https://www.roblox.com/library/7236554105/Studio-Camera-Editor)

RunCameraEditor.Advanced :
	Enables the GUI to set the camera's roll

ScreenshotAHK : (keep disabled!)
	I had attempted, and failed, to write a script to quickly save screenshots
	Every frame the Animator script renders will be saved as a screenshot (runs the screenshot plugin)
	see https://www.reddit.com/bq74c7

Timecode :
	Displays a timecode at the bottom center of the screen, which updates every frame drawn
	(not visible when camera plugin is over it)
	
ToggleCamera :
	Quickly disables the camera from tracking with the animation

]]