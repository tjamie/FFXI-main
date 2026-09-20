-- Based on Elizabet's RDM (and SCH) lua: https://www.ffxiah.com/forum/topic/53934/a-rdm-gearswap/
--

include('organizer-lib') -- optional
res = require('resources')
texts = require('texts')
include('Modes.lua')

settings = require('settings.lua')

-- Define your modes: 
-- You can add or remove modes in the table below, they will get picked up in the cycle automatically. 
-- to define sets for idle if you add more modes, name them: sets.me.idle.mymode and add 'mymode' in the group.
-- Same idea for nuke modes. 
idleModes = M('refresh', 'dt')
meleeModes = M('normal', 'accuracy', 'hybrid', 'dt')
regenModes = M('hybrid', 'duration', 'potency')
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

mainWeapon = M("Mpaca's Staff", "Musa", "Maxentius")
subWeapon = M("Enki Strap", "Ternion Dagger +1", "Genmei Shield")
------------------------------------------------------------------------------------------------------

----------------------------------------------------------
-- Auto CP Cape: Will put on CP cape automatically when
-- fighting Apex mobs and job is not mastered
----------------------------------------------------------
CP_CAPE = "Mecisto. Mantle" -- Put your CP cape here
----------------------------------------------------------

-- Setting this to true will stop the text spam, and instead display modes in a UI.
use_UI = true
hud_x_pos = settings.hud_x_pos
hud_y_pos = settings.hud_y_pos
hud_draggable = settings.hud_draggable
hud_font_size = settings.hud_font_size
hud_transparency = settings.hud_transparency
hud_font = settings.hud_font


-- Setup your Key Bindings here:
windower.send_command('bind ^insert gs c nuke cycle')       -- ctrl insert to Cycles Nuke element
windower.send_command('bind ^delete gs c nuke cycledown')   -- ctrl delete to Cycles Nuke element in reverse order   
windower.send_command('bind ^f12 gs c toggle idlemode')     -- ctrl F12 to change Idle Mode    
windower.send_command('bind ^f11 gs c toggle meleemode')    -- ctrl F11 to change Melee Mode  
windower.send_command('bind !f9 gs c toggle melee') 		-- Alt-F9 Toggle Melee mode on / off, locking of weapons
windower.send_command('bind !f8 gs c toggle mainweapon')	-- Alt-F8 Toggle Main Weapon
windower.send_command('bind ^f8 gs c toggle subweapon')		-- CTRL-F8 Toggle sub Weapon.
windower.send_command('bind !` input /ma Stun <t>') 		-- Alt-` Quick Stun Shortcut.
windower.send_command('bind !PAGEUP gs c sc tier')		    -- alt PgUp to change SC tier between Level 1 or Level 2 SC
windower.send_command('bind ^home gs c toggle regenmode')	-- ctrl Home Cycle regen mode
windower.send_command('bind ^PAGEUP gs c toggle runspeed')  -- ctrl PgUP Toggle run speed
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
keybinds_on['key_bind_sc_level'] = '(ALT-PGUp)'
keybinds_on['key_bind_regen'] = '(CTRL-HOME)'
keybinds_on['key_bind_lock_weapon'] = '(ALT-F9)'
keybinds_on['key_bind_movespeed_lock'] = '(CTRL-PgUp)'
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
    send_command('unbind !PAGEUP')
    send_command('unbind !f10')
    send_command('unbind ^f12')
    send_command('unbind ^f11')
    send_command('unbind `f10')
    send_command('unbind !end')  
    send_command('unbind ^end')  	
end

include('SCH_Lib.lua')

-- Optional. Swap to your sch macro sheet / book
set_macros(1,7) -- Sheet, Book
StartLockStyle=25
send_command('input /lockstyleset '..StartLockStyle)

refreshType = idleModes[1] -- leave this as is     

