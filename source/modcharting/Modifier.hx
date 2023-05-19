package modcharting;

import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.FlxG;

#if LEATHER
import states.PlayState;
import game.Note;
import game.StrumNote;
import game.Conductor;
#else 
import PlayState;
import Note;
#end

enum ModifierType
{
    ALL;
    PLAYERONLY;
    OPPONENTONLY;
    LANESPECIFIC;   
}

class ModifierSubValue 
{
    public var value:Float = 0.0;
    public var baseValue:Float = 0.0;
    public function new(value:Float)
    {
        this.value = value;
        baseValue = value;
    }
}

class Modifier
{
    public var baseValue:Float = 0;
    public var currentValue:Float = 0;
    public var subValues:Map<String, ModifierSubValue> = new Map<String, ModifierSubValue>();
    public var tag:String = '';
    public var type:ModifierType = ALL;
    public var playfield:Int = -1;
    public var targetLane:Int = -1;
    public var instance:ModchartMusicBeatState = null;
    public var renderer:PlayfieldRenderer = null;
    public static var beat:Float = 0;

    public function new(tag:String, ?type:ModifierType = ALL, ?playfield:Int = -1)
    {
        this.tag = tag;
        this.type = type;
        this.playfield = playfield;

        setupSubValues();
    }    
    public function getNotePath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        if (currentValue != baseValue)
            noteMath(noteData, lane, curPos, pf);
    }
    public function getStrumPath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        if (currentValue != baseValue)
            strumMath(noteData, lane, pf);
    }
    public function getIncomingAngle(lane:Int, curPos:Float, pf:Int):Array<Float>
    {
        if (currentValue != baseValue)
            return incomingAngleMath(lane, curPos, pf); 
        return [0,0];       
    }

    //cur pos is how close the note is to the strum, need to edit for boost and accel
    public function getNoteCurPos(lane:Int, curPos:Float, pf:Int)
    {
        if (currentValue != baseValue)
            curPos = curPosMath(lane, curPos, pf);  
        return curPos;      
    }
    //usually fnf does *0.45 to slow the scroll speed a little, thats what this is
    //kinda just called it notedist cuz idk what else to call it,
    //using it for reverse/scroll speed changes ig
    public function getNoteDist(noteDist:Float, lane:Int, curPos:Float, pf:Int)
    {

        if (currentValue != baseValue)
            noteDist = noteDistMath(noteDist, lane, curPos, pf);

        return noteDist; 
    }

    

    public dynamic function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int) {} //for overriding (and for custom mods with hscript)
    public dynamic function strumMath(noteData:NotePositionData, lane:Int, pf:Int) {}
    public dynamic function incomingAngleMath(lane:Int, curPos:Float, pf:Int):Array<Float> { return [0,0]; }
    public dynamic function curPosMath(lane:Int, curPos:Float, pf:Int) { return curPos; }
    public dynamic function noteDistMath(noteDist:Float, lane:Int, curPos:Float, pf:Int):Float { return noteDist; }
    public dynamic function setupSubValues() {}

    public function checkPlayField(pf:Int):Bool //returns true if should display on current playfield
    {
        return (playfield == -1) || (pf == playfield);
    }
    public function checkLane(lane:Int):Bool //returns true if should display on current lane
    {
        switch(type)
        {
            case LANESPECIFIC: 
                return lane == targetLane;
            case PLAYERONLY:
                return lane >= NoteMovement.keyCount;
            case OPPONENTONLY:
                return lane < NoteMovement.keyCount;
            default: //so haxe shuts the fuck up
        }
        return true;
    }

    public function reset() //for the editor
    {
        currentValue = baseValue;
        for (subMod in subValues)
            subMod.value = subMod.baseValue;
    }
    public function copy()
    {
        //for custom mods to copy from the stored ones in the map
        var mod:Modifier = new Modifier(this.tag, this.type, this.playfield);
        mod.noteMath = this.noteMath;
        mod.strumMath = this.strumMath;
        mod.incomingAngleMath = this.incomingAngleMath;
        mod.curPosMath = this.curPosMath;
        mod.noteDistMath = this.noteDistMath;
        mod.currentValue = this.currentValue;
        mod.baseValue = this.currentValue;
        mod.subValues = this.subValues;
        mod.targetLane = this.targetLane;
        mod.instance = this.instance;
        mod.renderer = this.renderer;
        return mod;
    }
    public function createSubMod(name:String, startVal:Float)
    {
        subValues.set(name, new ModifierSubValue(startVal));
    }
}

