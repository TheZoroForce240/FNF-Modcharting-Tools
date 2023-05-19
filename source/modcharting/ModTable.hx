package modcharting;

import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import modcharting.Modifier;
#if LEATHER
import game.Conductor;
#end

class ModTable
{
    public var modifiers:Map<String, Modifier> = new Map<String, Modifier>();
    private var instance:ModchartMusicBeatState = null;
    private var renderer:PlayfieldRenderer = null;

    //The table is used to precalculate all the playfield and lane checks on each modifier,
    //so it should end up with a lot less loops and if checks each frame
    //index table by playfield, then lane, and then loop through each modifier
    private var table:Array<Array<Array<Modifier>>> = [];

    public function new(instance:ModchartMusicBeatState, renderer:PlayfieldRenderer)
    {
        this.instance = instance;
        this.renderer = renderer;
        loadDefaultModifiers();
        reconstructTable();
    }

    public function add(mod:Modifier) : Void
    {
        mod.instance = instance;
        mod.renderer = renderer;
        remove(mod.tag); //in case you replace one???
        modifiers.set(mod.tag, mod);
    }
    public function remove(tag:String) : Void
    {
        if (modifiers.exists(tag))
            modifiers.remove(tag);
    }
    public function clear() : Void
    {
        modifiers.clear();

        loadDefaultModifiers();
    }
    public function resetMods() : Void
    {
        for (mod in modifiers)
            mod.reset();
    }
    public function setModTargetLane(tag:String, lane:Int) : Void
    {
        if (modifiers.exists(tag))
        {
            modifiers.get(tag).targetLane = lane;
        }
    }

    public function loadDefaultModifiers() : Void
    {
        //default modifiers
        add(new XModifier('x'));
        add(new YModifier('y'));
        add(new ZModifier('z'));
        add(new ConfusionModifier('confusion'));
        for (i in 0...((NoteMovement.keyCount+NoteMovement.playerKeyCount)))
        {
            add(new XModifier('x'+i, ModifierType.LANESPECIFIC));
            add(new YModifier('y'+i, ModifierType.LANESPECIFIC));
            add(new ZModifier('z'+i, ModifierType.LANESPECIFIC));
            add(new ConfusionModifier('confusion'+i, ModifierType.LANESPECIFIC));
            setModTargetLane('x'+i, i);
            setModTargetLane('y'+i, i);
            setModTargetLane('z'+i, i);
            setModTargetLane('confusion'+i, i);
        }
    }

    public function reconstructTable() : Void
    {
        table = [];

        for (pf in 0...renderer.playfields.length)
        {
            if (table[pf] == null)
                table[pf] = [];

            for (lane in 0...NoteMovement.totalKeyCount)
            {
                table[pf].push([]);

                for (mod in modifiers)
                {
                    if (mod.checkLane(lane) && mod.checkPlayField(pf))
                    {
                        table[pf][lane].push(mod); //add mod to table
                    }
                }
            }
        }
    }

