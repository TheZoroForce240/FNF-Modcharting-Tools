package modcharting;


import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.FlxStrip;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import openfl.geom.Vector3D;
import flixel.util.FlxSpriteUtil;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

import flixel.FlxG;
import modcharting.Modifier;
import flixel.system.FlxAssets.FlxShader;

#if LEATHER
import states.PlayState;
import game.Note;
import game.StrumNote;
import game.Conductor;
#else 
import PlayState;
import Note;
#end

using StringTools;

/*
typedef NotePositionData = 
{
    var x:Float;
    var y:Float;
    var z:Float;
    var angle:Float;
    var scaleX:Float;
    var scaleY:Float;
    var curPos:Float;
    var noteDist:Float;
    var lane:Int;
    var index:Int;
    var playfieldIndex:Int;
    var isStrum:Bool;
    var incomingAngleX:Float;
    var incomingAngleY:Float;
}
*/

class NotePositionData //made it a class so hscript should work
{
    public var x:Float;
    public var y:Float;
    public var z:Float;
    public var angle:Float;
    public var alpha:Float;
    public var scaleX:Float;
    public var scaleY:Float;
    public var curPos:Float;
    public var noteDist:Float;
    public var lane:Int;
    public var index:Int;
    public var playfieldIndex:Int;
    public var isStrum:Bool;
    public var incomingAngleX:Float;
    public var incomingAngleY:Float;
    public function new() {}
}

typedef Playfield = 
{
    var x:Float; //offsets lol
    var y:Float;
    var z:Float;
}

class PlayfieldRenderer extends FlxSprite //extending flxsprite just so i can edit draw
{
    var strumGroup:FlxTypedGroup<
    #if (PSYCH || LEATHER) StrumNote 
    #elseif KADE StaticArrow
    #elseif FOREVER_LEGACY UIStaticArrow
    #elseif ANDROMEDA Receptor
    #else FlxSprite #end>;
    var notes:FlxTypedGroup<Note>;
    var instance:PlayState;
    public var playfields:Array<Playfield> = []; //adding an extra playfield will add 1 for each player
    public var modifiers:Map<String, Modifier> = new Map<String, Modifier>();
    public var events:Array<ModchartEvent> = [];

    private static final noteUV:Array<Float> = [
        0,0, //top left
        1,0, //top right
        0,0.5, //half left
        1,0.5, //half right    
        0,1, //bottom left
        1,1, //bottom right 
    ];
    private static final noteIndices:Array<Int> = [
        0,1,2,1,3,2, 2,3,4,3,4,5
        //makes 4 triangles
    ];

