-- Based on Elizabet's RDM lua: https://www.ffxiah.com/forum/topic/53934/a-rdm-gearswap/
--
--[[
        Custom commands:

        Becasue /sch can be a thing... I've opted to keep this part 

        Shorthand versions for each strategem type that uses the version appropriate for
        the current Arts.
                                        Light Arts              Dark Arts
        gs c scholar light              Light Arts/Addendum
        gs c scholar dark                                       Dark Arts/Addendum
        gs c scholar cost               Penury                  Parsimony
        gs c scholar speed              Celerity                Alacrity
        gs c scholar aoe                Accession               Manifestation
        gs c scholar addendum           Addendum: White         Addendum: Black
    
        Toggle Function: 
        gs c toggle melee               Toggle Melee mode on / off for locking of weapons
        gs c toggle idlemode            Toggles between Refresh, DT and MDT idle mode.
        gs c toggle nukemode            Toggles between Normal and Accuracy mode for midcast Nuking sets (MB included)  
        gs c toggle mainweapon			cycles main weapons in the list you defined below
		gs c toggle subweapon			cycles main weapons in the list you defined below

        Casting functions:
        these are to set fewer macros (1 cycle, 5 cast) to save macro space when playing lazily with controler
        
        gs c nuke cycle                 Cycles element type for nuking
        gs c nuke cycledown             Cycles element type for nuking in reverse order    
	gs c nuke enspellup             Cycles element type for enspell
	gs c nuke enspelldown		Cycles element type for enspell in reverse order 

        gs c nuke t1                    Cast tier 1 nuke of saved element 
        gs c nuke t2                    Cast tier 2 nuke of saved element 
        gs c nuke t3                    Cast tier 3 nuke of saved element 
        gs c nuke t4                    Cast tier 4 nuke of saved element 
        gs c nuke t5                    Cast tier 5 nuke of saved element 
        gs c nuke helix                 Cast helix2 nuke of saved element 
        gs c nuke storm                 Cast Storm buff of saved element  if /sch
	gs c nuke enspell		Cast enspell of saved enspell element		

        HUD Functions:
        gs c hud hide                   Toggles the Hud entirely on or off
        gs c hud hidemode               Toggles the Modes section of the HUD on or off
        gs c hud hidejob		Toggles the Job section of the HUD on or off
        gs c hud lite			Toggles the HUD in lightweight style for less screen estate usage. Also on ALT-END
        gs c hud keybinds               Toggles Display of the HUD keybindings (my defaults) You can change just under the binds in the Gearsets file. Also on CTRL-END

        // OPTIONAL IF YOU WANT / NEED to skip the cycles...  
        gs c nuke Ice                   Set Element Type to Ice DO NOTE the Element needs a Capital letter. 
        gs c nuke Air                   Set Element Type to Air DO NOTE the Element needs a Capital letter. 
        gs c nuke Dark                  Set Element Type to Dark DO NOTE the Element needs a Capital letter. 
        gs c nuke Light                 Set Element Type to Light DO NOTE the Element needs a Capital letter. 
        gs c nuke Earth                 Set Element Type to Earth DO NOTE the Element needs a Capital letter. 
        gs c nuke Lightning             Set Element Type to Lightning DO NOTE the Element needs a Capital letter. 
        gs c nuke Water                 Set Element Type to Water DO NOTE the Element needs a Capital letter. 
        gs c nuke Fire                  Set Element Type to Fire DO NOTE the Element needs a Capital letter. 
--]]

include('organizer-lib') -- optional
res = require('resources')
texts = require('texts')
include('Modes.lua')

-- Define your modes: 
-- You can add or remove modes in the table below, they will get picked up in the cycle automatically. 
-- to define sets for idle if you add more modes, name them: sets.me.idle.mymode and add 'mymode' in the group.
-- Same idea for nuke modes. 
idleModes = M('refresh', 'dt')
meleeModes = M('normal', 'dt')
nukeModes = M('normal', 'acc')

------------------------------------------------------------------------------------------------------
-- Important to read!
------------------------------------------------------------------------------------------------------
-- This will be used later down for weapon combos, here's mine for example, you can add your REMA+offhand of choice in there
-- Add you weapons in the Main list and/or sub list.
-- Don't put any weapons / sub in your IDLE and ENGAGED sets'
-- You can put specific weapons in the midcasts and precast sets for spells, but after a spell is 
-- cast and we revert to idle or engaged sets, we'll be checking the following for weapon selection. 
-- Defaults are the first in each list

