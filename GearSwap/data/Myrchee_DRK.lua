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
idleModes = M('normal', 'dt', 'dynamis')
meleeModes = M('normal', 'accuracy', 'hybrid', 'dt', 'dynamis')
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

mainWeapon = M('Apocalypse', 'Ragnarok', 'Naegling')
subWeapon = M('Utu Grip', 'Blurred Shield +1')
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

include('DRK_Lib.lua')

-- Optional. Swap to your sch macro sheet / book
set_macros(1,11) -- Sheet, Book

refreshType = idleModes[1] -- leave this as is     

-- Setup your Gear Sets below:
function get_sets()
    
    -- JSE
    AF = {}         -- leave this empty
    RELIC = {}      -- leave this empty
    EMPY = {}       -- leave this empty


	-- Fill this with your own JSE. 
    --Atrophy
    AF.Head		=	""
    AF.Body		=	""
    AF.Hands	=	""
    AF.Legs		=	""
    AF.Feet		=	""

    --Vitiation
    RELIC.Head		=	""
    RELIC.Body		=	""
    RELIC.Hands 	=	""
    RELIC.Legs		=	""
    RELIC.Feet		=	""

    --Lethargy
    EMPY.Head		=	""
    EMPY.Body		=	""
    EMPY.Hands		=	""
    EMPY.Legs		=	""
    EMPY.Feet		=	""
    EMPY.Earring    =   ""

    -- Capes:
    -- Sucellos's And such, add your own.
    DRKCape = {}
    DRKCape.TP		=	{ name="Ankou's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10','Damage taken-5%',}}

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
    sets.me.idle.normal = {
    }

    -- Your idle DT set
    sets.me.idle.dt = set_combine(sets.me.idle.refresh,{
        ammo="Staunch Tathlum +1", --3
        head="Nyame Helm", --7
        body="Nyame Mail", --9
        hands="Nyame Gauntlets", --7
        legs="Nyame Flanchard", --8
        feet="Nyame Sollerets", --7
        neck="Elite Royal Collar", --5
        waist="Flume Belt", --4
        left_ear="Thureous Earring",
        right_ear="Odnowa Earring +1",
        left_ring="Murky Ring", --10
        right_ring="Lehko's Ring",
        back=DRKCape.TP, --5
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
        ammo="Coiste Bodhar",
        head="Sakpata's Helm",
        body="Sakpata's Plate",
        hands="Sakpata's Gauntlets",
        legs="Sakpata's Cuisses",
        feet="Sakpata's Leggings",
        neck="Abyssal Beads +1",
        waist="Sailfi Belt +1",
        left_ear="Cessance Earring",
        right_ear="Brutal Earring",
        left_ring="Petrov Ring",
        right_ring="Lehko's Ring",
        back		=	DRKCape.TP,
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
    -- sets.me.melee.mdtdw = set_combine(sets.me.melee.normaldw,{

    -- })
    
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
        ammo="Knobkierrie",
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
        back		=	DRKCape.MACC,
	}

    sets.me["Black Halo"] = set_combine(sets.me["Savage Blade"], {
        right_ring = "Metamor. Ring +1"
    })

    sets.me["Catastrophe"] = {
        ammo="Knobkierrie",
        head="Ratri Sallet",
        body="Nyame Mail",
        hands="Ratri Gadlings",
        legs="Ratri Cuisses",
        feet="Sulev. Leggings +2",
        neck="Abyssal Beads +1",
        waist="Sailfi Belt +1",
        left_ear="Thrud Earring",
        right_ear="Malignance Earring",
        left_ring="Niqmaddu Ring",
        right_ring="Ifrit Ring",
        back=DRKCape.TP,
    }

    sets.me["Quietus"] = {
        ammo="Knobkierrie",
        head="Ratri Sallet",
        body="Nyame Mail",
        hands="Ratri Gadlings",
        legs="Ratri Cuisses",
        feet="Sulev. Leggings +2",
        neck="Abyssal Beads +1",
        waist="Sailfi Belt +1",
        left_ear="Thrud Earring",
        right_ear="Moonshade Earring",
        left_ring="Niqmaddu Ring",
        right_ring="Ifrit Ring",
        back=DRKCape.TP,
    }

    sets.me["Cross Reaper"] = sets.me["Quietus"]

    sets.me["Entropy"] = {
        ammo="Coiste Bodhar",
        head="Ratri Sallet",
        body="Nyame Mail",
        hands="Ratri Gadlings",
        legs="Ratri Cuisses",
        feet="Sulev. Leggings +2",
        neck="Abyssal Beads +1",
        waist="Fotia Belt",
        left_ear="Thrud Earring",
        right_ear="Moonshade Earring",
        left_ring="Niqmaddu Ring",
        right_ring="Metamor. Ring +1",
        back=DRKCape.TP,
    }

    sets.me["Resolution"] = {
        ammo="Knobkierrie",
        head="Hjarrandi Helm",
        body="Nyame Mail",
        hands="Sakpata's Gauntlets",
        legs="Sakpata's Cuisses",
        feet="Sulev. Leggings +2",
        neck="Abyssal Beads +1",
        waist="Fotia Belt",
        left_ear="Thrud Earring",
        right_ear="Moonshade Earring",
        left_ring="Niqmaddu Ring",
        right_ring="Ifrit Ring",
        back=DRKCape.TP,
    }

    sets.me["Scourge"] = {
        ammo="Knobkierrie",
        head="Ratri Sallet",
        body="Nyame Mail",
        hands="Ratri Gadlings",
        legs="Ratri Cuisses",
        feet="Sulev. Leggings +2",
        neck="Abyssal Beads +1",
        waist="Sailfi Belt +1",
        left_ear="Thrud Earring",
        right_ear="Malignance Earring",
        left_ring="Niqmaddu Ring",
        right_ring="Ifrit Ring",
        back=DRKCape.TP,
    }
	
	
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
      
    -- Generic Casting Set that all others take off of. Here you should add all your fast cast RDM need 50 pre JP 42 at master
    sets.precast.casting = {
        -- main		=	"Crocea Mors",		--20
	    head		=	AF.Head,            --16
        hands = "Telchine Gloves", --3
        left_ring	=	"Kishar Ring",          --4
        right_ring	=	"Weather. Ring",        --5
        left_ear = "Malignance Earring", --4
        right_ear = EMPY.Earring, --7 at +0
        wait = "Embla Sash", --5
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
        neck		=	"Dls. Torque +2",
        waist		=	"Eschan Stone",
        left_ear	=	"Friomisi Earring",
        right_ear	=	"Malignance Earring",
        back		=	DRKCape.MACC,
        -- right_ring	=	"Freke Ring",
        -- right_ring  =   "Stikini Ring",
        -- left_ring   =   "Acumen Ring"
    }

    sets.midcast.nuking.normal = {
        main		=	"Bunzi's Rod",
        sub		    =	"Ammurapi Shield",
        -- ammo		=	"Pemphredo Tathlum",
        ammo        =   "Dosis Tathlum",
        head        =   EMPY.Head,
        body        =   EMPY.Body,
        hands       =   EMPY.Hands,
        legs        =   EMPY.Feet,
        feet        =   RELIC.Feet,
        neck		=	"Sibyl Scarf",
        -- waist		=	"Refoccilation Stone",
        waist       =   "Acuity Belt +1",
        left_ear	=	"Friomisi Earring",
        right_ear	=	"Malignance Earring",
        left_ring   =   "Acumen Ring",
        right_ring	=	"Metamor. Ring +1",
        back		=	DRKCape.INT,
    }
    -- used with toggle, default: F10
    -- Pieces to swap from freen nuke to Magic Burst
    -- TODO Was working here -- 01/29/2026
    sets.midcast.MB.normal = set_combine(sets.midcast.nuking.normal, {
        ammo        =   "Sroda Tathlum",
        -- left_ring	=	"Mujin Band",    
        head		=	"Ea Hat",
        hands       =   "Bunzi's Gloves",
        --body		=	Merl.Body.MB,
        -- neck		=	"Mizu. Kubikazari",
        -- right_ring	=	"Locus Ring",
    })
	
    sets.midcast.nuking.acc = {
        main		=	"Maxentius",
        sub		    =	"Ammurapi Shield",
        -- ammo		=	"Pemphredo Tathlum",
        ammo        =   "Dosis Tathlum",
        head        =   EMPY.Head,
        body        =   EMPY.Body,
        hands       =   EMPY.Hands,
        legs        =   EMPY.Feet,
        feet        =   RELIC.Feet,
        neck		=	"Dls. Torque +2",
        -- waist		=	"Refoccilation Stone",
        waist       =   "Acuity Belt +1",
        left_ear	=	"Friomisi Earring",
        right_ear	=	"Malignance Earring",
        left_ring   =   "Acumen Ring",
        right_ring	=	"Metamor. Ring +1",
        back		=	DRKCape.MACC,
        -- main		=	"Maxentius",
        -- sub		=	"Ammurapi Shield",
        -- left_ring	=	"Shiva Ring",    
        -- ammo		=	"Pemphredo Tathlum",
        -- waist		=	"Refoccilation Stone",
        -- left_ear	=	"Friomisi Earring",
        -- right_ear	=	"Enchntr. Earring +1",
        -- back		=	DRKCape.MACC,
        -- right_ring	=	"Freke Ring",
    }
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
        main={ name="Crocea Mors", augments={'Path: C',}},
        sub="Ammurapi Shield",
        range="Ullr",
        head=RELIC.Head,
        body=AF.Body,
        hands=EMPY.Hands,
        legs=EMPY.Legs,
        feet=RELIC.Feet,
        neck={ name="Dls. Torque +2", augments={'Path: A',}},
        waist="Obstin. Sash",
        left_ear="Malignance Earring",
        right_ear=EMPY.Earring,
        left_ring="Kishar Ring",
        right_ring="Stikini Ring",
        back		=	DRKCape.MACC
    }
	sets.midcast["Stun"] = set_combine(sets.midcast.Enfeebling.macc, {

	})
	--Type B-potency from: Mnd & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.mndpot = {
        main={ name="Crocea Mors", augments={'Path: C',}},
        sub="Ammurapi Shield",
        range="Ullr",
        head=RELIC.Head,
        body=AF.Body,
        hands=EMPY.Hands,
        legs=EMPY.Legs,
        feet=RELIC.Feet,
        neck={ name="Dls. Torque +2", augments={'Path: A',}},
        waist="Obstin. Sash",
        left_ear="Malignance Earring",
        right_ear=EMPY.Earring,
        left_ring="Kishar Ring",
        right_ring="Stikini Ring",
        back		=	DRKCape.MACC
    }
	-- Type C-potency from: Int & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.intpot = {
        main={ name="Crocea Mors", augments={'Path: C',}},
        sub="Ammurapi Shield",
        range="Ullr",
        head=RELIC.Head,
        body=AF.Body,
        hands=EMPY.Hands,
        legs=EMPY.Legs,
        feet=RELIC.Feet,
        neck={ name="Dls. Torque +2", augments={'Path: A',}},
        waist="Obstin. Sash",
        left_ear="Malignance Earring",
        right_ear=EMPY.Earring,
        left_ring="Kishar Ring",
        right_ring="Stikini Ring",
        back		=	DRKCape.MACC
    }
	--Type D-potency from: Enfeeb Skill & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.skillpot = {
        main={ name="Crocea Mors", augments={'Path: C',}},
        sub="Ammurapi Shield",
        range="Ullr",
        head=RELIC.Head,
        body=AF.Body,
        hands=EMPY.Hands,
        legs=EMPY.Legs,
        feet=RELIC.Feet,
        neck={ name="Dls. Torque +2", augments={'Path: A',}},
        waist="Obstin. Sash",
        left_ear="Malignance Earring",
        right_ear=EMPY.Earring,
        left_ring="Kishar Ring",
        right_ring="Stikini Ring",
        back		=	DRKCape.MACC
    }
	-- Tpe E-potency from: Enfeeb skill, Mnd, & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.skillmndpot = {
        main={ name="Crocea Mors", augments={'Path: C',}},
        sub="Ammurapi Shield",
        range="Ullr",
        head=RELIC.Head,
        body=AF.Body,
        hands=EMPY.Hands,
        legs=EMPY.Legs,
        feet=RELIC.Feet,
        neck={ name="Dls. Torque +2", augments={'Path: A',}},
        waist="Obstin. Sash",
        left_ear="Malignance Earring",
        right_ear=EMPY.Earring,
        left_ring="Kishar Ring",
        right_ring="Stikini Ring",
        back		=	DRKCape.MACC
    }
	-- Type F-potency from "Enfeebling potency" gear only
    sets.midcast.Enfeebling.skillmndpot = {
        main={ name="Crocea Mors", augments={'Path: C',}},
        sub="Ammurapi Shield",
        range="Ullr",
        head=RELIC.Head,
        body=AF.Body,
        hands=EMPY.Hands,
        legs=EMPY.Legs,
        feet=RELIC.Feet,
        neck={ name="Dls. Torque +2", augments={'Path: A',}},
        waist="Obstin. Sash",
        left_ear="Malignance Earring",
        right_ear=EMPY.Earring,
        left_ring="Kishar Ring",
        right_ring="Stikini Ring",
        back		=	DRKCape.MACC
    }
	
    -- Enhancing yourself 
    sets.midcast.enhancing.duration = {
        main="Pukulatmuj +1",
        sub="Ammurapi Shield",
        ammo="Staunch Tathlum +1",
        head={ name="Carmine Mask +1", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4',}},
        body=RELIC.Body,
        hands=AF.Hands,
        legs="Telchine Braconi",
        feet=EMPY.Feet,
        neck="Dls. Torque +2",
        waist="Embla Sash",
        left_ear="Mimir Earring",
        right_ear=EMPY.Earring,
        left_ring="Murky Ring",
        right_ring="Stikini Ring",
        back={ name="Ghostfyre Cape", augments={'Enfb.mag. skill +3','Enha.mag. skill +7','Mag. Acc.+4','Enh. Mag. eff. dur. +20',}},        
    }
    -- For Potency spells like Temper and Enspells
    sets.midcast.enhancing.potency = set_combine(sets.midcast.enhancing.duration, {
        main="Pukulatmuj +1",
        sub="Ammurapi Shield",
        ammo="Staunch Tathlum +1",
        head={ name="Carmine Mask +1", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4',}},
        body=RELIC.Body,
        hands=AF.Hands,
        legs={ name="Carmine Cuisses +1", augments={'Accuracy+20','Attack+12','"Dual Wield"+6',}},
        feet=EMPY.Feet,
        neck="Dls. Torque +2",
        waist="Embla Sash",
        left_ear="Mimir Earring",
        right_ear=EMPY.Earring,
        left_ring="Murky Ring",
        right_ring="Stikini Ring",
        back={ name="Ghostfyre Cape", augments={'Enfb.mag. skill +3','Enha.mag. skill +7','Mag. Acc.+4','Enh. Mag. eff. dur. +20',}},      
    }) 

    -- This is used when casting under Composure but enhancing someone else other than yourself. 
    sets.midcast.enhancing.composure = set_combine(sets.midcast.enhancing.duration, {
        head		=	EMPY.Head,
        body        =   EMPY.Body,
        hands		=	AF.Hands,
        legs		=	EMPY.Legs,
    })  


    -- Phalanx
    sets.midcast.phalanx =  set_combine(sets.midcast.enhancing.duration, {
        main = "Sakpata's Sword"
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
        body    =   AF.Body,
        legs    =   EMPY.Legs
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
        -- main		=	"Daybreak",
        -- ammo		=	"Homiliary",
        head		=	"Vanya Hood", --17
        body		=	"Chironic Doublet", --13
        hands		=	"Chironic Gloves",  --9
        legs		=	AF.Legs, --12
        feet		=	RELIC.Feet, --meva
        neck		=	"Henic Torque",
        waist		=	"Othila Sash",
        left_ear	=	"Mendi. Earring",
        right_ear	=	"Magnetic Earring",
        left_ring	=	"Stikini Ring",
        right_ring	=	"Lebeche Ring",
        back		=	"Ghostfyre Cape", --6 i guess but over cap
        -- sub		=	"Enki Strap",
    })
    sets.midcast.cure.weather = set_combine(sets.midcast.cure.normal,{

    })    

    ------------
    -- Regen
    ------------	
	sets.midcast.regen = set_combine(sets.midcast.enhancing.duration, {

    })


    ------------
    -- Blue Magic (enmity)
    ------------
    -- Will ideally want some some degree of SIRD if possible
    sets.midcast.enmity = set_combine(sets.me.melee.dtsw, {
        ammo = "Staunch Tathlum +1", --SIRD 11
        body = "Emet Harness", --enmity +9,
        legs = "Carmine Cuisses +1", --SIRD 20
        neck = "Unmoving Collar +1", --enmity +10
        right_ring = "Petrov Ring", --enmity +4
        left_ear = "Friomsi Earring", --enmity +2
        right_ear = "Magnetic Earring", --SIRD 8
        back = DRKCape.VIT, --enmity +10
    })
	
    ------------
    -- Aftercast
    ------------
      
    -- I don't use aftercast sets, as we handle what to equip later depending on conditions using a function.
	
end
