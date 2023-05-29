package modcharting;


import haxe.Json;
import openfl.net.FileReference;
#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

#if LEATHER
import states.PlayState;
import game.Conductor;
#end

import modcharting.Modifier;
import modcharting.PlayfieldRenderer;
import modcharting.NoteMovement;
import modcharting.ModchartUtil;

import openfl.events.Event;
import openfl.events.IOErrorEvent;

using StringTools;

//for lua and hscript
class ModchartFuncs
{
    public static function loadLuaFunctions()
    {
        #if PSYCH
        #if LUA_ALLOWED
        for (funkin in PlayState.instance.luaArray)
        {
            #if hscript
            funkin.initHaxeModule();
            #end
            Lua_helper.add_callback(funkin.lua, 'startMod', function(name:String, modClass:String, type:String = '', pf:Int = -1){
                startMod(name,modClass,type,pf);

                PlayState.instance.playfieldRenderer.modifierTable.reconstructTable(); //needs to be reconstructed for lua modcharts
            });
            Lua_helper.add_callback(funkin.lua, 'setMod', function(name:String, value:Float){
                setMod(name, value);
            });
            Lua_helper.add_callback(funkin.lua, 'setSubMod', function(name:String, subValName:String, value:Float){
                setSubMod(name, subValName,value);
            });
            Lua_helper.add_callback(funkin.lua, 'setModTargetLane', function(name:String, value:Int){
                setModTargetLane(name, value);
            });
            Lua_helper.add_callback(funkin.lua, 'setModPlayfield', function(name:String, value:Int){
                setModPlayfield(name,value);
            });
            Lua_helper.add_callback(funkin.lua, 'addPlayfield', function(?x:Float = 0, ?y:Float = 0, ?z:Float = 0){
                addPlayfield(x,y,z);
            });
            Lua_helper.add_callback(funkin.lua, 'removePlayfield', function(idx:Int){
                removePlayfield(idx);
            });
            Lua_helper.add_callback(funkin.lua, 'tweenModifier', function(modifier:String, val:Float, time:Float, ease:String){
                tweenModifier(modifier,val,time,ease);
            });
            Lua_helper.add_callback(funkin.lua, 'tweenModifierSubValue', function(modifier:String, subValue:String, val:Float, time:Float, ease:String){
                tweenModifierSubValue(modifier,subValue,val,time,ease);
            });
            Lua_helper.add_callback(funkin.lua, 'setModEaseFunc', function(name:String, ease:String){
                setModEaseFunc(name,ease);
            });
            Lua_helper.add_callback(funkin.lua, 'set', function(beat:Float, argsAsString:String){
                set(beat, argsAsString);
            });
            Lua_helper.add_callback(funkin.lua, 'ease', function(beat:Float, time:Float, easeStr:String, argsAsString:String){

                ease(beat, time, easeStr, argsAsString);
                
            });
        }
        #end
        #if hscript
        if (FunkinLua.hscript != null)
        {
            FunkinLua.hscript.variables.set('Math', Math);
            FunkinLua.hscript.variables.set('PlayfieldRenderer', PlayfieldRenderer);
            FunkinLua.hscript.variables.set('ModchartUtil', ModchartUtil);
            FunkinLua.hscript.variables.set('Modifier', Modifier);
            FunkinLua.hscript.variables.set('NoteMovement', NoteMovement);
            FunkinLua.hscript.variables.set('NotePositionData', NotePositionData);
            FunkinLua.hscript.variables.set('ModchartFile', ModchartFile);
        }
        #end


        #elseif LEATHER

        #end
    }

    public static function startMod(name:String, modClass:String, type:String = '', pf:Int = -1, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
        {
            instance = PlayState.instance;
            if (instance.playfieldRenderer.modchart.scriptListen)
            {
                instance.playfieldRenderer.modchart.data.modifiers.push([name, modClass, type, pf]);
            }
        }

        if (instance.playfieldRenderer.modchart.customModifiers.exists(modClass))
        {
            var modifier = new Modifier(name, getModTypeFromString(type), pf);
            if (instance.playfieldRenderer.modchart.customModifiers.get(modClass).interp != null)
                instance.playfieldRenderer.modchart.customModifiers.get(modClass).interp.variables.set('instance', instance);
            instance.playfieldRenderer.modchart.customModifiers.get(modClass).initMod(modifier); //need to do it this way instead because using current value in the modifier script didnt work
            //var modifier = instance.playfieldRenderer.modchart.customModifiers.get(modClass).copy();
            //modifier.tag = name; //set correct stuff because its copying shit
            //modifier.playfield = pf;
            //modifier.type = getModTypeFromString(type);
            instance.playfieldRenderer.modifierTable.add(modifier);
            return;
        }

        var mod = Type.resolveClass('modcharting.'+modClass);
        if (mod == null) {mod = Type.resolveClass('modcharting.'+modClass+"Modifier");} //dont need to add "Modifier" to the end of every mod

        if (mod != null)
        {
            var modType = getModTypeFromString(type);
            var modifier = Type.createInstance(mod, [name, modType, pf]);
            instance.playfieldRenderer.modifierTable.add(modifier);
        }
    }
    public static function getModTypeFromString(type:String)
    {
        var modType = ModifierType.ALL;
        switch (type.toLowerCase())
        {
            case 'player':
                modType = ModifierType.PLAYERONLY;
            case 'opponent':
                modType = ModifierType.OPPONENTONLY;
            case 'lane' | 'lanespecific':
                modType = ModifierType.LANESPECIFIC;
        }
        return modType;
    }

