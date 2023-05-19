package modcharting;

import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

#if LEATHER
import states.PlayState;
import game.Note;

#else 
import PlayState;
import Note;
#end

using StringTools;

class NoteMovement
{
    public static var keyCount = 4;
    public static var playerKeyCount = 4;
    public static var totalKeyCount = 8;
    public static var arrowScale:Float = 0.7;
    public static var arrowSize:Float = 112;
    public static var defaultStrumX:Array<Float> = [];
    public static var defaultStrumY:Array<Float> = [];
    public static var defaultScale:Array<Float> = [];
    public static var arrowSizes:Array<Float> = [];
    #if LEATHER
    public static var leatherEngineOffsetStuff:Map<String, Float> = [];
    #end
    public static function getDefaultStrumPos(game:PlayState)
    {
        defaultStrumX = []; //reset
        defaultStrumY = []; 
        defaultScale = [];
        arrowSizes = [];
        keyCount = #if (LEATHER || KADE) PlayState.strumLineNotes.length-PlayState.playerStrums.length #else game.strumLineNotes.length-game.playerStrums.length #end; //base game doesnt have opponent strums as group
        playerKeyCount = #if (LEATHER || KADE) PlayState.playerStrums.length #else game.playerStrums.length #end;

        for (i in #if (LEATHER || KADE) 0...PlayState.strumLineNotes.members.length #else 0...game.strumLineNotes.members.length #end)
        {
            #if (LEATHER || KADE) 
            var strum = PlayState.strumLineNotes.members[i];
            #else 
            var strum = game.strumLineNotes.members[i];
            #end
            defaultStrumX.push(strum.x);
            defaultStrumY.push(strum.y);
            #if LEATHER
            var localKeyCount = (i < keyCount ? keyCount : playerKeyCount);
            var s = Std.parseFloat(game.ui_settings[0]) * (Std.parseFloat(game.ui_settings[2]) - (Std.parseFloat(game.mania_size[localKeyCount-1])));
            #else 
            var s = 0.7;
            #end
            defaultScale.push(s);
            arrowSizes.push(160*s);
        }
        #if LEATHER
        leatherEngineOffsetStuff.clear();
        #end
        totalKeyCount = keyCount + playerKeyCount;
    }
    public static function getDefaultStrumPosEditor(game:ModchartEditorState)
    {
        #if ((PSYCH || LEATHER) && !DISABLE_MODCHART_EDITOR)
        defaultStrumX = []; //reset
        defaultStrumY = []; 
        defaultScale = [];
        arrowSizes = [];
        keyCount = game.strumLineNotes.length-game.playerStrums.length; //base game doesnt have opponent strums as group
        playerKeyCount = game.playerStrums.length;

        for (i in 0...game.strumLineNotes.members.length)
        {
            var strum = game.strumLineNotes.members[i];
            defaultStrumX.push(strum.x);
            defaultStrumY.push(strum.y);
            #if LEATHER
            var localKeyCount = (i < keyCount ? keyCount : playerKeyCount);
            var s = Std.parseFloat(game.ui_settings[0]) * (Std.parseFloat(game.ui_settings[2]) - (Std.parseFloat(game.mania_size[localKeyCount-1])));
            #else
            var s = 0.7;
            #end
            defaultScale.push(s);
            arrowSizes.push(160*s);
        }
        #end
        #if LEATHER
        leatherEngineOffsetStuff.clear();
        #end
    }
    public static function setNotePath(daNote:Note, lane:Int, scrollSpeed:Float, curPos:Float, noteDist:Float, incomingAngleX:Float, incomingAngleY:Float)
    {
        daNote.x = defaultStrumX[lane];
        daNote.y = defaultStrumY[lane];
        daNote.z = 0;

        var pos = ModchartUtil.getCartesianCoords3D(incomingAngleX,incomingAngleY, curPos*noteDist);
        daNote.y += pos.y;
        daNote.x += pos.x;
        daNote.z += pos.z;
    }

    public static function getLaneDiffFromCenter(lane:Int)
    {
        var col:Float = lane%4;
        if ((col+1) > (keyCount*0.5))
        {
            col -= (keyCount*0.5)+1;
        }
        else 
        {
            col -= (keyCount*0.5);
        }

        //col = (col-col-col); //flip pos/negative

        //trace(col);

        return col;
    }


}

