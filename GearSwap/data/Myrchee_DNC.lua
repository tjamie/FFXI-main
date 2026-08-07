-- Based on Elizabet's RDM lua: https://www.ffxiah.com/forum/topic/53934/a-rdm-gearswap/

include('organizer-lib') -- optional
res = require('resources')
texts = require('texts')
include('Modes.lua')

-- Define your modes: 
-- You can add or remove modes in the table below, they will get picked up in the cycle automatically. 
-- to define sets for idle if you add more modes, name them: sets.me.idle.mymode and add 'mymode' in the group.
-- Same idea for nuke modes. 
idleModes = M('dt', 'dynamis')
meleeModes = M('normal', 'dw', 'hybrid', 'crit', 'dynamis')

------------------------------------------------------------------------------------------------------
-- Important to read!
------------------------------------------------------------------------------------------------------
-- This will be used later down for weapon combos, here's mine for example, you can add your REMA+offhand of choice in there
-- Add you weapons in the Main list and/or sub list.
-- Don't put any weapons / sub in your IDLE and ENGAGED sets'
-- You can put specific weapons in the midcasts and precast sets for spells, but after a spell is 
-- cast and we revert to idle or engaged sets, we'll be checking the following for weapon selection. 
-- Defaults are the first in each list

mainWeapon = M('Aeneas', 'Tauret', "Gleti's Knife")
subWeapon = M("Gleti's Knife", "Fusetto +2")
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

include('DNC_Lib.lua')

-- Optional. Swap to your macro sheet / book
set_macros(1,8) -- Sheet, Book
StartLockStyle=46
send_command('input /lockstyleset '..StartLockStyle)

refreshType = idleModes[1] -- leave this as is     