-- Setup your Gear Sets below:
function get_sets()
    
    ------------------------------------------------------------------------------------------------------
	-- Constants & Upgradeables
	------------------------------------------------------------------------------------------------------

    -- JSE
    AF = {}         -- leave this empty
    RELIC = {}      -- leave this empty
    EMPY = {}       -- leave this empty

    --AF
    AF.Head		=	"Acad. Mortar. +3"
    AF.Body		=	"Acad. Gown +3"
    AF.Hands	=	"Acad. Bracers +3"
    AF.Legs		=	"Acad. Pants +3"
    AF.Feet		=	"Acad. Loafers +4"

    --Relic
    RELIC.Head		=	"Peda. Mortar. +4"
    RELIC.Body		=	"Peda. Gown +3"
    RELIC.Hands 	=	""
    RELIC.Legs		=	""
    RELIC.Feet		=	""

    --Empyrean
    EMPY.Head		=	"Arbatel Bonnet +2"
    EMPY.Body		=	"Arbatel Gown +2"
    EMPY.Hands		=	"Arbatel Bracers +2"
    EMPY.Legs		=	"Arbatel Pants +2"
    EMPY.Feet		=	"Arbatel Loafers +2"
    EMPY.Earring    =   ""

    -- Capes:
    -- Sucellos's And such, add your own.
    SCHCape = {}
    SCHCape.INT = { name="Lugh's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Phys. dmg. taken-10%',}}
    SCHCape.TP = { name="Lugh's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dbl.Atk."+10','Phys. dmg. taken-10%',}}
    SCHCape.FC = { name="Lugh's Cape", augments={'"Fast Cast"+10',}}

    -- etc
    Chironic = {}
    Chironic.Legs = {}
    Chironic.Legs.MACC = { name="Chironic Hose", augments={'Mag. Acc.+29','MND+14',}}
    
    -- Merlinic
    Merlinic = {}
    Merlinic.Head = {}
    Merlinic.Head.Phalanx = { name="Merlinic Hood", augments={'AGI+9','Phalanx +5','Accuracy+9 Attack+9','Mag. Acc.+7 "Mag.Atk.Bns."+7',}}
    Merlinic.Head.MAB   =   { name="Merlinic Hood", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','"Fast Cast"+4','Mag. Acc.+5','"Mag.Atk.Bns."+4',}}
    Merlinic.Legs = {}
    Merlinic.Legs.Phalanx = { name="Merlinic Shalwar", augments={'Chance of successful block +1','Sklchn.dmg.+3%','Phalanx +4','Accuracy+20 Attack+20','Mag. Acc.+15 "Mag.Atk.Bns."+15',}}
    Merlinic.Legs.MAB   =   { name="Merlinic Shalwar", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','Magic burst dmg.+3%','CHR+8','"Mag.Atk.Bns."+15',}}
    Merlinic.Feet = {}
    Merlinic.Feet.MAB   =   { name="Merlinic Crackows", augments={'Mag. Acc.+25 "Mag.Atk.Bns."+25','"Fast Cast"+2','CHR+10','Mag. Acc.+6','"Mag.Atk.Bns."+14',}}
    Merlinic.Feet.FC    =   Merlinic.Feet.MAB

	-- SETS
     
    sets.me = {}
    sets.buff = {}
    sets.me.idle = {}
    sets.me.melee = {}
    sets.weapons = {}
	
    -- Optional 
    --include('AugGear.lua') -- I list all my Augmented gears in a sidecar file since it's shared across many jobs. 

    -- Leave weapons out of the idles and melee sets. You can/should add weapons to the casting sets though
    -- Your idle set
    sets.me.idle.refresh = {
        ammo="Staunch Tathlum +1",
        head="Nyame Helm",
        body=EMPY.Body,                   --3 at +2, 4 at +3
        hands="Nyame Gauntlets",
        legs="Assid. pants +1",         --1
        feet="Nyame Sollerets",
        neck="Elite Royal Collar",
        waist="Null Belt",
        left_ear="Thureous Earring",
        right_ear="Alabaster Earring",
        left_ring="Murky Ring",
        right_ring="Defending Ring",
        back=SCHCape.INT
    }

    -- Your idle DT set
    -- sets.me.idle.dt = set_combine(sets.me.idle[refreshType],{ })
    sets.me.idle.dt = set_combine(sets.me.idle.refresh,{
        ammo="Staunch Tathlum +1", --3
        head="Nyame Helm", --7
        body="Adamantite Armor", --20
        hands="Nyame Gauntlets", --7
        legs="Nyame Flanchard", --8
        feet="Nyame Sollerets", --7
        neck="Loricate Torque +1", --6
        waist="Null Belt",
        left_ear="Tuisto Earring",
        right_ear="Odnowa Earring +1",
        left_ring="Murky Ring", --10
        right_ring="Gelatinous Ring +1",
        back=SCHCape.INT --10(pdt)
    })

    sets.me.idle.dynamis = set_combine(sets.me.idle.refresh,{
        neck="Argute Stole +1",
    })

    -- Your idle Sublimation set combine from refresh or DT depening on mode.
    sets.me.idle.sublimation = set_combine(sets.me.idle.refresh,{
        head=AF.Head,
        body=RELIC.Body,
        waist="Embla Sash",
    })  

    sets.me.resting = { 

    }
    
    -- sets.me.latent_refresh = {waist="Fucho-no-obi"}
    sets.me.latent_refresh = {}
    
	-- Combat Related Sets
	------------------------------------------------------------------------------------------------------
	-- Dual Wield sets
	------------------------------------------------------------------------------------------------------
    sets.me.melee.normaldw = {
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Null Loop",
        waist="Null Belt",
        left_ear="Cessance Earring",
        right_ear="Suppanomimi",
        left_ring="Petrov Ring",
        right_ring="Lehko's Ring",
        back="Null Shawl",
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
        waist="Null Belt"
    })
    
	------------------------------------------------------------------------------------------------------
	-- Single Wield sets. -- combines from DW sets
	-- So canjust put what will be changing when off hand is a shield
 	------------------------------------------------------------------------------------------------------   
    sets.me.melee.normalsw = set_combine(sets.me.melee.normaldw,{   
        right_ear="Brutal Earring",
    })
    sets.me.melee.accsw = set_combine(sets.me.melee.accuracydw,{

    })
    sets.me.melee.dtsw = set_combine(sets.me.melee.dtdw,{

    })
    sets.me.melee.mdtsw = set_combine(sets.me.melee.mdtdw,{

    })
    sets.me.melee.enspellsw = set_combine(sets.me.melee.enspelldw,{

    })
    sets.me.melee.enspellacc = set_combine(sets.me.melee.enspellaccdw,{
        
    })
	
	------------------------------------------------------------------------------------------------------
    -- Weapon Skills sets just add them by name.
	------------------------------------------------------------------------------------------------------
    
    sets.me["Black Halo"] = {
        ammo="Oshasha's Treatise",
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Rep. Plat. Medal",
        waist="Prosilio Belt",
        left_ear="Regal Earring",
        right_ear="Moonshade Earring",
        left_ring="Metamor. Ring +1",
        right_ring="Ifrit Ring",
        -- back=SMNCape.MND
	}

    sets.me["Realmrazer"] = {
        ammo="Oshasha's Treatise",
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Rep. Plat. Medal",
        waist="Fotia Belt",
        left_ear="Regal Earring",
        right_ear="Malignance Earring",
        left_ring="Metamor. Ring +1",
        right_ring="Lehko's Ring",
        -- back=SMNCape.MND
	}

    sets.me["Spirit Taker"] = sets.me["Black Halo"]
    sets.me["Retribution"] = sets.me["Black Halo"]
    sets.me["Shell Crusher"] = sets.me["Black Halo"]

    sets.me["Myrkr"] = {
        right_ear="Moonshade Earring",
	}
	
	------------------------------------------------------------------------------------------------------
    -- Buff sets
	------------------------------------------------------------------------------------------------------
    -- Gear that needs to be worn to **actively** enhance a current player buff.
    -- Fill up following with your avaible pieces.
    sets.buff['Rapture'] = {
        head = EMPY.Head
    }
    sets.buff['Perpetuance'] = {
        hands = EMPY.Hands
    }
    sets.buff['Immanence'] = {
        hands = EMPY.Hands
    }
    sets.buff['Penury'] = {
        legs = EMPY.Legs
    }
    sets.buff['Parsimony'] = {
        legs = EMPY.Legs
    }
    sets.buff['Celerity'] = {
        -- feet="Peda. Loafers +3"
    }
    sets.buff['Alacrity'] = {
        -- feet="Peda. Loafers +3"
    }
    sets.buff['Klimaform'] = {
        feet = EMPY.Feet
    }
    -- Ebulience set empy now as we get better damage out of a good Merlinic head
    -- orig author left it there still if it becomes needed so the SCH.lua file won't need modification
    -- should you want to use this set
    sets.buff['Ebullience'] = {

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
      
    -- Generic fast cast
    sets.precast.casting = {
        main = "Musa",                      --10 (at R25)
	    head = AF.Head,                     --8
        body = "Agwu's Robe",               --8
        hands = AF.Hands,                   --9
        legs = "Agwu's Slops",              --7
        feet = Merlinic.Feet.FC,            --7 (with augments)
        left_ring = "Kishar Ring",          --4
        right_ring = "Weather. Ring",       --5
        left_ear = "Malignance Earring",    --4
        waist = "Embla Sash",               --5
        back = SCHCape.FC                   --10
        -- Total: 77
    }

    sets.precast.grimoire = set_combine(sets.precast.casting,{
        head = RELIC.Head, --13
        feet = AF.Feet, --12
    })
    
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
	    left_ring	=	"Lebeche Ring",	
        right_ear   =   "Mendi. Earring"	
    })
      
    ---------------------
    -- Ability Precasting
    ---------------------

    sets.precast["Tabula Rasa"] = {
        -- legs="Pedagogy Pants +1"
    }
    sets.precast["Enlightenment"] = {
        body = RELIC.Body
    }
    sets.precast["Sublimation"] = {
        head = AF.Head,
        -- body="Peda. Gown +3"
    }
	
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
        head = "Pixie Hairpin +1",
    }

    sets.midcast.LightHelix = {
        main = "Daybreak",
        sub = "Ammurapi Shield",
        right_ring = "Weather. Ring",
    }

    -- Make sure you have a non weather obi in this set. Helix get bonus naturally no need Obi.	
    sets.midcast.Helix = {
	    -- waist		=	"Refoccilation Stone",
    }	

    -- Whatever you want to equip mid-cast as a catch all for all spells, and we'll overwrite later for individual spells
    sets.midcast.casting = {

    }

    sets.midcast.nuking.normal = {
        main		=	"Bunzi's Rod",
        sub		    =	"Ammurapi Shield",
        -- ammo		=	"Pemphredo Tathlum",
        ammo        =   "Dosis Tathlum",
        head        =   RELIC.Head,
        body        =   EMPY.Body,
        hands       =   EMPY.Hands,
        legs        =   Merlinic.Legs.MAB,
        feet        =   EMPY.Feet,
        neck		=	"Sibyl Scarf",
        -- waist		=	"Refoccilation Stone",
        waist       =   "Acuity Belt +1",
        left_ear	=	"Malignance Earring",
        right_ear	=	"Regal Earring",
        left_ring	=	"Metamor. Ring +1",
        right_ring  =   "Acumen Ring",
        back		=	SCHCape.INT,
    }
    -- used with toggle, default: F10
    -- Pieces to swap from freen nuke to Magic Burst
    -- TODO Was working here -- 01/29/2026
    sets.midcast.MB.normal = set_combine(sets.midcast.nuking.normal, {
        ammo        =   "Sroda Tathlum",
        -- left_ring	=	"Mujin Band",    
        -- head		=	"Agwu's Cap",
        body        =   "Agwu's Robe",
        neck        =   "Argute Stole +1"
    })
	
    sets.midcast.nuking.acc = {
        main		=	"Maxentius",
        sub		    =	"Ammurapi Shield",
        -- ammo		=	"Pemphredo Tathlum",
        ammo        =   "Dosis Tathlum",
        head        =   RELIC.Head,
        body        =   EMPY.Body,
        hands       =   EMPY.Hands,
        legs        =   Merlinic.Legs.MAB,
        feet        =   EMPY.Feet,
        neck		=	"Sibyl Scarf",
        -- waist		=	"Refoccilation Stone",
        waist       =   "Acuity Belt +1",
        left_ear	=	"Malignance Earring",
        right_ear	=	"Regal Earring",
        right_ring  =  "Acumen Ring",
        left_ring	=	"Metamor. Ring +1",
        back		=	SCHCape.INT,
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
        -- TODO find macc ammo piece
        main = "Maxentius",
        sub = "Ammurapi Shield",
        head = AF.Head,
        body =AF.Body,
        hands = EMPY.Hands,
        legs = EMPY.Legs,
        feet = AF.Feet,
        neck = "Argute Stole +1",
        waist = "Obstin. Sash",
        left_ear = "Malignance Earring",
        right_ear = "Regal Earring",
        left_ring = "Kishar Ring",
        right_ring = "Stikini Ring",
        back = SCHCape.INT,
    }
	sets.midcast["Stun"] = set_combine(sets.midcast.Enfeebling.macc, {

	})
	--Type B-potency from: Mnd & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.mndpot = {
        main = "Maxentius",
        sub = "Ammurapi Shield",
        head = AF.Head,
        body =AF.Body,
        hands = EMPY.Hands,
        legs = EMPY.Legs,
        feet = AF.Feet,
        neck = "Argute Stole +1",
        waist = "Obstin. Sash",
        left_ear = "Malignance Earring",
        right_ear = "Regal Earring",
        left_ring = "Kishar Ring",
        right_ring = "Stikini Ring",
        back = SCHCape.INT,
    }
	-- Type C-potency from: Int & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.intpot = {
        main = "Maxentius",
        sub = "Ammurapi Shield",
        head = AF.Head,
        body = AF.Body,
        hands = EMPY.Hands,
        legs = EMPY.Legs,
        feet = AF.Feet,
        neck = "Argute Stole +1",
        waist = "Obstin. Sash",
        left_ear = "Malignance Earring",
        right_ear = "Regal Earring",
        left_ring = "Kishar Ring",
        right_ring = "Stikini Ring",
        back = SCHCape.INT,
    }
	--Type D-potency from: Enfeeb Skill & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.skillpot = {
        main = "Maxentius",
        sub = "Ammurapi Shield",
        head = AF.Head,
        body =AF.Body,
        hands = EMPY.Hands,
        legs = EMPY.Legs,
        feet = AF.Feet,
        neck = "Argute Stole +1",
        waist = "Obstin. Sash",
        left_ear = "Malignance Earring",
        right_ear = "Regal Earring",
        left_ring = "Kishar Ring",
        right_ring = "Stikini Ring",
        back = SCHCape.INT,
    }
	-- Tpe E-potency from: Enfeeb skill, Mnd, & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.skillmndpot = {
        main = "Maxentius",
        sub = "Ammurapi Shield",
        head = AF.Head,
        body =AF.Body,
        hands = EMPY.Hands,
        legs = EMPY.Legs,
        feet = AF.Feet,
        neck = "Argute Stole +1",
        waist = "Obstin. Sash",
        left_ear = "Malignance Earring",
        right_ear = "Regal Earring",
        left_ring = "Kishar Ring",
        right_ring = "Stikini Ring",
        back = SCHCape.INT,
    }
	-- Type F-potency from "Enfeebling potency" gear only
    sets.midcast.Enfeebling.potency = {
        main = "Maxentius",
        sub = "Ammurapi Shield",
        head = AF.Head,
        body =AF.Body,
        hands = EMPY.Hands,
        legs = EMPY.Legs,
        feet = AF.Feet,
        neck = "Argute Stole +1",
        waist = "Obstin. Sash",
        left_ear = "Malignance Earring",
        right_ear = "Regal Earring",
        left_ring = "Kishar Ring",
        right_ring = "Stikini Ring",
        back = SCHCape.INT,
    }
	
    -- Enhancing yourself 
    sets.midcast.enhancing.duration = {
        main = "Musa",
        sub = "Enki Strap",
        -- body = "Telchine Chas.",
        body = RELIC.Body,
        hands = "Telchine Gloves",
        legs = "Telchine Braconi",
        feet = "Telchine pigaches",
        neck = "Melic Torque",
        waist="Embla Sash",
        left_ear="Mimir Earring",
        left_ring="Murky Ring",
        right_ring="Stikini Ring",
        beck = SCHCape.INT,
    }
    -- For Potency spells like Temper and Enspells
    sets.midcast.enhancing.potency = set_combine(sets.midcast.enhancing.duration, {
        waist="Embla Sash",
        left_ear="Mimir Earring",
        left_ring="Murky Ring",
        right_ring="Stikini Ring",
    })

    -- Storms
    sets.midcast.storm = set_combine(sets.midcast.enhancing.duration, {

    })  

    -- Phalanx
    sets.midcast.phalanx =  set_combine(sets.midcast.enhancing.duration, {
        -- main        =   "Sakpata's Sword",
        head		=	Merlinic.Head.Phalanx,
        -- body		=	Taeon.Body.Phalanx,
        -- hands		=	Taeon.Hands.Phalanx,
        legs        =   Merlinic.Legs.Phalanx,
        -- feet		=	Taeon.Feet.Phalanx,
    })

    -- Stoneskin
    sets.midcast.stoneskin = set_combine(sets.midcast.enhancing.duration, {
	-- waist		=	"Siegel Sash",
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
        legs		=	AF.Legs, --15
        feet		=	"Nyame Sollerets",
        neck		=	"Henic Torque",
        waist		=	"Othila Sash",
        left_ear	=	"Magnetic Earring",
        right_ear	=	"Mendi. Earring", --5
        left_ring	=	"Stikini Ring",
        right_ring	=	"Lebeche Ring", --3
        back		=	SCHCape.INT,
        -- sub		=	"Enki Strap",
    })
    sets.midcast.cure.weather = set_combine(sets.midcast.cure.normal,{

    })    

    ------------
    -- Regen
    ------------	
	sets.midcast.regen = {}
    sets.midcast.regen.hybrid = set_combine(sets.midcast.enhancing.duration, {
        main = "Musa",
        sub = "Enki Strap",
        head = EMPY.Head,
        body = "Telchine Chas.",
        back = SCHCape.INT,
    })
	-- Focus on Regen Duration 	
    sets.midcast.regen.duration = set_combine(sets.midcast.regen.hybrid,{

    }) 
	-- Focus on Regen Potency 	
    sets.midcast.regen.potency = set_combine(sets.midcast.regen.hybrid,{

    })
	
    ------------
    -- Aftercast
    ------------
      
    -- lol
	
end