mainWeapon = M('Daybreak', 'Lathi', 'Malevolence')
subWeapon = M('Ammurapi Shield', 'Enki Strap')
------------------------------------------------------------------------------------------------------

----------------------------------------------------------
-- Auto CP Cape: Will put on CP cape automatically when
-- fighting Apex mobs and job is not mastered
----------------------------------------------------------
CP_CAPE = "Mecisto. Mantle" -- Put your CP cape here
----------------------------------------------------------

-- Setting this to true will stop the text spam, and instead display modes in a UI.
-- Currently in construction.
use_UI = true
hud_x_pos = 2200    --important to update these if you have a smaller screen
hud_y_pos = 500     --important to update these if you have a smaller screen
hud_draggable = true
hud_font_size = 8
hud_transparency = 180 -- a value of 0 (invisible) to 255 (no transparency at all)
hud_font = 'Impact'


-- Setup your Key Bindings here:
	windower.send_command('bind ^insert gs c nuke cycle')        -- ctrl insert to Cycles Nuke element
	windower.send_command('bind ^delete gs c nuke cycledown')    -- ctrl delete to Cycles Nuke element in reverse order   
	windower.send_command('bind ^f12 gs c toggle idlemode')       -- ctrl F12 to change Idle Mode    
	windower.send_command('bind ^f11 gs c toggle meleemode')      -- ctrl F11 to change Melee Mode  
	windower.send_command('bind !f9 gs c toggle melee') 		-- Alt-F9 Toggle Melee mode on / off, locking of weapons
	windower.send_command('bind !f8 gs c toggle mainweapon')	-- Alt-F8 Toggle Main Weapon
	windower.send_command('bind ^f8 gs c toggle subweapon')		-- CTRL-F8 Toggle sub Weapon.
	windower.send_command('bind !` input /ma Stun <t>') 		-- Alt-` Quick Stun Shortcut.
	windower.send_command('bind ^home gs c nuke enspellup')		-- ctrl Home Cycle Enspell Up
	windower.send_command('bind ^PAGEUP gs c nuke enspelldown')  -- ctrl PgUP Cycle Enspell Down
	windower.send_command('bind ^f10 gs c toggle mb')           -- F10 toggles Magic Burst Mode on / off.
	windower.send_command('bind !f10 gs c toggle nukemode')		-- Alt-F10 to change Nuking Mode
	windower.send_command('bind F10 gs c toggle matchsc')		-- CTRL-F10 to change Match SC Mode      	
	windower.send_command('bind !end gs c hud lite')            -- Alt-End to toggle light hud version       
	windower.send_command('bind ^end gs c hud keybinds')        -- CTRL-End to toggle Keybinds  

--[[
    This gets passed in when the Keybinds is turned on.
    IF YOU CHANGED ANY OF THE KEYBINDS ABOVE, edit the ones below so it can be reflected in the hud using the "//gs c hud keybinds" command
]]
keybinds_on = {}
keybinds_on['key_bind_idle'] = '(CTRL-F12)'
keybinds_on['key_bind_melee'] = '(CTRL-F11)'
keybinds_on['key_bind_casting'] = '(ALT-F10)'
keybinds_on['key_bind_mainweapon'] = '(ALT-F8)'
keybinds_on['key_bind_subweapon'] = '(CTRL-F8)'
keybinds_on['key_bind_element_cycle'] = '(CTRL-INS + DEL)'
keybinds_on['key_bind_enspell_cycle'] = '(CTRL-HOME + PgUP)'
keybinds_on['key_bind_lock_weapon'] = '(ALT-F9)'
keybinds_on['key_bind_matchsc'] = '(F10)'

-- Remember to unbind your keybinds on job change.
function user_unload()
    send_command('unbind ^insert')
    send_command('unbind ^delete')	
    send_command('unbind f9')
    send_command('unbind !f9')
    send_command('unbind f8')
    send_command('unbind !f8')
    send_command('unbind ^f8')
    send_command('unbind f10')
    send_command('unbind f12')
    send_command('unbind !`')
    send_command('unbind ^home')
    send_command('unbind ^PAGEUP')
    send_command('unbind !f10')
    send_command('unbind ^f12')
    send_command('unbind ^f11')
    send_command('unbind `f10')
    send_command('unbind !end')  
    send_command('unbind ^end')  	
