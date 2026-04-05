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
idleModes = M('refresh', 'dt', 'dynamis')
meleeModes = M('normal', 'accuracy')
nukeModes = M('normal', 'acc')

-- TODO set hotkeys/UI elements for these as needed
LagMode = false -- Default LagMode. If you have a lot of lag issues, change to "true".
AccMode = false
ImpactDebuff = false
Empy = false
ForceIlvl = false
MeteorStrike = 1
HeavenlyStrike = 1
WindBlade = 1
Geocrush = 1
Thunderstorm = 5
GrandFall = 1

------------------------------------------------------------------------------------------------------
-- Idle/Engaged Weapons
------------------------------------------------------------------------------------------------------
-- Don't put any weapons / sub in your IDLE and ENGAGED sets'

mainWeapon = M('Gridarvor', 'Maxentius')
subWeapon = M('Elan Strap', 'Genmei Shield', 'Ternion Dagger +1')
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
	windower.send_command('bind !` input /ma Stun <t>') 	
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
    send_command('unbind !f10')
    send_command('unbind ^f12')
    send_command('unbind ^f11')
    send_command('unbind `f10')
    send_command('unbind !end')  
    send_command('unbind ^end')  	
end

include('SMN_Lib.lua')

-- Optional. Swap to your sch macro sheet / book
set_macros(1,17) -- Sheet, Book
StartLockStyle=29
send_command('wait 2; input /lockstyleset '..StartLockStyle)

refreshType = idleModes[1] -- leave this as is     