//adding drunk and tipsy for all axis because i can

class DrunkXModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('speed', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += currentValue * (FlxMath.fastCos( ((Conductor.songPosition*0.001) + ((lane%NoteMovement.keyCount)*0.2) + 
        (curPos*0.45)*(10/FlxG.height)) * (subValues.get('speed').value*0.2)) * Note.swagWidth*0.5);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class DrunkYModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('speed', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += currentValue * (FlxMath.fastCos( ((Conductor.songPosition*0.001) + ((lane%NoteMovement.keyCount)*0.2) + 
        (curPos*0.45)*(10/FlxG.height)) * (subValues.get('speed').value*0.2)) * Note.swagWidth*0.5);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class DrunkZModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('speed', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue * (FlxMath.fastCos( ((Conductor.songPosition*0.001) + ((lane%NoteMovement.keyCount)*0.2) + 
        (curPos*0.45)*(10/FlxG.height)) * (subValues.get('speed').value*0.2)) * Note.swagWidth*0.5);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}


class TipsyXModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('speed', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += currentValue * ( FlxMath.fastCos( Conductor.songPosition*0.001 *(1.2) + 
        (lane%NoteMovement.keyCount)*(2.0) + subValues.get('speed').value*(0.2) ) * Note.swagWidth*0.4 );
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}

class TipsyYModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('speed', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += currentValue * ( FlxMath.fastCos( Conductor.songPosition*0.001 *(1.2) + 
        (lane%NoteMovement.keyCount)*(2.0) + subValues.get('speed').value*(0.2) ) * Note.swagWidth*0.4 );
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}

class TipsyZModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('speed', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue * ( FlxMath.fastCos( Conductor.songPosition*0.001 *(1.2) + 
        (lane%NoteMovement.keyCount)*(2.0) + subValues.get('speed').value*(0.2) ) * Note.swagWidth*0.4 );
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}


class ReverseModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var scrollSwitch = 520;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch = -520;
        noteData.y += scrollSwitch * currentValue;
    }
    override function noteDistMath(noteDist:Float, lane:Int, curPos:Float, pf:Int)
    {
        return noteDist * (1-(currentValue*2));
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}


class IncomingAngleModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));
        currentValue = 1.0;
    }
    override function incomingAngleMath(lane:Int, curPos:Float, pf:Int)
    {
        return [subValues.get('x').value, subValues.get('y').value];
    }
    override function reset()
    {
        super.reset();
        currentValue = 1.0; //the code that stop the mod from running gets confused when it resets in the editor i guess??
    }
}


class RotateModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));

        subValues.set('rotatePointX', new ModifierSubValue((FlxG.width/2)-(NoteMovement.arrowSize/2)));
        subValues.set('rotatePointY', new ModifierSubValue((FlxG.height/2)-(NoteMovement.arrowSize/2)));
        currentValue = 1.0;
    }

    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var xPos = NoteMovement.defaultStrumX[lane];
        var yPos = NoteMovement.defaultStrumY[lane];
        var rotX = ModchartUtil.getCartesianCoords3D(subValues.get('x').value, 90, xPos-subValues.get('rotatePointX').value);
        noteData.x += rotX.x+subValues.get('rotatePointX').value-xPos;
        var rotY = ModchartUtil.getCartesianCoords3D(90, subValues.get('y').value, yPos-subValues.get('rotatePointY').value);
        noteData.y += rotY.y+subValues.get('rotatePointY').value-yPos;
        noteData.z += rotX.z + rotY.z;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
    override function reset()
    {
        super.reset();
        currentValue = 1.0;
    }
}

class StrumLineRotateModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));
        subValues.set('z', new ModifierSubValue(90.0));
        currentValue = 1.0;
    }

    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var laneShit = lane%NoteMovement.keyCount;
        var offsetThing = 0.5;
        var halfKeyCount = NoteMovement.keyCount/2;
        if (lane < halfKeyCount)
        {
            offsetThing = -0.5;
            laneShit = lane+1;
        }
        var distFromCenter = ((laneShit)-halfKeyCount)+offsetThing; //theres probably an easier way of doing this
        //basically
        //0 = 1.5
        //1 = 0.5
        //2 = -0.5
        //3 = -1.5
        //so if you then multiply by the arrow size, all notes should be in the same place
        noteData.x += -distFromCenter*NoteMovement.arrowSize;

        var upscroll = true;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                upscroll = false;

        //var rot = ModchartUtil.getCartesianCoords3D(subValues.get('x').value, subValues.get('y').value, distFromCenter*NoteMovement.arrowSize);
        var q = SimpleQuaternion.fromEuler(subValues.get('z').value, subValues.get('x').value, (upscroll ? -subValues.get('y').value : subValues.get('y').value)); //i think this is the right order???
        //q = SimpleQuaternion.normalize(q); //dont think its too nessessary???
        noteData.x += q.x * distFromCenter*NoteMovement.arrowSize;
        noteData.y += q.y * distFromCenter*NoteMovement.arrowSize;
        noteData.z += q.z * distFromCenter*NoteMovement.arrowSize;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
    override function reset()
    {
        super.reset();
        currentValue = 1.0;
    }
}

class BumpyModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('speed', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue * 40 * FlxMath.fastSin(curPos*0.01*subValues.get('speed').value);
    }
}

class XModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteData.x += currentValue;
    }
}
class YModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteData.y += currentValue;
    }
}
class ZModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteData.z += currentValue;
    }
}

class ConfusionModifier extends Modifier //note angle
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.angle += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteData.angle += currentValue;
    }
}

class ScaleModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 1.0;
        currentValue = 1.0;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleX *= currentValue;
        noteData.scaleY *= currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteData.scaleX *= currentValue;
        noteData.scaleY *= currentValue;
    }
}

class ScaleXModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 1.0;
        currentValue = 1.0;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleX *= currentValue;
        //noteData.scaleY *= currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteData.scaleX *= currentValue;
        //noteData.scaleY *= currentValue;
    }
}

class ScaleYModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 1.0;
        currentValue = 1.0;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        //noteData.scaleX *= currentValue;
        noteData.scaleY *= currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        //noteData.scaleX += currentValue;
        noteData.scaleY *= currentValue;
    }
}


class SpeedModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 1.0;
        currentValue = 1.0;
    }
    override function curPosMath(lane:Int, curPos:Float, pf:Int)
    {
        return curPos * currentValue;
    }
}


class StealthModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.alpha *= 1-currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}

class NoteStealthModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.alpha *= 1-currentValue;
    }
}


class InvertModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += NoteMovement.arrowSizes[lane] * (lane % 2 == 0 ? 1 : -1) * currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}

class FlipModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var nd = lane % NoteMovement.keyCount;
        var newPos = FlxMath.remapToRange(nd, 0, NoteMovement.keyCount, NoteMovement.keyCount, -NoteMovement.keyCount);
        noteData.x += NoteMovement.arrowSizes[lane] * newPos * currentValue;
        noteData.x -= NoteMovement.arrowSizes[lane] * currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}


class MiniModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 1.0;
        currentValue = 1.0;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var col = (lane%NoteMovement.keyCount);
        //noteData.x -= (NoteMovement.arrowSizes[lane]-(NoteMovement.arrowSizes[lane]*currentValue))*col;

        //noteData.x += (NoteMovement.arrowSizes[lane]*currentValue*NoteMovement.keyCount*0.5);
        noteData.scaleX *= currentValue;
        noteData.scaleY *= currentValue;
        noteData.x -= ((NoteMovement.arrowSizes[lane]/2)*(noteData.scaleX-NoteMovement.defaultScale[lane]));
        noteData.y -= ((NoteMovement.arrowSizes[lane]/2)*(noteData.scaleY-NoteMovement.defaultScale[lane]));
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}

class ShrinkModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var scaleMult = 1 + (curPos*0.001*currentValue);
        noteData.scaleX *= scaleMult;
        noteData.scaleY *= scaleMult;
    }
}



class BeatXModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += currentValue * getShift(noteData, lane, curPos, pf);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
    public static function getShift(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int):Float
    {
        var fAccelTime = 0.2;
        var fTotalTime = 0.5;
    
        /* If the song is really fast, slow down the rate, but speed up the
        * acceleration to compensate or it'll look weird. */
        //var fBPM = Conductor.bpm * 60;
        //var fDiv = Math.max(1.0, Math.floor( fBPM / 150.0 ));
        //fAccelTime /= fDiv;
        //fTotalTime /= fDiv;

        /* offset by VisualDelayEffect seconds */
        var fBeat = Modifier.beat + fAccelTime;
        //fBeat /= fDiv;

        var bEvenBeat = ( Math.floor(fBeat) % 2 ) != 0;

        /* -100.2 -> -0.2 -> 0.2 */
        if( fBeat < 0 )
            return 0;

        fBeat -= Math.floor( fBeat );
        fBeat += 1;
        fBeat -= Math.floor( fBeat );

        if( fBeat >= fTotalTime )
            return 0;

        var fAmount:Float;
        if( fBeat < fAccelTime )
        {
            fAmount = FlxMath.remapToRange( fBeat, 0.0, fAccelTime, 0.0, 1.0);
            fAmount *= fAmount;
        } else /* fBeat < fTotalTime */ {
            fAmount = FlxMath.remapToRange( fBeat, fAccelTime, fTotalTime, 1.0, 0.0);
            fAmount = 1 - (1-fAmount) * (1-fAmount);
        }

        if( bEvenBeat )
            fAmount *= -1;

        var fShift = 20.0*fAmount*FlxMath.fastSin( (curPos *0.01) + (Math.PI/2.0) );
        return fShift;
    }
}

class BeatYModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += currentValue * BeatXModifier.getShift(noteData, lane, curPos, pf);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}

class BeatZModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue * BeatXModifier.getShift(noteData, lane, curPos, pf);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}



class BounceXModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('speed', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += currentValue * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos*0.005*subValues.get('speed').value));
    }
}
class BounceYModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('speed', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += currentValue * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos*0.005*subValues.get('speed').value));
    }
}
class BounceZModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('speed', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos*0.005*subValues.get('speed').value));
    }
}
class EaseCurveModifier extends Modifier
{
    public var easeFunc = FlxEase.linear;
    public function setEase(ease:String)
    {
        easeFunc = ModchartUtil.getFlxEaseByString(ease);
    }
}

class EaseCurveXModifier extends EaseCurveModifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += (easeFunc(curPos*0.01)*currentValue*0.2);
    }
}
class EaseCurveYModifier extends EaseCurveModifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += (easeFunc(curPos*0.01)*currentValue*0.2);
    }
}
class EaseCurveZModifier extends EaseCurveModifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += (easeFunc(curPos*0.01)*currentValue*0.2);
    }
}
class EaseCurveAngleModifier extends EaseCurveModifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.angle += (easeFunc(curPos*0.01)*currentValue*0.2);
    }
}
/*
class EaseCurveScaleModifier extends EaseCurveModifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleX += (easeFunc(curPos*0.01)*currentValue*0.2);
        noteData.scaleY += (easeFunc(curPos*0.01)*currentValue*0.2);
    }
}*/


class InvertSineModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += FlxMath.fastSin(0 + (curPos*0.004))*(NoteMovement.arrowSizes[lane] * (lane % 2 == 0 ? 1 : -1) * currentValue*0.5);
    }
}


class BoostModifier extends Modifier
{
    override function curPosMath(lane:Int, curPos:Float, pf:Int)
    {
        var yOffset:Float = 0;

        var speed = renderer.getCorrectScrollSpeed();

        var fYOffset = -curPos / speed;
		var fEffectHeight = FlxG.height;
		var fNewYOffset = fYOffset * 1.5 / ((fYOffset+fEffectHeight/1.2)/fEffectHeight);
		var fBrakeYAdjust = currentValue * (fNewYOffset - fYOffset);
		fBrakeYAdjust = FlxMath.bound( fBrakeYAdjust, -400, 400 ); //clamp
        
		yOffset -= fBrakeYAdjust*speed;

        return curPos+yOffset;
    }
}

class BrakeModifier extends Modifier
{
    override function curPosMath(lane:Int, curPos:Float, pf:Int)
    {
        var yOffset:Float = 0;

        var speed = renderer.getCorrectScrollSpeed();

        var fYOffset = -curPos / speed;
		var fEffectHeight = FlxG.height;
		var fScale = FlxMath.remapToRange(fYOffset, 0, fEffectHeight, 0, 1); //scale
		var fNewYOffset = fYOffset * fScale; 
		var fBrakeYAdjust = currentValue * (fNewYOffset - fYOffset);
		fBrakeYAdjust = FlxMath.bound( fBrakeYAdjust, -400, 400 ); //clamp
        
		yOffset -= fBrakeYAdjust*speed;

        return curPos+yOffset;
    }
}
class JumpModifier extends Modifier //custom thingy i made
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        strumMath(noteData, lane, pf);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        var beatVal = Modifier.beat - Math.floor(Modifier.beat); //should give decimal

        var scrollSwitch = 1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch = -1;

        

        noteData.y += (beatVal*(Conductor.stepCrochet*currentValue))*renderer.getCorrectScrollSpeed()*0.45*scrollSwitch;
    }
}