end

include('BLM_Lib.lua')

-- Optional. Swap to your sch macro sheet / book
set_macros(1,12) -- Sheet, Book
StartLockStyle=21


refreshType = idleModes[1] -- leave this as is     

-- Setup your Gear Sets below:
function get_sets()
    
    -- JSE
    AF = {}         -- leave this empty
    RELIC = {}      -- leave this empty
    EMPY = {}       -- leave this empty


	-- Fill this with your own JSE. 
    --Spaekona
    AF.Head		    =	""
    AF.Body		    =	"Spaekona's Coat +2"
    AF.Hands	    =	""
    AF.Legs		    =	""
    AF.Feet		    =	""

    --
    RELIC.Head		=	""
    RELIC.Body		=	""
    RELIC.Hands 	=	""
    RELIC.Legs		=	""
    RELIC.Feet		=	""

    --
    EMPY.Head		=	""
    EMPY.Body		=	""
    EMPY.Hands		=	""
    EMPY.Legs		=	""
    EMPY.Feet		=	""
    EMPY.Earring    =   ""

    -- Merlinic
    MERLINIC = {}
    MERLINIC.Head = {}
    MERLINIC.Head.MAB   =   { name="Merlinic Hood", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','"Fast Cast"+4','Mag. Acc.+5','"Mag.Atk.Bns."+4',}}
    MERLINIC.Head.FC    =   MERLINIC.Head.MAB
    MERLINIC.Legs = {}
    MERLINIC.Legs.MAB   =   { name="Merlinic Shalwar", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','Magic burst dmg.+3%','CHR+8','"Mag.Atk.Bns."+15',}}
    MERLINIC.Feet = {}
    MERLINIC.Feet.MAB   =   { name="Merlinic Crackows", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','"Fast Cast"+2','CHR+10','Mag. Acc.+6','"Mag.Atk.Bns."+14',}}
    MERLINIC.Feet.FC    =   MERLINIC.Feet.MAB

    -- Capes:
    -- Sucellos's And such, add your own.
    BLMCape = {}
    BLMCape.MAB = { name="Taranus's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+5','"Mag.Atk.Bns."+10',}}

	-- SETS
     
    sets.me = {}        		-- leave this empty
    sets.buff = {} 			-- leave this empty
    sets.me.idle = {}			-- leave this empty
    sets.me.melee = {}          	-- leave this empty
    sets.weapons = {}			-- leave this empty
	
    -- Optional 
    --include('AugGear.lua') -- I list all my Augmented gears in a sidecar file since it's shared across many jobs. 

    -- Leave weapons out of the idles and melee sets. You can/should add weapons to the casting sets though
    -- Your idle set
    sets.me.idle.refresh = {
        ammo="Staunch Tathlum +1",
        head="Nyame Helm",
        body="Agwu's Robe",
        hands="Nyame Gauntlets",
        legs="Assid. Pants +1",
        feet="Nyame Sollerets",
        neck="Elite Royal Collar",
        waist="Null Belt",
        left_ear="Alabaster Earring",
        right_ear="Thureous Earring",
        left_ring="Murky Ring",
        right_ring="Lehko's Ring",
        back="Solemnity Cape",
    }

    -- Your idle DT set
    sets.me.idle.dt = set_combine(sets.me.idle.refresh,{
        ammo="Staunch Tathlum +1",
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Elite Royal Collar",
        waist="Null Belt",
        left_ear="Alabaster Earring",
        right_ear="Thureous Earring",
        left_ring="Murky Ring",
        right_ring="Lehko's Ring",
        back="Solemnity Cape",
    })

    sets.me.idle.dynamis = set_combine(sets.me.idle.dt,{
        -- neck="Dls. Torque +2",
    })

    -- sets.me.idle.mdt = set_combine(sets.me.idle.refresh,{

    -- })  
	-- Your MP Recovered Whilst Resting Set
    sets.me.resting = { 

    }
    
    -- sets.me.latent_refresh = {waist="Fucho-no-obi"}
    sets.me.latent_refresh = {}
    
	-- Combat Related Sets
	------------------------------------------------------------------------------------------------------
	-- Dual Wield sets
	------------------------------------------------------------------------------------------------------
    sets.me.melee.normaldw = {
    }
    sets.me.melee.hybriddw = set_combine(sets.me.melee.normaldw, {
        left_ring="Murky Ring"
    })
    sets.me.melee.dtdw = set_combine(sets.me.idle.dt,{

    })
    sets.me.melee.dynamisdw = set_combine(sets.me.melee.normaldw,{
        -- neck="Dls. Torque +2",
    })
    sets.me.melee.accuracydw = set_combine(sets.me.melee.normaldw,{
        neck="Null Loop",
        wait="Null Belt"
    })
    
	------------------------------------------------------------------------------------------------------
	-- Single Wield sets. -- combines from DW sets
	-- So canjust put what will be changing when off hand is a shield
 	------------------------------------------------------------------------------------------------------   
    sets.me.melee.normalsw = set_combine(sets.me.melee.normaldw,{   
        -- legs		=	RELIC.Legs,
    })
    sets.me.melee.accsw = set_combine(sets.me.melee.accuracydw,{

    })
    sets.me.melee.dtsw = set_combine(sets.me.melee.dtdw,{

    })
    sets.me.melee.mdtsw = set_combine(sets.me.melee.mdtdw,{

    })
	
	------------------------------------------------------------------------------------------------------
    -- Weapon Skills sets just add them by name.
	------------------------------------------------------------------------------------------------------
    sets.me["Savage Blade"] = {
        ammo="Coiste Bodhar",
        head=RELIC.Head,
        body="Nyame Mail",
        hands=AF.Hands,
        legs="Jhakri Slops +2",
        feet=EMPY.Feet,
        neck="Rep. Plat. Medal",
        waist="Sailfi Belt +1",
        left_ear="Moonshade Earring",
        right_ear="Sherida Earring",
        left_ring="Ifrit Ring",
        right_ring="Ifrit Ring",1,
        back		=	BLMCape.MACC,
	}
    sets.me["Black Halo"] = set_combine(sets.me["Savage Blade"], {
        right_ring = "Metamor. Ring +1"
    })
    

    -- Feel free to add new weapon skills, make sure you spell it the same as in game. These are the only two I ever use though 
	
	
    ---------------
    -- Casting Sets
    ---------------
    sets.precast = {}   		-- Leave this empty  
    sets.midcast = {}    		-- Leave this empty  
    sets.aftercast = {}  		-- Leave this empty  
    sets.midcast.nuking = {}		-- leave this empty
    sets.midcast.MB	= {}		-- leave this empty   
    sets.midcast.enhancing = {} 	-- leave this empty   
    ----------
    -- Precast
    ----------
      
    -- Generic Casting Set that all others take off of.
    -- FC cap with /RDM is 65
    sets.precast.casting = {
	    head        =   MERLINIC.Head.FC, --12
        body        =   "Rosette Jaseran", --3
        hands       =   "Agwu's Gages", --6
        legs        =   "Agwu's Slops", --7
        feet        =   MERLINIC.Feet.FC, --7
        waist       =   "Embla Sash", --5
        left_ring   =   "Kishar Ring", --4
        right_ring  =   "Weather. Ring", --5
        left_ear    =   "Malignance Earring", --4
        right_ear   =   "Barkaro. Earring", --3 for elemental
        -- Total 53/elemental 56
    }
    
    sets.precast["Dispelga"] = set_combine(sets.precast.casting,{
        main="Daybreak",
        sub="Ammurapi Shield",        
    })

    sets.precast["Stun"] = set_combine(sets.precast.casting,{

    })

    -- Enhancing Magic, eg. Siegal Sash, etc
    sets.precast.enhancing = set_combine(sets.precast.casting,{

    })
  
    -- Stoneskin casting time -, works off of enhancing -
    sets.precast.stoneskin = set_combine(sets.precast.enhancing,{

    })
      
    -- Curing Precast, Cure Spell Casting time -
    sets.precast.cure = set_combine(sets.precast.casting,{
	    -- back		=	"Pahtli Cape",
        feet		=	"Telchine Pigaches",
	    left_ring	=	"Lebeche Ring",	
        right_ear   =   "Mendi. Earring"	
    })
      
    ---------------------
    -- Ability Precasting
    ---------------------

    sets.precast["Chainspell"] = {body = RELIC.Body}
	 

	
	----------
    -- Midcast
    ----------
	
    -- Just go make it, inventory will thank you and making rules for each is meh.
    sets.midcast.Obi = {
    	-- waist="Hachirin-no-Obi",
    }
    sets.midcast.Orpheus = {
        --waist="Orpheus's Sash", -- Commented cause I dont have one yet
    }  
	-----------------------------------------------------------------------------------------------
	-- Helix sets automatically derives from casting sets. SO DONT PUT ANYTHING IN THEM other than:
	-- Pixie in DarkHelix
	-- Belt that isn't Obi.
	-----------------------------------------------------------------------------------------------
    -- Make sure you have a non weather obi in this set. Helix get bonus naturally no need Obi.	
    sets.midcast.DarkHelix = {
        head		=	"Pixie Hairpin +1",
        waist		=	"Refoccilation Stone",
        left_ring	=	"Archon Ring",
    }
    -- Make sure you have a non weather obi in this set. Helix get bonus naturally no need Obi.	
    sets.midcast.Helix = {
	    waist		=	"Refoccilation Stone",
    }	

    -- Whatever you want to equip mid-cast as a catch all for all spells, and we'll overwrite later for individual spells
    sets.midcast.casting = {  
        -- main		=	"Bunzi's Rod",
        -- sub		    =	"Ammurapi Shield",
        -- ammo		=	"Pemphredo Tathlum",
        ammo        =   "Dosis Tathlum",
        back		=	BLMCape.MAB,
        -- right_ring	=	"Freke Ring",
        -- right_ring  =   "Stikini Ring",
        -- left_ring   =   "Acumen Ring"
    }

    sets.midcast.nuking.normal = {
        main		=	"Lathi",
        sub		    =	"Enki Strap",
        -- ammo		=	"Pemphredo Tathlum",
        ammo        =   "Sroda Tathlum",
        head        =   MERLINIC.Head.MAB,
        body        =   AF.Body,
        hands       =   "Jhakri Cuffs +2",
        legs        =   MERLINIC.Legs.MAB,
        feet        =   MERLINIC.Feet.MAB,
        neck		=	"Sibyl Scarf",
        -- waist		=	"Refoccilation Stone",
        waist       =   "Acuity Belt +1",
        left_ear	=	"Malignance Earring",
        right_ear	=	"Barkarole Earring",
        left_ring   =   "Shiva Ring", --TODO get freke ring
        right_ring	=	"Metamor. Ring +1",
        back		=	BLMCape.MAB,
    }
    -- used with toggle, default: F10
    -- Pieces to swap from freen nuke to Magic Burst
    sets.midcast.MB.normal = set_combine(sets.midcast.nuking.normal, {
        -- MB Damage I caps at +40
        ammo        =   "Sroda Tathlum",
        head		=	"Ea Hat", --MB 6, MB2 6
        hands       =   "Agwu's Gages", --MB 8
        legs        =   "Agwu's Slops", --MB 9
        feet        =   "Agwu's Pigaches", --MB 6
        back        =   BLMCape.MAB, --MB 5
    })
	
    sets.midcast.nuking.acc = set_combine(sets.midcast.nuking.normal, {

    })
    -- used with toggle, default: F10
    -- Pieces to swap from freen nuke to Magic Burst
    sets.midcast.MB.acc = set_combine(sets.midcast.nuking.acc, {
        -- left_ring	=	"Mujin Band",    
        -- neck		=	"Mizu. Kubikazari",
        -- right_ring	=	"Locus Ring",
    })
	
    -- Enfeebling

	sets.midcast.Enfeebling = {} -- leave Empty
	--Type A-pure macc no potency mod
    sets.midcast.Enfeebling.macc = {
        main="Bunzi's Rod",
        sub="Ammurapi Shield",
        ammo="Staunch Tathlum +1",
        head=MERLINIC.MAB,
        body=AF.Body, -- accuracy + enfeebling skill
        hands="Jhakri Cuffs +2",
        legs="Agwu's Slops",
        feet="Jhakri Pigaches +2",
        neck="Null Loop",
        waist="Null Belt",
        left_ear="Malignance Earring",
        right_ear="Barkaro. Earring",
        left_ring="Kishar Ring",
        right_ring="Stikini Ring",
        back		=	BLMCape.MAB
    }
	sets.midcast["Stun"] = set_combine(sets.midcast.Enfeebling.macc, {

	})
	--Type B-potency from: Mnd & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.mndpot = sets.midcast.Enfeebling.macc
	-- Type C-potency from: Int & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.intpot = sets.midcast.Enfeebling.macc
	--Type D-potency from: Enfeeb Skill & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.skillpot = sets.midcast.Enfeebling.macc
	-- Tpe E-potency from: Enfeeb skill, Mnd, & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.skillmndpot = sets.midcast.Enfeebling.macc
	-- Type F-potency from "Enfeebling potency" gear only
    sets.midcast.Enfeebling.skillmndpot = sets.midcast.Enfeebling.macc
	
    -- Enhancing yourself 
    sets.midcast.enhancing.duration = {
        sub="Ammurapi Shield",
        ammo="Staunch Tathlum +1",
        head="Umuthi Hat",
        body="Telchine Chas.",
        hands="Telchine Gloves",
        legs="Telchine Braconi",
        feet="Telchine Pigaches",
        neck="Melic Torque",
        waist="Embla Sash",
        left_ear="Mimir Earring",
        left_ring="Murky Ring",
        right_ring="Stikini Ring",
    }
    -- For Potency spells like Temper and Enspells
    sets.midcast.enhancing.potency = set_combine(sets.midcast.enhancing.duration, {
    }) 

    -- This is used when casting under Composure but enhancing someone else other than yourself. 
    sets.midcast.enhancing.composure = set_combine(sets.midcast.enhancing.duration, {
    })  


    -- Phalanx
    sets.midcast.phalanx =  set_combine(sets.midcast.enhancing.duration, {
        --head		=	Taeon.Head.Phalanx,
        --body		=	Taeon.Body.Phalanx,
        --hands		=	Taeon.Hands.Phalanx,
        --legs		=	Taeon.Legs.Phalanx,
        --feet		=	Taeon.Feet.Phalanx,
    })

    -- Stoneskin
    sets.midcast.stoneskin = set_combine(sets.midcast.enhancing.duration, {
	-- waist		=	"Siegel Sash",
    })
    sets.midcast.refresh = set_combine(sets.midcast.enhancing.duration, {
    })
    sets.midcast.refresh_self = set_combine(sets.midcast.refresh,{
        waist = "Gishdubar Sash"
    })

    sets.midcast.aquaveil = set_combine(sets.midcast.refresh, {
	
	})
	
    sets.midcast["Drain"] = set_combine(sets.midcast.nuking, {
        -- main		=	"Rubicundity",
        head		=	"Pixie Hairpin +1",
        neck		=	"Erra Pendant",
    })
    sets.midcast["Aspir"] = sets.midcast["Drain"]
 	
    sets.midcast["Dispelga"] = set_combine(sets.midcast.Enfeebling.macc, {
        main="Daybreak",
        sub="Ammurapi Shield"
    })

    sets.midcast.cure = {} -- Leave This Empty
    -- Cure Potency
    sets.midcast.cure.normal = set_combine(sets.midcast.casting,{
        main		=	"Daybreak", --30
        sub         =   "Ammurapi Shield",
        -- ammo		=	"Homiliary",
        head		=	"Vanya Hood", --17
        neck		=	"Henic Torque",
        waist		=	"Othila Sash",
        left_ear	=	"Mendi. Earring", --5
        right_ear	=	"Magnetic Earring",
        left_ring	=	"Stikini Ring",
        right_ring	=	"Lebeche Ring",
        back		=	"Solemnity Cape", --7 i guess but over cap
    })
    sets.midcast.cure.weather = set_combine(sets.midcast.cure.normal,{

    })    

    ------------
    -- Regen
    ------------	
	sets.midcast.regen = set_combine(sets.midcast.enhancing.duration, {

    })
	
    ------------
    -- Aftercast
    ------------
      
    -- I don't use aftercast sets, as we handle what to equip later depending on conditions using a function.
	
end

send_command('input /lockstyleset '..StartLockStyle)