-- Setup your Gear Sets below:
function get_sets()
    
    -- JSE
    AF = {}         -- leave this empty
    RELIC = {}      -- leave this empty
    EMPY = {}       -- leave this empty


	-- Fill this with your own JSE. 
    --
    AF.Head		    =	"Maxixi Tiara +1"
    AF.Body		    =	"Maxixi Casaque +1"
    AF.Hands	    =	"Maxixi Bangles +4"
    AF.Legs		    =	""
    AF.Feet		    =	"Maxixi Toe Shoes +1"

    --
    RELIC.Head		=	"Horos Tiara +1"
    RELIC.Body		=	""
    RELIC.Hands 	=	""
    RELIC.Legs		=	"Horos Tights +4"
    RELIC.Feet		=	""

    --
    EMPY.Head		=	""
    EMPY.Body		=	""
    EMPY.Hands		=	""
    EMPY.Legs		=	""
    EMPY.Feet		=	"Macu. Toe Sh. +2"
    EMPY.Earring    =   "Macu. Earring +1"

    -- Capes
    DNCCape = {}
    DNCCape.DEX		=	{ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%',}}
    DNCCape.Crit    =   { name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10',}}
	DNCCape.Waltz   =   DNCCape.Crit

    -- SETS 
    sets.me = {}        -- leave this empty
    sets.buff = {}      -- leave this empty
    sets.me.idle = {}   -- leave this empty
    sets.me.melee = {}  -- leave this empty
    sets.weapons = {}   -- leave this empty
	
    -- Optional 
    --include('AugGear.lua') -- I list all my Augmented gears in a sidecar file since it's shared across many jobs. 

    -- Leave weapons out of the idles and melee sets. You can/should add weapons to the casting sets though
    -- Your idle set
    sets.me.idle.refresh = {

    }

    -- Your idle DT set
    sets.me.idle.dt = set_combine(sets.me.idle.refresh,{
        ammo = "Staunch Tathlum +1", --3
        head = "Malignance Chapeau", --6
        body = "Malignance Tabard", --9
        hands = "Malignance Gloves", --5
        legs = "Malignance Tights", --7
        feet = "Malignance Boots", --4
        neck = "Elite Royal Collar", --5
        waist = "Null Belt", --(meva)
        left_ring = "Murky Ring", --10
        right_ring = "Defending Ring", --10
        left_ear = "Alabaster Earring",
        right_ear = "Thureous Earring",
        back = "Null Shawl"
        --TODO adjust as needed when DT gets added to a dnc cape
    })

    sets.me.idle.dynamis = set_combine(sets.me.idle.dt,{
        neck = "Etoile Gorget +1",
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
    sets.me.melee.normal = {
        ammo = "Coiste Bodhar",
        head = "Malignance Chapeau",
        body = "Malignance Tabard",
        hands = "Malignance Gloves",
        legs = "Malignance Tights",
        feet = EMPY.Feet,
        neck = "Anu Torque",
        waist = "Sailfi Belt +1",
        left_ear = "Sherida Earring",
        right_ear = "Cessance Earring",
        -- left_ring = "Petrov Ring",
        left_ring = "Gere Ring",
        right_ring = "Lehko's Ring",
        back = "Null Shawl"
    }
    sets.me.melee.hybrid = set_combine(sets.me.melee.normal, {
        left_ring = "Murky Ring"
        --DT -46
    })
    sets.me.melee.dw = set_combine(sets.me.melee.normal, {
        waist = "Reiki Yotai"
    })
    sets.me.melee.crit = set_combine(sets.me.dw, {
        head = "Gleti's Mask", --5
        body = "Gleti's Cuirass", --8
        hands = "Gleti's Gauntlets", --6
        legs = "Gleti's Breeches", --7
        feet = "Gleti's Boots", --4
        left_ear = "Odr Earring", --5
        left_ring = "Gere Ring", --TA5
        right_ring = "Lehko's Ring", --10
        -- total crit rate = 45
        -- +5 from merits = 50
        -- +5 from gleti's knife = 55
    })
    sets.me.melee.dynamis = set_combine(sets.me.melee.normal,{
        neck="Etoile Gorget +1",
    })
    sets.me.melee.accuracy = set_combine(sets.me.melee.normal,{
        neck = "Null Loop",
        waist = "Null Belt"
    })
	
	------------------------------------------------------------------------------------------------------
    -- Weapon Skills
	------------------------------------------------------------------------------------------------------
    sets.me["Ruthless Stroke"] = {
        -- Placeholder
	}
    sets.me["Rudra's Storm"] = {
        ammo = "Coiste Bodhar",
        head = "Nyame Helm",
        body = "Nyame Mail",
        hands = AF.Hands,
        legs = RELIC.Legs,
        feet = "Nyame Sollerets",
        neck = "Rep. Plat. Medal",
        waist = "Kentarch Belt +1",
        left_ear = "Moonshade Earring",
        right_ear = EMPY.Earring,
        left_ring = "Epaminondas's Ring",
        right_ring = "Ilabrat Ring",
        back = DNCCape.DEX
    }
    sets.me["Evisceration"] = set_combine(sets.me["Rudra's Storm"], {
        ammo = "Coiste Bodhar",
        head = "Gleti's Mask",
        body = "Gleti's Cuirass",
        hands = "Gleti's Gauntlets",
        legs = "Gleti's Breeches",
        feet = "Gleti's Boots",
        neck = "Rep. Plat. Medal",
        waist = "Fotia Belt",
        left_ear ="Odr Earring",
        right_ear = EMPY.Earring,
        left_ring = "Epaminondas's Ring",
        right_ring = "Ilabrat Ring",
        back = DNCCape.Crit
    })
   sets.me["Shark Bite"] = set_combine(sets.me["Rudra's Storm"], {
        ammo = "Coiste Bodhar",
        head = "Nyame Helm",
        body = "Nyame Mail",
        hands = AF.Hands,
        legs = "Nyame Flanchard",
        feet = "Nyame Sollerets",
        neck = "Rep. Plat. Medal",
        waist = "Kentarch Belt +1",
        left_ear = "Moonshade Earring",
        right_ear = EMPY.Earring,
        left_ring = "Epaminondas's Ring",
        right_ring = "Ilabrat Ring",
        back = DNCCape.DEX
    })
    sets.me["Exenterator"] = set_combine(sets.me["Rudra's Storm"], {
        ammo = "Coiste Bodhar",
        head = "Nyame Helm",
        body = "Gleti's Cuirass",
        hands = AF.Hands,
        legs = RELIC.Legs,
        feet ="Nyame Sollerets",
        neck = "Rep. Plat. Medal",
        waist = "Fotia Belt",
        left_ear = "Moonshade Earring",
        right_ear = EMPY.Earring,
        left_ring = "Gere Ring",
        right_ring = "Sroda Ring",
        back = DNCCape.Crit --TODO make a AGI+DA cape
    })
    sets.me["Pyrrhic Kleos"] = set_combine(sets.me["Rudra's Storm"], {
        ammo = "Coiste Bodhar",
        head = "Gleti's Mask",
        body = "Gleti's Cuirass",
        hands = "Gleti's Gauntlets",
        legs = "Gleti's Breeches",
        feet = "Gleti's Boots",
        neck = "Rep. Plat. Medal", --TODO replace with JSE neck when augmented
        waist = "Fotia Belt",
        left_ear ="Sherida Earring",
        right_ear = EMPY.Earring,
        left_ring = "Sroda Ring",
        right_ring = "Gere Ring",
        back = DNCCape.DEX --TODO make STR/WSD or STR/DA back
    })
	
	
    ---------------
    -- Ability Sets
    ---------------
    sets.precast = {}   		-- Leave this empty  
    sets.midcast = {}    		-- Leave this empty  
    sets.aftercast = {}  		-- Leave this empty
    ----------
    -- Precast
    ----------
      
    -- Generic fast cast
    sets.precast.casting = {
    }

    sets.precast["Stun"] = set_combine(sets.precast.casting,{

    })

    -- Enhancing Magic, eg. Siegal Sash, etc
      
    ---------------------
    -- Ability Precasting
    ---------------------

    sets.precast["Trance"] = {
        body = RELIC.Head
    }
    
    sets.precast["No Foot Rise"] = {
        body = RELIC.Body
    }

    sets.precast.jig = {
        legs = RELIC.Legs,
        feet = AF.Feet,
    }

    sets.precast.waltz = {
        head = RELIC.Head,
        body = AF.Body,
        feet = AF.Feet,
        neck = "Etoile Gorget +1",
        back = DNCCape.Waltz,
    }

    sets.precast.samba = {
        head = AF.Head,
    }
	
	----------
    -- Midcast
    ----------

    -- Whatever you want to equip mid-cast as a catch all for all spells, and we'll overwrite later for individual spells
    sets.midcast.casting = {
    }
	
    ------------
    -- Aftercast
    ------------
      
    -- I don't use aftercast sets, as we handle what to equip later depending on conditions using a function.
	
end
