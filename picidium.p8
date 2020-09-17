pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
dbg=false

--init

--todo: fix/setup points
-- some say.. 10 small surface
-- 25 large surface
-- 100 ship runway
-- 100-1000 fighter 
-- 100 wave ann bonus
-- 10,000 bonus manta

function _init()
	init_title()
	init_logo()
end

function init_title()
	init_manta()
	init_formations()
	init_fighters()
	init_levels()
	init_bullets()
	init_dreadnought()
	init_stars()

	cam_x=0
	title_drawn=false
	title_colrs={9,10,7}

	_update60=update_title
	_draw=draw_title
end

function init_ready()
	local t=time()
	roll_sp=1
	ready_time=t
	land_time=t
	fire_hold_time=t
	stop_time=t
	wave_time=t
	wave_wait=5
	wave_idx=1
	wave_fire_time=t
	wave_fire_wait=2
	num_runw_hits=0
	land_now=false
	fly_secs=30
	land_colr=6
	update_map(level)

	_update60=update_ready
	_draw=draw_ready
end

function init_bonus()
	medi_time=time()
	wave_idx=0
	
	_update60=update_bonus
	_draw=draw_bonus
end

function init_destroy_dreadnought()
	medi_time=time()
	wave_idx=0
	
	_update60=update_destroy_dreadnought
	_draw=draw_destroy_dreadnought
end

function init_game()
	reset_manta()

	_update60=update_game
	_draw=draw_game
end

function init_stars()
	stars={}
	for i=0,20 do
		local s={
			x=rnd(128),
			y=rnd(128)-20,
			c=7
		}
		add(stars,s)
	end
end

function init_manta()
	manta={
		sp=1,
		x=64,
		y=32,
		h=4,
		flp_h=false,
		flp_v=false,
		dx=2,
		dy=0,
		anim_time=time(),
		turning=false,
		destroyed=false,
		coll_y_min=0,
		coll_y_max=7,
		points=0,
		lives=3,
		fireballs={},
		landing
	}
	dx_inc=1
	dx_max=2
	sp_roll_90=10
	sp_level=1
	sp_turn_end=12
	init_fireballs(50,
		manta.fireballs)
end

function init_fireballs(c,fireballs)
	for i=1,c do
		add(fireballs,{
			x=0,y=0,dx=0,dy=0,
			r=0,c=7,active=false
		})
	end
end

function init_bullets()
	bullets={}
	sp_bullet=13
	sp_bullet_narw=14
	sp_bullet_roll=15
	sp_bullet_fighter=121
end

function init_dreadnought()
	map_end=2164
	flg_map_obstacle=0
	flg_map_runway=6
	flg_map_run_fi=7
	sp_damage=103
	sp_damage_sm=119
	sp_run_fi=87
	sp_thing=21	
	fast_time=time()
	medi_time=time()
	slow_time=time()
	beacon_colr=8
	explosions={}
	obstacles={}
	obstacles[sp_run_fi]={
		points=500,
		sp_dmg=sp_damage,
		sfx=1,
		fireball_r=4
	}
	obstacles[sp_thing]={
		points=25,
		sp_dmg=sp_damage_sm,
		sfx=2,
		fireball_r=3
	}		
end

function init_formations()
	forms={}
	forms[1]={
		xd={12,6,12,6,0},
		y={10,20,30,40,50},
		move=move_left	
	}
	forms[2]={
		xd={0,10,20,30,40},
		y={55,55,55,55,55},
		move=move_left_loop
	}
	forms[3]={
		xd={-28,-21,-14,-7,0},
		y={33,33,33,33,33},
		move=move_right_splt 
	}
	forms[4]={
		xd={0,-9,-18,-27,-36},
		y={25,28,32,35,38},
		move=move_right_zip
	}
	forms[5]={
		xd={0,-12,-24,0,0},
		y={23,23,23,-1,-1},
		move=move_right_down
	}
	forms[6]={
		xd={-20,-10,0,0,0},
		y={34,34,34,23,43},
		move=move_right
	} // t+90 shape
end

function init_fighters()
	fighters={}
	fighters[1]={
		sp=79, -- sphere thing
		right=true,
		form=1
	}
	fighters[2]={
		sp=95, -- donut
		right=true,
		form=2
	}
	fighters[3]={
		sp=125, --pincer thing
		right=false,
		form=3
	}			
	fighters[4]={
		sp=127, --twix
		flp=true,
		right=false,
		form=4
	}		
	fighters[5]={
		sp=78, --arrow
		fast=true,
		flp=false,
		right=false,
		form=5 --middle then diag
	}	
	fighters[6]={
		sp=111, --h thing
		flp=false,
		right=false,
		form=6 --middle t
	}
	wave={
		locns={}
	}
end

function init_levels()
	level=1
	levels={}
	levels[1]={ name="zinc",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=0,
		colr_manta=10,
		colr_manta2=9,
		colr_main=6,
		colr_shad=13 }
	levels[2]={ name="lead",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=14,
		colr_space=1,
		colr_manta=0x08,
		colr_manta2=0x88,
		colr_main=5,
		colr_shad=0x85 }
	levels[3]={ name="copper",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=0,
		colr_manta=11,
		colr_manta2=0x8b,
		colr_main=4,
		colr_shad=0x84 }
	levels[4]={ name="silver",
		--fighters={1,2,3,4,5,6,2,1,5},
		fighters={4},
		min_runw_hits=12,
		colr_space=0,
		colr_manta=12,
		colr_manta2=0x8c,
		colr_main=6,
		colr_shad=13 }
	levels[5]={ name="iron",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=0,
		colr_manta=12,
		colr_manta2=0x8c,
		colr_main=0x8b,
		colr_shad=3 }
	levels[6]={ name="gold",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=0,
		colr_manta=6,
		colr_manta2=0x86,
		colr_main=9,
		colr_shad=0x89 }
	levels[7]={ name="platinum",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=3,
		colr_manta=0x8e,
		colr_manta2=8,
		colr_main=13,
		colr_shad=0x8d}
	levels[8]={ name="tungsten",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=0x084,
		colr_manta=12,
		colr_manta2=0x8c,
		colr_main=5,
		colr_shad=0x85 }
	levels[9]={ name="iridon",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=0,
		colr_manta=11,
		colr_manta2=0x8b,
		colr_main=12,
		colr_shad=0x8c }
	levels[10]={ name="kallisto",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=2,
		colr_manta=14,
		colr_manta2=0x8e,
		colr_main=6,
		colr_shad=13 }
	levels[11]={ name="tri-alloy",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=0,
		colr_manta=11,
		colr_manta2=0x8b,
		colr_main=4,
		colr_shad=0x84 }
	levels[12]={ name="quadmium",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,	
		colr_space=0,
		colr_manta=6,
		colr_manta2=0x86,
		colr_main=12,
		colr_shad=1 }
	levels[13]={ name="ergonite",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=1,
		colr_manta=0x8e,
		colr_manta2=8,
		colr_main=5,
		colr_shad=0x85 }
	levels[14]={ name="galactium",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=0,
		colr_manta=11,
		colr_manta2=0x8b,
		colr_main=13,
		colr_shad=0x8d }
	levels[14]={ name="picidium",
		fighters={1,2,3,4,5,6,2,1,5},
		min_runw_hits=12,
		colr_space=0,
		colr_manta=10,
		colr_manta2=0x8a,
		colr_main=0x8e,
		colr_shad=8 }
end
-->8
--update

function update_title()
	if btnp(❎) then
		default_colrs()
		init_ready()
	end
	
	if dbg and btnp(4) then
		level+=1
		if level==15 then
			level=1
		end
	end
end

function update_ready()
	if level==15 then
		level=1
	end
	if time()-ready_time>3
		or btnp(❎) then 
		if (manta.lives>0) then 
	
			--todo: warp to dreadnought
			init_game()
		else 
			init_title()
		end
	else
		animate_manta_roll(true)
	end
end

function update_bonus()
	if time()-medi_time>1.2
		or btnp(4)
		or btnp(❎) then
		medi_time=time()
		wave_idx+=1
	end
	if wave_idx==7 then
		init_destroy_dreadnought()	
	end
end

function update_game()
	update_manta()
	update_cam()
	animate_manta()
	update_bullets()
	update_explosions()
	update_dreadnought()
	update_fighters()
end