    public static function setMod(name:String, value:Float, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
            instance = PlayState.instance;
        if (instance.playfieldRenderer.modchart.scriptListen)
        {
            instance.playfieldRenderer.modchart.data.events.push(["set", [0, value+","+name]]);
        }
        if (instance.playfieldRenderer.modifierTable.modifiers.exists(name))
            instance.playfieldRenderer.modifierTable.modifiers.get(name).currentValue = value;
    }
    public static function setSubMod(name:String, subValName:String, value:Float, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
            instance = PlayState.instance;
        if (instance.playfieldRenderer.modchart.scriptListen)
        {
            instance.playfieldRenderer.modchart.data.events.push(["set", [0, value+","+name+":"+subValName]]);
        }
        if (instance.playfieldRenderer.modifierTable.modifiers.exists(name))
            instance.playfieldRenderer.modifierTable.modifiers.get(name).subValues.get(subValName).value = value;
    }
    public static function setModTargetLane(name:String, value:Int, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
            instance = PlayState.instance;
        if (instance.playfieldRenderer.modifierTable.modifiers.exists(name))
            instance.playfieldRenderer.modifierTable.modifiers.get(name).targetLane = value;
    }
    public static function setModPlayfield(name:String, value:Int, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
            instance = PlayState.instance;
        if (instance.playfieldRenderer.modifierTable.modifiers.exists(name))
            instance.playfieldRenderer.modifierTable.modifiers.get(name).playfield = value;
    }
    public static function addPlayfield(?x:Float = 0, ?y:Float = 0, ?z:Float = 0, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
            instance = PlayState.instance;
        instance.playfieldRenderer.addNewPlayfield(x,y,z);
    }
    public static function removePlayfield(idx:Int, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
            instance = PlayState.instance;
        instance.playfieldRenderer.playfields.remove(instance.playfieldRenderer.playfields[idx]);
    }

    public static function tweenModifier(modifier:String, val:Float, time:Float, ease:String, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
            instance = PlayState.instance;
        instance.playfieldRenderer.modifierTable.tweenModifier(modifier,val,time,ease, Modifier.beat);
    }

    public static function tweenModifierSubValue(modifier:String, subValue:String, val:Float, time:Float, ease:String, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
            instance = PlayState.instance;
        instance.playfieldRenderer.modifierTable.tweenModifierSubValue(modifier,subValue,val,time,ease, Modifier.beat);
    }

    public static function setModEaseFunc(name:String, ease:String, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
            instance = PlayState.instance;
        if (instance.playfieldRenderer.modifierTable.modifiers.exists(name))
        {
            var mod = instance.playfieldRenderer.modifierTable.modifiers.get(name);
            if (Std.isOfType(mod, EaseCurveModifier))
            {
                var temp:Dynamic = mod;
                var castedMod:EaseCurveModifier = temp;
                castedMod.setEase(ease);
            }
        }
    }
    public static function set(beat:Float, argsAsString:String, ?instance:ModchartMusicBeatState = null)
    {
        if (instance == null)
        {
            instance = PlayState.instance;
            if (instance.playfieldRenderer.modchart.scriptListen)
            {
                instance.playfieldRenderer.modchart.data.events.push(["set", [beat, argsAsString]]);
            }
        }
        var args = argsAsString.trim().replace(' ', '').split(',');

        instance.playfieldRenderer.eventManager.addEvent(beat, function(arguments:Array<String>) {
            for (i in 0...Math.floor(arguments.length/2))
            {
                var name:String = Std.string(arguments[1 + (i*2)]);
                var value:Float = Std.parseFloat(arguments[0 + (i*2)]);
                if(Math.isNaN(value))
                    value = 0;
                if (instance.playfieldRenderer.modifierTable.modifiers.exists(name))
                {
                    instance.playfieldRenderer.modifierTable.modifiers.get(name).currentValue = value;
                }
                else 
                {
                    var subModCheck = name.split(':');
                    if (subModCheck.length > 1)
                    {
                        var modName = subModCheck[0];
                        var subModName = subModCheck[1];
                        if (instance.playfieldRenderer.modifierTable.modifiers.exists(modName))
                            instance.playfieldRenderer.modifierTable.modifiers.get(modName).subValues.get(subModName).value = value;
                    }
                }
                    
            }
        }, args);
    }
    public static function ease(beat:Float, time:Float, ease:String, argsAsString:String, ?instance:ModchartMusicBeatState = null) : Void
    {
        if (instance == null)
        {
            instance = PlayState.instance;
            if (instance.playfieldRenderer.modchart.scriptListen)
            {
                instance.playfieldRenderer.modchart.data.events.push(["ease", [beat, time, ease, argsAsString]]);
            }
        }
            
        if(Math.isNaN(time))
            time = 1;

        var args = argsAsString.trim().replace(' ', '').split(',');

        var func = function(arguments:Array<String>) {
            
            for (i in 0...Math.floor(arguments.length/2))
            {
                var name:String = Std.string(arguments[1 + (i*2)]);
                var value:Float = Std.parseFloat(arguments[0 + (i*2)]);
                if(Math.isNaN(value))
                    value = 0;
                var subModCheck = name.split(':');
                if (subModCheck.length > 1)
                {
                    var modName = subModCheck[0];
                    var subModName = subModCheck[1];
                    //trace(subModCheck);
                    instance.playfieldRenderer.modifierTable.tweenModifierSubValue(modName,subModName,value,time*Conductor.crochet*0.001,ease, beat);
                }
                else
                    instance.playfieldRenderer.modifierTable.tweenModifier(name,value,time*Conductor.crochet*0.001,ease, beat);
                
            }
        };
        instance.playfieldRenderer.eventManager.addEvent(beat, func, args);
    }
    
}


