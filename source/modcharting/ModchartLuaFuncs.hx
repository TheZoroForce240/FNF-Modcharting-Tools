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

//for psych lua
class ModchartLuaFuncs
{
   
    public static function luaFunctionStuff()
    {
        #if PSYCH
        #if LUA_ALLOWED
        for (funkin in PlayState.instance.luaArray)
        {
            #if hscript
            funkin.initHaxeInterp();
            #end
            Lua_helper.add_callback(funkin.lua, 'startMod', function(name:String, modClass:String, type:String = '', pf:Int = -1){

                var mod = Type.resolveClass('modcharting.'+modClass);
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
            });

            Lua_helper.add_callback(funkin.lua, 'setMod', function(name:String, value:Float){
                if (PlayState.instance.playfieldRenderer.modifiers.exists(name))
                    PlayState.instance.playfieldRenderer.modifiers.get(name).currentValue = value;
            });

            Lua_helper.add_callback(funkin.lua, 'setSubMod', function(name:String, subValName:String, value:Float){
                if (PlayState.instance.playfieldRenderer.modifiers.exists(name))
                    PlayState.instance.playfieldRenderer.modifiers.get(name).subValues.set(subValName, value);
            });

            Lua_helper.add_callback(funkin.lua, 'setModTargetLane', function(name:String, value:Int){
                if (PlayState.instance.playfieldRenderer.modifiers.exists(name))
                    PlayState.instance.playfieldRenderer.modifiers.get(name).targetLane = value;
            });

            Lua_helper.add_callback(funkin.lua, 'setModPlayfield', function(name:String, value:Int){
                if (PlayState.instance.playfieldRenderer.modifiers.exists(name))
                    PlayState.instance.playfieldRenderer.modifiers.get(name).playfield = value;
            });

            Lua_helper.add_callback(funkin.lua, 'addPlayfield', function(?x:Float = 0, ?y:Float = 0, ?z:Float = 0){
                PlayState.instance.playfieldRenderer.addNewplayfield(x,y,z);
            });
            Lua_helper.add_callback(funkin.lua, 'removePlayfield', function(idx:Int){
                PlayState.instance.playfieldRenderer.playfields.remove(PlayState.instance.playfieldRenderer.playfields[idx]);
            });


            Lua_helper.add_callback(funkin.lua, 'tweenModifier', function(modifier:String, val:Float, time:Float, ease:String){
                PlayState.instance.playfieldRenderer.tweenModifier(modifier,val,time,ease);
            });

            Lua_helper.add_callback(funkin.lua, 'tweenModifierSubValue', function(modifier:String, subValue:String, val:Float, time:Float, ease:String){
                PlayState.instance.playfieldRenderer.tweenModifierSubValue(modifier,subValue,val,time,ease);
            });

            Lua_helper.add_callback(funkin.lua, 'setModEaseFunc', function(name:String, ease:String){
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
            });



            Lua_helper.add_callback(funkin.lua, 'set', function(beat:Float, argsAsString:String){
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
            });


            Lua_helper.add_callback(funkin.lua, 'ease', function(beat:Float, time:Float, ease:String, argsAsString:String){
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
            });
        }
        #end
        #if hscript
        if (FunkinLua.haxeInterp != null)
        {
            FunkinLua.haxeInterp.variables.set('Math', Math);
            FunkinLua.haxeInterp.variables.set('PlayfieldRenderer', PlayfieldRenderer);
            FunkinLua.haxeInterp.variables.set('ModchartUtil', ModchartUtil);
            FunkinLua.haxeInterp.variables.set('Modifier', Modifier);
            FunkinLua.haxeInterp.variables.set('NoteMovement', NoteMovement);
            FunkinLua.haxeInterp.variables.set('NotePositionData', PlayfieldRenderer.NotePositionData);
        }
        #end


        #elseif LEATHER

        #end
    }
    
}


