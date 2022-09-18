package modcharting;

import modcharting.PlayfieldRenderer.NotePositionData;
import flixel.FlxG;

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
        noteData.x += currentValue * (Math.cos( ((Conductor.songPosition*0.001) + ((lane%NoteMovement.keyCount)*0.2) + 
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
        noteData.y += currentValue * (Math.cos( ((Conductor.songPosition*0.001) + ((lane%NoteMovement.keyCount)*0.2) + 
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
        noteData.z += currentValue * (Math.cos( ((Conductor.songPosition*0.001) + ((lane%NoteMovement.keyCount)*0.2) + 
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
        noteData.x += currentValue * ( Math.cos( Conductor.songPosition*0.001 *(1.2) + 
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
        noteData.y += currentValue * ( Math.cos( Conductor.songPosition*0.001 *(1.2) + 
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
        noteData.z += currentValue * ( Math.cos( Conductor.songPosition*0.001 *(1.2) + 
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
        if (ClientPrefs.downScroll)
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

/* doesnt work well
class BumpyModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue * 40 * Math.sin(curPos/16);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteData.z += currentValue * 40;
    }
}
*/
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