    public function new(strumGroup:FlxTypedGroup<
        #if (PSYCH || LEATHER) StrumNote 
        #elseif KADE StaticArrow
        #elseif FOREVER_LEGACY UIStaticArrow
        #elseif ANDROMEDA Receptor
        #else FlxSprite #end>, notes:FlxTypedGroup<Note>,instance:PlayState) 
    {
        this.strumGroup = strumGroup;
        this.notes = notes;
        this.instance = instance;

        strumGroup.visible = false; //drawing with renderer instead
        notes.visible = false;

        addNewplayfield(0,0,0);

        //default modifiers
        addModifier(new XModifier('x'));
        addModifier(new YModifier('y'));
        addModifier(new ZModifier('z'));
        addModifier(new ConfusionModifier('confusion'));
        for (i in 0...((NoteMovement.keyCount+NoteMovement.playerKeyCount)))
        {
            addModifier(new XModifier('x'+i, ModifierType.LANESPECIFIC));
            addModifier(new YModifier('y'+i, ModifierType.LANESPECIFIC));
            addModifier(new ZModifier('z'+i, ModifierType.LANESPECIFIC));
            addModifier(new ConfusionModifier('confusion'+i, ModifierType.LANESPECIFIC));
            modifiers.get('x'+i).targetLane = i;
            modifiers.get('y'+i).targetLane = i;
            modifiers.get('z'+i).targetLane = i;
            modifiers.get('confusion'+i).targetLane = i;
        }
        

        super(0,0);
    }


    public function addNewplayfield(?X:Float = 0, ?Y:Float = 0, ?Z:Float = 0)
    {
        playfields.push({x:X,y:Y,z:Z});
    }

    public function addModifier(mod:Modifier)
    {
        mod.instance = instance;
        removeModifier(mod.tag); //in case you replace one???
        modifiers.set(mod.tag, mod);
    }

    public function removeModifier(tag:String)
    {
        if (modifiers.exists(tag))
            modifiers.remove(tag);
    }

    override function update(elapsed:Float) 
    {
        if (events.length > 1)
        {
            events.sort(function(a, b){
                if (a.time < b.time)
                    return -1;
                else if (a.time > b.time)
                    return 1;
                else
                    return 0;
            });
        }
		while(events.length > 0) {
			var event:ModchartEvent = events[0];
			if(Conductor.songPosition < event.time) {
				break;
			}
            //Reflect.callMethod(this, event.func, event.args);
            event.func(event.args);
			events.shift();
		}

        Modifier.beat = ((Conductor.songPosition *0.001)*(Conductor.bpm/60));
        super.update(elapsed);
    }


    override public function draw()
    {
        if (alpha == 0 || !visible)
            return;

        strumGroup.cameras = this.cameras;
        notes.cameras = this.cameras;

        
        //drawStrums();
        //drawSustains();
        //drawNotes();
        
        drawStuff(getNotePositions());


        //draw notes to screen

        
    }


    private function addDataToStrum(strumData:NotePositionData, strum:FlxSprite)
    {
        strum.x = strumData.x;
        strum.y = strumData.y;
        //strum.z = strumData.z;
        strum.angle = strumData.angle;
        strum.alpha = strumData.alpha;
        strum.scale.x = strumData.scaleX;
        strum.scale.y = strumData.scaleY;
    }

    private function getDataForStrum(i:Int, p:Int)
    {
        var strumX = NoteMovement.defaultStrumX[i];
        var strumY = NoteMovement.defaultStrumY[i];
        var strumZ = 0;
        var strumAngle = 0;
        var strumScaleX = NoteMovement.defaultScale[i];
        var strumScaleY = NoteMovement.defaultScale[i];
        if (ModchartUtil.getIsPixelStage(instance))
        {
            //work on pixel stages
            strumScaleX = 1*PlayState.daPixelZoom;
            strumScaleY = 1*PlayState.daPixelZoom;
        }
            
        var strumData:NotePositionData = new NotePositionData();
            strumData.x = strumX + playfields[p].x;
            strumData.y =  strumY + playfields[p].y;
            strumData.z = strumZ + playfields[p].z; 
            strumData.angle = strumAngle;
            strumData.alpha = 1;
            strumData.scaleX = strumScaleX; 
            strumData.scaleY = strumScaleY; 
            strumData.index = i;
            strumData.playfieldIndex = p;
            strumData.lane = i;
            strumData.curPos = 0;
            strumData.noteDist = 0;
            strumData.isStrum = true;
            strumData.incomingAngleX = 0;
            strumData.incomingAngleY = 0;
        for (mod in modifiers)
            mod.getStrumPath(strumData, i, p);

        return strumData;
    }

   

    private function addDataToNote(noteData:NotePositionData, daNote:Note)
    {
        daNote.x = noteData.x;
        daNote.y = noteData.y;
        daNote.z = noteData.z;
        daNote.angle = noteData.angle;
        daNote.alpha = noteData.alpha;
        daNote.scale.x = noteData.scaleX;
        daNote.scale.y = noteData.scaleY;
    }
    private function createDataFromNote(noteIndex:Int, playfieldIndex:Int, curPos:Float, noteDist:Float, incomingAngle:Array<Float>)
    {
        var noteX = notes.members[noteIndex].x;
        var noteY = notes.members[noteIndex].y;
        var noteZ = notes.members[noteIndex].z;
        var noteAngle = 0;
        var lane = getLane(noteIndex);
        var noteScaleX = NoteMovement.defaultScale[lane];
        var noteScaleY = NoteMovement.defaultScale[lane];
        if (ModchartUtil.getIsPixelStage(instance))
        {
            //work on pixel stages
            noteScaleX = 1*PlayState.daPixelZoom;
            noteScaleY = 1*PlayState.daPixelZoom;
        }
        /*var noteData:NotePositionData = {
            x: noteX + playfields[playfieldIndex].x,
            y: noteY + playfields[playfieldIndex].y,
            z: noteZ + playfields[playfieldIndex].z, 
            angle: noteAngle, 
            scaleX: noteScaleX, 
            scaleY: noteScaleY, 
            index: noteIndex,
            playfieldIndex: playfieldIndex,
            lane: getLane(noteIndex),
            curPos: curPos,
            noteDist: noteDist,
            isStrum: false,
            incomingAngleX: incomingAngle[0],
            incomingAngleY: incomingAngle[1]
        };*/

        var noteData:NotePositionData = new NotePositionData();
        noteData.x = noteX + playfields[playfieldIndex].x;
        noteData.y = noteY + playfields[playfieldIndex].y;
        noteData.z = noteZ + playfields[playfieldIndex].z; 
        noteData.angle = noteAngle;
        #if PSYCH
        noteData.alpha = notes.members[noteIndex].multAlpha;
        #else 
        if (notes.members[noteIndex].isSustainNote)
            noteData.alpha = 0.6;
        else 
            noteData.alpha = 1;
        #end
        noteData.scaleX = noteScaleX; 
        noteData.scaleY = noteScaleY; 
        noteData.index = noteIndex;
        noteData.playfieldIndex = playfieldIndex;
        noteData.lane = lane;
        noteData.curPos = curPos;
        noteData.noteDist = noteDist;
        noteData.isStrum = false;
        noteData.incomingAngleX = incomingAngle[0];
        noteData.incomingAngleY = incomingAngle[1];
        return noteData;
    }

    private function getNoteCurPos(noteIndex:Int, strumTimeOffset:Float = 0)
    {
        var distance = (Conductor.songPosition - notes.members[noteIndex].strumTime) + strumTimeOffset;
        return distance*ModchartUtil.getScrollSpeed(instance);
    }
    private function getLane(noteIndex:Int)
    {
        return (notes.members[noteIndex].mustPress ? notes.members[noteIndex].noteData+NoteMovement.keyCount : notes.members[noteIndex].noteData);
    }
    private function getNoteDist(noteIndex:Int)
    {
        var noteDist = -0.45;
        if (ModchartUtil.getDownscroll(instance))
            noteDist *= -1;
        //for (mod in modifiers)
            //noteDist = mod.getNoteDist(noteData, lane, curPos, p);
        return noteDist;
    }






    private function getNotePositions()
    {
        var notePositions:Array<NotePositionData> = [];
        for (p in 0...playfields.length)
        {
            for (i in 0...strumGroup.members.length)
            {
                var strumData = getDataForStrum(i, p);
                notePositions.push(strumData);
            }
            for (i in 0...notes.members.length)
            {
                var songSpeed = ModchartUtil.getScrollSpeed(instance);

                var lane = getLane(i);

                var noteDist = getNoteDist(i);
                for (mod in modifiers)
                    noteDist = mod.getNoteDist(noteDist, lane, 0, p);
                

                var sustainTimeThingy:Float = 0;

                //just causes too many issues lol, might fix it at some point
                /*if (notes.members[i].animation.curAnim.name.endsWith('end') && ClientPrefs.downScroll)
                {
                    if (noteDist > 0)
                        sustainTimeThingy = (NoteMovement.getFakeCrochet()/4)/2; //fix stretched sustain ends (downscroll)
                    //else 
                        //sustainTimeThingy = (-NoteMovement.getFakeCrochet()/4)/songSpeed;
                }*/
                    

                var curPos = getNoteCurPos(i, sustainTimeThingy);

                for (mod in modifiers)
                    curPos = mod.getNoteCurPos(lane, curPos, p);

                if ((notes.members[i].wasGoodHit || (notes.members[i].prevNote.wasGoodHit)) && curPos >= 0 && notes.members[i].isSustainNote)
                    curPos = 0;

                var incomingAngle:Array<Float> = [0,0];
                for (mod in modifiers)
                {
                    var ang = mod.getIncomingAngle(lane, curPos, p); //need to get incoming angle before
                    incomingAngle[0] += ang[0];
                    incomingAngle[1] += ang[1];
                }
                if (noteDist < 0)
                    incomingAngle[0] += 180; //make it match for both scrolls
                    

                //get the general note path
                NoteMovement.setNotePath(notes.members[i], lane, songSpeed, curPos, noteDist, incomingAngle[0], incomingAngle[1]);

                //save the position data
                var noteData = createDataFromNote(i, p, curPos, noteDist, incomingAngle);

                //add offsets to data with modifiers
                for (mod in modifiers)
                    mod.getNotePath(noteData, lane, curPos, p);

                //add position data to list
                notePositions.push(noteData);
            }
        }
        //sort by z before drawing
        notePositions.sort(function(a, b){
            if (a.z < b.z)
                return -1;
            else if (a.z > b.z)
                return 1;
            else
                return 0;
        });
        return notePositions;
    }

    private function drawStuff(notePositions:Array<NotePositionData>)
    {
        for (noteData in notePositions)
        {
            if (noteData.isStrum) //draw strum
            {
                var strumNote = strumGroup.members[noteData.index];
                var thisNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x+(strumNote.width/2), noteData.y+(strumNote.height/2), noteData.z*0.001), 
                ModchartUtil.defaultFOV*(Math.PI/180), -(strumNote.width/2), -(strumNote.height/2));

                noteData.x = thisNotePos.x;
                noteData.y = thisNotePos.y;
                noteData.scaleX *= (1/-thisNotePos.z);
                noteData.scaleY *= (1/-thisNotePos.z);

                addDataToStrum(noteData, strumGroup.members[noteData.index]); //set position and stuff before drawing
                strumGroup.members[noteData.index].cameras = this.cameras;

                

                /*if (!PlayState.isPixelStage)
                {
                    strumNote.centerOrigin();
                    strumNote.updateHitbox();
                    strumNote.offset.x = strumNote.frameWidth / 2;
                    strumNote.offset.y = strumNote.frameHeight / 2;
                    strumNote.offset.x -= (56 / 0.7) * (strumNote.scale.x);
                    strumNote.offset.y -= (56 / 0.7) * (strumNote.scale.x); //using scale x here is important dont ask
                    //the z offsetting should be done automatically
                }*/
                if (noteData.alpha > 0)
                    strumGroup.members[noteData.index].draw();
            }
            else if (!notes.members[noteData.index].isSustainNote) //draw regular note
            {
                var daNote = notes.members[noteData.index];
                var thisNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x+(daNote.width/2), noteData.y+(daNote.height/2), noteData.z*0.001), 
                ModchartUtil.defaultFOV*(Math.PI/180), -(daNote.width/2), -(daNote.height/2));