function update_manta()
	update_fireballs(manta.fireballs)
	
	if manta.destroyed then
		if time()-destroy_time>2.5 then
			init_ready()
		end
		return
	end
	
	if manta.landing 
		and manta.h==0 then
		level+=1
		init_bonus()
	end
	
	if not manta.turning 
		and not manta.landing then
		if btnp(⬅️) then 
			manta_acc(-1)
		end
		if btnp(➡️) then
			manta_acc(1)
		end
	end	

	if hit_map_flg(manta,
		flg_map_obstacle) then
		destroy_manta()
	else
		manta.x+=manta.dx
	end
			
	if btn(⬇️)	and manta.y<62 then
		manta.y+=1
	end
	if btn(⬆️)	and manta.y>2 then
		manta.y-=1
	end

	local is_rolled=manta.sp==sp_roll_90
	
	if not btn(❎) then
		fire_hold_time=time()
	elseif time()-fire_hold_time>.25 then
		if btnp(⬆️) then
			if m and manta.flp_v then
				roll_manta_back()
			else
				roll_manta(false)
			end
		elseif btnp(⬇️) then
			if is_rolled and not manta.flp_v then
				roll_manta_back()
			else
				roll_manta(true)
			end
		end
	end
	
	if btnp(❎) then
		fire_bullet()
	end
	
	local too_far_left=manta.x<1
	if too_far_left then
		manta.dx=dx_inc
		manta.turning=true
	else
		local too_far_right=manta.x>map_end-manta.x
		if too_far_right then
			manta.dx=-dx_inc
			manta.turning=true
		end
	end
	
	if is_rolled then
		manta.coll_y_min=2
		manta.coll_y_max=5
	else
		manta.coll_y_min=0
		manta.coll_y_max=7
	end	
	
	if not is_rolled
		and not manta.turning
		and land_now
		and manta.dx>0
		and hit_map_flg(manta,
		flg_map_runway) then
		manta.flp_h=false
		manta.dx=.25
		manta.landing=true
	end

end

function update_cam()
	if not manta.landing
		and not manta.destoryed then
  		cam_x=manta.x-64
  		camera(cam_x,-40)
 	end
end

function update_bullets()
	foreach(bullets, function(bullet)
		
		if bullet.sp==sp_bullet_fighter
			and (bullet.x>=manta.x
 			and bullet.x<=manta.x+16)
			and (bullet.y>=manta.y
				and bullet.y<=manta.y+8) 
			then
				destroy_manta()
				del(bullets,bullet)
				return
		end
		
		local hit_fi=false
		local hit_obs=hit_map_flg(
			bullet,flg_map_run_fi)
 	if hit_obs then
 		del(bullets,bullet)
			destroy_obstacle(hit_obs)
		else 
			hit_fi=hit_fighter(bullet)
	 	if hit_fi then
	 		del(bullets,bullet)
				destroy_fighter(hit_fi)
			end 
		end		
 	if not hit_obs 
 		and not hit_fi then
 		bullet.move(bullet)
 		local abs_x=bullet.x-cam_x
 		local is_off_scr = 
 		 abs_x<0 or abs_x>128
 		if is_off_scr then
 			del(bullets,bullet)
 		end
 	end

	end)	
end

function update_explosions()
	foreach(explosions, function(e)
		local burning=update_fireballs(e.fireballs)
		if not burning then
			del(explosions,e)
		end
	end)
end
	
function update_fireballs(
	fireballs)
	local burning=false
	foreach(fireballs, function(f)
		if f.active then
			burning=true
			f.x+=f.dx/f.mass
			f.y+=f.dy/f.mass
			f.r-=.2
			if f.c~=5 then
				f.c+=1
			end
			if f.c==11 then
				f.c=7
			end
			if f.r<.1 then
				f.active=false
			elseif f.r<3 then
				f.c=5
			end
		end
	end)
	return burning
end

function update_dreadnought()
	local min_fighters_hit=
		num_runw_hits>
		levels[level].min_runw_hits
	if min_fighters_hit
		and time()-land_time>fly_secs then
		land_now=true
	end
	if time()-fast_time>.08 then
		pal(11,rnd(16))
		fast_time=time()
	end
	if time()-medi_time>.45 then
		poke(0x5f1f,beacon_colr)
		if beacon_colr==8then
			beacon_colr=0x88
		else
			beacon_colr=8
		end
		if land_now then
			if land_colr==0 then
				land_colr=7
			else
				land_colr=0
			end
		end
		medi_time=time()
	end
end

