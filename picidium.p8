pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
dbg=true

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
	init_fighters()
	init_levels()
	init_manta()
	init_bullets()
	init_dreadnought()
	init_stars()

	title_drawn=false
	title_colrs={9,10,7}

	_update60=update_title
	_draw=draw_title
end

function init_ready()
	ready_time=time()
	land_time=time()
	fire_hold_time=time()
	stop_time=time()
	wave_time=time()
	wave_wait=3
	wave_idx=1
	num_runw_hits=0
	land_now=false
	fly_secs=30
	land_colr=6
	update_map(level)

	_update60=update_ready
	_draw=draw_ready
end

function init_game()
	cam_x=0
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
	sp_roll_45=10
	sp_level=1
	sp_turn_end=12
	init_fireballs(50,manta.fireballs)
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
end

function init_dreadnought()
	map_start=0
	map_end=2164
	map_bottom=64
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

function init_fighters()
	fighters={}
	fighters[1]={
		sp=79, -- sphere thing
		right=true,
		form=1 --staircase fly level
	}
	fighters[2]={
		sp=95, -- donut
		right=true,
		form=2 --bottom level then loop fly level
	}
	fighters[3]={
		sp=125, --pincer thing
		right=false,
		form=3 --centre unzip to circle
	}			
	fighters[4]={
		sp=127, --twix
		flp=true,
		right=false,
		form=4 --diagonal then something
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
		locs={}
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
		fighters={1,2,3,4,5,6,2,1,5},
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
		init_ready()
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

	local is_rolled=manta.sp==sp_roll_45
	
	if not btn(❎) then
		fire_hold_time=time()
	elseif time()-fire_hold_time>.25 then
		if btnp(⬆️) then
			if is_rolled and manta.flp_v then
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
 		and not hit_spr then
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
		and #wave.locs==0
		and time()-wave_time>wave_wait 
		then
			wave_time=time()
			wave_wait=3+rnd(6)
			launch_wave()
	end

	foreach(wave.locs, 
		function(l)
			update_fighter_x(l)
			local fighter_offscreen=
				(wave.right and l.x<cam_x-16)
				or (not wave.right and l.x>cam_x+144) 
			if fighter_offscreen then
				del(wave.locs,l)
			end
	end)
	
end

function update_fighter_x(l)
		local dx=.5
		local manta_mv=manta.dx>0
		local wave_mv=not wave.right
		if wave_mv==manta_mv then
			dx=abs(manta.dx)+1
		end
		if wave.fast then
			dx+=.5
		end
		if wave.right then
			dx*=-1
		end
		dx=dx

		l.x+=dx
end
-->8
--draw

function draw_title()
	if not title_drawn then
		cls()
		camera(0,0)	
		outline("kp73's pico-8 tribute",22,10,5,6)			
		outline("to the original 1986 c-64",15,18,5,6)			
		outline("uridium",48,26,5,6)			
		outline("press ❎",46,107,5,9)
		draw_logo()
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
	--default colrs
	pal(9,9,1)
	pal(10,10,1)		
	pal(7,7,1)
	poke(0x5f15,0x5)
	poke(0x5f1a,0xa)
	poke(0x5f19,0x9)
	poke(0x5f16,0x6)
	poke(0x5f1d,0xd)

	cls()
	camera(0,0)
	outline("player 1",50,44,7,9,4)
	if (manta.lives>0) then
		print("game on!",51,57,7,9)
		outline(manta.lives.."♥ left",50,68,7,9,4)
	else
		print("game over!",48,56,7)
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
		print("mem "..stat(0),cam_x+90,-40,2)
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
 		print("picidium",cam_x+52,-31,7)
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

function draw_fighters()
	local i=1
	foreach(wave.locs, 
		function(l)
			spr_shad(5,wave.sp,
				l.x,
				l.y,
				1,1,
				wave.flp,
				false,
				13
				)
		i+=i
	end)		
end
-->8
--animate

function animate_manta()
	if manta.turning then
 		if manta.sp==sp_turn_end then 
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
--fun

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
	local bullet={}
	local aim_right=orig.dx>0
	bullet.x=orig.x
	bullet.y=orig.y
	bullet.sp=sp
	bullet.aim=1*dx_max*2
	bullet.coll_y_min=1
	bullet.coll_y_max=6
	if sp==sp_bullet_narw then
		bullet.coll_y_min=2
		bullet.coll_y_max=5
	elseif sp==sp_bullet_roll then
		bullet.coll_y_min=5
		bullet.coll_y_max=5
	end
	if not aim_right then
		bullet.aim*=-1
	end
	bullet.move=function(this)
		this.x+=this.aim
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
	del(wave.locs,hit_fi)
end

function fire_bullet()
	local sp=sp_bullet
	if manta.sp==8
		or manta.sp==9
		or manta.sp==11
		or manta.sp==12 then
		sp=sp_bullet_narw
	elseif manta.sp==sp_roll_45 then
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
		manta.sp=sp_roll_45
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
	wave.locs={}
	local x=cam_x-64
	if wave.right then
		x=cam_x+192
	end
	for i=1,5 do
		add(wave.locs,
			{
				x=x,
				y=5+(i*10)
			})
	end

	--move to next wave
	wave_idx+=1
	if wave_idx>
		#lf then
		wave_idx=1
	end
	
end

-->8
--coll

function hit_map_flg(obj,flg)
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
	for i=1,#wave.locs do
		local l=wave.locs[i]
	
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
	local sx,sy=7,50

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
6666d55000000000066766667696d55661666166000000006666666667666766666766660a7007a06666d666666dd0d0d0d0d0d0d0d076669a0009a007aaaaa0
6666757070707070767766667969d555665566550000000066666666677777766667666600a77a006666d666666d0707070707070707766609a09a007a9999a9
6666d15d0d0d0d0d0d6766667696d5556656665600000000666666666766666766676666009aa9006666d666666d0d0d0d0d0d0d0d0d7666077777707a9007a9
6666d55000000000066766667969d5556f166f1600000000666666666766666d66676666007997006666d666666d70707070707070707666099999907a9007a9
6666d65777077707776766667696d55561666166000000006666666667ddddd66667666607a00a706666d666666dd0d0d0d0d0d0d0d0766609a09a007a7777a9
6666d57d067d067d067766667969d55566556655000000006666666667666d66666766667a0000a76666d666666d070707070707070776669a0009a00aaaaa90
6666d65777077707776766666ddd6655665666560000000066666666dddddddd66676666000000006666d666666d0d0d0d0d0d0d0d0d7666aaaaaaaa00999900
6666d55ddd0ddd0ddd676666000000006666666600000000f16666666655656666676666666666666666d666666d70707070707070707666077777a077777770
6666d55000000000066766660000000066666666000000006dd666666505555666676666666666666666d666666dd0d0d0d0d0d0d0d0766609a999409a99a990
6666d55000000000066766660000000066666666000000001166655655d506d066676666666666666666d666666d0707070707070707766600a000000a90a900
6666d55000000000066766660000000066666666000000006dd666665d0d005666676666666666666666d666666d0d0d0d0d0d0d0d0d76667777777aaaaaaaaa
6666d5500000000006676666000000007d667d660000000011556556650656556666dddddddddddddddd666666667777777777777777666699a999949a99a944
6666d55000000000066766660000000065566556000000006dd5556665006d0566666666666666666666666666666666666666666666666600a000000a90a900
6666d0000000000000076666000000006666666600000000f166555656505556666666666666666666666666666666666666666666666666077777a077777770
6666d00000000000000766660000000066666666000000006dd66656666556666666666666666666666666666666666666666666666666660999994099999990
0000000000000000000766666666d0006666666600000000666665566666666666676666000000006666d666000000000000000009aaa9997777770000077770
0000000000000000000766666666d0006666666600000000666666666660565666676666000000006666d66600000000000000009aaa9000007aaa00777aaa70
0000000000000000000766666666d000666666660000000066666556665d056666676666000000006666d666000000000000000007d000000777770794949499
00007777777700000007666666666777666666660000000066666666650060567776666600000000666667770000000000000000999999007aaaaa7a07aaaaa9
000766666666d0000000dddd6666666666666ddd00000000666666666650d566666666660000000066666666000000000000000007d000007aaaaa9a77777779
000766666666d00000000000666666666666d00000000000666666666665056666666666000000006666666600000000000000009aaa90000999990994949499
000766666666d00000000000666666666666d000000000006666666666650666666666660000000066666666000000000000000009aaa999007aa900007aaa90
000766666666d00000000000666666666666d0000000000066666666666666666666666600000000666666660000000000000000000000009999990000099990
ffffff07e5fff78000794c12199052402c67c3f12d4549ab20382cad299dc369a5fa2243a2dd27bb4ee9fe769b0627b19170c161fa9dde9b9e482d899a6bb1e6
7c3b3d95b285c664bb32767bdebe6bdf67f6b4294f83afc37d17c17ce83e83eae39b62bd7b3e8667d57cdb3e83e5f9bc997ddf343f7cf29def11f3d3bfbe73a0
b02cdbc3964fb7efbf1ff4190078f5bffefc6f7722f7b6e7f3e15930ee48bc3efbff1cff16dcff2eaccf7fff01f3e3aff3cdff4eff2ffb9bd4eff3ff32eff476
ef75ffbaf9347eff5ff3be1ff7bffddfffef784cff1fbcf0f38df098cff2fff9beff4ffcd267abef9eff5ff7bfffd3f9cf639f18cff8fffccffaf4fc3e7d76ff
fe777e17754e9fb08dffcfffeffb70fef39ff5df0bcf0eff17c57d5fff70276efff10101e9cfff5034cf49cf7eec10c2c3bffff0fff72efff54cf52cf19fffb1
7dcffff8ff943dce5bfcfff19f3ecfdffdf7f7ef5dfff39fffb293d294ca78c34ef72fc3f301e4eff39f1424791148769fbcd9beaf92787c13ff349ff19be851
2c243c92ff1ff318fdefbdfff79f5eff9f195cf52eff9f4ef7afffcfb3fff76efffdc19fffb3ffff7243effff8dfff79cff3f02c91639c1dfdf7df5f7d8fffb3
50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff78000794c12199052402c67c3f12d4549ab20382cad299dc369a5fa2243a2dd27bb4ee9fe769b0627b19170c161fa9dde9b9e482d899a6bb1e6
7c3b3d95b285c664bb32767bdebe6bdf67f6b4294f83afc37d17c17ce83e83eae39b62bd7b3e8667d57cdb3e83e4f5e276e57ff0dcf1fb46bf74cf4fcefafd82
c2807f2f4a1dfe9ffe7cf35420c1e7defbf3bdfd98cfda9fdf8745e08f34874ffbff1cff16dcff2eaccf7fff01f3e3aff3cdff4eff2ffb9bd4eff3ff32eff476
ef75ffbaff7ccffbef76d3eff6ffbbfffdff098ff3e79f1e70bf1219ff5eff37dff9ef9b5ce47df3dffbeff6fffb7e39fd22f309ff1fff99ff5f9e97cfafceff
dfee709d3f710bff9fffdff7f0edf72ffbaf169f1cff3e8beabefff04eccfff30202c39fffb0688f929ffcf1270fcefff3cfff98fff711f790f74efff6c53fff
f3ef72dc2b7de3fff74ef83f7ff7ffdf9f75ffff4efffa4e5f79426d34e12ff397e9f18072fff9cf021abc802c3bcf5eec57df493c3e89ff1acff8c57ca0161a
1e49ff8ff90cf6ffdefffbcf2fffcf8c2ef21fffc72ff3dff7efd9fff33ffff6e8cfffd9ffff31a1ffff7cefffb4eff9701ec0b94e8efefbefafb6cfffd92041
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff78000794c12199052402c67c3f12d4549ab20382cad299dc369a5fa2243a2dd27bb4ee9fe769b0627b19170c161fa9dde9b9e482d899a6bb1e6
7c3b3d95b285c664bb32767bdebe6bdf67f6b4294f83afc37d17c17ce83e83eae39b62bd7b3e8667d57cdb3e83e4f5e276e57ff0dcf1fb46bf74cf4fcefafd82
c2807f2f4a1dfe9ffe7cf35420c1e7defbf3bdfd98cfda9fdf8745e08b71874ffbff1cff16dcff2eaccf7fff01f3e3aff3cdff4eff2ffb9bd4eff3ff32eff476
ef75ffbaf950b9ff7dffca7cffdef77fffbff121ff7cf2f3cf06f3422ffbcff7eaff3df37b8d9eaf7aff7dffdeff7fc72fbd4e702ff3eff33ffbe3d3f8f5f9df
fbfdd99b19d3f710bff9fffdff7f0edf72ffbaf169f1cff3e8beabefff04eccfff30202c39fffb0688f929ffcd9415e9dfff78fff31ffff22ef21ef8cfffd8b6
efff7cff4a966fad7efff8cf17efeffefbf3ffaefff9cfff59c7ea521be12f09ff9c3fcf04839fff4e7090d56401e95ef277eabe7ac1e17ccff05ef74ea36580
b0d07acf7cff40e7bff6ffff5e79ff7e7461f798ff7e39ff9eff3ffecfff99fff7374efffecffff90d8ffff36ffff52fffc380768d4274f7ff5f7df53efffe41
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff78000794c12199052402c67c3f12d4549ab20382cad299dc369a5fa2243a2dd27bb4ee9fe769b0627b19170c161fa9dde9b9e482d899a6bb1e6
7c3b3d95b285c664bb32767bdebe6bdf67f6b4294f83afc37d17c17ce83e83eae39b62bd7b3e8667d57cdb3e83e4f5e276e57ff0dcf1fb46bf74cf4fcefafd82
c2807f2f4a1dfe9ffe7cf35420c1e7defbf3bdfd98cfda9fdf8745e08b71874ffbff1cff16dcff2eaccf7fff01f3e3aff3cdff4eff2ffb9bd4eff3ff32eff476
ef75ffbaf950b9ff7dffca7cffdef77fffbff121ff7cf2f3cf06f3422ffbcff7eaff3df37b8d9eaf7aff7dffdeff7fc72fbd4e702ff3eff33ffbe3d3f8f5f9df
fbfdd7e609d3f710bff9fffdff7f0edf72ffbaf169f1cff3e8beabefff04eccfff30202c39fffb0688f929ffcf1270fcefff3cfff98fff711f790f74efff6c53
ffff3ef72dc2b7de3fff74ef83f7ff7ffdf9f75ffff4efffa4e579426d34e12ff397e9f18072fff9cf021abc802c3bcf5eec57df493c3e89ff1acff8c57ca016
1a1e49ff8ff90cf6ffdefffbcf2fffcf8c2ef21fffc72ff3dff7efd9fff33ffff6e8cfffd9ffff31a1ffff7cefffb4eff9701ec0b94e8efefbefafb6cfffd920
20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff78000794c12199052402c67c3f12d4549ab20382cad299dc369a5fa2243a2dd27bb4ee9fe769b0627b19170c161fa9dde9b9e482d899a6bb1e6
7c3b3d95b285c664bb32767bdebe6bdf67f6b4294f83afc37d17c17ce83e83eae39b62bd7b3e8667d57cdb3e83ead74e276e57ff0dcf1fb46bf74cf4fcefafd8
2c2807f2f4a1dfe9ffe7cf35420c1e7defbf3bdfd98cfda9fdf8745e083521874ffbff1cff16dcff2eaccf7fff01f3e3aff3cdff4eff2ffb9bd4eff3ff32eff4
76ef75ffbaff7ccffbef76d3eff6ffbbfffdff098ff3e79f1e70bf1219ff5eff37dff9ef9b5ce47df3dffbeff6fffb7e39fd22f309ff1fff99ff5f9e97cfafce
ffdfee709d3f710bff9fffdff7f0edf72ffbaf169f1cff3e8beabefff04eccfff30202c39fffb0688f929ffc92154976ffff1efff4cfffb88fb48f32fff73ea9
ffff1ff396a9db6f9fff32f7c9fbffbffefcfbafff72fff752f8fbe8426d34e12ff397e9f18072fff9cf021abc802c3bcf5eec57df493c3e89ff1acff8c57ca0
161a1e49ff8ff90cf6ffdefffbcf2fffcf8c2ef21fffc72ff3dff7efd9fff33ffff6e8cfffd9ffff31a1ffff7cefffb4eff9701ec0b94e8efefbefafb6cfffd9
20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff78000794c12199052402c67c3f12d4549ab20382cad299dc369a5fa2243a2dd27bb4ee9fe769b0627b19170c161fa9dde9b9e482d899a6bb1e6
7c3b3d95b285c664bb32767bdebe6bdf67f6b4294f83afc37d17c17ce83e83eae39b62bd7b3e8667d57cdb3e83eac72f176e57ff0dcf1fb46bf74cf4fcefafd8
2c2807f2f4a1dfe9ffe7cf35420c1e7defbf3bdfd98cfda9fdf8745e0835e0f8ef7ff38ff3ca9ff5c599ffeff12e7c74ff78bff9cff5ef737b9cff7ef74cff9e
ccffaef75fff89ff7dffca7cffdef77fffbff121ff7cf2f3cf06f3422ffbcff7eaff3df37b8d9eaf7aff7dffdeff7fc72fb54e702ff3eff33ffbe3d3f8f5f9df
fbfddf02b7ef206ff3fffbfffe1cbff4ef75f3c2f38ff7c17d57dfff18c99fff70404872fff71c01f352ff935e4e9dfff78fff31ffff22ef21ef8cfffd8b6eff
f7cff4a956fad7efff8cf17efeffefbf3ffaefff9cfff59c3efa32985f0978cff4e97e702c9cff72f3848e23280fc2f79b37d5f35e0f836ef782ff327d1b2485
86835ef3ef720fbdf7bffff2fbcff3f32b8fb4cff3f9cff4fff9f77efffccfffb932fff77effff486cffff1bffff29ff7e14833c6293afbffafbefa1fff77aff
77a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff78000794c12199052402c67c3f12d4549ab20382cad299dc369a5fa2243a2dd27bb4ee9fe769b0627b19170c161fa9dde9b9e482d899a6bb1e6
7c3b3d95b285c664bb32767bdebe6bdf67f6b4294f83afc37d17c17ce83e83eae39b62bd7b3e8667d57cdb3e83ead74e276e57ff0dcf1fb46bf74cf4fcefafd8
2c2807f2f4a1dfe9ffe7cf35420c1e7defbf3bdfd98cfda9fdf8745e083500e1dffef70ff7853ffb8b23ffdff34cf8f8eff07ff39ffbcff6e639fffcff88ff3d
99ff5dffaef590b9ff7dffca7cffdef77fffbff121ff7cf2f3cf06f3422ffbcff7eaff3df37b8d9eaf7aff7dffdeff7fc72fbd4e702ff3eff33ffbe3d3f8f5f9
dffbfdd9ee422fcf50cef7eff7fffd387ff9cffae785e70fff83eabeafff30933ffff08080f4efff2812e7a4ef37a4415e9dfff78fff31ffff22ef21ef8cfffd
8b6efff7cff4a966fad7efff8cf17efeffefbf3ffaefff9cfff59c3ea32985f0978cff4e97e702c9cff72f3848e23280fc2f79b37d5f35e0f836ef782ff327d1
b248586835ef3ef720fbdf7bffff2fbcff3f32b8fb4cff3f9cff4fff9f77efffccfffb932fff77effff486cffff1bffff29ff7e14833c6293afbffafbefa1fff
77a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff07e5fff78000794c12199052402c67c3f12d4549ab20382cad299dc369a5fa2243a2dd27bb4ee9fe769b0627b19170c161fa9dde9b9e482d899a6bb1e6
7c3b3d95b285c664bb32767bdebe6bdf67f6b4294f83afc37d17c17ce83e83eae39b62bd7b3e8667d57cdb3e83ead74e276e57ff0dcf1fb46bf74cf4fcefafd8
2c2807f2f4a1dfe9ffe7cf35420c1e7defbf3bdfd98cfda9fdf8745e083500e1dffef70ff7853ffb8b23ffdff34cf8f8eff07ff39ffbcff6e639fffcff88ff3d
99ff5dffaef590b9ff7dffca7cffdef77fffbff121ff7cf2f3cf06f3422ffbcff7eaff3df37b8d9eaf7aff7dffdeff7fc72fbd4e702ff3eff33ffbe3d3f8f5f9
dffbfdd7e609d3f710bff9fffdff7f0edf72ffbaf169f1cff3e8beabefff04eccfff30202c39fffb0688f929ffc92434976ffff1efff4cfffb88fb48f32fff73
ea9ffff1ff396a9db6f9fff32f7c9fbffbffefcfbafff72fff752f8be8426d34e12ff397e9f18072fff9cf021abc802c3bcf5eec57df493c3e89ff1acff8c57c
a0161a1e49ff8ff90cf6ffdefffbcf2fffcf8c2ef21fffc72ff3dff7efd9fff33ffff6e8cfffd9ffff31a1ffff7cefffb4eff9701ec0b94e8efefbefafb6cfff
d9200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
ffffff705effff080097c42191092504c2763c1fd25494ba0283c2da92d93c1a4bad57111a956eb95d72cff7b35c30b98d8c030e8bd7ecf6dc744269cc54db0db7e3d9e9ac152c36a3dd91b3dbf675db7ebbb725497a1c7d9eeb388e63c7711c579f5c93eddb7134bbaee3de711ca72f9733affb87e68f5fb2fd237e7af6d76f
1416847b79d2e8f7fcf7e39f22010ebff6df9fedef44fed6fdfe3f780e873cf08770e98fff87ffc59affc795f9f17f22fe7cf47fb8ffcbffe6ff739bfc8ffe4ffcaf4eff2ffe5fbf4ad8fccffe6f3dfe77ffbfffe1ff91f85f7ef9e30ffb2391ffe7ff74fdbffebac54ed73ffddffe7fffc7e793ff267f90fff3ff9afff7e979
fcfaec7ffeee7383ecf90bd8fffd7fffff07c0fb4ffe573f2c3ff87f1cd775fdff839cf9ff0b048427ffffc1103f253fba55a23cfbff13ffffe2ff6fc45fc21ff9ff1fd7fcff91ff49d3ecb5cfff3ff9e3fc1ffcfcf3dffffaff2bffff259f6b49ac873ce47ff23c3f104efe3ff9414297118467f9cb9debfa2987c731ff47f9
1fb98e15c242c329fff13f81dffedbff9ff9e57ffa91c55fe27ffae4fffa3ffd3bffffe6ffef1cf9ff3fff7f2834feff90fdff99fc4f0fc21936c9d1df7ffdf5d7f8ff3f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff705eff7f080097c42191092504c2763c1fd25494ba0283c2da92d93c965aaf22342add72bbe49eef67b960721b19071c16afd9edb9e984d298a9b61b6ec7b3d3592b586c46bb2367b7edebb6fd766f4b92f438fa3cd7711cc78ee338ae3eb926dbb7e368765dc7bde338cef7c399d7fd43f3c72fd9fe113f3dfbeb370a
0bc2bd3c69f47bfefbf14f9100875ffbefcff677227f6b7e3f1e95036e9947fffb1ffc1fd6fc2faecc7fff0ff1e3a3ffc3fd4ffe2fff9bdbe4fff33fe2ff74e67ff5bffa59b0f97ffdcf7afcdffe77ffbfff21f17ffcf2c30ff64322ffcbffe7fa3ffd738b9dae7ffa7ffddffe7fcf27bf4d7e20ffe3ff33ffebd3f3f8f5d9ff
fbdde706d9f317b0fff9fffd7f0fde7ff2bffa61f9c1ffe3b8aeebff0fe4ccff3f20203cf9ff0b86f829f9cf1f72f0ecff3ffcff89ff7f117f097fe4ff6f5cf3ff3ffe27cdb2d73eff7fe48ff3f77ffffdf957ffffe4ffafe47549623de421ff93e7f98170f2ffc90f12ba8c203ccb5fee5cd74f393c8ef91fcaffc875ac1016
1a4ef98fff09fcf6dffeffcb2fffcf8f2cfe12ffcf27ffd3ffe7dff9ff33ffffe6c8ffdff9ff3fa1f1ff7fecffbfe4ff7910ceb0498efefeebafbfc6ffdf29bf53000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff705eff7f080097c42191092504c2763c1fd25494ba0283c2da92d93c965aaf22342add72bbe49eef67b960721b19071c16afd9edb9e984d298a9b61b6ec7b3d3592b586c46bb2367b7edebb6fd766f4b92f438fa3cd7711cc78ee338ae3eb926dbb7e368765dc7bde3384e5f2e675ef70fcd1fbf64fb47fcf4ecafdf28
2c08f7f2a4d1eff9efc73f45021c7eedbf3fdbdf89fcadf9fd78540eb813791efffd0ffe0f6bfe1757e6bfff87f8f1d1ffe1fe27ff97ffcd6df2fff91ff17f3af3bffa5ffd9ce8fcbffe673dfe6fffbbffdfff90f83f7ef9e107fb2191ffe5ff73fd9ffeb9c54ed73ffdbffe6fffbfe793df263f90fff1ff99fff5e979fcfaec
fffdee736b459ebf80fdcfffefff7bf0fe93ffd50fcb0ffe1fc7755dff7f2067feff0101e1c9ff5f30c44fc97f6ee4c0c2b3fffff0ff27feff45fc25fc91ffbf71cdfffff89f34cd5efbfcff913fcedffffdf7e75ffdff93ffbf92cf96c47ac843fe27cff303e1e4ff931f247419417896bfdcb9ae9f72781cf33f94ff91eb58
212c349cf21fff13f8edbffdff975ffe9f1f59fc25fe9f4ffea7ffcfbff3ff67feffcd91ffbff3ff7f42e3ffffd8ff7fc9fff3209c61931cfdfdd75f7f8dffbf53000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