                noteData.x = thisNotePos.x;
                noteData.y = thisNotePos.y;
                noteData.scaleX *= (1/-thisNotePos.z);
                noteData.scaleY *= (1/-thisNotePos.z);
                //set note position using the position data
                addDataToNote(noteData, notes.members[noteData.index]); 
                //make sure it draws on the correct camera
                notes.members[noteData.index].cameras = this.cameras;
                //draw it
                if (noteData.alpha > 0)
                    notes.members[noteData.index].draw();
            }
            else //draw sustain
            {
                var daNote = notes.members[noteData.index];

                if (daNote.mesh == null)
                {
                    daNote.alpha = 1;
                    daNote.mesh = new SustainMesh(0,0); //setup strip
                    daNote.mesh.loadGraphic(daNote.updateFramePixels());
                    daNote.mesh.shader = daNote.shader;
                    for (uv in noteUV)
                        daNote.mesh.uvtData.push(uv);
                    for (ind in noteIndices)
                        daNote.mesh.indices.push(ind);
                }
                daNote.mesh.scrollFactor = daNote.scrollFactor;
                daNote.mesh.x = 0;
                daNote.mesh.y = 0;
                daNote.alpha = noteData.alpha;
                daNote.mesh.alpha = daNote.alpha;

                var songSpeed = ModchartUtil.getScrollSpeed(instance);
                var lane = noteData.lane;
                
                //makes the sustain match the center of the parent note when at weird angles
                var yOffsetThingy = (NoteMovement.arrowSizes[lane]/2);

                var thisNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x+(daNote.width/2)+ModchartUtil.getNoteOffsetX(daNote), noteData.y+(NoteMovement.arrowSizes[noteData.lane]/2), noteData.z*0.001), 
                ModchartUtil.defaultFOV*(Math.PI/180), -(daNote.width/2), yOffsetThingy-(NoteMovement.arrowSizes[noteData.lane]/2));
                

                var timeToNextSustain = ModchartUtil.getFakeCrochet()/4;
                if (noteData.noteDist < 0)
                    timeToNextSustain = -ModchartUtil.getFakeCrochet()/4; //weird shit that fixes upscroll lol

                //if (daNote.animation.curAnim.name.endsWith('end') && nextNoteDist < 0)
                    //timeToNextSustain /= 2; //fix stretched sustain ends (upscroll)
                //for some reason nextnotepos and thisnotepos are flipped on each scroll
        
                var nextHalfNotePos = getSustainPoint(noteData, timeToNextSustain*0.5);
                var nextNotePos = getSustainPoint(noteData, timeToNextSustain);
                
                var doDraw = noteData.alpha > 0;
                var strumData = getDataForStrum(getLane(noteData.index), noteData.playfieldIndex);
                //need to calculate for clipping and shit            
                //var clipBullshit = ModchartUtil.calculatePerspective(new Vector3D(strumData.x+ModchartUtil.getNoteOffsetX(daNote)+(daNote.width/2), strumData.y, strumData.z*0.001), 
                //ModchartUtil.defaultFOV*(Math.PI/180), -(daNote.width/2), NoteMovement.arrowSizes[lane]/2);
                //var clipPointX = clipBullshit.x;
                //var clipPointY = clipBullshit.y;    
    
                    
                if (doDraw)
                {
                    var flipGraphic = false;

                    // mod/bound to 360, add 360 for negative angles, mod again just in case
                    var fixedAngY = ((noteData.incomingAngleY%360)+360)%360;

                    //make sure that clipping always works
                    var reverseClip = (fixedAngY > 90 && fixedAngY < 270);

                    //clipping
                    if (noteData.noteDist > 0) //downscroll
                    {
                        /*if (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit))
                        {
                            clipPoint(thisNotePos, clipPointX, clipPointY, reverseClip);
                            clipPoint(nextHalfNotePos, clipPointX, clipPointY, reverseClip);
                            clipPoint(nextNotePos, clipPointX, clipPointY, reverseClip);
                        }*/
                        if (!ModchartUtil.getDownscroll(instance)) //fix reverse
                            flipGraphic = true;
                    }
                    else
                    {
                        /*if (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit))
                        {
                            clipPoint(thisNotePos, clipPointX, clipPointY, !reverseClip);
                            clipPoint(nextHalfNotePos, clipPointX, clipPointY, !reverseClip);
                            clipPoint(nextNotePos, clipPointX, clipPointY, !reverseClip);
                        }*/
                        if (ModchartUtil.getDownscroll(instance))
                            flipGraphic = true;
                    }
                    //render that shit
                    daNote.mesh.vertices = new DrawData();
                    var yOffset = 2; //fix small gaps
                    if (reverseClip)
                        yOffset = -yOffset;

                    if (flipGraphic)
                    {
                        daNote.mesh.vertices.push(nextNotePos.x);
                        daNote.mesh.vertices.push(nextNotePos.y+yOffset); //slight offset to fix small gaps
                        daNote.mesh.vertices.push(nextNotePos.x+(daNote.frameWidth*(1/-nextNotePos.z)*noteData.scaleX));
                        daNote.mesh.vertices.push(nextNotePos.y+yOffset);

                        daNote.mesh.vertices.push(nextHalfNotePos.x);
                        daNote.mesh.vertices.push(nextHalfNotePos.y);
                        daNote.mesh.vertices.push(nextHalfNotePos.x+(daNote.frameWidth*(1/-nextHalfNotePos.z)*noteData.scaleX));
                        daNote.mesh.vertices.push(nextHalfNotePos.y);

                        daNote.mesh.vertices.push(thisNotePos.x);
                        daNote.mesh.vertices.push(thisNotePos.y);
                        daNote.mesh.vertices.push(thisNotePos.x+(daNote.frameWidth*(1/-thisNotePos.z)*nextNotePos.scaleX));
                        daNote.mesh.vertices.push(thisNotePos.y);
                    }
                    else 
                    {
                        daNote.mesh.vertices.push(thisNotePos.x);
                        daNote.mesh.vertices.push(thisNotePos.y);
                        daNote.mesh.vertices.push(thisNotePos.x+(daNote.frameWidth*(1/-thisNotePos.z)*noteData.scaleX));
                        daNote.mesh.vertices.push(thisNotePos.y);

                        daNote.mesh.vertices.push(nextHalfNotePos.x);
                        daNote.mesh.vertices.push(nextHalfNotePos.y);
                        daNote.mesh.vertices.push(nextHalfNotePos.x+(daNote.frameWidth*(1/-nextHalfNotePos.z)*noteData.scaleX));
                        daNote.mesh.vertices.push(nextHalfNotePos.y);

                        daNote.mesh.vertices.push(nextNotePos.x);
                        daNote.mesh.vertices.push(nextNotePos.y+yOffset); //slight offset to fix small gaps
                        daNote.mesh.vertices.push(nextNotePos.x+(daNote.frameWidth*(1/-nextNotePos.z)*nextNotePos.scaleX));
                        daNote.mesh.vertices.push(nextNotePos.y+yOffset);
                    }
                    daNote.mesh.cameras = this.cameras;
                    daNote.mesh.draw();
                }
            }

        }
    }
    
    overload extern inline function clipPoint(point:NotePositionData, clipX:Float, clipY:Float, downscroll:Bool)
    {
        if (downscroll)
        {
            if (point.y < clipY)
            {
                point.y = clipY;
                point.x = clipX;
            }
        }
        else 
        {
            if (point.y > clipY)
            {
                point.y = clipY;
                point.x = clipX;
            } 
        }
    }
    overload extern inline function clipPoint(point:Vector3D, clipX:Float, clipY:Float, downscroll:Bool)
    {
        if (downscroll)
        {
            if (point.y < clipY)
            {
                point.y = clipY;
                point.x = clipX;
            }
        }
        else 
        {
            if (point.y > clipY)
            {
                point.y = clipY;
                point.x = clipX;
            } 
        }
    }

    function getSustainPoint(noteData:NotePositionData, timeOffset:Float):NotePositionData
    {
        var daNote = notes.members[noteData.index];
        var songSpeed = ModchartUtil.getScrollSpeed(instance);
        var lane = noteData.lane;

        var noteDist = getNoteDist(noteData.index);
        var noteCurPos = getNoteCurPos(noteData.index, timeOffset);

        for (mod in modifiers)
            noteCurPos = mod.getNoteCurPos(lane, noteCurPos, noteData.playfieldIndex);

        if ((daNote.wasGoodHit || (daNote.prevNote.wasGoodHit)) && noteCurPos >= 0)
            noteCurPos = 0;
        for (mod in modifiers)
            noteDist = mod.getNoteDist(noteDist, lane, noteCurPos, noteData.playfieldIndex);
        var incomingAngle:Array<Float> = [0,0];
        for (mod in modifiers)
        {
            var ang = mod.getIncomingAngle(lane, noteCurPos, noteData.playfieldIndex); //need to get incoming angle before
            incomingAngle[0] += ang[0];
            incomingAngle[1] += ang[1];
        }
        if (noteDist < 0)
            incomingAngle[0] += 180; //make it match for both scrolls
        //get the general note path for the next note
        NoteMovement.setNotePath(daNote, lane, songSpeed, noteCurPos, noteDist, incomingAngle[0], incomingAngle[1]);
        //save the position data 
        var noteData = createDataFromNote(noteData.index, noteData.playfieldIndex, noteCurPos, noteDist, incomingAngle);
        //add offsets to data with modifiers
        for (mod in modifiers)
            mod.getNotePath(noteData, noteData.lane, noteCurPos, noteData.playfieldIndex);
        var yOffsetThingy = (NoteMovement.arrowSizes[lane]/2);
        var finalNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x+(daNote.width/2)+ModchartUtil.getNoteOffsetX(daNote), noteData.y+(NoteMovement.arrowSizes[noteData.lane]/2), noteData.z*0.001), 
        ModchartUtil.defaultFOV*(Math.PI/180), -(daNote.width/2), yOffsetThingy-(NoteMovement.arrowSizes[noteData.lane]/2));

        noteData.x = finalNotePos.x;
        noteData.y = finalNotePos.y;
        noteData.z = finalNotePos.z;

        return noteData;
    }




    public function tweenModifier(modifier:String, val:Float, time:Float, ease:String)
    {
        if (modifiers.exists(modifier))
        {       
            var easefunc = getFlxEaseByString(ease);  
            #if PSYCH  
            instance.modchartTweens.set(modifier, FlxTween.tween(modifiers.get(modifier), {currentValue: val}, time, {ease: easefunc,
                onComplete: function(twn:FlxTween) {
                    instance.callOnLuas('onTweenCompleted', [modifier]);
                    instance.modchartTweens.remove(modifier);
                }
            }));
            #else 
            FlxTween.tween(modifiers.get(modifier), {currentValue: val}, time, {ease: easefunc,
                onComplete: function(twn:FlxTween) {
  
                }
            });
            #end
        }
    }

    public function tweenModifierSubValue(modifier:String, subValue:String, val:Float, time:Float, ease:String)
    {
        if (modifiers.exists(modifier))
        {       
            if (modifiers.get(modifier).subValues.exists(subValue))
            {

                var easefunc = getFlxEaseByString(ease);   
                var tag = modifier+' '+subValue; 

                var startValue = modifiers.get(modifier).subValues.get(subValue);


                #if PSYCH
                instance.modchartTweens.set(tag, FlxTween.num(startValue, val, time, {ease: easefunc,
                    onComplete: function(twn:FlxTween) {
                        instance.callOnLuas('onTweenCompleted', [tag]);
                        instance.modchartTweens.remove(tag);
                    },
                    onUpdate: function(twn:FlxTween) {
                        //need to update like this because its inside a map
                        if (modifiers.exists(modifier))
                            modifiers.get(modifier).subValues.set(subValue, FlxMath.lerp(startValue, val, easefunc(twn.percent)));
                    }
                }));

                #else 
                FlxTween.num(startValue, val, time, {ease: easefunc,
                    onComplete: function(twn:FlxTween) {
                        if (modifiers.exists(modifier))
                            modifiers.get(modifier).subValues.set(subValue, val);
                    },
                    onUpdate: function(twn:FlxTween) {
                        //need to update like this because its inside a map
                        if (modifiers.exists(modifier))
                            modifiers.get(modifier).subValues.set(subValue, FlxMath.lerp(startValue, val, easefunc(twn.percent)));
                    }
                });
                #end
            }

        }
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


    private function getTimeFromBeat(beat:Float)
    {
        var totalTime:Float = 0;
        var curBpm = Conductor.bpm;
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

    public function addEvent(beat:Float, func:Array<String>->Void, args:Array<String>)
    {
        var time = getTimeFromBeat(beat);
        //trace(time);
        events.push(new ModchartEvent(time, func, args));
    }


}


/*

class SustainRenderer
{
    public var shader:SustainShader = new SustainShader();
    public function new()
    {
        shader.xSkew.value = [0.0];
        shader.ySkew.value = [0.0];
    }
    public function update(xSkew:Float, ySkew:Float)
    {
        shader.xSkew.value = [xSkew];
        shader.ySkew.value = [ySkew];
    }
}
class SustainShader extends FlxShader
{
    @:glVertexBody("
	// start of default code required for alpha and color to work 
	openfl_Alphav = openfl_Alpha;
	openfl_TextureCoordv = openfl_TextureCoord;
	if (openfl_HasColorTransform) {
		openfl_ColorMultiplierv = openfl_ColorMultiplier;
		openfl_ColorOffsetv = openfl_ColorOffset / 255.0;
	}
	// end of default code
	
	mat4 transform = openfl_Matrix;
		
	gl_Position = transform * openfl_Position;
    //gl_Position.w += 0.1;
    gl_Position.x += gl_Position.x + gl_Position.y * ((gl_Position.x+xSkew) - gl_Position.x);
	")
	@:glVertexSource("
	#pragma header
	attribute float alpha;
	attribute vec4 colorMultiplier;
	attribute vec4 colorOffset;
	uniform bool hasColorTransform;
	uniform float iTime;
	
    uniform float xSkew;
    uniform float ySkew;
        
	void main(void)
	{
		#pragma body
		
		// start of default code required for alpha and color to work 
		openfl_Alphav = openfl_Alpha * alpha;
		if (hasColorTransform)
		{
			openfl_ColorOffsetv = colorOffset / 255.0;
			openfl_ColorMultiplierv = colorMultiplier;
		}
		// end of default code
	}")
	public function new()
	{
		super();
	}
}

*/

/*
class TestingState extends MusicBeatState 
{
    var testStrip:FlxStrip;
    override function create()
    {
        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

        var sustainNote = new FlxSprite(0,0);
        sustainNote.frames = Paths.getSparrowAtlas('NOTE_assets');
        sustainNote.animation.addByPrefix('purplehold', 'purple hold piece');
        sustainNote.animation.play('purplehold', true);
        add(sustainNote);

        testStrip = new FlxStrip(300, 300);
        testStrip.loadGraphic(sustainNote.updateFramePixels());

        testStrip.vertices.push(0);
        testStrip.vertices.push(0);

        testStrip.vertices.push(100);
        testStrip.vertices.push(0);

        testStrip.vertices.push(200);
        testStrip.vertices.push(200);

        testStrip.vertices.push(300);
        testStrip.vertices.push(200);

        testStrip.uvtData.push(0);
        testStrip.uvtData.push(0);

        testStrip.uvtData.push(1);
        testStrip.uvtData.push(0);

        testStrip.uvtData.push(0);
        testStrip.uvtData.push(1);

        testStrip.uvtData.push(1);
        testStrip.uvtData.push(1);

        testStrip.indices.push(0);
        testStrip.indices.push(1);
        testStrip.indices.push(2);
        testStrip.indices.push(1);
        testStrip.indices.push(3);
        testStrip.indices.push(2);
        

        add(testStrip);

        super.create();
    }
}*/