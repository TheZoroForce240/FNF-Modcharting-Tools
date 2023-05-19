package modcharting;

import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import openfl.geom.Vector3D;
import flixel.FlxG;

#if LEATHER
import states.PlayState;
import game.Note;
import game.Conductor;
#else 
import PlayState;
import Note;
#end

using StringTools;

class ModchartUtil
{
    public static function getDownscroll(instance:ModchartMusicBeatState)
    {
        //need to test each engine
        //not expecting all to work
        #if PSYCH 
        return ClientPrefs.downScroll;
        #elseif LEATHER
        return utilities.Options.getData("downscroll");
        #elseif ANDROMEDA //dunno why youd use this on andromeda but whatever, already got its own cool modchart system
        return instance.currentOptions.downScroll;
        #elseif KADE 
        return PlayStateChangeables.useDownscroll;
        #elseif FOREVER_LEGACY //forever might not work just yet because of the multiple strumgroups
        return Init.trueSettings.get('Downscroll');
        #elseif FPSPLUS 
        return Config.downscroll;
        #elseif MIC_D_UP //basically no one uses this anymore
        return MainVariables._variables.scroll == "down"
        #else 
        return false;
        #end
    }
    public static function getMiddlescroll(instance:ModchartMusicBeatState)
    {
        #if PSYCH 
        return ClientPrefs.middleScroll;
        #elseif LEATHER
        return utilities.Options.getData("middlescroll");
        #else 
        return false;
        #end
    }
    public static function getScrollSpeed(instance:PlayState)
    {
        if (instance == null)
            return PlayState.SONG.speed;

        #if (PSYCH || ANDROMEDA) 
        return instance.songSpeed;
        #elseif LEATHER
        @:privateAccess
        return instance.speed;
        #elseif KADE 
        return PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed;
        #else 
        return PlayState.SONG.speed; //most engines just use this
        #end
    }


    public static function getIsPixelStage(instance:ModchartMusicBeatState)
    {
        if (instance == null)
            return false;
        #if LEATHER
        return PlayState.SONG.ui_Skin == 'pixel';
        #else 
        return PlayState.isPixelStage;
        #end
    }

    public static function getNoteOffsetX(daNote:Note, instance:ModchartMusicBeatState)
    {
        #if PSYCH
        return daNote.offsetX;
        #elseif LEATHER 
        //fuck
        var offset:Float = 0;
       
        var lane = daNote.noteData;
        if (daNote.mustPress)
            lane += NoteMovement.keyCount;
        var strum = instance.playfieldRenderer.strumGroup.members[lane];

        var arrayVal = Std.string([lane, daNote.arrow_Type, daNote.isSustainNote]);

        if (!NoteMovement.leatherEngineOffsetStuff.exists(arrayVal))
        {
            var tempShit:Float = 0.0;

            
            var targetX = NoteMovement.defaultStrumX[lane];
            var xPos = targetX;
            while (Std.int(xPos + (daNote.width / 2)) != Std.int(targetX + (strum.width / 2)))
            {
                xPos += (xPos + daNote.width > targetX + strum.width ? -0.1 : 0.1);
                tempShit += (xPos + daNote.width > targetX + strum.width ? -0.1 : 0.1);
            }
            //trace(arrayVal);
            //trace(tempShit);

            NoteMovement.leatherEngineOffsetStuff.set(arrayVal, tempShit);
        }
        offset = NoteMovement.leatherEngineOffsetStuff.get(arrayVal);
        
        return offset;
        #else 
        return (daNote.isSustainNote ? 37 : 0); //the magic number
        #end
    }
    

    static var currentFakeCrochet:Float = -1;
    static var lastBpm:Float = -1;

    public static function getFakeCrochet()
    {
        if (PlayState.SONG.bpm != lastBpm)
        {
            currentFakeCrochet = (60 / PlayState.SONG.bpm) * 1000; //only need to calculate once
            lastBpm = PlayState.SONG.bpm;
        }
        return currentFakeCrochet;
            
    }