function update_fighters()
	if	not landed 
		and #wave.locns==0
		and time()-wave_time>wave_wait 
		then
			wave_time=time()
			wave_wait=3+rnd(6)
			launch_wave()
	end

	local form=forms[wave.form]
	foreach(wave.locns, 
		function(l)
			form.move(l)
			local fighter_offscreen=
				(wave.right and l.x<cam_x-16)
				or (not wave.right and l.x>cam_x+144) 
			if fighter_offscreen then
				del(wave.locns,l)
			end
	end)
	
		-- fire stuff maybe
	if #wave.locns>1 
		and time()-wave_fire_time>
			wave_fire_wait 
		then
			wave_fire_time=time()
			wave_fire_wait=rnd(25)/10
			local i=flr(rnd(#wave.locns))+1
			local l=wave.locns[i]
			local b=new_bullet(l,
					sp_bullet_fighter)
					b.dx*=.6
			add(bullets,b)				
	end

end

function update_destroy_dreadnought()
	if time()-medi_time>1.2
		or btnp(4)
		or btnp(❎) then
		medi_time=time()
		wave_idx+=1
	end
	if wave_idx==3 then
		init_ready()
	end	
end
-->8
--draw

function draw_title()
	if not title_drawn then
		cls()
		camera(0,0)	
		default_colrs()
		local tx="kp73"
		outline(tx,64-#tx*2,41,5,6)
		tx="a pico-8 tribute"
		outline(tx,64-#tx*2,10,5,6)
		tx="to the original 1986 c-64"			
		outline(tx,64-#tx*2,18,5,6)
		tx="uridium"			
		outline(tx,64-#tx*2,26,5,6)			
		tx="press ❎"
		outline(tx,64-#tx*2,107,5,9)
		draw_logo(7)
		title_drawn=true
	end
	
	if time()-fast_time>.085 then
		fast_time=time()
		pal(9,title_colrs[1],1)
		pal(10,title_colrs[2],1)		
		pal(7,title_colrs[3],1)
		add(title_colrs,title_colrs[1])
		deli(title_colrs,1)
	end
	
	if dbg then
		rectfill(0,-0,128,8,0)
		print("🅾️ change start level "..level,0,0,7)
	end
end

function draw_ready()
	cls()
	camera(0,0)
	local tx="player 1"
	outline(tx,64-#tx*2,44,7,9,4)
	if (manta.lives>0) then
		tx="game on!"
		print(tx,64-#tx*2,57,7,9)
		tx=manta.lives.."    left"
		outline(tx,64-#tx*2,68,7,9,4)
		spr(manta.sp,54,67,1,1,manta.flp)
	else
		tx="game over!"
		print(tx,64-#tx*2,56,7)
	end
end

function draw_game()
	cls()

	--shadow colr
	poke(0x5f15,0x85)

	--manta colr
	poke(0x5f1a,levels[level].colr_manta)
	poke(0x5f19,levels[level].colr_manta2)

	--dreadnought colr
	poke(0x5f16,levels[level].colr_main)
	poke(0x5f1d,levels[level].colr_shad)
	
	draw_stars()
	draw_dreadnought()
	draw_stars_bodge()
	draw_bullets()
	draw_explosions()		
	draw_manta()
	draw_fighters()
	draw_hud()
end

function draw_hud()
	if dbg then
		print("cpu "..stat(1)*100,cam_x+41,-39,2)
		print("fps "..stat(7),cam_x+90,-32,2)
		print("deb "..manta.x,cam_x+90,-40,2)
	end
	print("1 up ♥"..manta.lives,cam_x+1,-39,7)
	print(manta.points,cam_x+1,-31,7)
	if land_now then
		print("land now!",cam_x+53,-31,land_colr)
	else
		if time()-slow_time>3 then
			if time()-slow_time>6 then
				slow_time=time()
 		end
 		print("picidium",cam_x+52,-31,13)
 	else
 		print(level.."."..levels[level].name,
 			cam_x+52,-31,7)
		end
	end
end

function draw_stars()
	rectfill(-64,-20,2048,100,
		levels[level].colr_space)
	foreach(stars, function(s)
		pset(cam_x+s.x,s.y,s.c)
	end)
end

function draw_stars_bodge()
	foreach(stars, function(s)
		if s.y>=70 then
			pset(cam_x+s.x,s.y,s.c)
		end
	end)
end

function draw_dreadnought()	
	map(0,0)	
	rectfill(-64,70,2048,90,
		levels[level].colr_space)
end

function draw_manta()
	if not manta.destroyed then
		spr_shad(manta.h,
			manta.sp,
			manta.x,manta.y,
			1,1,
			manta.flp_h,
			manta.flp_v,
			5)
	end
	draw_fireballs(manta.fireballs)
end

function draw_bullets()
	foreach(bullets, function(b)
		spr(b.sp,b.x,b.y,
			1,1,false,manta.flp_v)
	end)
end

function draw_explosions()
	foreach(explosions, 
		function(e)
			draw_fireballs(e.fireballs)
	end)
end

function draw_fireballs(
	fireballs)
	foreach(fireballs, 
		function(f)
			if f.active then
				circfill(f.x,f.y,f.r,f.c)
 		end
	end)
end

function draw_fighters()
	local i=1
	foreach(wave.locns, 
		function(l)
			spr(wave.sp,l.x,l.y,
				1,1,wave.flp)
--			spr_shad(5,wave.sp,
--				l.x,
--				l.y,
--				1,1,
--				wave.flp,
--				false,
--				13
--				)
		i+=i
	end)		
end

function draw_bonus()
	local tx="destruction sequence primed!"
	if wave_idx==1 then
		default_colrs()
		camera(0,0)
		cls()
	else
		draw_hud()
		if wave_idx==2 then
			outline(tx,64-#tx*2,30,7,8,4)
		elseif wave_idx==3 then
			tx="formation annihilation bonus:"
			outline(tx,64-#tx*2,44,7,8,4)
		elseif wave_idx==4 then
			--todo: wave bonus points
			tx="0".." x 00 = 0000";
			print(tx,64-#tx*2,58,7,8,4)
		elseif wave_idx==5 then
			tx="ship destruct bonus:"
			outline(tx,64-#tx*2,72,7,8,4)
		elseif wave_idx==6 then
			--todo: ship bonus points
			tx="0".." x 00 = 0000";
			print(tx,64-#tx*2,86,7,8,4)
		end
	end
end

function draw_destroy_dreadnought()
end

function spr_shad(depth,sp,
	x,y,w,h,fh,fv,colr)
	
	local shad_x=x+depth
	local shad_y=y+depth
	local sheet_start_x=flr(sp%16)*8
	local sheet_start_y=flr(sp/16)*8
	local colr_space=levels[level].colr_space
	
	for vert=0,7 do
	 local sheet_y=sheet_start_y
	 if fv then
			sheet_y+=7-vert
	 else
			sheet_y+=vert
	 end
	
	 for horiz=0,7 do
			local sheet_x=sheet_start_x
			if fh then
			  sheet_x+=7-horiz
			else
			  sheet_x+=horiz
			end
			s=sget(sheet_x,sheet_y)
			if s~=0 then
				local p=pget(shad_x+horiz,shad_y+vert)
				if p~=colr_space then			
			 	pset(shad_x+horiz,
			 		shad_y+vert,colr)
				end
			end				
		end
	
	end
	
	spr(sp,x,y,w,h,fh,fv)
end

function default_colrs()
	--default colrs
	for i=0x01,0x0f do
		poke(0x5f00+i,i)
		pal(i,i,1)
	end
end
-->8
--animate

function animate_manta()
	if manta.turning then
		if manta.sp>=sp_turn_end then 
			manta.sp=sp_level
			manta.turning=false
			manta.flp_h=manta.dx<1 		
		elseif time()-manta.anim_time>.04 then
			manta.anim_time=time()
			manta.sp+=1
		end
	end
	if manta.landing
		and manta.h>0
		and time()-stop_time>.3 then
		manta.h-=.5
		stop_time=time()
	end
end

function animate_manta_roll(right)
	if time()-manta.anim_time>.05 then
		manta.anim_time=time()
		if manta.sp==1 then
			manta.flp=right
			manta.sp=12
		else
			manta.sp-=1
			if manta.sp==6 then
				manta.sp=1
				manta.flp=not right
			end
		end
	end
end

function explode(obj,r)
	foreach(obj.fireballs, 
		function(f)
			if not f.active then
				f.active=true
				f.x=obj.x
				f.y=obj.y+1			
				f.dx=-.5+rnd(1)
				f.dy=-.5+rnd(1)
				f.mass=.5+rnd(1)
				f.r=.5+rnd(r)
				f.c=6
			end
		end)
end

-->8
--func

function reset_manta()
	manta.sp=1
	manta.x=0
	manta.y=32
	manta.h=4
	manta.flp_h=false
	manta.flp_v=false
	manta.dx=1
	manta.dy=0
	manta.turning=false
	manta.destroyed=false
	manta.landing=false
end

function update_map(level)
	local adr=0x2400
	if (level>5) then
		adr=0x1000
		level-=6
	end
	adr+=0x0200*level
	px9_mdecomp(0,0,adr,mget,mset)
end

function new_bullet(orig, sp)
	local aim_right=orig.dx>0
	local bullet={
		x=orig.x,
		y=orig.y,
		sp=sp,
		dx=dx_max*2,
		coll_y_min=1,
		coll_y_max=6,
		move=function(this)
			this.x+=this.dx
		end
	}
	if not aim_right then
		bullet.dx*=-1
		bullet.x-=5
	else
		bullet.x+=5
	end
	if sp==sp_bullet_narw then
		bullet.coll_y_min=2
		bullet.coll_y_max=5
	elseif sp==sp_bullet_roll then
		bullet.coll_y_min=5
		bullet.coll_y_max=5
	end
	return bullet
end

function destroy_manta()
	sfx(0)
	manta.destroyed=true
	explode(manta,12)
	local dx=0.2
	if manta.dx<1 then
		dx*=-1
	end
	manta.dx=dx
	manta.lives-=1
	destroy_time=time()
end

function destroy_obstacle(hit)
	local obst=obstacles[hit.sp]
	local e={
		x=hit.mx*8,
		y=hit.my*8,
		fireballs={}
	}
	init_fireballs(50,
		e.fireballs)
	add(explosions,e)
	explode(e,obst.fireball_r)
	manta.points+=obst.points
	if obst.points>25 then
	 num_runw_hits+=1	
	end
	sfx(obst.sfx)
	mset(hit.mx,hit.my,obst.sp_dmg)
end

function destroy_fighter(hit_fi)
	local e={
		x=hit_fi.x+4,
		y=hit_fi.y+4,
		fireballs={}
	}
	init_fireballs(50,
		e.fireballs)
	add(explosions,e)
	explode(e,5)
	manta.points+=1000
	sfx(1)
	del(wave.locns,hit_fi)
end

function fire_bullet()
	local sp=sp_bullet
	if manta.sp==8
		or manta.sp==9
		or manta.sp==11
		or manta.sp==12 then
		sp=sp_bullet_narw
	elseif manta.sp==sp_roll_90 then
		sp=sp_bullet_roll
	end
	sfx(3)
	add(bullets,new_bullet(manta,sp))
end

function manta_acc(k)
	local dx=manta.dx+(k*dx_inc)
	if abs(dx)>dx_max then
		return
	end
	if dx==0 then
		dx=k*dx_inc
		manta.turning=true
	end
	manta.dx=dx
end

--todo: some roll animation
function roll_manta(flp_v)
	if manta.sp==sp_90_roll then 
		manta.sp=sp_level
	else
		manta.sp=sp_roll_90
	end
	manta.flp_v=flp_v
	manta.flp_h=manta.dx>0
end

function roll_manta_back() 
	manta.sp=sp_level
	manta.flp_h=manta.dx<0
end

function launch_wave()
	sfx(4,2)
	local lf=levels[level].fighters
	wave=fighters[lf[wave_idx]]
	wave.locns={}
	local x=manta.x-64-16
	if wave.right then
		x=manta.x+64
	end
	dx=1
	if wave.right then
		dx=-1
	end
	local form=forms[wave.form]
	for i=1,5 do
		local y=form.y[i]
		if y~=-1 then
			add(wave.locns,{
					i=i,
					x=x+form.xd[i],
					y=y,
					dx=dx
			})
		end
	end

	--move to next wave
	wave_idx+=1
	if wave_idx>
		#lf then
		wave_idx=1
	end
	
end

--todo: replace these hacks with something more elegant

function move_left(l)
		local ldx=1
		if manta.dx<0 then
			ldx=dx_max
		end
		l.x-=ldx
end

function move_right(l)
		local ldx=1
		if manta.dx>0 then
			ldx=dx_max
		end
		l.x+=ldx
end

function move_left_loop(l)
		ldx=1
		if manta.dx<0 then
			ldx=dx_max
		end
		--todo: make this a loop/circle
		if manta.x+16>l.x then
			local a=manta.x-l.x/100
			l.y+=sin(a)
		end
		l.x-=ldx
end

function move_right_down(l)
		local ldx=1
		if manta.dx>0 then
			ldx=dx_max
		end
		l.x+=ldx
		if l.x>manta.x-16 then
			l.y+=1
		end
end

function move_right_splt(l)
		local ldx=1
		if manta.dx>0 then
			ldx=dx_max
		end
		l.x+=ldx
		local d=manta.x-l.x
		if d<50 then
			if l.i%2==0 then
				if l.y<45 then 
					l.y+=.5
				end
			elseif l.y>22 then
				l.y-=.5
			end
		end
end

function move_right_zip(l)
	local ldx=1
	if manta.dx>0 then
		ldx=dx_max
	end
	l.x+=ldx
	local d=manta.x-l.x
	if d<50 then
		if l.i%2~=0 then
			if l.y>25 then
				l.y-=.5
			end
		else
			if l.y<35 then
				l.y+=.5
			end		end
	end
end
-->8
--coll

function hit_map_flg(obj,flg)
	if obj.sp==sp_bullet_fighter then
		return
	end
	for coll_y=
		obj.y+obj.coll_y_min,
		obj.y+obj.coll_y_max do	
		if manta.flp_v 
			and obj.sp==sp_bullet_roll then
			coll_y-=3
		end
		local cx=obj.x
		local mx=cx/8
		local my=coll_y/8
		local sp=mget(mx,my)
		if fget(sp,flg) then
			return {
				sp=sp,
				mx=mx,
				my=my
			}
		end
	end
end

function hit_fighter(obj)
	if obj.sp==sp_bullet_fighter then
		return
	end
	for i=1,#wave.locns do
		local l=wave.locns[i]
	
		for coll_y=
			obj.y+obj.coll_y_min,
			obj.y+obj.coll_y_max do	
			if manta.flp_v 
				and obj.sp==sp_bullet_roll then
				coll_y-=3
			end
		
			if obj.x>=l.x
				and obj.x<=l.x+7
				and coll_y>=l.y
				and coll_y<=l.y+7 then
				return l
			end
			
		end
	
	end
end


-->8
-- 3rd party

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

function init_logo()
	--g=encoded logo, ns=encoded shadow
	g,ns={},"```う``らc``う``````````テ``オg``テ```````テト○をスト➡️すトoをh`bc`c`トトかをチト⧗をト○を|`せoらg`テトかテチトカんトかテ|`せ○オg`らc▤うう`らc`スう|`せトチg`きc…`|````オ`|`せク○g`きc…`|``き`オ`|`せこgg`きc▤`|``らaオ`|`せccg`きトかx|`きりaオx|`せc`g`きトかう|`られaオう|`せc`g`きト○う|`られaオう|`せc`g`きc`う|`られaオう|`せc`g`きc`うう`られaスううきせc`g`きc`うチトりれトかうストこc`g`きc`うチトれれト○うストこc`g`きc`うストりこトoうオトくc`g`きc`う``らc``う``きc`g``a`う``らc``う``きc`g````う``らc``う``きc`g````お``オg``テ``らc`g`テトトかストトトトトトトトトc`b`トトトかチトトトトトトトトトc```テトト○ストトトトトトトトトa```"
	--width,height
	w,h=126,24

	--colr gradient 0123456789:;<=>? == colrs 0-15 
	col="9:79:79:79:79:79:79:79:7"
	--colr gradient height 
	cbl=1
	--shadow colr
	scol=5
	sdx,sdy=1,1

	for n=0,3023 do
		if ord(ns,n\7+1)-96&2^(n%7)>0 then
			g[n]=ord(col,n\w\cbl+1) --logo body
			g[n+w*sdy+sdx]=scol --shadow
		end
	end
end

function draw_logo()
	local sx,sy=9,55

	--draw logo and shadow
	for n=0,3275 do
		if(g[n])pset(n%w+sx,n\w+sy,g[n])
	end
end


-- px9 decompress, memory-only
-- 273 tokens

function px9_mdecomp
(
	x0,y0, -- where to draw to
	src,   -- compressed data
	vget,  -- read fn (x,y)
	vset   -- write fn (x,y,v)
)
	local function vlist_val(l, val)
		-- find position
		for i=1,#l do
			if l[i]==val then
				for j=i,2,-1 do
					l[j]=l[j-1]
				end
				l[1] = val
				return i
			end
		end
	end

	-- bit cache is between 16 and 
	-- 31 bits long with the next
	-- bit always aligned to the
	-- lsb of the fractional part
	local cache,cache_bits=0,0
	local function getval(bits)
		if cache_bits<16 then
			-- cache next 16 bits
			cache+=%src>>>16-cache_bits
			cache_bits+=16
			src+=2
		end
		-- clip out the bits we want
		-- and shift to integer bits
		local val=cache<<32-bits>>>16-bits
		-- now shift those bits out
		-- of the cache
		cache=cache>>>bits
		cache_bits-=bits
		return val
	end

	-- get number plus n
	local function gnp(n)
		local bits=0
		repeat
			bits+=1
			local vv=getval(bits)
			n+=vv
		until vv<(1<<bits)-1
		return n
	end

	-- header
	local 
		w,h_1,      -- w,h-1
		eb,el,pr,
		x,y,
		splen,
		predict
		=
		gnp"1",gnp"0",
		gnp"1",{},{},
		0,0,
		0
		--,nil

	for i=1,gnp"1" do
		add(el,getval(eb))
	end
	for y=y0,y0+h_1 do
		for x=x0,x0+w-1 do
			splen-=1

			if(splen<1) then
				splen,predict=gnp"1",not predict
			end

			local a=y>y0 and vget(x,y-1) or 0

			-- create vlist if needed
			local l=pr[a]
			if not l then
				l={}
				for e in all(el) do
					add(l,e)
				end
				pr[a]=l
			end

			-- grab index from stream
			-- iff predicted, always 1
			local v=l[predict and 1 or gnp"2"]

			-- update predictions
			vlist_val(l, v)
			vlist_val(el, v)

			-- set
			vset(x,y,v)

			-- advance
			x+=1
			y+=x\w
			x%=w
		end
	end
end

__gfx__
00000000007770000007770000007000000070000007000000777000000777000000000000000000000000000000000000000000000000000000000000000000
00000000079977770079977000079a000000a00000a77000077aa7007777aa700007770000000000000000000000000000077700777777770000000000000000
0000000079a75700079a50000079a700000770000079170000099170007999177777aa700007777000000aa00007777077779970000000007777777700000000
000000007a75157007a51600007a5a000005a00000a77700007777700777777700799917777aaaa70007aaa077755a9700755a97000000000000000000000000
000000007a75157007a51600007a5a000005a00000a77700007777700777777700799917777aaaa7075aaaa777755a9700755a97000000000000000000000000
0000000079a75700079a50000079a700000770000079170000099170007999177777aa7000077770777777700007777077779970000000007777777777777777
00000000079977770079977000079a000000a00000a77000077aa7007777aa700007770000000000000000000000000000077700777777770000000000000000
00000000007770000007770000007000000070000007000000777000000777000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000666666666666d50000000000000766666666666667d67d666666666666666666666666666666666666666666
00000000000000000000000000000000000000006667d6666666d557777667777777666676767676665565566666666666666666666666666666666666666666
00000000000000000000000000000000000000006667d6666666d556666d7666666766666666666666ddd6666666666666666666666666666666666666666666
0000000000000777777777777770000000000000667a9d666666d556666d7666666766666666666666dbb7666666666666666666666666666666666666666666
000000000007766666666666666770000000000067a7d9d66666d556666d7666666766667776777666dbb76666666dddddd66666666666666666666666666666
0000000077766666666666666666677700000000667a9d666666d556666d76666667666666666666666777666666d00000076666666666666666666666666666
00000077666666666666666666666666770000006667d6666666d556666d7666666766666666666667d67d666666d00000076666666666677777777776666666
00007766666666666666666666666666667700006667d6666666d556666d76666667666676767676665565566666d0000007666666666676666666666d666666
000766666666666677777776666666666666d000666666666666d556666d7666666766666666666666666666000766666666d00066666676666666766d566666
00076666666666667666666d666666666666d0006ddddd666666d556666d766666676666767676767d666666000766666666d00066666676666666766d566666
00076666666666667666666d6ddddd666666d0006dbbbb766666d556666d7666666766666666666665566666000766666666d00066666676666666766d566666
00076666666666667666666d6d6666766666d0006dbbbb766666d556666d7666666766666766666666666666000766666666d00066666676666666766d566666
00076666666666667666666d6d6666766666d0006dbbbb766666d556666d76666667666667767776666666660000dddddddd000066666676666666766d566666
00076666666666667666666d667777766666d0006dbbbb766666d556666d766666676666676666667d666666000000000000000066666676666666766d566666
00076666666666667666666d666666666666d000667777766666d556666d7666666766666666666665566666000000000000000066666676777777666d566666
00076666666666666ddddddd666666666666d000666666666666d556666d7666666766667676767666666666000000000000000066666676666666666d566666
0000dd6666666666666666666666666666dd0000666666666666d556666d766666676666666666666d5666666666d0000007666666666676666666666d566666
000000dd666666666666666666666666dd0000006dddddd76666d556666d766666676666666667d66d5666666666d000000766666666666dddddddddd5566666
00000000ddd666666666666666666ddd000000006ddddd776666d556666d766666676666666666556d5666666666d00000076666666666665555555555666666
00000000000dd66666666666666dd000000000006ddbbb776666d556666d766666676666666666666d5666666666677777766666666666666666666666666666
0000000000000dddddddddddddd00000000000006ddbbb776666d556666d766666676666666666666d5666666666666666666666666666666666666666666666
00000000000000000000000000000000000000006ddbbb776666d556666d766666676666666667d66d5666666666666666666666666666666666666666666666
00000000000000000000000000000000000000006d7777776666d55dddd66dddddd7666666666655667777776666666666666666666666666666666666666666
0000000000000000000000000000000000000000666666666666d000000000000007666666666666666666666666666666666666666666666666666666666666
6666d550000000000007666600000000666666666666666666666666566666666666666666666666666666666666666666666666666666667777000000777700
6666d55000000000066766660000000066666666666666667676767655667676666666666666666666666666666666666666666666666666aaaaa77007999970
6666d5500000000006676666000000006666666666666666666666665666666666666666666666666666666666666666666666666666666609999900779aa997
6666d550000000000667666600000000666666666666666667666666666566666666777777777777777766666666dddddddddddddddd666600aaaaaa99aa77a9
6666d550000000000667666600000000666666667d667d66677677766665567666676666666666666666d666666d7070707070707070766600aaaaaa77aa99a7
6666d6577707770777676666000000006666666665566556676666665665666666676666666666666666d666666dd0d0d0d0d0d0d0d0766609999900997aa779
6666d57d067d067d067766660000000067d67d6666666666666666665566666666676666666666666666d666666d070707070707070776667777a77009777790
6666d65777d777d777676666000000006655655666666666767676765666767666676666666666666666d666666d0d0d0d0d0d0d0d0d7666aaaa000000999900
6666d55ddd0ddd0ddd676666677766666f166f1600000000666666667777777766676666a700007a6666d666666d70707070707070707666aaaaaaaa00777700
6666d55000000000066766667696d55661666166777777776666666667666766666766660a7007a06666d666666dd0d0d0d0d0d0d0d076669a0009a007aaaaa0
6666757070707070767766667969d555665566550000000066666666677777766667666600a77a006666d666666d0707070707070707766609a09a007a9999a9
6666d15d0d0d0d0d0d6766667696d5556656665600000000666666666766666766676666009aa9006666d666666d0d0d0d0d0d0d0d0d7666077777707a9007a9
6666d55000000000066766667969d5556f166f1600000000666666666766666d66676666007997006666d666666d70707070707070707666099999907a9007a9
6666d65777077707776766667696d55561666166000000006666666667ddddd66667666607a00a706666d666666dd0d0d0d0d0d0d0d0766609a09a007a7777a9
6666d57d067d067d067766667969d55566556655777777776666666667666d66666766667a0000a76666d666666d070707070707070776669a0009a00aaaaa90
6666d65777077707776766666ddd6655665666560000000066666666dddddddd66676666000000006666d666666d0d0d0d0d0d0d0d0d7666aaaaaaaa00999900
6666d55ddd0ddd0ddd676666000000006666666600000000f16666666655656666676666666666666666d666666d70707070707070707666077777a077777770
6666d55000000000066766660000000066666666000000006dd666666505555666676666666666666666d666666dd0d0d0d0d0d0d0d0766609a999409a99a990
6666d55000000000066766660000000066666666777777771166655655d506d066676666666666666666d666666d0707070707070707766600a000000a90a900
6666d55000000000066766660000000066666666000000006dd666665d0d005666676666666666666666d666666d0d0d0d0d0d0d0d0d76667777777aaaaaaaaa
6666d5500000000006676666000000007d667d660000000011556556650656556666dddddddddddddddd666666667777777777777777666699a999949a99a944
6666d55000000000066766660000000065566556777777776dd5556665006d0566666666666666666666666666666666666666666666666600a000000a90a900
6666d0000000000000076666000000006666666600000000f166555656505556666666666666666666666666666666666666666666666666077777a077777770
6666d00000000000000766660000000066666666000000006dd66656666556666666666666666666666666666666666666666666666666660999994099999990
0000000000000000000766666666d0006666666600000000666665566666666666676666000000006666d666000000000000000009aaa9997777770000077770
0000000000000000000766666666d0006666666600000000666666666660565666676666000000006666d66600000000000000009aaa9000007aaa00777aaa70
0000000000000000000766666666d000666666660000000066666556665d056666676666000770006666d666000000000000000007d000000777770794949499
000077777777000000076666666667776666666600000000666666666500605677766666007aa900666667770000000000000000999999007aaaaa7a07aaaaa9
000766666666d0000000dddd6666666666666ddd00000000666666666650d56666666666007aa90066666666000000000000000007d000007aaaaa9a77777779
000766666666d00000000000666666666666d00077777777666666666665056666666666000990006666666600000000000000009aaa90000999990994949499
000766666666d00000000000666666666666d000000000006666666666650666666666660000000066666666000000000000000009aaa999007aa900007aaa90
000766666666d00000000000666666666666d0000000000066666666666666666666666600000000666666660000000000000000000000009999990000099990
ffffff07e5fff7900098842e0f905041a523b98de87e34a9a82575060585b3a17bcde69a5fa2243a252fa9ddee9fe769b0627b19170c161fc746a31a4366aade
68bd1fce4761c26ba91deb9cee6b7cebe6bdf67f6b429c17c1d7e9be83e8367c17c175f9c539debd1743bbea3eed17c1fe9fd9fedf3cf1df5ef96e7afb4fddf6
2efb76f3ef9416148f34a1dfe9f5ffdf95420c1efeef0f38df098cf0e8dfeff38bae92f3c9fceff0ffb8ff7cfbff39ffbc3dcff6edccfbfff11f3f3aff3cdff8
eff4ffbabde71fffaaff7584ef0ffcef76ff7bffd95fff7ff3ce1ff7cff5eff3ff7a4cff5fbcf2fb8df298cff6fffbbeff8ffdd267abef9eff9ff7dfffebf9cf
a19f3cf2e97cfafcef7e7ee41effed7e7306ffbffff30ffff00cdff4eff5f7c2f78ff7c17d57dfff58c97dfff70efff34cfff788ffff0fcefff48fff30222efb
4e75f743fffbfffdff03c3bfff71fff73efff74cf32cf19fff32fccfff39ff943bce5bfcfff59fcdd3ff71ff38ff1cff1e77ffff5efffc4ec447bac34eff57e9
f301e4eff39f142479114872fbd8eb9beaf92787c13fb9cffac57ca0161a1e49ff8ff90cf6f3d5ffff6efffecfbffefbfffdf7e28ffff3cf53fffd72ff3efffe
fd1e8cfff1afff741a1ffff8ceffff4effb701ec0b94e8eff0efdf7ffd8fff345000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff7900098842e0f905041a523b98de87e34a9a82575060585b3a17bcde69a5fa2243a252fa9ddee9fe769b0627b19170c161fc746a31a4366aade
68bd1fce4761c26ba91deb9cee6b7cebe6bdf67f6b429c17c1d7e9be83e8367c17c175f9c539debd1743bbea3eed17c1fe9fd9fedf3cf1df5ef96e7afb4fddf6
2efb76f3ef9416148f34a1dfe9f5ffdf95420c1efeef0f38df098cf0e8dfeff38bae92f3c9fceff0ffb8ff7cfbff39ffbc3dcff6edccfbfff11f3f3aff3cdff8
eff4ffbabde71fffaaff7584ef0ffcef76ff7bffd95fff7ff3ce1ff7cff5eff3ff7a4cff5fbcf2fb8df298cff6fffbbeff8ffdd267abef9eff9ff7dfffebf9cf
a19f3cf2e97cfafcef7e7ee41effed7e7306ffbffff30ffff00cdff4eff5f7c2f78ff7c17d57dfff58c97dfff70efff34cfff788ffff0fcefff48fff30222efb
4e75f743fffbfffdff03c3bfff71fff73efff74cf32cf19fff32fccfff39ff943bce5bfcfff59fcdd3ff71ff38ff1cff1e77ffff5efffc4ec447bac34eff57e9
f301e4eff39f142479114872fbd8eb9beaf92787c13fb9cffac57ca0161a1e49ff8ff90cf6f3d5ffff6efffecfbffefbfffdf7e28ffff3cf53fffd72ff3efffe
fd1e8cfff1afff741a1ffff8ceffff4effb701ec0b94e8eff0efdf7ffd8fff345000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff7900098842e0f905041a523b98de87e34a9a82575060585b3a17bcde69a5fa2243a252fa9ddee9fe769b0627b19170c161fc746a31a4366aade
68bd1fce4761c26ba91deb9cee6b7cebe6bdf67f6b429c17c1d7e9be83e8367c17c175f9c539debd1743bbea3eed17c1fe9fd9fedf3cf1df5ef96e7afb4fddf6
2efb76f3ef9416148f34a1dfe9f5ffdf95420c1efeef0f38df098cf0e8dfeff38bae92f3c9fceff0ffb8ff7cfbff39ffbc3dcff6edccfbfff11f3f3aff3cdff8
eff4ffbabde71fffaaff7584ef0ffcef76ff7bffd95fff7ff3ce1ff7cff5eff3ff7a4cff5fbcf2fb8df298cff6fffbbeff8ffdd267abef9eff9ff7dfffebf9cf
a19f3cf2e97cfafcef7e7ee41effed7e7306ffbffff30ffff00cdff4eff5f7c2f78ff7c17d57dfff58c97dfff70efff34cfff788ffff0fcefff48fff30222efb
4e75f743fffbfffdff03c3bfff71fff73efff74cf32cf19fff32fccfff39ff943bce5bfcfff59fcdd3ff71ff38ff1cff1e77ffff5efffc4ec447bac34eff57e9
f301e4eff39f142479114872fbd8eb9beaf92787c13fb9cffac57ca0161a1e49ff8ff90cf6f3d5ffff6efffecfbffefbfffdf7e28ffff3cf53fffd72ff3efffe
fd1e8cfff1afff741a1ffff8ceffff4effb701ec0b94e8eff0efdf7ffd8fff345000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff7900098842e0f905041a523b98de87e34a9a82575060585b3a17bcde69a5fa2243a252fa9ddee9fe769b0627b19170c161fc746a31a4366aade
68bd1fce4761c26ba91deb9cee6b7cebe6bdf67f6b429c17c1d7e9be83e8367c17c175f9c539debd1743bbea3eed17c1fe9fd9fedf3cf1df5ef96e7afb4fddf6
2efb76f3ef9416148f34a1dfe9f5ffdf95420c1efeef0f38df098cf0e8dfeff38bae92f3c9fceff0ffb8ff7cfbff39ffbc3dcff6edccfbfff11f3f3aff3cdff8
eff4ffbabde71fffaaff7584ef0ffcef76ff7bffd95fff7ff3ce1ff7cff5eff3ff7a4cff5fbcf2fb8df298cff6fffbbeff8ffdd267abef9eff9ff7dfffebf9cf
a19f3cf2e97cfafcef7e7ee41effed7e7306ffbffff30ffff00cdff4eff5f7c2f78ff7c17d57dfff58c97dfff70efff34cfff788ffff0fcefff48fff30222efb
4e75f743fffbfffdff03c3bfff71fff73efff74cf32cf19fff32fccfff39ff943bce5bfcfff59fcdd3ff71ff38ff1cff1e77ffff5efffc4ec447bac34eff57e9
f301e4eff39f142479114872fbd8eb9beaf92787c13fb9cffac57ca0161a1e49ff8ff90cf6f3d5ffff6efffecfbffefbfffdf7e28ffff3cf53fffd72ff3efffe
fd1e8cfff1afff741a1ffff8ceffff4effb701ec0b94e8eff0efdf7ffd8fff345000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff7900098842e0f905041a523b98de87e34a9a82575060585b3a17bcde69a5fa2243a252fa9ddee9fe769b0627b19170c161fc746a31a4366aade
68bd1fce4761c26ba91deb9cee6b7cebe6bdf67f6b429c17c1d7e9be83e8367c17c175f9c539debd1743bbea3eed17c1fe9fd9fedf3cf1df5ef96e7afb4fddf6
2efb76f3ef9416148f34a1dfe9f5ffdf95420c1efeef0f38df098cf0e8dfeff38bae92f3c9fceff0ffb8ff7cfbff39ffbc3dcff6edccfbfff11f3f3aff3cdff8
eff4ffbabde71fffaaff7584ef0ffcef76ff7bffd95fff7ff3ce1ff7cff5eff3ff7a4cff5fbcf2fb8df298cff6fffbbeff8ffdd267abef9eff9ff7dfffebf9cf
a19f3cf2e97cfafcef7e7ee41effed7e7306ffbffff30ffff00cdff4eff5f7c2f78ff7c17d57dfff58c97dfff70efff34cfff788ffff0fcefff48fff30222efb
4e75f743fffbfffdff03c3bfff71fff73efff74cf32cf19fff32fccfff39ff943bce5bfcfff59fcdd3ff71ff38ff1cff1e77ffff5efffc4ec447bac34eff57e9
f301e4eff39f142479114872fbd8eb9beaf92787c13fb9cffac57ca0161a1e49ff8ff90cf6f3d5ffff6efffecfbffefbfffdf7e28ffff3cf53fffd72ff3efffe
fd1e8cfff1afff741a1ffff8ceffff4effb701ec0b94e8eff0efdf7ffd8fff345000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff7900098842e0f905041a523b98de87e34a9a82575060585b3a17bcde69a5fa2243a252fa9ddee9fe769b0627b19170c161fc746a31a4366aade
68bd1fce4761c26ba91deb9cee6b7cebe6bdf67f6b429c17c1d7e9be83e8367c17c175f9c539debd1743bbea3eed17c1fe9fd9fedf3cf1df5ef96e7afb4fddf6
2efb76f3ef9416148f34a1dfe9f5ffdf95420c1efeef0f38df098cf0e8dfeff38bae92f3c9fceff0ffb8ff7cfbff39ffbc3dcff6edccfbfff11f3f3aff3cdff8
eff4ffbabde71fffaaff7584ef0ffcef76ff7bffd95fff7ff3ce1ff7cff5eff3ff7a4cff5fbcf2fb8df298cff6fffbbeff8ffdd267abef9eff9ff7dfffebf9cf
a19f3cf2e97cfafcef7e7ee41effed7e7306ffbffff30ffff00cdff4eff5f7c2f78ff7c17d57dfff58c97dfff70efff34cfff788ffff0fcefff48fff30222efb
4e75f743fffbfffdff03c3bfff71fff73efff74cf32cf19fff32fccfff39ff943bce5bfcfff59fcdd3ff71ff38ff1cff1e77ffff5efffc4ec447bac34eff57e9
f301e4eff39f142479114872fbd8eb9beaf92787c13fb9cffac57ca0161a1e49ff8ff90cf6f3d5ffff6efffecfbffefbfffdf7e28ffff3cf53fffd72ff3efffe
fd1e8cfff1afff741a1ffff8ceffff4effb701ec0b94e8eff0efdf7ffd8fff345000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff7900098842e0f905041a523b98de87e34a9a82575060585b3a17bcde69a5fa2243a252fa9ddee9fe769b0627b19170c161fc746a31a4366aade
68bd1fce4761c26ba91deb9cee6b7cebe6bdf67f6b429c17c1d7e9be83e8367c17c175f9c539debd1743bbea3eed17c1fe9fd9fedf3cf1df5ef96e7afb4fddf6
2efb76f3ef9416148f34a1dfe9f5ffdf95420c1efeef0f38df098cf0e8dfeff38bae92f3c9fceff0ffb8ff7cfbff39ffbc3dcff6edccfbfff11f3f3aff3cdff8
eff4ffbabde71fffaaff7584ef0ffcef76ff7bffd95fff7ff3ce1ff7cff5eff3ff7a4cff5fbcf2fb8df298cff6fffbbeff8ffdd267abef9eff9ff7dfffebf9cf
a19f3cf2e97cfafcef7e7ee41effed7e7306ffbffff30ffff00cdff4eff5f7c2f78ff7c17d57dfff58c97dfff70efff34cfff788ffff0fcefff48fff30222efb
4e75f743fffbfffdff03c3bfff71fff73efff74cf32cf19fff32fccfff39ff943bce5bfcfff59fcdd3ff71ff38ff1cff1e77ffff5efffc4ec447bac34eff57e9
f301e4eff39f142479114872fbd8eb9beaf92787c13fb9cffac57ca0161a1e49ff8ff90cf6f3d5ffff6efffecfbffefbfffdf7e28ffff3cf53fffd72ff3efffe
fd1e8cfff1afff741a1ffff8ceffff4effb701ec0b94e8eff0efdf7ffd8fff345000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff7900098842e0f905041a523b98de87e34a9a82575060585b3a17bcde69a5fa2243a252fa9ddee9fe769b0627b19170c161fc746a31a4366aade
68bd1fce4761c26ba91deb9cee6b7cebe6bdf67f6b429c17c1d7e9be83e8367c17c175f9c539debd1743bbea3eed17c1fe9fd9fedf3cf1df5ef96e7afb4fddf6
2efb76f3ef9416148f34a1dfe9f5ffdf95420c1efeef0f38df098cf0e8dfeff38bae92f3c9fceff0ffb8ff7cfbff39ffbc3dcff6edccfbfff11f3f3aff3cdff8
eff4ffbabde71fffaaff7584ef0ffcef76ff7bffd95fff7ff3ce1ff7cff5eff3ff7a4cff5fbcf2fb8df298cff6fffbbeff8ffdd267abef9eff9ff7dfffebf9cf
a19f3cf2e97cfafcef7e7ee41effed7e7306ffbffff30ffff00cdff4eff5f7c2f78ff7c17d57dfff58c97dfff70efff34cfff788ffff0fcefff48fff30222efb
4e75f743fffbfffdff03c3bfff71fff73efff74cf32cf19fff32fccfff39ff943bce5bfcfff59fcdd3ff71ff38ff1cff1e77ffff5efffc4ec447bac34eff57e9
f301e4eff39f142479114872fbd8eb9beaf92787c13fb9cffac57ca0161a1e49ff8ff90cf6f3d5ffff6efffecfbffefbfffdf7e28ffff3cf53fffd72ff3efffe
fd1e8cfff1afff741a1ffff8ceffff4effb701ec0b94e8eff0efdf7ffd8fff345000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000008000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000010100008000000000000000000000000000000100000000000000000000000000000000000000000000000000
2c08f7f2a4d1eff9efc73f45021c7eedbf3fdbdf89fcadf9fd78540ef84378f4bfffc1ff61cdffe2cafcf7ff103f3efa3fdcffe4fff2bfb94dfe3fff23fe4f67fe57ffabffc7fcbffe673dfe6fffbbffdfff90f83f7ef9e107fb2191ffe5ff73fd9ffeb9c54ed73ffdbffe6fffbfe793df223f90fff1ff99fff5e979fcfaecff
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff705effff08008948e2f00905145a329bd88ee7439a8a52576050583b6eb9dd52eb558446a5e435bbddf3fd2c174c6e23e380c3e2f9c8744269cc54db0db7e3d9e92c586c35a37d93dd6d8f7dddb6dfee6d4992e338fa3cd7711cc78ee338ae3eb926dbb7e368765dc7bde338def33bdffb873ffacb3fcd4f7fe9bbdfc4
7fcf7efc93c282f08734fa3dbffefbb34880c3dffde107fb21911f34bf1f8fca013f9ccffe07ff87ffc5afff8fffc9d3fc5fdeccafff1bf1efa3ffc3fd7ffe47ffa7db7ec9ffea7ff5fbfe5fffb3ff9bf57ff7ffebf13ffc3ffe2fff9fc4fff4cb0f3fd80f89fc5fffb7ebfff7cf2d76bafee9fff8fffcbf3e9ffc19f9c12f9e
c7afcffedfe74ee17fdee73760fff7fffdff1f00f73ff97ffdb1fce1ff715cd7f5ff0f725eff7f81ffbf10ff7f21feffc293ffff6088bf92fffcd1fcfffe7fffc3f0ecff4ffcff8bffbf11bf097fe4ff7f3cf3ff47fe27cdb2d73effffe48ff3f7df7fff1ffcedffaffcff979c896e9587fcafcef307c2c9ff27b7842e2308cf
f2933bd7f5530e8f63fe87f27f721d2b84858653fee37f027ffd74fdff99ff7ff3efbffffe6f7fb9e0ffeff0d7fc6f9ffc7fffb77f8723ffffe7ff0f85c6ff1fb2ffbf93ffed4138c32639fa3ff8f7df7fe3ffff14ffa3cfff5ffaff4fcbff277f2cff7fe1ff2f24ff7fe1ffff2cff7fc76d6ffecb0000000000000000000000
fffffff05dff7f0a0089482614781c54098948a96b66daf17c804161ad64b9603632ce8cd67a41a3522b1199549a4ea89c46050e8bcdf891de76c3ed783ddfaf68c71e8d5a2a3aad86c556acffffff98ec598fa33b8ee3dc711cd79e2bdb755dbfecba0ebd7a4db74db74db6235bb25dd964bbb3bdfdcef71ef1c3b33f7ef925
17ff847fce1c39728fa21c523ffd327ffd96fdf7e39f397e7d3e1cc0fcfbc9e7c8cf7ec833e93f47fefebdf91f2cd7ffe17ff1ffc8fe1fb3ffc9ffc535ac7ef9e59718ff9cf925f2f6972fff9bdfe3fff33ffa3f25ffabf0ffb2ff1782f99ffdcfecc7ffdbff6ec7ffef3bbebc92fc270ef33ffc3ff6fb5ffe3fffa7ffd7f77d
fb2b5384bff3cf05bbfeb7ffdff47ffc93fff342f3f3cff6bffb5fffbfb7fff9f7fd21c7c1fffbfffebf6ffeffc091feff83feff05dd75ede2e9ff7ff8ff13ffff82e4ff6f84df3ffe07f8bffe5fd3ff6bfcff8fb3ff7fe4ff9ffcff95ffeb95ffffe28770f4ff7d3d4ffbfcfb2f2987e3e5274f3edf2ffbff33fef0e4e7dfe4
b7fb97fee1ff4f9c381cfc661e47feffcdffdfe1ffef5cfeffcf0ffdff43ffffe87ff6ffe8feffc1ffaecffeff51fa8033ff7fe9ff3f75feff51927fff97f3bf7cf27f91f9cb1ff3ff27feff44f2ff27feffd3fcffa51fec1fff5b00ffa7ffffb4fc7ff2c7f2ff17feff42f2ff17feffd0f2ff7fdcf6e6bf0c00000000000000
ffffff705eff7f0a0089482614781c94ba66485351c7f3010685a1ca46c699d15a2f68545a2b592e1870586c259a4ea89cc68c4c2a47b61baee7fb15ed78fd8e4755618f462d2c864eab57ac5f27fb613d8e6bcf957f9b63d36dd36d93edc8966c5736d9ee6cefaeabc7aeebd85fdff9de914444f2c39723db711cbfec388ef8
e397fdf2cf4fd95fbffd97e3c7e3c101c49fc9e5c7fc7a0dfe3c72ccf5efcf3ffffc77fe96487eff1f9cbefa35a01cfea9fb97eff83ffc10ff8bffc7ff24fbbfd8bbfd6f5cf9fff863fbff3c47fe47ffa7f95f25df17dfc90552bffffe7b8c9fcefc15798f5fe2d7edcfffd7ff2cfe6fe9ff0e09e2ff97702579857f66e67ff8
7fdcfe97ffcfffe961ff3223e16f27963ffe48fff8d1ff75a196f9dffe7f97fff1fe3bf83fffafffdfcbfffc78f8b5fff7fffdff1f20f9ff07e1f7b04922f1ff17ce3c4ff2ff1f7e9eff3f610f6ffcdda3ff67cf334ff2ff2f8ef8ff1bd78e6317872b9fffd10ffbff1ffeff88d7fb8b5979b8fbff4ffeffcaff7ff99ff3ff3e
f2ff67dcfbff37ff7fe75eff1fffe3ff47fbfafffc7ffeff4cfbe57fc811e465f3ff778ee4fff13f7c73cbf0477ff3ff077ec2e1918770e4fffffcff21feffd0e5ff1ffd7ef8ff3fec0d5ffeffd2ff7ffadbf7cbfccfffe7c9fffcff3fcdff5ffac1fe0100000000000000000000000000000000000000000000000000000000
ffffff705eff7f09008948e2f00905145a329bd88ee7439a8a52576050583b1ab7dc6ea9f52a42a352f29addeef97e960b26b79171c061f17c643aa13466aaed86dbf1ec74162cb69ad1bec9eeb6c7be6edb6ff7b624c9711c7d9eeb388e63c7711c579f5c93eddb7134bbaee3de711ceff99deffdc31ffde59fe6a7bff4dd6f
e2bf673ffe496141f8431afd9e5ffffd5924c0e1effef083fd90c80f8efdfe3fb8ea293f9ccffe0fff8bffc7bfff93ffcbd3fc6fdeccbfff1ff1f3a3ffc3fd8ffe4fffabdb7ef1ffaaff5748fef0cffe67ffb7ff9df5fff73fecf17ffc5ffe3fffa7c4fff5cb2fbfd82f89fc6fffbfebfff8df2d76bafee9fff97ffdffbe9ffc
1af9c32f9ec7afcffee7e74ee1ffdee73760fffbff3ff0ff0fc0fd4ffe5f7f2c7ff87f1cd775fdff859cd7ff7fe0ff3fc4ff7f88fffff0ecff4ff8ff0322e2bfe4577f34ffbfffdfff303cfbff17ff7fe3ff7fc43fc21ff9ff23cffcff93ff49b3ecb5cfff5ff9dc3dff17ff83ffc1ffe177ffffe5ffcfe44c74ab3ce4ff759e
3f104efe3ff9414297118427bf8dbeb9ae9f72781cf39bfcaf5cc70a61a1e194fff89fc06f3f5dffffe6ffeffcfbefbfffdf7f2ef8ff3ffc35ffdf27ffe3ffefdfe1c8ff1ffaff47a1f1ff8fecffffe4ff7b10ceb0498efe0ffefdf7dff8ff430500000000000000000000000000000000000000000000000000000000000000
ffffff705eff7f09008948e2f00905145a329bd88ee7439a8a52576050583b1ab7dc6ea9f52a42a352f29addeef97e960b26b79171c061f17c643aa13466aaed86dbf1ec74162cb69ad1bec9eeb6c7be6edb6ff7b624c9711c7d9eeb388e63c7711c579f5c93eddb7134bbaee3de711ceff99deffdc31ffde59fe6a7bff4dd6f
e2bf673ffe496141f8431afd9e5ffffd5924c0e1effef083fd90c80f8efdfe3fb8ea293f9ccffe0fff8bffc7bfff93ffcbd3fc6fdeccbfff1ff1f3a3ffc3fd8ffe4fffabdb7ef1ffaaff5748fef0cffe67ffb7ff9df5fff73fecf17ffc5ffe3fffa7c4fff5cb2fbfd82f89fc6fffbfebfff8df2d76bafee9fff97ffdffbe9ffc
1af9c32f9ec7afcffee7e74ee1ffdee73760fffbff3ff0ff0fc0fd4ffe5f7f2c7ff87f1cd775fdff859cd7ff7fe0ff3fc4ff7f88fffff0ecff4ff8ff0322e2bfe4577f34ffbfffdfff303cfbff17ff7fe3ff7fc43fc21ff9ff23cffcff93ff49b3ecb5cfff5ff9dc3dff17ff83ffc1ffe177ffffe5ffcfe44c74ab3ce4ff759e
3f104efe3ff9414297118427bf8dbeb9ae9f72781cf39bfcaf5cc70a61a1e194fff89fc06f3f5dffffe6ffeffcfbefbfffdf7f2ef8ff3ffc35ffdf27ffe3ffefdfe1c8ff1ffaff47a1f1ff8fecffffe4ff7b10ceb0498efe0ffefdf7dff8ff430500000000000000000000000000000000000000000000000000000000000000
ffffff705eff7f09008948e2f00905145a329bd88ee7439a8a52576050583b1ab7dc6ea9f52a42a352f29addeef97e960b26b79171c061f17c643aa13466aaed86dbf1ec74162cb69ad1bec9eeb6c7be6edb6ff7b624c9711c7d9eeb388e63c7711c579f5c93eddb7134bbaee3de711ceff99deffdc31ffde59fe6a7bff4dd6f
e2bf673ffe496141f8431afd9e5ffffd5924c0e1effef083fd90c80f8efdfe3fb8ea293f9ccffe0fff8bffc7bfff93ffcbd3fc6fdeccbfff1ff1f3a3ffc3fd8ffe4fffabdb7ef1ffaaff5748fef0cffe67ffb7ff9df5fff73fecf17ffc5ffe3fffa7c4fff5cb2fbfd82f89fc6fffbfebfff8df2d76bafee9fff97ffdffbe9ffc
1af9c32f9ec7afcffee7e74ee1ffdee73760fffbff3ff0ff0fc0fd4ffe5f7f2c7ff87f1cd775fdff859cd7ff7fe0ff3fc4ff7f88fffff0ecff4ff8ff0322e2bfe4577f34ffbfffdfff303cfbff17ff7fe3ff7fc43fc21ff9ff23cffcff93ff49b3ecb5cfff5ff9dc3dff17ff83ffc1ffe177ffffe5ffcfe44c74ab3ce4ff759e
3f104efe3ff9414297118427bf8dbeb9ae9f72781cf39bfcaf5cc70a61a1e194fff89fc06f3f5dffffe6ffeffcfbefbfffdf7f2ef8ff3ffc35ffdf27ffe3ffefdfe1c8ff1ffaff47a1f1ff8fecffffe4ff7b10ceb0498efe0ffefdf7dff8ff430500000000000000000000000000000000000000000000000000000000000000
ffffff705eff7f09008948e2f00905145a329bd88ee7439a8a52576050583b1ab7dc6ea9f52a42a352f29addeef97e960b26b79171c061f17c643aa13466aaed86dbf1ec74162cb69ad1bec9eeb6c7be6edb6ff7b624c9711c7d9eeb388e63c7711c579f5c93eddb7134bbaee3de711ceff99deffdc31ffde59fe6a7bff4dd6f
e2bf673ffe496141f8431afd9e5ffffd5924c0e1effef083fd90c80f8efdfe3fb8ea293f9ccffe0fff8bffc7bfff93ffcbd3fc6fdeccbfff1ff1f3a3ffc3fd8ffe4fffabdb7ef1ffaaff5748fef0cffe67ffb7ff9df5fff73fecf17ffc5ffe3fffa7c4fff5cb2fbfd82f89fc6fffbfebfff8df2d76bafee9fff97ffdffbe9ffc
1af9c32f9ec7afcffee7e74ee1ffdee73760fffbff3ff0ff0fc0fd4ffe5f7f2c7ff87f1cd775fdff859cd7ff7fe0ff3fc4ff7f88fffff0ecff4ff8ff0322e2bfe4577f34ffbfffdfff303cfbff17ff7fe3ff7fc43fc21ff9ff23cffcff93ff49b3ecb5cfff5ff9dc3dff17ff83ffc1ffe177ffffe5ffcfe44c74ab3ce4ff759e
3f104efe3ff9414297118427bf8dbeb9ae9f72781cf39bfcaf5cc70a61a1e194fff89fc06f3f5dffffe6ffeffcfbefbfffdf7f2ef8ff3ffc35ffdf27ffe3ffefdfe1c8ff1ffaff47a1f1ff8fecffffe4ff7b10ceb0498efe0ffefdf7dff8ff430500000000000000000000000000000000000000000000000000000000000000
__sfx__
00070000266101d620326300563016630386302363004630326202b6200e62036610046102c6103260021600346002a6000460019600226001160013600066000a60004600066000160002600016000060000600
000300001b620276201b6201162021620266102361013610246101e61021610126100961007610006100661004610046100761002610056100161000600006000060000600006000060000600006000060000600
000200001e62021630116300762006610056100361001610006100061000610006100061000610006100660002600046000360000600006000060000600006000060000600006000060000600006000060000600
00030000105301253014530115300d530085300453001500015000150001500055000250003400014000400004000040000100002200012000000000000000000000000000000000000000000000000000000000
000100001544018440184401544013440134401544017440184401844015440144401444017440184401744015440154401644018440194401844016440154401544017440194401944017440154401544017440
00020000256700d67036670216701a67021670136700c6702b670106701f6701a670116702e670256702067018670216602b6601b6500865012640206301b6301d6202362020610196101561019610366003a600
000900001d34322333163530362400703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
000d00003205035000330003500034000000003500036000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
0b 7d6e0759
0d 7317307f
07 797f7d7f
0a 0f5e7f72
0b 3f7a6179
0f 417f6338
07 2e6b7f0f
07 644c7f3f
08 20203c79
0d 7f0b0678
06 29794f1f
0e 72706c7f
0e 3f7c7f09
01 7f7f117f
0c 097f647f
0c 6f5c737f
0a 3f7e274d
0b 32573e7f
0e 7f640f73
0d 777f7f7d
0d 79577f7f
0f 647f2f64
0b 75172456
04 431e723f
02 791e1f08
0e 277f1f7c
06 20214b08
0f 42337c65
0d 4e757d14
0f 4363187f
07 217c0f5c
09 470a6121
0f 61147f78
0b 1f406f7f
0f 6d7f3f7c
0f 727f7c48
0d 622f717f
0a 7c723f7d
0e 7f7e1d7f
06 3f737f6f
0f 0e7c7f1d
03 7f7f131a
0f 7f7f477e
0d 7f4b7e1f
0a 07610c1b
0f 64686f3f
0b 7e7a6b7c
03 7f1d0244
