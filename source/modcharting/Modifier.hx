package modcharting;

import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import modcharting.PlayfieldRenderer.NotePositionData;
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


class Modifier
{
    public var baseValue:Float = 0;
    public var currentValue:Float = 0;
    public var subValues:Map<String, Float> = new Map<String, Float>();
    public var tag:String = '';
    public var type:ModifierType = ALL;
    public var playfield:Int = -1;
    public var targetLane:Int = -1;
    public var instance:PlayState = null;
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
        if (checkPlayField(pf) && currentValue != baseValue && checkLane(lane))
            noteMath(noteData, lane, curPos, pf);
    }
    public function getStrumPath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        if (checkPlayField(pf) && currentValue != baseValue && checkLane(lane))
            strumMath(noteData, lane, pf);        
    }
    public function getIncomingAngle(lane:Int, curPos:Float, pf:Int):Array<Float>
    {
        if (checkPlayField(pf) && currentValue != baseValue && checkLane(lane))
            return incomingAngleMath(lane, curPos, pf); 
        return [0,0];       
    }

    //cur pos is how close the note is to the strum, need to edit for boost and accel
    public function getNoteCurPos(lane:Int, curPos:Float, pf:Int)
    {
        if (checkPlayField(pf) && currentValue != baseValue && checkLane(lane))
            curPos = curPosMath(lane, curPos, pf);  
        return curPos;      
    }
    //usually fnf does *0.45 to slow the scroll speed a little, thats what this is
    //kinda just called it notedist cuz idk what else to call it,
    //using it for reverse/scroll speed changes ig
    public function getNoteDist(noteDist:Float, lane:Int, curPos:Float, pf:Int)
    {

        if (checkPlayField(pf) && currentValue != baseValue && checkLane(lane))
            noteDist = noteDistMath(noteDist, lane, curPos, pf);  

        return noteDist; 
    }

    

    public dynamic function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int) {} //for overriding
    public dynamic function strumMath(noteData:NotePositionData, lane:Int, pf:Int) {}
    public dynamic function incomingAngleMath(lane:Int, curPos:Float, pf:Int):Array<Float> { return [0,0]; }
    public dynamic function curPosMath(lane:Int, curPos:Float, pf:Int) { return curPos; }
    public dynamic function noteDistMath(noteDist:Float, lane:Int, curPos:Float, pf:Int):Float { return noteDist; }
    public dynamic function setupSubValues() {}

    function checkPlayField(pf:Int):Bool //returns true if should display on current playfield
    {
        return (playfield == -1) || (pf == playfield);
    }
    function checkLane(lane:Int):Bool //returns true if should display on current lane
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
}

//adding drunk and tipsy for all axis because i can

class DrunkXModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('speed', 1.0);
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += currentValue * (FlxMath.fastCos( ((Conductor.songPosition*0.001) + ((lane%NoteMovement.keyCount)*0.2) + 
        (curPos*0.45)*(10/FlxG.height)) * (subValues.get('speed')*0.2)) * Note.swagWidth*0.5);
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
        subValues.set('speed', 1.0);
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += currentValue * (FlxMath.fastCos( ((Conductor.songPosition*0.001) + ((lane%NoteMovement.keyCount)*0.2) + 
        (curPos*0.45)*(10/FlxG.height)) * (subValues.get('speed')*0.2)) * Note.swagWidth*0.5);
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
        subValues.set('speed', 1.0);
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue * (FlxMath.fastCos( ((Conductor.songPosition*0.001) + ((lane%NoteMovement.keyCount)*0.2) + 
        (curPos*0.45)*(10/FlxG.height)) * (subValues.get('speed')*0.2)) * Note.swagWidth*0.5);
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
        subValues.set('speed', 1.0);
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += currentValue * ( FlxMath.fastCos( Conductor.songPosition*0.001 *(1.2) + 
        (lane%NoteMovement.keyCount)*(2.0) + subValues.get('speed')*(0.2) ) * Note.swagWidth*0.4 );
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
        subValues.set('speed', 1.0);
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += currentValue * ( FlxMath.fastCos( Conductor.songPosition*0.001 *(1.2) + 
        (lane%NoteMovement.keyCount)*(2.0) + subValues.get('speed')*(0.2) ) * Note.swagWidth*0.4 );
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
        subValues.set('speed', 1.0);
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue * ( FlxMath.fastCos( Conductor.songPosition*0.001 *(1.2) + 
        (lane%NoteMovement.keyCount)*(2.0) + subValues.get('speed')*(0.2) ) * Note.swagWidth*0.4 );
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
        subValues.set('x', 0.0);
        subValues.set('y', 0.0);
        currentValue = 1.0;
    }
    override function incomingAngleMath(lane:Int, curPos:Float, pf:Int)
    {
        return [subValues.get('x'), subValues.get('y')];
    }
}


class RotateModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('x', 0.0);
        subValues.set('y', 0.0);

        subValues.set('rotatePointX', FlxG.width/2);
        subValues.set('rotatePointY', FlxG.height/2);
        currentValue = 1.0;
    }

    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var xPos = NoteMovement.defaultStrumX[lane];
        var yPos = NoteMovement.defaultStrumY[lane];
        var rotX = ModchartUtil.getCartesianCoords3D(subValues.get('x'), 90, xPos-subValues.get('rotatePointX')+(Note.swagWidth/2));
        noteData.x += rotX.x+subValues.get('rotatePointX')-(Note.swagWidth/2)-xPos;
        var rotY = ModchartUtil.getCartesianCoords3D(90, subValues.get('y'), yPos-subValues.get('rotatePointY')+(Note.swagWidth/2));
        noteData.y += rotY.y+subValues.get('rotatePointY')-(Note.swagWidth/2)-yPos;
        noteData.z += rotX.z + rotY.z;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}

class BumpyModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('speed', 1.0);
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue * 40 * FlxMath.fastSin(curPos*0.01*subValues.get('speed'));
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
        noteData.x -= (NoteMovement.arrowSizes[lane]-(NoteMovement.arrowSizes[lane]*currentValue))*col;
        //noteData.x += (NoteMovement.arrowSizes[lane]*currentValue*NoteMovement.keyCount*0.5);
        noteData.scaleX *= currentValue;
        noteData.scaleY *= currentValue;
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
        subValues.set('speed', 1.0);
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += currentValue * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos*0.005*subValues.get('speed')));
    }
}
class BounceYModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('speed', 1.0);
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += currentValue * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos*0.005*subValues.get('speed')));
    }
}
class BounceZModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('speed', 1.0);
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos*0.005*subValues.get('speed')));
    }
}
class EaseCurveModifier extends Modifier
{
    public var easeFunc = FlxEase.linear;
    public function setEase(ease:String)
    {
        easeFunc = PlayfieldRenderer.getFlxEaseByString(ease);
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

        var speed = ModchartUtil.getScrollSpeed(instance);

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

        var speed = ModchartUtil.getScrollSpeed(instance);

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

        

        noteData.y += (beatVal*(Conductor.stepCrochet*currentValue))*ModchartUtil.getScrollSpeed(instance)*0.45*scrollSwitch;
    }
}