    public static var zNear:Float = 0;
    public static var zFar:Float = 100;
    public static var defaultFOV:Float = 90;

    /**
        Converts a Vector3D to its in world coordinates using perspective math
    **/
    public static function calculatePerspective(pos:Vector3D, FOV:Float, offsetX:Float = 0, offsetY:Float = 0)
    {

        /* math from opengl lol
            found from this website https://ogldev.org/www/tutorial12/tutorial12.html
        */

        //TODO: maybe try using actual matrix???

        var newz = pos.z - 1;
        var zRange = zNear - zFar;
        var tanHalfFOV = FlxMath.fastSin(FOV*0.5)/FlxMath.fastCos(FOV*0.5); //faster tan
        if (pos.z > 1) //if above 1000 z basically
            newz = 0; //should stop weird mirroring with high z values

        //var m00 = 1/(tanHalfFOV);
        //var m11 = 1/tanHalfFOV;
        //var m22 = (-zNear - zFar) / zRange; //isnt this just 1 lol
        //var m23 = 2 * zFar * zNear / zRange;
        //var m32 = 1;

        var xOffsetToCenter = pos.x - (FlxG.width*0.5); //so the perspective focuses on the center of the screen
        var yOffsetToCenter = pos.y - (FlxG.height*0.5);

        var zPerspectiveOffset = (newz+(2 * zFar * zNear / zRange));


        //xOffsetToCenter += (offsetX / (1/-zPerspectiveOffset));
        //yOffsetToCenter += (offsetY / (1/-zPerspectiveOffset));
        xOffsetToCenter += (offsetX * -zPerspectiveOffset);
        yOffsetToCenter += (offsetY * -zPerspectiveOffset);

        var xPerspective = xOffsetToCenter*(1/tanHalfFOV);
        var yPerspective = yOffsetToCenter*tanHalfFOV;
        xPerspective /= -zPerspectiveOffset;
        yPerspective /= -zPerspectiveOffset;

        pos.x = xPerspective+(FlxG.width*0.5); //offset it back to normal
        pos.y = yPerspective+(FlxG.height*0.5);
        pos.z = zPerspectiveOffset;

        

        //pos.z -= 1;
        //pos = perspectiveMatrix.transformVector(pos);

        return pos;
    }
    /**
        Returns in-world 3D coordinates using polar angle, azimuthal angle and a radius.
        (Spherical to Cartesian)

        @param	theta Angle used along the polar axis.
        @param	phi Angle used along the azimuthal axis.
        @param	radius Distance to center.
    **/
    public static function getCartesianCoords3D(theta:Float, phi:Float, radius:Float):Vector3D
    {
        var pos:Vector3D = new Vector3D();
        var rad = FlxAngle.TO_RAD;
        pos.x = FlxMath.fastCos(theta*rad)*FlxMath.fastSin(phi*rad);
        pos.y = FlxMath.fastCos(phi*rad);
        pos.z = FlxMath.fastSin(theta*rad)*FlxMath.fastSin(phi*rad);
        pos.x *= radius;
        pos.y *= radius;
        pos.z *= radius;

        return pos;
    }

    public static function getFlxEaseByString(?ease:String = '') {
		switch(ease.toLowerCase().trim()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}


    public static function getTimeFromBeat(beat:Float)
    {
        var totalTime:Float = 0;
        var curBpm = Conductor.bpm;
        if (PlayState.SONG != null)
            curBpm = PlayState.SONG.bpm;
        for (i in 0...Math.floor(beat))
        {
            if (Conductor.bpmChangeMap.length > 0)
            {
                for (j in 0...Conductor.bpmChangeMap.length)
                {
                    if (totalTime >= Conductor.bpmChangeMap[j].songTime)
                        curBpm = Conductor.bpmChangeMap[j].bpm;
                }
            }
            totalTime += (60/curBpm)*1000;
        }

        var leftOverBeat = beat - Math.floor(beat);
        totalTime += (60/curBpm)*1000*leftOverBeat;

        return totalTime;
    }
}