    public function applyStrumMods(noteData:NotePositionData, lane:Int, pf:Int) : Void
    {
        if (table[pf] != null && table[pf][lane] != null)
        {
            var modList:Array<Modifier> = table[pf][lane];
            for (mod in modList)
                mod.getStrumPath(noteData, lane, pf);
        }
    }
    public function applyNoteMods(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int) : Void
    {
        if (table[pf] != null && table[pf][lane] != null)
        {
            var modList:Array<Modifier> = table[pf][lane];
            for (mod in modList)
                mod.getNotePath(noteData, lane, curPos, pf);
        }
    }
    public function applyNoteDistMods(noteDist:Float, lane:Int, pf:Int) : Float
    {
        if (table[pf] != null && table[pf][lane] != null)
        {
            var modList:Array<Modifier> = table[pf][lane];
            for (mod in modList)
                noteDist = mod.getNoteDist(noteDist, lane, 0, pf);
        }
        return noteDist;
    }
    public function applyCurPosMods(lane:Int, curPos:Float, pf:Int) : Float
    {
        if (table[pf] != null && table[pf][lane] != null)
        {
            var modList:Array<Modifier> = table[pf][lane];
            for (mod in modList)
                curPos = mod.getNoteCurPos(lane, curPos, pf);
        }
        return curPos;
    }
    public function applyIncomingAngleMods(lane:Int, curPos:Float, pf:Int) : Array<Float>
    {
        var incomingAngle:Array<Float> = [0,0];
        if (table[pf] != null && table[pf][lane] != null)
        {
            var modList:Array<Modifier> = table[pf][lane];
            for (mod in modList)
            {
                var ang = mod.getIncomingAngle(lane, curPos, pf); //need to get incoming angle before
                incomingAngle[0] += ang[0];
                incomingAngle[1] += ang[1];
            }
        }
        return incomingAngle;
    }


    
    public function tweenModifier(modifier:String, val:Float, time:Float, ease:String, beat:Float)
    {
        var modifiers:Map<String, Modifier> = renderer.modifierTable.modifiers;
        if (modifiers.exists(modifier))
        {       
            var easefunc = ModchartUtil.getFlxEaseByString(ease);  
            if (Conductor.songPosition >= ModchartUtil.getTimeFromBeat(beat)+(time*1000)) //cancel if should have ended
            {
                modifiers.get(modifier).currentValue = val;
                return;
            }
            time /= renderer.speed;
            var tween = renderer.tweenManager.tween(modifiers.get(modifier), {currentValue: val}, time, {ease: easefunc,
                onComplete: function(twn:FlxTween) {
    
                }
            });
            if (Conductor.songPosition > ModchartUtil.getTimeFromBeat(beat)) //skip to where it should be i guess??
            {
                @:privateAccess
                tween._secondsSinceStart += ((Conductor.songPosition-ModchartUtil.getTimeFromBeat(beat))*0.001);
                @:privateAccess
                tween.update(0);
            }
            if (renderer.editorPaused)
                tween.active = false;
        }
    }

    public function tweenModifierSubValue(modifier:String, subValue:String, val:Float, time:Float, ease:String, beat:Float)
    {
        var modifiers:Map<String, Modifier> = renderer.modifierTable.modifiers;
        if (modifiers.exists(modifier))
        {       
            if (modifiers.get(modifier).subValues.exists(subValue))
            {
                var easefunc = ModchartUtil.getFlxEaseByString(ease);   
                var tag = modifier+' '+subValue; 

                var startValue = modifiers.get(modifier).subValues.get(subValue).value;

                if (Conductor.songPosition >= ModchartUtil.getTimeFromBeat(beat)+(time*1000)) //cancel if should have ended
                {
                    modifiers.get(modifier).subValues.get(subValue).value = val;
                    return;
                }
                time /= renderer.speed;
                var tween = renderer.tweenManager.num(startValue, val, time, {ease: easefunc,
                    onComplete: function(twn:FlxTween) {
                        if (modifiers.exists(modifier))
                            modifiers.get(modifier).subValues.get(subValue).value = val;
                    },
                    onUpdate: function(twn:FlxTween) {
                        //need to update like this because its inside a map
                        if (modifiers.exists(modifier))
                            modifiers.get(modifier).subValues.get(subValue).value = FlxMath.lerp(startValue, val, easefunc(twn.percent));
                    }
                });
                if (Conductor.songPosition > ModchartUtil.getTimeFromBeat(beat)) //skip to where it should be i guess??
                {
                    @:privateAccess
                    tween._secondsSinceStart += ((Conductor.songPosition-ModchartUtil.getTimeFromBeat(beat))*0.001);
                    @:privateAccess
                    tween.update(0);
                }
                if (renderer.editorPaused)
                    tween.active = false;
            }

        }
    }
}