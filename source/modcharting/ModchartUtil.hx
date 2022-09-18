package modcharting;

import flixel.math.FlxAngle;
import openfl.geom.Vector3D;
import flixel.FlxG;

class ModchartUtil
{
    public static function getDownscroll(instance:PlayState)
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
    public static function getScrollSpeed(instance:PlayState)
    {
        #if (PSYCH || ANDROMEDA) 
        return instance.songSpeed;
        #elseif LEATHER
        return instance.speed;
        #elseif KADE 
        return PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed;
        #else 
        return PlayState.SONG.speed; //most engines just use this
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
        var tanHalfFOV = Math.tan(FOV/2);
        if (pos.z > 1) //if above 1000 z basically
            newz = 0; //should stop weird mirroring with high z values

        //var m00 = 1/(tanHalfFOV);
        //var m11 = 1/tanHalfFOV;
        //var m22 = (-zNear - zFar) / zRange; //isnt this just 1 lol
        //var m23 = 2 * zFar * zNear / zRange;
        //var m32 = 1;

        var xOffsetToCenter = pos.x - FlxG.width/2; //so the perspective focuses on the center of the screen
        var yOffsetToCenter = pos.y - FlxG.height/2;

        var zPerspectiveOffset = (newz+(2 * zFar * zNear / zRange));

        xOffsetToCenter += (offsetX / (1/-zPerspectiveOffset));
        yOffsetToCenter += (offsetY / (1/-zPerspectiveOffset));

        var xPerspective = xOffsetToCenter*(1/tanHalfFOV);
        var yPerspective = yOffsetToCenter/(1/tanHalfFOV);
        xPerspective /= -zPerspectiveOffset;
        yPerspective /= -zPerspectiveOffset;

        pos.x = xPerspective+FlxG.width/2; //offset it back to normal
        pos.y = yPerspective+FlxG.height/2;
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
        pos.x = Math.cos(theta*rad)*Math.sin(phi*rad);
        pos.y = Math.cos(phi*rad);
        pos.z =  Math.sin(theta*rad)*Math.sin(phi*rad);
        pos.x *= radius;
        pos.y *= radius;
        pos.z *= radius;

        return pos;
    }
}