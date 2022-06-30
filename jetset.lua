--poke(0x5f2c,135) --east
--poke(0x5f2c,133) --west
--poke(0x5f2c,131) --north
--poke(0x5f2c,0) --south/normal
--poke(0x5f2c,129) --change direction
--poke(0x5f2e,1)

function _init()
	loop_mode = "start" --switching between menus and the game
--start screen varibles
	sscreeny = -16
	sscreenx = {34,30} -- cursor x pos to allign with the text
	select = 1
	hlt = {11,3} --hightlight text
	ptxt = "one player"
	players = 1 --ammount of players currently playing
	levelstars={0,0,0,0,0,0,0,0,0} --star tally of stars collected across the nine levels
	levelscores={{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}} --high scores across all 9 levels
--level title card varibles
	tcardy = 0 --used for the scrolling effect
	tcardx = 0 --used to right just the "street" text

--game varibles
	biket = {"double peg","icepick",
	"toothpick","luc-e","un-luc-e",
 "butcher","levitator","magic carpet",
 "feeble","smith","crooked",
 "pedal","crankarm","sprocket",
 "rodeo","derek duster","hitchhiker"}

	bordt = {"50-50","5-0","feeble",
	"smith","salad","suski","nosegrind",
	"crooked","overcrook","willy",
	"losi","boardslide","lipslide",
	"noseslide","noseblunt","tailslide",
	"blunt","darkslide"}

	boott = {"acid","citric acid",
	"hotdog","makio","mistrial",
	"mizou","pornstar","sidewalk",
	"soul","stub soul","tea kettle",
	"x","torque soul","backslide",
	"cab driver","darkslide",
	"fastslide","full torque",
	"pudslide","royale","tabernacle",
	"torque","unity","wheelbarrow",
 "savannah","cloudy night","fishbrain",
 "kindgrind","misfit","overpuss","soyale",
 "sunny day","sweatstance","ufo"}
	trick = ""

	playerx = 16
	playery = 104
	players = 1 --player sprite
	playerf = false --flip sprite
	playerl = 0 --players lives
	mapx = 0 --map scroll
	mapx2 = 128 --2nd map scroll
	inair = false
	rnd1 = 7 -- rnd top rail
	rnd2 = 6 -- rnd middle rail
	rnd3 = 7 -- rnd bottom rail
	rnd4 = 7 -- 2nd row rnd top rail
	rnd5 = 0 -- 2nd row rnd middle rail
	rnd6 = 7 -- 2nd row rnd bottom rail
	rndspikes = 0
	spikes = false --if true cover 1 of the 3 rails in spikes
	sa1 = {0,0,0} --spike covering array
	sa2 = {0,0,0} --spike covering for second row array
	changep = 10 --change peripheral
	last = 0 --spam-prevent-timer
	nospam = 0 --prevents trick spamming for points
	score = 0
	bonus_score = 0
	total1 = 0
	total2 = 0
	btog = 0 --toogle for bonus (toogles prevent an action happerning every frame
	tstog = 0 --toggle so when total score is updated its only updated once
	t_row = 0 --switch ups done in a row without failing
	r_row = 0 --unique rails landed on in a row
	start = false
	speed = 2
	rating = 4
	ratet = {"perfect","  ok!  ","sketchy","       "}
	minutes = 2
	seconds = 0
	frames = 0 --frame counter for timer
	cef = 0 --combo ending frames needed to pass to activate
	cef2 = false --how long before the function should be turned on
	wallriding = false
	wallridetime = 38
	goaltext1 = "grind the rails!"
	goaltext2 = "before security arrives."
	endlevel = false
	endlevelx = 176 --end of street artwork xpos
	endlevelx2 = -100 --police cornering artwork xpos
	arrest = 0 --arrest animation state
	arrestx = -100 --officer who arrests you xpos
	arrestf = 0 --frame counter for oscillating text between colors
	arrestt = 0 --toggle between colors
	direction = 0 --direction of travel
	screenflip = false
	nojump = false
	nowall = false

	cl = 1 --current level
	clu = 1 --current levels unlocked
	level_names = {
	"crooked city",
	"nosegrind nightlife",
	"makio mall",
	"fishbrain aquirium",
	"feeble forest",
	"darkslide desert",
	"crankarm cave",
	"handrail hell",
	"grind palace",
	"game compleation"
	}
	level_palette = {
	{5,12,0},{13,1,0},{7,5,0},
	{1,3,1},{4,3,0},{7,9,1},
	{4,0,1},{5,8,1},{13,2,1}
	}--wall,background,extended palette?
	--city{5,12}-forest{4,3}
	--art{7,5}-desert{7+,9+}
	--night{13,1}-cave{4+,0+}
	--hell{5+,8+}-aquarium{1+,3+}
	--purple{13+,2+} fuck it im out of ideas for level palettes so purple is royal castle level cause at school they taught us purple was royal
end

function resetimer()
	minutes = 2
	seconds = 0
	frames = 0
end

function resetvaribles()
--varible reset (i should make this a function)
	playerx = 16
	playery = 104
	players = 1
	playerf = false
	mapx = 0
	mapx2 = 128
	inair = false
	rnd1 = 7
	rnd2 = 6
	rnd3 = 7
	rnd4 = 7
	rnd5 = 0
	rnd6 = 7
	last = 0
	nospam = 0
	score = 0
	bonus_score = 0
	btog = 0
	tstog = 0
	t_row = 0
	r_row = 0
	start = false
	rating = 4
	cef = 0
	cef2 = false
	arrest = 0
	arrestx = -100
	arrestf = 0
	endlevel = false
	nojump = false
	nowall = false
end

function randomtrickname()
	--random trick to match current peripheral
 t_row += 1
	if (pget(playerx+2,playery+6) == 8) then
		trick = biket[flr(rnd(#biket))+1]
	elseif (pget(playerx+2,playery+6) == 9) then
		trick = bordt[flr(rnd(#bordt))+1]
	elseif (pget(playerx+2,playery+6) == 10) then
		trick = boott[flr(rnd(#boott))+1]
	end
end

function increasescore()
--32767
--if score or multi are odd calculations wont be accuret sometimes (idk why lol)
	if (tstog == 0) then
--3: repeat -step 2- 4 times (idk why lol)
		for j=1, 4 do
--1: divide the calculations into 4ths so itll never produce a number that overflows
--2: then enumerate that 4th to the display values
			for i=1,(score/2)*(r_row/2) do
				total1 += 1
				if (total1 == 10000) then
					total1 = 0
					total2 += 1
				end
			end
		end
--4: and finally enumrate the bonus score to the display values
		for k=1, bonus_score do
			total1 += 1
			if (total1 == 10000) then
					total1 = 0
					total2 += 1
				end
		end
	end
	tstog = 1
end

function addspikes1()
	if (spikes == true) then
		rndspikes = flr(rnd(3))
		if (rndspikes == 0) sa1 = {35,0,0}
		if (rndspikes == 1) sa1 = {0,35,0}
		if (rndspikes == 2) sa1 = {0,0,35}
	end
end
function addspikes2()
	if (spikes == true) then
		rndspikes = flr(rnd(3))
		if (rndspikes == 0) sa2 = {35,0,0}
		if (rndspikes == 1) sa2 = {0,35,0}
		if (rndspikes == 2) sa2 = {0,0,35}
	end
end
--credit to bitjericho---------
function paste_screen(screen,x,y,flip_x,flip_y)
 if flip_x then
  ax = #screen
 else
  ax = 1
 end

 for sx = 1, #screen do
  if flip_y then
   ay = #screen[1]
  else
   ay = 1
  end
  for sy = 1, #screen[sx] do
   rect(x+sx-1,y+sy-1,x+sx-1,y+sy-1,screen[ax][ay])
   if flip_y then
    ay -= 1
   else
    ay += 1
   end
  end
  if flip_x then
   ax -= 1
  else
   ax += 1
  end
 end
end

function copy_screen(x,y,width,height)
 local screen = {}

 for sx = x,x+width-1 do
  screen[sx-x+1] = {}
  for sy = y,y+height-1 do
   screen[sx-x+1][sy-y+1] = pget(sx,sy)
  end
 end
	return screen
end
-------------------------------
--credit to 24appnet-----------
function outline(s,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x+1,y+1,c2)
end
----------------------

function _update()
----------shared
--screen flip
	if (screenflip == true) then
		poke(0x5f2c,129)
	elseif (screenflip == false) then
		poke(0x5f2c,0)
	end
----------start screen loop
if loop_mode == "start" then
 --make the ska bg move
 sscreeny += 1
 if (sscreeny > 0) then
 	sscreeny = -16
 end
 --selection up/down input
 if (btnp(2)) then
 	if (select == 1) then
 		select = 2
 		hlt = {3,11}
 	elseif (select == 2) then
 	 select = 1
 	 hlt = {11,3}
 	end
 end
 if (btnp(3)) then
 	if (select == 2) then
 		select = 1
 		hlt = {11,3}
 	elseif (select == 1) then
 	 select = 2
 	 hlt = {3,11}
 	end
 end
 --selection left/right input
 if (btnp(0)) then
 	if (select == 1) then
 		if (players == 1) then
 			players = 2
 			ptxt = "two player"
 		elseif (players == 2) then
 			players = 1
 			ptxt = "one player"
 		end
 	end
 	if (select == 2) then
 		if (cl > clu and cl == 10) then
 			cl = clu
 		elseif (cl == 1) then
 			cl = 10
 		else
 			cl -= 1
 		end
 	end
 end
 if (btnp(1)) then
 	if (select == 1) then
 		if (players == 2) then
 			players = 1
 			ptxt = "one player"
 		elseif (players == 1) then
 			players = 2
 			ptxt = "one player" --use to say two player but not implemented
 		end
 	end
 	if (select == 2) then
 		if (cl == clu) then
 			cl = 10
 		elseif (cl == 10) then
 			cl = 1
 		else
 			cl += 1
 		end
 	end
 end
 --select level and advance loop mode
 if (btnp(4) and cl != 10) then
 	loop_mode = "level"
 	wait_tran = time()
	end
end
----------title card loop
if loop_mode == "level" then
 --make the jaggard line move
 tcardy -= 1
 if (tcardy == -16) then
 	tcardy = 0
 end
 if (btnp(4) and time()-wait_tran > 0.25) then
 	loop_mode = "game"
 	wait_tran = time()
 	playerl = 0
 	goaltext1 = "grind the rails!"
		goaltext2 = "before security arrives."
 end
 if (btnp(5)) then
 	loop_mode = "start"
 end
end
----------main game loop
if loop_mode == "game" then
 --timer
 if (start == true) frames += 1
 if (frames == 30) then
 	frames = 0
 	if (minutes == 2) then
 		minutes -= 1
 		seconds = 59
 	else
 		seconds -= 1
 	end
 	if (minutes == 1 and seconds == -1) then
 		minutes -= 1
 		seconds = 59
 	end
 	if (minutes == 0 and seconds == -1) then
			endlevel = true
			seconds = 0
		end
 end
	--moving up and down in air
	if (inair == true) then
		if (btn(2) and playery > 78) then
			playery -= 1
		end
		if (btn(3) and playery < 120) then
			playery += 1
		end
	end
	--jumping
	----up jump
	if (btnp(5) and inair == false and players != 57 and nojump == false) then
		sfx(0,-2) --stop grind sound
		playery -= 4
		last = time()
		inair = true
		changep = 8 + flr(rnd(3))
		trick = ""
		rating = 4
		btog = 0
		cef2 = true
		wallriding = false
	----magnet player to a rail
	elseif (btnp(5) and inair == true) then --go down early
		inair = false
		randomtrickname()
		playery += 4
	end
	----down jump
	if (time() - last > 1 and inair == true) then
  randomtrickname()
  last = 9999 --it just works
  inair=false
  playery += 4
 end
	--constantly moving forward
	--playerx += 2
	--if (playerx > 127) then --screenwrap
		--playerx = -8
		--rnd1 = flr(rnd(9))
		--rnd2 = flr(rnd(9))
		--rnd3 = flr(rnd(9))
	--end
	--constantly moving forward 2
	--moving rails and randomizing rails
	if (start == true) then
		mapx -= speed
		mapx2 -= speed
		if (mapx == -128 and endlevel != true) then
			addspikes1()
			mapx = 128
			rnd1 = flr(rnd(11))
			rnd2 = flr(rnd(11))
			rnd3 = flr(rnd(11))
		end
		if (mapx2 == -128 and endlevel != true) then
			addspikes2()
			mapx2 = 128
			rnd4 = flr(rnd(11))
			rnd5 = flr(rnd(11))
			rnd6 = flr(rnd(11))
		end
	end
	--grind sound
	if (inair == false) then
		if (pget(playerx-1,playery+7) == 2 or
						pget(playerx+8,playery+7) == 2 or
						pget(playerx-1,playery+7) == 8 or
						pget(playerx+8,playery+7) == 8 or
						pget(playerx-1,playery+8) == 2 or
						pget(playerx+8,playery+8) == 2) then
			sfx(0,0)
			nowall = false
		else
			sfx(0,-2) --stop grind sound
		end
	end
	--grind rating
	if (inair == false and players != 57) then
	 if (pget(playerx-1,playery+7) == 2 or
			 	 pget(playerx+8,playery+7) == 2) then
		 rating = 1
		 if (btog == 0) then
		 	bonus_score += 50
		 	r_row += 1
		 	btog = 1
		 end
	 elseif (pget(playerx-1,playery+7) == 8 or
			 			   pget(playerx+8,playery+7) == 8) then
		 rating = 3
		 if (btog == 0) then
		 	bonus_score += 10
		 	r_row += 1
		 	btog = 1
		 end
	 elseif (pget(playerx-1,playery+8) == 2 or
						    pget(playerx+8,playery+8) == 2) then
		 rating = 2
		 if (btog == 0) then
				bonus_score += 25
				r_row += 1
				btog = 1
			end
	 end
	end
	--start moving
	if (btnp(4) and start == false and time()-wait_tran > 0.25) then
		start = true
		goaltext1 = ""
		goaltext2 = ""
	end
	--change peripheral
	if (inair == true and btnp(4)) then
		changep += 1
		if (changep == 11) then changep = 8 end
	end
	--trick switch-up mechanic
	nospam += 1 --nospam makes sure you have to press the button slower not spam it
	if (btnp(4) and inair == false and nospam >= 9 and stat(16) == 0) then
		sfx(1,1)
		tstog = 0
		nospam = 0
		score += 5
		randomtrickname()
	elseif (btnp(4) and inair == false and nospam < 9) then --checks for spamming and deducts points
		sfx(2,1)
		increasescore()
		nospam = 0
		r_row = 0
		bonus_score = 0
		score = 0
		t_row = 0
	end
	--wallride
	----initate wallride
	if (playery < 84 and inair == false and btn(4) and wallriding == false and nowall == false) then
	 wallriding = true
	 nowall = true
	 trick = "wallgrind"
	 wallridetime = 38
	end
	----prevent them being on the wall forever
	if (wallriding == true) then
		wallridetime -= 1
	end
	----too long on a wall... kill the player
	if (wallridetime == 0) then wallriding = false end
	--combo ending
	----cef (combo ending frames)
	----excists so function is not
	----frame perfect as if it was
	----that would be unfair on the
	----player if it was
	-- when you end your combo before the end of timer
	if (inair == false and stat(16) == -1 and cef2 == true and wallriding == false and endlevel == false) then
		cef += 1
		if (cef == 2) then
			increasescore()
			t_row = 0
			r_row = 0
			score = 0
			bonus_score = 0
			cef = 0
		 start = false
		 players = 57
		 rating = 4
		 trick = ""
		 if (playery < 90) then playery = 90 end
		end
	-- when you end your combo at the end of timer
	-- basically plays a cutscene
	elseif (inair == false and stat(16) == -1 and cef2 == true and wallriding == false and endlevel == true and screenflip == false) then
		trick = ""
		nojump = true
		if (playerx == 16) then
			tstog = 0
			increasescore()
		end
		--increasescore() why is this here?
		--moves player into the corrext x and y pos
		if (playery < 104) then
			playery += 1
		elseif (playery > 104) then
			playery -= 1
		end
		if (playerx == 104) then
			playerx = 104
		else
			playerx += 1
			endlevelx -= 1
		end
		-- flips player sprite when it reaches its destination
		if (playerx == 104 and playery == 104) then
			playerf = true
		end
		----keeps the police advancing to player when theyve stopped
		if (endlevelx2 != 32) then
			endlevelx2 += 1
		elseif (endlevelx2 == 32) then
			--updates player on their new objective
			--reset the game to a playing state
			--initiate screen flipping to make the player think theyre going back the way they're coming
			--reset the igt as well
			--and finally adds spikes to the rails
			resetvaribles()
			resetimer()
			goaltext1 = "oh no it's security!"
			goaltext2 = "make it out alive."
			screenflip = true
			rnd1 = 7
			rnd2 = 7
			rnd3 = 7
			playerx = 16
			endlevelx = 0
			endlevelx2 = 64
			spikes = true
		end
	----when grinding on the way back greet the player with sweet victory
	elseif (inair == false and stat(16) == -1 and cef2 == true and wallriding == false and endlevel == true and screenflip == true) then
		--increase score
		trick = ""
		nojump = true
		if (playerx == 16) then
			tstog = 0
			increasescore()
		end
		--move player to correct ypos
		if (playery < 104) then
			playery += 1
		elseif (playery > 104) then
			playery -= 1
		end
		--move player
		playerx += 1
		goaltext1 = "congratulations"
		goaltext2 = "you're grind royalty"
	end
	--progressing to the next level
	if (btnp(4) and playerx > 128) then
		if (levelstars[cl] < 3-playerl) levelstars[cl] = (3-playerl) --gives player a ranking out of 3 stars, if they replay the level and get less than their best dont take that away from them
		--update the final tally with
		--the players highscore and
		--make sure not to overwrite
		--their highest score with a
		--lower score
		if (total2 > levelscores[cl][1]) then
			levelscores[cl][1] = total2
			levelscores[cl][2] = total1
		elseif (total2 == levelscores[cl][1]) then
			if (total1 > levelscores[cl][2]) then
				levelscores[cl][1] = total2
				levelscores[cl][2] = total1
			end
		end
		--other stuff that needs reseting beofre going onto the next level
		cl += 1
		clu += 1
		resetvaribles()
		resetimer()
		screenflip = false
		sa1 = {0,0,0}
		sa2 = {0,0,0}
		spikes = false
		loop_mode = "level"
		endlevelx = 176
		endlevelx2 = -100
		total1 = 0
		total2 = 0
	end
	--police arresting player animation
	--arrest 0: ani not started
	--arrest 1: police move towards players
	--arrest 2: police drag you off
	--arrest 3: status screen of lives remaining
	if (players == 57 and arrest == 0) then
		arrest = 1
	end
	if (arrest == 1 and arrestx < 12) then
		arrestx += 1
	end
	if (arrest == 2) then
		arrestx -= 0.5
		playerx -= 0.5
	end
	if (arrest == 3) then
		arrestf += 1
		if (arrestf%15 == 0 and arrestt == 0) then
			arrestt = 1
		elseif (arrestf%15 == 0 and arrestt == 1) then
			arrestt = 0
		end
	end
	if (arrestx == 10) then
		for i = 1,15 do flip() end --frame wait function
		arrest = 2
	end
	if (arrestx < -50 and arrest == 2) then
		arrest = 3
		if (playerl == 0) then
			goaltext1 = "you've been arrested!"
			goaltext2 = "but let off with a warning."
		elseif (playerl == 1) then
			goaltext1 = "oh no, arrested again!"
			goaltext2 = "you've been fined $1,000,000."
		elseif (playerl == 2) then
			goaltext1 = "this is the final arrest!"
			goaltext2 = "death sentence for you."
		end
	end
	--game restart and live deduction
	if (arrest == 3 and btnp(4) and playerl != 2) then
		playerl += 1
		pal(11,11)
		pal(3,3)
		resetvaribles()
		sa1 = {0,0,0}
		sa2 = {0,0,0}
		goaltext1 = "grind the rails!"
		goaltext2 = "before security arrives."
		--show half way point if respawning after half way
		if (screenflip == true) then
			endlevelx = 0
			endlevelx2 = 64
			rnd1 = 7
			rnd2 = 7
			rnd3 = 7
			goaltext1 = "oh no it's security!"
			goaltext2 = "make it out alive."
		end
	elseif (arrest == 3 and btnp(4) and playerl == 2) then
		wait_tran = time()
		loop_mode = "gameover"
	end
	--after screen is flipped move end of the street and police away from player
	if (screenflip == true and start == true) then
		endlevelx -= 2
		endlevelx2 -= 2
	end
end
----------game over loop
if loop_mode == "gameover" then
	screenflip = false
	spikes = false --2022
	if (btnp(4) and time()-wait_tran > 0.25) then --restart level
		loop_mode = "level"
	end
	if (btnp(5) and time()-wait_tran > 0.25) then
		loop_mode = "start" --go back to the title screen
	end
end
end

function _draw()
cls()
palt(0, false)
palt(14, true)
----------start screen loop
if loop_mode == "start" then
	--scrolling grid background
	pal(5,2+128,1)
	pal(11,11,0)
	pal(3,3,0)
	rectfill(0,0,127,127,2)
	map(17,0,sscreeny,sscreeny,18,18)
	--game name
	pal(12,5,1)
	map(5,20,4,32,15,4)
	--selection box
	rectfill(21,65,103,96,7)
	rectfill(22,66,102,95,0)
	pset(23,67,7)pset(101,67,7)
	pset(23,94,7)pset(101,94,7)
	--selection cursor
	spr(37,sscreenx[select],62+(select*6))
	--menu items
	print(ptxt,63-#ptxt*2,70,hlt[1])
	print("select level",63-12*2,76,hlt[2])
	--currently selected level
	print(level_names[cl],63-#level_names[cl]*2,82,7)
	if (cl != 10) then
		--white underlay text
		print("       ★★★",63-13*2,88,7)
		--high score for selected level
		print(levelscores[cl][1]..levelscores[cl][2],50-(4*#tostr(levelscores[cl][1])+#tostr(levelscores[cl][2])),88,7)
		--star count for selected level
		for s=1,levelstars[cl] do
			print("★",57+(s*8),88,11)
		end
	else
		--game compleation stats
		print("   % ★x  ",63-10*2,88,7)
		print("★",63,88,11)
		--count how many stars the player has and print that
		starcount = 0
		for s in all(levelstars) do
			starcount += s
		end
		print(starcount,83-(4*2),88,7)
		--count % towards 1 million points
		millcount = 0
		for m in all(levelscores) do
			millcount += m[1]
		end
		if (millcount > 100) millcount = 100
		print(millcount,55-(4*#tostr(millcount)),88,7)
	end
end
----------title card loop
if loop_mode == "level" then
	pal(5,10+128,1)
	pal(11,11,0)
	pal(3,3,0)
	--color bg
	rectfill(0,0,42,127,11)
	--bg grid
	map(17,0,0,0,6,16)
	--color fg
	rectfill(43,0,127,127,0)
	--scrolling jagged line
	map(16,0,35,tcardy,1,18)
	--level info text
	outline("mission "..cl,46,57,3,0)
	outline(level_names[cl],46,65,11,0)
	outline("street",22+(#level_names[cl]*4),73,11,0)
	outline("★★★",102,2,3,0)
end
----------main game loop
if loop_mode == "game" then
	pal(4,8+128,1) --the rail posts are brown, we make them a different shade of red since collision looks for the red to detect grinds. this fixes a bug where the rail posts were grindable
	--bg
	if (arrest != 3) then --display correct color on the arrest status screen
		if (level_palette[cl][3] == 0) then
			pal(5,level_palette[cl][1],1)
			pal(12,level_palette[cl][2],1)
		elseif (level_palette[cl][3] == 1) then
			pal(5,level_palette[cl][1]+128,1)
			pal(12,level_palette[cl][2]+128,1)
		end
	else
		pal(12,12,1)
	end
	rectfill(0,0,127,127,12) --sky
	rectfill(0,32,127,96,5) --wall
	rectfill(0,96,127,127,6) --floor
	rect(-1,32,128,95,0) --outline
	--rails
	map(sa1[1],rnd1,mapx,119,16,1) --top
	map(sa1[2],rnd2,mapx,104,16,1) --middle
	map(sa1[3],rnd3,mapx,89,16,1) --bottom
	map(sa2[1],rnd4,mapx2,119,16,1) --2nd row top
	map(sa2[2],rnd5,mapx2,104,16,1) --2nd row middle
	map(sa2[3],rnd6,mapx2,89,16,1) --2nd row bottom
	--end of the level draw stuff
	if (endlevel == true) then
		----streets end
		map(0,12,endlevelx,32,5,12)
		----police coming to arrest yo ass at the dead end
		map(5,12,endlevelx2,90,4,5)
	end
	--screen-flip special assests
	----end of the street and end level police
	if (screenflip == true) then
		map(0,24,endlevelx,32,5,12)
		map(9,12,endlevelx2,90,4,5)
	end
	--player
	pal(10,changep)
	if (inair == true) then --floor shadow
		line(playerx,playery+11,playerx+7,playery+11,0)
	end
	spr(players,playerx,playery,1,1,playerf)
	--arresting police officer
	spr(56,arrestx,playery)
	--ui text
	----score
	print("score:"..score.."x"..r_row,1,1,0)
	print("bonus:"..bonus_score+t_row,1,7,0)
	--total score base
 print("0000000",100,1,0)
 ----box sneakyly covers 0000000 so i dont have to add them lol
 rectfill(128-(4*#tostr(total1)),1,128,6,12)
 rectfill(111-(4*#tostr(total2)),1,111,6,12)
	----total score display values
	print(total1,128-(4*#tostr(total1)),1,0)
	print(total2,112-(4*#tostr(total2)),1,0)
	----timer
	if (seconds > 9) then
		print(minutes..":"..seconds,56,1,8)
	else
		print(minutes..":0"..seconds,56,1,8)
	end
	----wallride timebar
	if (wallriding == true) then
		rectfill(44,7,82,11,0)
		rectfill(44,7,44+wallridetime,11,11)
	end
	----ljusting tricks ui element
	t_string = tostr(t_row)..":tricks"
	print(t_string,128-(4*#t_string),7,0)
	----trick name and rating
	print(trick,64-#trick*2,13,137)
	print(ratet[rating],50,7,135)
	----lives screen backdrop
	if (arrest == 3) then
		rectfill(0,0,127,127,5)
		if (arrestt == 0) then
			pal(11,136)
			pal(3,2)
		else
			pal(11,12)
			pal(3,1)
		end
	end
	----goal text
	--------drop shadow
	print(goaltext1,63-#goaltext1*2,59,3)
	print(goaltext2,63-#goaltext2*2,65,3)
	--------normal
	print(goaltext1,64-#goaltext1*2,59,11)
	print(goaltext2,64-#goaltext2*2,65,11)
	----------screenflip text back the right way
	if (screenflip == true) then
		paste_screen(copy_screen(0,0,128,32),0,0,true,false)
		if (goaltext1 != "") then
			if (goaltext1 == "oh no it's security!") then
				paste_screen(copy_screen(0,59,128,11),0,59,true,false)
				spr(23,-3,59)
				rectfill(120,59,128,67,5)
				line(95,59,95,64,5)
				line(32,64,32,69,0)
				pset(32,62,0)
			else
				paste_screen(copy_screen(0,52,128,32),0,52,true,false)
			end
		end
	end
	--print("grinds:"..r_row,1,19,0)
end
----------game over loop
if loop_mode == "gameover" then
	print("game over",64-9*2,52,7)
	print("(🅾️) to restart level",64-21*2,59,7)
	print("(❎) to exit to menu",64-20*2,65,7)
end
end