-- Setup your Gear Sets below:
function get_sets()
    
    -- ===================================================================================================================
    --      JSE etc
    -- ===================================================================================================================
     
    AF = {}
    RELIC = {}
    EMPY = {}
    SMNCape = {}
    HELIOS = {}
    MERLINIC = {}
    APOGEE = {}

    -- AF
    AF.Head = "Convoker's Horn +3"
    AF.Body = "Con. Doublet +4"
    AF.Feet = "Con. Pigaches +1"

    -- Relic
    RELIC.Head = "Glyphic Horn +1"
    RELIC.Hands = "Glyphic Bracers +1"

    -- Empyrean
    EMPY.Head = "Beckoner's Horn +2"
    EMPY.Earring = "Beck. Earring"

    -- Capes
    SMNCape.MACC = { name="Campestres's Cape", augments={'Pet: M.Acc.+20 Pet: M.Dmg.+20','Eva.+20 /Mag. Eva.+20','Pet: Mag. Acc.+10','"Fast Cast"+4',}}
    SMNCape.ACC = { name="Campestres's Cape", augments={'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Pet: Accuracy+10 Pet: Rng. Acc.+10','Pet: "Regen"+10',}}
    SMNCape.MND = { name="Campestres's Cape", augments={'MND+20','Accuracy+20 Attack+20','MND+10','Weapon skill damage +10%',}}
    SMNCape.Delay = { name="Conveyance Cape", augments={'Summoning magic skill +1','Pet: Enmity+11','Blood Pact ab. del. II -2',}}

    -- Helios
    HELIOS.Head = {}
    HELIOS.Head.ATK = { name="Helios Band", augments={'Pet: Attack+29 Pet: Rng.Atk.+29','Pet: "Dbl. Atk."+8','Blood Pact Dmg.+7',}}

    -- Merlinic
    MERLINIC.Hands = {}
    MERLINIC.Hands.ATK = { name="Merlinic Dastanas", augments={'Pet: Accuracy+12 Pet: Rng. Acc.+12','Blood Pact Dmg.+8','Pet: STR+9','Pet: Mag. Acc.+3',}}
    MERLINIC.Hands.MAB = { name="Merlinic Dastanas", augments={'Pet: "Mag.Atk.Bns."+9','Blood Pact Dmg.+10','Pet: DEX+8','Pet: Mag. Acc.+8',}}

    -- Apogee
    APOGEE.Head = {}
    APOGEE.Head.MAB = { name="Apogee Crown +1", augments={'MP+80','Pet: "Mag.Atk.Bns."+35','Blood Pact Dmg.+8',}}
    APOGEE.Body = {}
    APOGEE.Body.MAB = { name="Apo. Dalmatica +1", augments={'MP+80','Pet: "Mag.Atk.Bns."+35','Blood Pact Dmg.+8',}}
    APOGEE.Legs = {}
    APOGEE.Legs.ATK = { name="Apogee Slacks +1", augments={'Pet: STR+20','Blood Pact Dmg.+14','Pet: "Dbl. Atk."+4',}}
    APOGEE.Legs.MAB = { name="Apogee Slacks +1", augments={'MP+80','Pet: "Mag.Atk.Bns."+35','Blood Pact Dmg.+8',}}
    APOGEE.Feet = {}
    APOGEE.Feet.ATK = { name="Apogee Pumps +1", augments={'MP+80','Pet: Attack+35','Blood Pact Dmg.+8',}}
    APOGEE.Feet.MAB = { name="Apogee Pumps", augments={'MP+60','Pet: "Mag.Atk.Bns."+30','Blood Pact Dmg.+7',}}

	-- SETS
     
    sets.me = {}        		-- leave this empty
    sets.buff = {} 			-- leave this empty
    sets.me.idle = {}			-- leave this empty
    sets.me.melee = {}          	-- leave this empty
    sets.weapons = {}			-- leave this empty

    -- Leave weapons out of the idles and melee sets. You can/should add weapons to the casting sets though
    -- Your refresh/perpetuation set
    sets.me.idle.refresh = {
        ammo="Sancus Sachet +1",
        head=EMPY.Head,
        body=APOGEE.Body.MAB,
        hands="Bunzi's Gloves",
        legs="Assid. Pants +1",
        feet=APOGEE.Feet.ATK,
        neck="Caller's Pendant",
        waist="Incarnation Sash",
        left_ear="C. Palug Earring",
        right_ear=EMPY.Earring,
        left_ring="Defending Ring",
        right_ring="Murky Ring",
        back=SMNCape.ACC,
    }

    -- Your idle DT set
    sets.me.idle.dt = set_combine(sets.me.idle.refresh,{
        head="Nyame Helm", --7
        body="Nyame Mail", --9
        hands="Nyame Gauntlets", --7
        legs="Nyame Flanchard", --8
        feet="Nyame Sollerets", --7
        neck="Elite Royal Collar", --5
        left_ear="Thureous Earring",
        right_ear="Odnowa Earring +1",
    })

    sets.me.idle.dynamis = set_combine(sets.me.idle.refresh,{
        neck="Smn. Collar +2",
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
        ammo="Sancus Sachet +1",
        head=EMPY.Head,
        body="Nyame Mail",
        hands="Bunzi's Gloves",
        legs="Nyame Flanchard",
        feet=APOGEE.Feet.ATK, --only in here for the per cost
        neck="Null Loop",
        waist="Null Belt",
        left_ear="Sroda Earring",
        right_ear=EMPY.Earring,
        left_ring="Petrov Ring",
        right_ring="Lehko's Ring",
        back=SMNCape.ACC,
    }
    sets.me.melee.hybriddw = set_combine(sets.me.melee.normaldw, {
        left_ring="Murky Ring"
    })
    sets.me.melee.dtdw = set_combine(sets.me.idle.dt,{

    })
    sets.me.melee.dynamisdw = set_combine(sets.me.melee.normaldw,{
        neck="Smn. Torque +2",
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

    })
    sets.me.melee.accuracysw = set_combine(sets.me.melee.accuracydw,{

    })
    sets.me.melee.dtsw = set_combine(sets.me.melee.dtdw,{

    })
    sets.me.melee.mdtsw = set_combine(sets.me.melee.mdtdw,{

    })
	
	------------------------------------------------------------------------------------------------------
    -- Weapon Skills sets
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
        left_ear="Sroda Earring",
        right_ear="Moonshade Earring",
        left_ring="Ifrit Ring",
        right_ring="Metamor. Ring +1",
        back=SMNCape.MND
	}
    sets.me["Shell Crusher"] = {
        -- ideally want macc for unresisted DEF down
        ammo="Oshasha's Treatise",
        head="Nyame Helm",
        body=AF.Body,
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Null Loop",
        waist="Null Belt",
        left_ear="Malignance Earring",
        right_ear="Moonshade Earring",
        left_ring="Weather. Ring",
        right_ring="Metamor. Ring +1",
        back=SMNCape.MND
	}
    -- sets.me["Seraph Blade"] = {
    --     head=EMPY.Head,
    --     body="Nyame Mail",
    --     hands="Jhakri Cuffs +2",
    --     legs=EMPY.Legs,
    --     feet=EMPY.Feet,
    --     neck="Baetyl Pendant",
    --     waist="Sailfi Belt +1",
    --     left_ear="Regal Earring",
    --     right_ear="Moonshade Earring",
    --     left_ring="Metamor. Ring +1",
    --     right_ring="Weather. Ring",
    --     back=RDMCape.MACC,
    -- }

    
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
    -- Fast cast etc
    -- With /rdm, FC caps at 65 (-15% from Fast Cast II trait)
    sets.precast.casting = {
	    head="Bunzi's Hat", --10
        neck="Elite Royal Collar",
        left_ear="Malignance Earring", --4
        right_ear=EMPY.Earring, --0
        body="Inyanga Jubbah +2", --14
        hands="Telchine Gloves", --3
        legs="Telchine Braconi", --3
        feet="Merlinic Crackows", --5
        left_ring="Weather. Ring", --5
        right_ring="Kishar Ring", --4
        waist="Embla Sash", --5
        back=SMNCape.MACC, --4
        -- Total: 57
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
      
 	
	----------
    -- Midcast
    ----------

    sets.midcast["Mana Cede"] = {
        -- hands="Beckoner's Bracers +3"
    }
    
    sets.midcast["Astral Flow"] = {
        head=RELIC.Head,
    }
	
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
        -- left_ring	=	"Archon Ring",
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
        -- ammo        =   "Dosis Tathlum",
        -- neck		=	"Dls. Torque +2",
        -- waist		=	"Eschan Stone",
        -- left_ear	=	"Regal Earring",
        -- right_ear	=	"Malignance Earring",
        -- back		=	RDMCape.MACC,
        -- right_ring	=	"Freke Ring",
        -- right_ring  =   "Stikini Ring",
        -- left_ring   =   "Acumen Ring"
    }

    sets.midcast.nuking.normal = {
        main		=	"Bunzi's Rod",
        sub		    =	"Ammurapi Shield",
        -- ammo		=	"Pemphredo Tathlum",
        ammo        =   "Dosis Tathlum",
        head        =   "Nyame Helm",
        body        =   "Nyame Mail",
        hands       =   "Bunzi's Gloves",
        legs        =   "Nyame Flanchard",
        feet        =   "Nyame Sollerets",
        neck		=	"Sibyl Scarf",
        -- waist		=	"Refoccilation Stone",
        waist       =   "Acuity Belt +1",
        left_ear	=	"Friomisi Earring",
        right_ear	=	"Malignance Earring",
        left_ring   =   "Shiva Ring",
        right_ring	=	"Metamor. Ring +1",
        -- back		=	RDMCape.INT,
    }
    -- used with toggle, default: F10
    -- Pieces to swap from freen nuke to Magic Burst
    -- TODO Was working here -- 01/29/2026
    sets.midcast.MB.normal = set_combine(sets.midcast.nuking.normal, {
        -- ammo        =   "Sroda Tathlum",
        -- left_ring	=	"Mujin Band",    
        -- head		=	"Ea Hat",
        hands       =   "Bunzi's Gloves",
    })
	
    sets.midcast.nuking.acc = {
        main		=	"Bunzi's Rod",
        sub		    =	"Ammurapi Shield",
        ammo        =   "Dosis Tathlum",
        head        =   "Nyame Helm",
        body        =   "Nyame Mail",
        hands       =   "Bunzi's Gloves",
        legs        =   "Nyame Flanchard",
        feet        =   "Nyame Sollerets",
        neck		=	"Sibyl Scarf",
        waist       =   "Acuity Belt +1",
        left_ear	=	"Friomisi Earring",
        right_ear	=	"Malignance Earring",
        left_ring   =   "Shiva Ring",
        right_ring	=	"Metamor. Ring +1",
    }
    -- used with toggle, default: F10
    -- Pieces to swap from freen nuke to Magic Burst
    sets.midcast.MB.acc = set_combine(sets.midcast.nuking.acc, {
    })
	
    -- Enfeebling

	sets.midcast.Enfeebling = {} -- leave Empty
	--Type A-pure macc no potency mod
    sets.midcast.Enfeebling.macc = {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        hands="Inyan. Dastanas +2",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        neck="Henic Torque",
        left_ear="Malignance Earring",
        right_ring="Stikini Ring",
    }
	sets.midcast["Stun"] = set_combine(sets.midcast.Enfeebling.macc, {

	})
	--Type B-potency from: Mnd & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.mndpot = {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        hands="Inyan. Dastanas +2",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        neck="Henic Torque",
        left_ear="Malignance Earring",
        right_ring="Stikini Ring",
    }
	-- Type C-potency from: Int & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.intpot = {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        hands="Inyan. Dastanas +2",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        neck="Henic Torque",
        left_ear="Malignance Earring",
        right_ring="Stikini Ring",
    }
	--Type D-potency from: Enfeeb Skill & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.skillpot = {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        hands="Inyan. Dastanas +2",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        neck="Henic Torque",
        left_ear="Malignance Earring",
        right_ring="Stikini Ring",
    }
	-- Tpe E-potency from: Enfeeb skill, Mnd, & "Enfeeb Potency" gear
    sets.midcast.Enfeebling.skillmndpot = {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        hands="Inyan. Dastanas +2",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        neck="Henic Torque",
        left_ear="Malignance Earring",
        right_ring="Stikini Ring",
    }
	-- Type F-potency from "Enfeebling potency" gear only
    sets.midcast.Enfeebling.potency = {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        hands="Inyan. Dastanas +2",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        neck="Henic Torque",
        left_ear="Malignance Earring",
        right_ring="Stikini Ring",
    }
	
    -- Enhancing yourself 
    sets.midcast.enhancing.duration = {
        main="Daybreak",
        sub="Ammurapi Shield",
        -- head
        body="Telchine Chas.",
        hands="Telchine Gloves",
        legs="Telchine Braconi",
        feet="Telchine Pigaches",
        wait="Embla Sash",
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
        main="Daybreak", --30
        sub="Ammurapi Shield",
        head="Bunzi's Hat",
        body="Bunzi's Robe", --15
        hands="Inyan. Dastanas +2", --skill+20
        legs="Bunzi's Pants", --SIRD 20
        neck="Henic Torque", --skill+10
        left_ring="Lebeche Ring", --3
        right_ring="Stikini Ring", --skill+5
        left_ear="Mendi. Earring", --5
    })
    sets.midcast.cure.weather = set_combine(sets.midcast.cure.normal,{
    })    

    ------------
    -- Regen
    ------------	
	sets.midcast.regen = set_combine(sets.midcast.enhancing.duration, {
    })

    ------------------------------------------------------------------------------------------------------
	-- Avatars and Blood Pacts
	------------------------------------------------------------------------------------------------------
    sets.pet_midcast = {}

    -- BP Delay
    -- Avatar's Favor skill tiers are 512 / 575 / 670 / 735
    sets.midcast.BP = {
        main={ name="Espiritus", augments={'Summoning magic skill +15','Pet: Mag. Acc.+30','Pet: Damage taken -4%',}},
        sub="Elan Strap",
        ammo="Sancus Sachet +1",
        head=EMPY.Head,
        body=AF.Body,
        hands="Inyan. Dastanas +2",
        legs="Baayami Slops",
        feet="Baayami Sabots",
        neck="Melic Torque",
        waist="Cornelia's Belt", -- ¯\_(ツ)_/¯
        left_ear="Lodurr Earring",
        right_ear=EMPY.Earring,
        left_ring="Evoker's Ring",
        right_ring="Stikini Ring"
    }

    -- Shock Squall is too fast to swap gear in pet_midcast() or otherwise. It'll generally land in your BP timer set.
    sets.midcast.BP["Shock Squall"] = set_combine(sets.midcast.BP, {
        neck="Smn. Collar +2",
        left_ear="Enmerkar Earring",
        right_ear="Lugalbanda Earring",
        -- ring1="Cath Palug Ring",
        -- ring2="Fickblix's Ring",
        waist="Incarnation Sash",
        back=SMNCape.MACC,
    })

    -- Elemental Siphon sets. Zodiac Ring is affected by day, Chatoyant Staff by weather, and Twilight Cape by both.
    sets.midcast.Siphon = {
        main={ name="Espiritus", augments={'Summoning magic skill +15','Pet: Mag. Acc.+30','Pet: Damage taken -4%',}},
        -- sub="Vox Grip",
        -- ammo="Esper Stone +1",
        head="Baayami Hat",
        -- neck="Hoxne Torque",
        -- ear1="Cath Palug Earring",
        left_ear="Lodurr Earring",
        body="Baayami Robe",
        legs="Baayami Slops",
        -- feet="Beckoner's Pigaches +3"
        feet="Baayami Sabots",
        hands="Inyan. Dastanas +2",
        left_ring="Evoker's Ring",
        right_ring="Stikini Ring",
        back=SMNCape.Delay,
        -- waist="Kobo Obi",
    }
    
    sets.midcast.SiphonZodiac = set_combine(sets.midcast.Siphon, { 
        -- ring1="Zodiac Ring"
    })
    
    sets.midcast.SiphonWeather = set_combine(sets.midcast.Siphon, {
        -- main="Chatoyant Staff"
    })
    
    sets.midcast.SiphonWeatherZodiac = set_combine(sets.midcast.SiphonZodiac, {
        -- main="Chatoyant Staff"
    })

    -- Summoning Midcast, cap spell interruption if possible (Baayami Robe gives 100, need 2 more)
    sets.midcast.Summon = set_combine(sets.me.idle.dt, {
        body="Baayami Robe",
        legs="Bunzi's Pants",
    })
	
    -- Main physical pact set (Volt Strike, Predator Claws, etc.)
    -- Prioritize BP Damage & Pet: Double Attack
    sets.pet_midcast.Physical_BP = {
        main="Gridarvor",
        sub="Elan Strap",
        ammo="Sancus Sachet +1", --TODO rank up epitaph to replace this
        -- ammo="Epitaph",
        head=HELIOS.Head.ATK,
        body=AF.Body,
        hands=MERLINIC.Hands.ATK,
        legs=APOGEE.Legs.ATK,
        feet=APOGEE.Legs.ATK,
        -- neck="Shulmanu Collar",
        neck="Smn. Collar +2",
        waist="Incarnation Sash",
        left_ear="Sroda Earring",
        right_ear="Lugalbanda Earring",
        left_ring="Varar Ring +1",
        -- right_ring="Varar Ring +1",1,
        right_ring="C. Palug Ring",
        back=SMNCape.ACC,
    }

    -- Physical Pact AM3 set, less emphasis on Pet:DA
    sets.pet_midcast.Physical_BP_AM3 = set_combine(sets.pet_midcast.Physical_BP, {
        body=AF.Body,
        -- left_ring="Varar Ring +1",
        feet=APOGEE.Feet.ATK,
    })
    
    -- Physical pacts which benefit more from TP than Pet:DA (like Spinning Dive and other pacts you never use except that one time)
    sets.pet_midcast.Physical_BP_TP = set_combine(sets.pet_midcast.Physical_BP, {
        -- head={ name="Apogee Crown +1", augments={'MP+80','Pet: Attack+35','Blood Pact Dmg.+8',}},
        body=AF.Body,
        -- left_ring="Varar Ring +1",
        waist="Regal Belt",
        legs="Enticer's Pants",
        feet=APOGEE.Feet.ATK,
    })

    -- Used for all physical pacts when AccMode is true
    -- TODO create avatar BP mode in this lua
    sets.pet_midcast.Physical_BP_Acc = set_combine(sets.pet_midcast.Physical_BP, {
        right_ear=EMPY.Earring,
        body=AF.Body,
    })

    -- Base magic pact set
    -- Prioritize BP Damage & Pet:MAB
    sets.pet_midcast.Magic_BP_Base = {
        --TODO make a MAB espiritus. Or get lucky with perfect augments.
        main={ name="Grioavolr", augments={'Blood Pact Dmg.+3','Pet: INT+9','Pet: Mag. Acc.+16','Pet: "Mag.Atk.Bns."+25','DMG:+12',}},
        sub="Elan Strap",
        ammo="Sancus Sachet +1",
        -- ammo="Epitaph", see above regarding this piece
        -- head=APOGEE.Head.MAB,
        head="C. Palug Crown",
        neck="Smn. Collar +2",
        body=APOGEE.Body.MAB,
        hands=MERLINIC.Hands.MAB,
        legs="Enticer's Pants",
        feet=APOGEE.Feet.MAB,
        left_ear="Lugalbanda Earring",
        right_ear=EMPY.Earring,
        left_ring="Varar Ring +1",
        right_ring="Varar Ring +1",1,
        waist="Regal Belt",
        back=SMNCape.MACC,
    }

    -- Some magic pacts benefit more from TP than others.
    -- Note: This set will only be used on merit pacts if you have less than 4 merits.
    --       Make sure to update your merit values at the top of this Lua.
    sets.pet_midcast.Magic_BP_TP = set_combine(sets.pet_midcast.Magic_BP_Base, {
    })
    
    -- NoTP set used when you don't need Enticer's
    sets.pet_midcast.Magic_BP_NoTP = set_combine(sets.pet_midcast.Magic_BP_Base, {
        legs=APOGEE.Legs.MAB,
    })
    
    sets.pet_midcast.Magic_BP_TP_Acc = set_combine(sets.pet_midcast.Magic_BP_TP, {
        -- head={ name="Merlinic Hood", augments={'Pet: Mag. Acc.+21 Pet: "Mag.Atk.Bns."+21','Blood Pact Dmg.+7','Pet: INT+6','Pet: "Mag.Atk.Bns."+11',}},
        body=AF.Body,
        -- hands={ name="Merlinic Dastanas", augments={'Pet: Mag. Acc.+29','Blood Pact Dmg.+10','Pet: INT+7','Pet: "Mag.Atk.Bns."+10',}}
    })
    
    sets.pet_midcast.Magic_BP_NoTP_Acc = set_combine(sets.pet_midcast.Magic_BP_NoTP, {
        -- head={ name="Merlinic Hood", augments={'Pet: Mag. Acc.+21 Pet: "Mag.Atk.Bns."+21','Blood Pact Dmg.+7','Pet: INT+6','Pet: "Mag.Atk.Bns."+11',}},
        body=AF.Body,
        -- hands={ name="Merlinic Dastanas", augments={'Pet: Mag. Acc.+29','Blood Pact Dmg.+10','Pet: INT+7','Pet: "Mag.Atk.Bns."+10',}}
    })

    -- Favor BP Damage above all. Pet:MAB also very strong.
    -- Pet: Accuracy, Attack, Magic Accuracy moderately important.
    sets.pet_midcast.FlamingCrush = {
        main={ name="Grioavolr", augments={'Blood Pact Dmg.+3','Pet: INT+9','Pet: Mag. Acc.+16','Pet: "Mag.Atk.Bns."+25','DMG:+12',}},
        sub="Elan Strap",
        ammo="Sancus Sachet +1",
        -- ammo="Epitaph", see above regarding this piece
        -- head=APOGEE.Head.MAB,
        head="C. Palug Crown",
        neck="Smn. Collar +2",
        body=AF.Body,
        hands=MERLINIC.Hands.MAB,
        legs=APOGEE.Legs.MAB,
        feet=APOGEE.Feet.MAB,
        left_ear="Lugalbanda Earring",
        right_ear=EMPY.Earring,
        left_ring="Varar Ring +1",
        right_ring="Varar Ring +1",1,
        waist="Regal Belt",
        back=SMNCape.ACC,
    }
    
    sets.pet_midcast.FlamingCrush_Acc = set_combine(sets.pet_midcast.FlamingCrush, {
        -- hands={ name="Merlinic Dastanas", augments={'Pet: Accuracy+28 Pet: Rng. Acc.+28','Blood Pact Dmg.+10','Pet: DEX+9','Pet: Mag. Acc.+9','Pet: "Mag.Atk.Bns."+3',}},
        -- feet="Beckoner's Pigaches +3"
    })

    -- Pet: Magic Acc set - Mainly used for debuff pacts like Bitter Elegy
    sets.pet_midcast.MagicAcc_BP = {
        main={ name="Grioavolr", augments={'Blood Pact Dmg.+3','Pet: INT+9','Pet: Mag. Acc.+16','Pet: "Mag.Atk.Bns."+25','DMG:+12',}},
        sub="Elan Strap",
        ammo="Sancus Sachet +1",
        -- ammo="Epitaph", see above regarding this piece
        head="Bunzi's Hat",
        neck="Adad Amulet",
        body=AF.Body,
        hands="Bunzi's Gloves",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        left_ear="Lugalbanda Earring",
        right_ear=EMPY.Earring,
        -- left_ring="Varar Ring +1",
        -- right_ring="Varar Ring +1",1,
        waist="Incarnation Sash",
        back=SMNCape.MACC,
    }
    
    sets.pet_midcast.Debuff_Rage = sets.pet_midcast.MagicAcc_BP

    -- Pure summoning magic set, mainly used for buffs like Hastega II.
    sets.pet_midcast.SummoningMagic = {
        main={ name="Espiritus", augments={'Summoning magic skill +15','Pet: Mag. Acc.+30','Pet: Damage taken -4%',}},
        -- sub="Vox Grip",
        head="Baayami Hat",
        neck="Melic Torque",
        left_ear="C. Palug Earring",
        right_ear="Lodurr Earring",
        -- left_ear="Lodurr Earring",
        -- right_ear=EMPY.Earring,
        body="Baayami Robe",
        hands="Inyan. Dastanas +2",
        left_ring="Evoker's Ring",
        right_ring="Stikini Ring",
        back=SMNCape.Delay,
        -- waist="Kobo Obi",
        legs="Baayami Slops",
        feet="Baayami Sabots"
    }

    sets.pet_midcast.Buff = set_combine(sets.pet_midcast.SummoningMagic, {

    })

    -- Super optional set.
    sets.pet_midcast.Buff.Empy = set_combine(sets.pet_midcast.Buff, {
    })
    
    -- Wind's Blessing set. Pet:MND increases potency.
    sets.pet_midcast.Buff_MND = set_combine(sets.pet_midcast.Buff, {
    })
    
    -- Don't drop Avatar level in this set if you can help it.
    -- You can use Avatar:HP+ gear to increase the HP recovered, but most of it will decrease your own max HP.
    sets.pet_midcast.Buff_Healing = set_combine(sets.pet_midcast.Buff, {
    })
    
    -- This set is used for certain blood pacts when ImpactDebuff mode is turned ON. (/console gs c ImpactDebuff)
    -- These pacts are normally used with magic damage gear, but they're also strong debuffs when enhanced by summoning skill.
    -- This set is safe to ignore.
    sets.pet_midcast.Impact = set_combine(sets.pet_midcast.SummoningMagic, {
    })

    ------------
    -- Aftercast
    ------------
      
    -- I don't use aftercast sets, as we handle what to equip later depending on conditions using a function.
	
end