--[[
	THINGS TO DO:

X			make hi-hat z-rotation multiply to 0 as hiHatPosition goes to 0
X			check hi-hat anim when the song ends
X  9-27-20	review splash animation
X  9-27-20	check 4-way perc animations in general

X  9-27-20		organize hi-hat anim into a lookup matrix
X  9-27-20		then 4-Way perc anim as a lookup matrix
X  10-1-20		make 4-way spin
			
X 10-31-20	make marbles toggleable with booleans
			
X  11-1-20	fixed bugs with 4-way inst playing "splash q-notes" and "hi-hat test"
			
X  12-9-20			create splash-arm Desmos
X 12-23-20		make splash bouncy
X 12-27-20		cowbell bounce
X 12-27-20		hi-hat bounce
X 12-27-20		woodblock bounce
X 12-28-20	make the 4-way instruments bounce
			
X   1-4-21	see if the line '(#anim ~= 0)' applies to the other matrix keyframe things
			
X   1-4-21	make marble toggle code cleaner
X   1-4-21	make the intrument keyframes toggleable with booleans
			
X   1-5-21		write down trajectory points / plane angles
X  2-19-21 		Create Desmos graph of 10 drum trajectories 
X  2-19-21			Create base "drm" animation
			
X  2-19-21				fill out for snare
X  2-19-21				fill out for bass drum
X  2-20-21				fill out for tom 1
X  2-20-21				fill out for tom 2
X  2-20-21				fill out for tom 3
X  2-20-21				fill out for tom 4
X  2-20-21				fill out for tom 5
X  2-20-21				fill out for tom 6
X  2-20-21				fill out for crash 1
X  2-20-21				fill out for crash 2
X  2-20-21			Fill out keyPoints/timeDomains for all 10 sub-animations
X  2-20-21				Bass, snare, crash 1, crash 2
X  2-21-21				Tom 1, Tom 2, Tom 3, Tom 4, Tom 5, Tom 6
X  2-21-21			Adjust times/points to match original video
X  2-21-21		Marble trajectories
			
X  2-27-21			desmos graph for a drum bouncing
X  2-27-21			coding the bass drum bounce
X  2-27-21			coding the snare, tom 1, tom 2, tom 3 --- tom 6
X   3-3-21		coding the cymbal hits
          			
X   3-7-21			bass drum legs movement
X   3-7-21		Drum bouncing
X   3-7-21	drum animations
          	
          	
          	remake the cymbal meshes in blender (specifically make the top hi-hat not have a bottom)
          	
          	make all cymbals rotate when hit (keyframes)
          	
X   3-7-21			Format iMac's song
X   3-8-21		iMac's marimba song
          	
X   4-1-21		import iMac's rick astely PD
X   4-1-21 		record rick astely PD
          	
          	Import and record other user's songs
          	
X   3-9-21	Timecode system
          	
X  3-11-21		create camera part and moduleScript
X  3-12-21			set up and test first few camera CFrames
X  3-13-21			duplicate kayframe code, from motionParameters keyframeUpdator
X  3-14-21				notation for splines
X  3-14-21				copying autoArc code for splines
X  3-14-21				works the first time
X  3-14-21			camera slpines
X  3-15-21			Make a test camera track for Insrument Test.mid
X  3-15-21		primitive camera keyframe system
          		
X   4-2-21			figure out underlying math
X   4-3-21				create a test camera track
X   4-5-21			import smoothing code correctly
X   4-8-21			write smoothing code for only pairs of spines, not all keyframes
X   4-8-21			fix right-vector issue
          		Smooth the transition between two splines

X  3-15-21				design a simple keyframe UI (https://i.imgur.com/Z98SIeZ.png)
X  3-17-21			local test GUI
X  3-21-21			program the test GUI buttons/sliders
X  3-21-21		Camera editor GUI
          			
X  3-25-21			editor has working play/pause button
X   4-1-21			make bottom slider update the times, as well as play/pause
X  4-14-21				make a test keyframe display
X  4-21-21				keyframes selecatable
X  7-22-21				Add Remove buttons working
X  7-23-21				cameraFunc updates as keyframes change
X  7-31-21					camera pos pauses when keyframe highlighted
X   8-2-21					CFrame pos updates when you highlight keyframe
X   8-3-21					keyframeTable lastIndex() updates as keyframes are changed
X   8-4-21				keyframes editable
X   8-4-21				camera pos editable
X long ago			display keyframes
X  8-11-21		Camera editor plugin
          		
          		
X  8-17-21			script to swap out textures by a style in workspace.Textures
X  8-20-21		textures build script
X  8-21-21		textures selectors system
X  8-22-21		improve texture selectors
X  8-27-21		written all texture selectors
X  9-15-21	texturing ver 1
          	
X  9-29-21	make everything 0.25 times as small for the lighting to work
X 10-15-21	texturing ver 2
          	
X 10-15-21		Place all lights
X 10-16-21		able to keyframe light brightness
X 10-22-21	In-game lights
          	
X 10-22-21		create textures in photoshop
X 10-23-21		"Decals" build script
X 10-23-21	Add decals to drum heads, floor, walls, etc.
X 10-25-21	Add decals for marimba blocks, modify floor planks
          	
X 11-6-21 		create all settings to workspace.switches folder
X 11-7-21 		write readme
X 11-7-21 	workspace.switches folder
          	
X 11-16-21	Go back and finalize Camera script
          	
X 12-17-21		Start to add Y and Z axis support for autoArc
X 12-18-21		autoArc can do X Y and Z axies
X 12-19-21	Camera can spline in multiple directions
          	
X 12-19-21	improve autoArc anti-ridge
          	
X long ago	lights keyframeable
          	
X  1-24-21		outOfBounds notes don't error (reinterpreted)
X  1-25-21		importMidi doesn't have hardcoded values
X  1-31-21			overfit & underfit test Midis
X   2-6-21			default importData settings
          			
X   2-6-21			all cases coded except CHROMATIC when width > noteSlots
X   2-7-22				algorithm planned
X   2-8-22			width > noteSlots case coded in
X   2-8-22		overfit and underfit work properly
          		
X   2-9-22		check that the drumset doesn't rely on hard-coded strings
X long ago	MIDI's are easy to import / adapt to Pipe Dream set

X         	Stress test ALL of the animated instruments
]]