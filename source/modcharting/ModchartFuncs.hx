package modcharting;


#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

import modcharting.Modifier;
import modcharting.PlayfieldRenderer;
import modcharting.NoteMovement;
import modcharting.ModchartUtil;

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
            FunkinLua.hscript.variables.set('NotePositionData', PlayfieldRenderer.NotePositionData);
        }
        #end


        #elseif LEATHER

        #end
    }

    static function startMod(name:String, modClass:String, type:String = '', pf:Int = -1)
    {
        var mod = Type.resolveClass('modcharting.'+modClass);
        if (mod == null) {mod = Type.resolveClass('modcharting.'+modClass+"Modifier");} //dont need to add "Modifier" to the end of every mod

        if (mod != null)
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
            var modifier = Type.createInstance(mod, [name, modType, pf]);
            PlayState.instance.playfieldRenderer.addModifier(modifier);
        }
    }

    static function setMod(name:String, value:Float)
    {
        if (PlayState.instance.playfieldRenderer.modifiers.exists(name))
            PlayState.instance.playfieldRenderer.modifiers.get(name).currentValue = value;
    }
    static function setSubMod(name:String, subValName:String, value:Float)
    {
        if (PlayState.instance.playfieldRenderer.modifiers.exists(name))
            PlayState.instance.playfieldRenderer.modifiers.get(name).subValues.set(subValName, value);
    }
    static function setModTargetLane(name:String, value:Int)
    {
        if (PlayState.instance.playfieldRenderer.modifiers.exists(name))
            PlayState.instance.playfieldRenderer.modifiers.get(name).targetLane = value;
    }
    static function setModPlayfield(name:String, value:Int)
    {
        if (PlayState.instance.playfieldRenderer.modifiers.exists(name))
            PlayState.instance.playfieldRenderer.modifiers.get(name).playfield = value;
    }
    static function addPlayfield(?x:Float = 0, ?y:Float = 0, ?z:Float = 0)
    {
        PlayState.instance.playfieldRenderer.addNewplayfield(x,y,z);
    }
    static function removePlayfield(idx:Int)
    {
        PlayState.instance.playfieldRenderer.playfields.remove(PlayState.instance.playfieldRenderer.playfields[idx]);
    }

    static function tweenModifier(modifier:String, val:Float, time:Float, ease:String)
    {
        PlayState.instance.playfieldRenderer.tweenModifier(modifier,val,time,ease);
    }

    static function tweenModifierSubValue(modifier:String, subValue:String, val:Float, time:Float, ease:String)
    {
        PlayState.instance.playfieldRenderer.tweenModifierSubValue(modifier,subValue,val,time,ease);
    }

    static function setModEaseFunc(name:String, ease:String)
    {
        if (PlayState.instance.playfieldRenderer.modifiers.exists(name))
        {
            var mod = PlayState.instance.playfieldRenderer.modifiers.get(name);
            if (Std.isOfType(mod, EaseCurveModifier))
            {
                var temp:Dynamic = mod;
                var castedMod:EaseCurveModifier = temp;
                castedMod.setEase(ease);
            }
        }
    }
    static function set(beat:Float, argsAsString:String)
    {
        var args = argsAsString.trim().replace(' ', '').split(',');

        PlayState.instance.playfieldRenderer.addEvent(beat, function(arguments:Array<String>) {
            for (i in 0...Math.floor(arguments.length/2))
            {
                var name:String = Std.string(arguments[1 + (i*2)]);
                var value:Float = Std.parseFloat(arguments[0 + (i*2)]);
                if (PlayState.instance.playfieldRenderer.modifiers.exists(name))
                {
                    PlayState.instance.playfieldRenderer.modifiers.get(name).currentValue = value;
                }
                else 
                {
                    var subModCheck = name.split(':');
                    if (subModCheck.length > 1)
                    {
                        var modName = subModCheck[0];
                        var subModName = subModCheck[1];
                        if (PlayState.instance.playfieldRenderer.modifiers.exists(modName))
                            PlayState.instance.playfieldRenderer.modifiers.get(modName).subValues.set(subModName, value);
                    }
                }
                    
            }
        }, args);
    }
    public static function ease(beat:Float, time:Float, ease:String, argsAsString:String) : Void
    {
        var args = argsAsString.trim().replace(' ', '').split(',');

        PlayState.instance.playfieldRenderer.addEvent(beat, function(arguments:Array<String>) {
            for (i in 0...Math.floor(arguments.length/2))
            {
                var name:String = Std.string(arguments[1 + (i*2)]);
                var value:Float = Std.parseFloat(arguments[0 + (i*2)]);

                var subModCheck = name.split(':');
                if (subModCheck.length > 1)
                {
                    var modName = subModCheck[0];
                    var subModName = subModCheck[1];
                    //trace(subModCheck);
                    PlayState.instance.playfieldRenderer.tweenModifierSubValue(modName,subModName,value,time*Conductor.crochet*0.001,ease);
                }
                else
                    PlayState.instance.playfieldRenderer.tweenModifier(name,value,time*Conductor.crochet*0.001,ease);
                
            }
        }, args);

    }
}


