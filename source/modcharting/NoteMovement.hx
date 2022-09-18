package modcharting;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import Note;
import flixel.FlxG;
import PlayState;

using StringTools;

class NoteMovement
{
    public static var keyCount = 4;
    public static var playerKeyCount = 4;
    public static var arrowScale:Float = 0.7;
    public static var arrowSize:Float = 112;
    public static var defaultStrumX:Array<Float> = [];
    public static var defaultStrumY:Array<Float> = [];
    public static function getDefaultStrumPos(game:PlayState)
    {
        defaultStrumX = []; //reset
        defaultStrumY = []; 
        for (i in game.strumLineNotes.members)
        {
            defaultStrumX.push(i.x);
            defaultStrumY.push(i.y);
        }
        #if LEATHER
        arrowScale = Std.parseFloat(game.ui_Settings[0]) * (Std.parseFloat(game.ui_Settings[2]) - (Std.parseFloat(game.mania_size[localKeyCount-1])));
        #else 
        arrowScale = 0.7;
        #end

        keyCount = Math.floor(game.strumLineNotes.length/2); //base game doesnt have opponent strums as group
        playerKeyCount = game.playerStrums.length;
        arrowSize = 160 * arrowScale;

    }
    public static function setNotePath(daNote:Note, lane:Int, scrollSpeed:Float, curPos:Float, noteDist:Float, incomingAngleX:Float, incomingAngleY:Float)
    {
        daNote.x = defaultStrumX[lane];
        daNote.y = defaultStrumY[lane];
        daNote.z = 0;

        //daNote.zScaledOffsetX = daNote.offsetX; //using actual offset so it matches with the perspective math bullshit
        //daNote.zScaledOffsetY = daNote.offsetY;

        var pos = ModchartUtil.getCartesianCoords3D(incomingAngleX,incomingAngleY, curPos*noteDist);
        daNote.y += pos.y;
        daNote.x += pos.x;
        daNote.z += pos.z;

        //if (noteDist > 0)
            //fixDownscrollSustains(daNote, scrollSpeed); //will prob rewrite rendering soon

        //var targetNotePos = 
    }

    /*private static function fixDownscrollSustains(daNote:Note, scrollSpeed:Float)
    {
        var songSpeed = scrollSpeed;
        var fakeCrochet = getFakeCrochet();
        var offsetThingy:Float = 0;
        if (daNote.animation.curAnim.name.endsWith('end')) {
            offsetThingy += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
            offsetThingy -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
            if(PlayState.isPixelStage) {
                offsetThingy += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
            } else {
                offsetThingy -= 19;
            }
        }
        offsetThingy += ((Note.swagWidth) / 2) - (60.5 * (songSpeed - 1));
        offsetThingy += 27.5 * ((lastBpm / 100) - 1) * (songSpeed - 1);
        //daNote.zScaledOffsetY += offsetThingy;
    }*/


}

