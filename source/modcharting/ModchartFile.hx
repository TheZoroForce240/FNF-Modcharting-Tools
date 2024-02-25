package modcharting;

import flixel.math.FlxMath;
import haxe.Exception;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
#if LEATHER
import states.PlayState;
import game.Note;
import game.Conductor;
#if polymod
import polymod.backends.PolymodAssets;
#end
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if hscript
import hscript.*;
#end
#if (HSCRIPT_ALLOWED && PSYCH && PSYCHVERSION >= "0.7")
import psychlua.HScript;
#end
using StringTools;

typedef ModchartJson = 
{
    var modifiers:Array<Array<Dynamic>>;
    var events:Array<Array<Dynamic>>;
    var playfields:Int;
}

class ModchartFile
{
    //used for indexing
    public static final MOD_NAME = 0; //the modifier name
    public static final MOD_CLASS = 1; //the class/custom mod it uses
    public static final MOD_TYPE = 2; //the type, which changes if its for the player, opponent, a specific lane or all
    public static final MOD_PF = 3; //the playfield that mod uses
    public static final MOD_LANE = 4; //the lane the mod uses

    public static final EVENT_TYPE = 0; //event type (set or ease)
    public static final EVENT_DATA = 1; //event data
    public static final EVENT_REPEAT = 2; //event repeat data

    public static final EVENT_TIME = 0; //event time (in beats)
    public static final EVENT_SETDATA = 1; //event data (for sets)
    public static final EVENT_EASETIME = 1; //event ease time
    public static final EVENT_EASE = 2; //event ease
    public static final EVENT_EASEDATA = 3; //event data (for eases)

    public static final EVENT_REPEATBOOL = 0; //if event should repeat
    public static final EVENT_REPEATCOUNT = 1; //how many times it repeats
    public static final EVENT_REPEATBEATGAP = 2; //how many beats in between each repeat


    public var data:ModchartJson = null;
    private var renderer:PlayfieldRenderer;
    public var scriptListen:Bool = false;
    #if hscript
    public var customModifiers:Map<String, Dynamic> = new Map<String, Dynamic>();
    #end
    public var hasDifficultyModchart:Bool = false; //so it loads false as default!

    //Very useful edwhak, since different modifiers act with different versions of OM for either (leather) or you own engine (SCE)
    //okay i get it, now explain why this shit breaks the whole json reader?
    #if SCEModchartingTools
    public var suffixForPath:String = ''; //To not do more work lamo.
    public var activeOpponentmodeSuffix:Bool = false; //Used if you REALLY have custom opponentMode modcharts.
    #end

    #if HScriptImproved
    public var scripts:ScriptPack;
    #end
    
    public function new(renderer:PlayfieldRenderer)
    {
        #if SCEModchartingTools
        suffixForPath = '';
        if (CoolUtil.opponentModeActive && activeOpponentmodeSuffix) suffixForPath = '-opponentMode';
        #end
        #if PSYCH
	    #if (PSYCHVERSION >= "0.7")
           	data = loadFromJson(PlayState.SONG.song.toLowerCase(), Difficulty.getString().toLowerCase() == null ? Difficulty.defaultList[PlayState.storyDifficulty] : Difficulty.getString().toLowerCase());
	    #elseif (PSYCHVERSION < "0.7")
            	data = loadFromJson(PlayState.SONG.song.toLowerCase(), CoolUtil.difficultyString().toLowerCase() == null ? CoolUtil.difficulties[PlayState.storyDifficulty] : CoolUtil.difficultyString().toLowerCase());
	    #end
        #else 
            data = loadFromJson(PlayState.SONG.song.toLowerCase(), PlayState.storyDifficultyStr);
        #end
        this.renderer = renderer;
        renderer.modchart = this;
        loadPlayfields();
        loadModifiers();
        loadEvents();
	#if HScriptImproved
	(scripts = new codenameengine.scripting.ScriptPack("ModchartFile")).setParent(this);
	#end
    }

    public function loadFromJson(folder:String, difficulty:String):ModchartJson //load da shit
    {
        var rawJson = null;
        var filePath = null;

        var folderShit:String = "";
        
        var moddyFile:String = Paths.json(#if SCEModchartingTools 'songs/' + #end #if PSYCH Paths.formatToSongPath(folder) #else PlayState.SONG.song #end + '/modchart-' + difficulty.toLowerCase() #if SCEModchartingTools + suffixForPath #end);
        var moddyFile2:String = Paths.json(#if SCEModchartingTools 'songs/' + #end #if PSYCH Paths.formatToSongPath(folder) #else PlayState.SONG.song #end + '/modchart' #if SCEModchartingTools + suffixForPath #end);

        #if MODS_ALLOWED
        var moddyFileMods:String = Paths.modsJson(#if SCEModchartingTools 'songs/' + #end #if PSYCH Paths.formatToSongPath(folder) #else PlayState.SONG.song #end + '/modchart-' + difficulty.toLowerCase() #if SCEModchartingTools + suffixForPath #end);
        var moddyFileMods2:String = Paths.modsJson(#if SCEModchartingTools 'songs/' + #end #if PSYCH Paths.formatToSongPath(folder) #else PlayState.SONG.song #end + '/modchart' #if SCEModchartingTools + suffixForPath #end);
        #end

        #if PSYCH
        try 
        {

            #if sys
            #if MODS_ALLOWED
            if(FileSystem.exists(moddyFileMods) && difficulty.toLowerCase() != null) 
                hasDifficultyModchart = true;
                if (FileSystem.exists(moddyFileMods2) && !FileSystem.exists(moddyFileMods))
                    hasDifficultyModchart = false;
            else if(FileSystem.exists(moddyFileMods2) && difficulty.toLowerCase() == null && !FileSystem.exists(moddyFileMods)) hasDifficultyModchart = false;
            #end

            if(FileSystem.exists(moddyFile) && difficulty.toLowerCase() != null) 
                hasDifficultyModchart = true;
                if (FileSystem.exists(moddyFile) && !FileSystem.exists(moddyFile))
                    hasDifficultyModchart = false;
            else if(FileSystem.exists(moddyFile2) && difficulty.toLowerCase() == null && !FileSystem.exists(moddyFile)) hasDifficultyModchart = false;

            #if MODS_ALLOWED
            if (hasDifficultyModchart)
            {
                rawJson = File.getContent(moddyFileMods).trim();
                folderShit = moddyFileMods.replace('modchart-' + difficulty.toLowerCase() + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");

                trace('${difficulty} Modchart Found In Mods! loading modchart-${difficulty.toLowerCase()}.json');
            }
            else
            {
                rawJson = File.getContent(moddyFileMods2).trim();
                folderShit = moddyFileMods2.replace('modchart' + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");

                trace('${difficulty} Modchart Has Not Been Found In Mods! loading modchart.json');
            }
            #end

            if (hasDifficultyModchart)
            {
                rawJson = File.getContent(moddyFile).trim();
                folderShit = moddyFile.replace('modchart-' + difficulty.toLowerCase() + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");

                trace('${difficulty} Modchart Found! loading modchart-${difficulty.toLowerCase()}.json');
            }
            else
            {
                rawJson = File.getContent(moddyFile2).trim();
                folderShit = moddyFile2.replace('modchart' + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");

                trace('${difficulty} Modchart Has Not Been Found! loading modchart.json');
            }
            #else
            #if MODS_ALLOWED
            if(Assets.exists(moddyFileMods) && difficulty.toLowerCase() != null) 
                hasDifficultyModchart = true;
                if (Assets.exists(moddyFileMods2) && !Assets.exists(moddyFileMods))
                    hasDifficultyModchart = false;
            else if(Assets.exists(moddyFileMods2) && difficulty.toLowerCase() == null && !Assets.exists(moddyFileMods)) hasDifficultyModchart = false;
            #end

            if(Assets.exists(moddyFile) && difficulty.toLowerCase() != null) 
                hasDifficultyModchart = true;
                if (Assets.exists(moddyFile) && !Assets.exists(moddyFile))
                    hasDifficultyModchart = false;
            else if(Assets.exists(moddyFile2) && difficulty.toLowerCase() == null && !Assets.exists(moddyFile)) hasDifficultyModchart = false;

            #if MODS_ALLOWED
            if (hasDifficultyModchart)
            {
                rawJson = File.getContent(moddyFileMods).trim();
                folderShit = moddyFileMods.replace('modchart-' + difficulty.toLowerCase() + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");

                trace('${difficulty} Modchart Found In Mods! loading modchart-${difficulty.toLowerCase()}.json');
            }
            else
            {
                rawJson = File.getContent(moddyFileMods2).trim();
                folderShit = moddyFileMods2.replace('modchart' + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");

                trace('${difficulty} Modchart Has Not Been Found In Mods! loading modchart.json');
            }
            #end

            if (hasDifficultyModchart)
            {
                rawJson = File.getContent(moddyFile).trim();
                folderShit = moddyFile.replace('modchart-' + difficulty.toLowerCase() + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");

                trace('${difficulty} Modchart Found! loading modchart-${difficulty.toLowerCase()}.json');
            }
            else
            {
                rawJson = File.getContent(moddyFile2).trim();
                folderShit = moddyFile2.replace('modchart' + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");

                trace('${difficulty} Modchart Has Not Been Found! loading modchart.json');
            }
            #end
        }
        catch(e:Dynamic)
        {
            trace(e);
        }
        #end
        
        if (rawJson == null)
        {
            try
            {
                #if MODS_ALLOWED
                if (hasDifficultyModchart)
                {

                    #if LEATHER
                        filePath = Paths.json("song data/" + folder + '/modchart-' + difficulty.toLowerCase() #if SCEModchartingTools + suffixForPath #end);
                        folderShit = PolymodAssets.getPath(filePath.replace('modchart-' + difficulty.toLowerCase() + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/"));
                    #else 
                        filePath = Paths.modsJson(#if SCEModchartingTools 'songs/' + #end folder + '/modchart-' + difficulty.toLowerCase() #if SCEModchartingTools + suffixForPath #end);
                        folderShit = filePath.replace('modchart-' + difficulty.toLowerCase() + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");
                    #end

                    trace('${difficulty} Modchart FolderShit Found In Mods! loading modchart-${difficulty.toLowerCase()}.json');
                }
                else
                { 
                    #if LEATHER
                        filePath = Paths.json("song data/" + folder + '/modchart' #if SCEModchartingTools + suffixForPath #end);
                        folderShit = PolymodAssets.getPath(filePath.replace('modchart' + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/"));
                    #else 
                        filePath = Paths.modsJson(#if SCEModchartingTools 'songs/' + #end folder + '/modchart' #if SCEModchartingTools + suffixForPath #end);
                        folderShit = filePath.replace('modchart' + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");
                    #end

                    trace('${difficulty} Modchart Has No FolderShit Found In Mods! loading modchart.json');
                }
                #end


                if (hasDifficultyModchart)
                {
                    #if LEATHER
                        filePath = Paths.json("song data/" + folder + '/modchart-' + difficulty.toLowerCase() #if SCEModchartingTools + suffixForPath #end);
                        folderShit = PolymodAssets.getPath(filePath.replace('modchart-' + difficulty.toLowerCase() + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/"));
                    #else 
                        filePath = Paths.json(#if SCEModchartingTools 'songs/' + #end folder + '/modchart-' + difficulty.toLowerCase() #if SCEModchartingTools + suffixForPath #end);
                        folderShit = filePath.replace('modchart-' + difficulty.toLowerCase() + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");
                    #end

                    trace('${difficulty} Modchart FolderShit Found! loading modchart-${difficulty.toLowerCase()}.json');
                }
                else
                {
                    #if LEATHER
                        filePath = Paths.json("song data/" + folder + '/modchart' #if SCEModchartingTools + suffixForPath #end);
                        folderShit = PolymodAssets.getPath(filePath.replace('modchart' + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/"));
                    #else 
                        filePath = Paths.json(#if SCEModchartingTools 'songs/' + #end folder + '/modchart' #if SCEModchartingTools + suffixForPath #end);
                        folderShit = filePath.replace('modchart' + #if SCEModchartingTools suffixForPath + #end '.json', "customMods/");
                    #end

                    trace('${difficulty} Modchart Has No FolderShit Found! loading modchart.json');
                }
            }
            catch(e:Dynamic)
            {
                trace(e);
            }
            
            trace(filePath);
            #if sys
            if(FileSystem.exists(filePath))
                rawJson = File.getContent(filePath).trim();
            else #end //should become else if i think???
                if (Assets.exists(filePath))
                    rawJson = Assets.getText(filePath).trim();
                
        }
        var json:ModchartJson = null;
        if (rawJson != null)
        {
            for (i in 0...difficulty.length)
                json = cast Json.parse(rawJson);
            trace('loaded json');
            trace(folderShit);
            #if (hscript && sys)
            if (FileSystem.isDirectory(folderShit))
            {
                trace("folder le exists");
                for (file in FileSystem.readDirectory(folderShit))
                {
                    trace(file);
                    if(file.endsWith('.hx')) //custom mods!!!!
                    {
			var scriptStr = File.getContent(folderShit + file);
			var script = null;
			#if HScriptImproved
			script = Script.create(folderShit + file);
			scripts.add(script);
			script.load();
			#else
			script = #if (HSCRIPT_ALLOWED && PSYCH && PSYCHVERSION >= "0.7") new HScript(null, scriptStr) #end #else new CustomModifierScript(scriptStr) #end;
			#end
                        customModifiers.set(file.replace(".hx", ""), script);
                        trace('loaded custom mod: ' + file);
                    }
                }
            }
            #end
        }
        else 
        {
            json = {modifiers: [], events: [], playfields: 1};
        }
        return json;
    }
    public function loadEmpty()
    {
        data.modifiers = [];
        data.events = [];
        data.playfields = 1;
    }

    public function loadModifiers()
    {
        if (data == null || renderer == null)
            return;
        renderer.modifierTable.clear();
        for (i in data.modifiers)
        {
            ModchartFuncs.startMod(i[MOD_NAME], i[MOD_CLASS], i[MOD_TYPE], Std.parseInt(i[MOD_PF]), renderer.instance);
            if (i[MOD_LANE] != null)
                ModchartFuncs.setModTargetLane(i[MOD_NAME], i[MOD_LANE], renderer.instance);
        }
        renderer.modifierTable.reconstructTable();
    }
    public function loadPlayfields()
    {
        if (data == null || renderer == null)
            return;

        renderer.playfields = [];
        for (i in 0...data.playfields)
            renderer.addNewPlayfield(0,0,0,1);
    }
    public function loadEvents()
    {
        if (data == null || renderer == null)
            return;
        renderer.eventManager.clearEvents();
        for (i in data.events)
        {
            if (i[EVENT_REPEAT] == null) //add repeat data if it doesnt exist
                i[EVENT_REPEAT] = [false, 1, 0];

            if (i[EVENT_REPEAT][EVENT_REPEATBOOL])
            {
                for (j in 0...(Std.int(i[EVENT_REPEAT][EVENT_REPEATCOUNT])+1))
                {
                    addEvent(i, (j*i[EVENT_REPEAT][EVENT_REPEATBEATGAP]));
                }
            }
            else 
            {
                addEvent(i);
            }

        }
    }
    private function addEvent(i:Array<Dynamic>, ?beatOffset:Float = 0)
    {
        switch(i[EVENT_TYPE])
        {
            case "ease": 
                ModchartFuncs.ease(Std.parseFloat(i[EVENT_DATA][EVENT_TIME])+beatOffset, Std.parseFloat(i[EVENT_DATA][EVENT_EASETIME]), i[EVENT_DATA][EVENT_EASE], i[EVENT_DATA][EVENT_EASEDATA], renderer.instance);
            case "set": 
                ModchartFuncs.set(Std.parseFloat(i[EVENT_DATA][EVENT_TIME])+beatOffset, i[EVENT_DATA][EVENT_SETDATA], renderer.instance);
            case "hscript": 
                //maybe just run some code???
        }
    }

    public function createDataFromRenderer() //a way to convert script modcharts into json modcharts
    {
        if (renderer == null)
            return;

        data.playfields = renderer.playfields.length;
        scriptListen = true;
    }
}

#if hscript
class CustomModifierScript
{
    public var interp:Interp = null;
    var script:Expr;
    var parser:Parser;
    public function new(scriptStr:String)
    {
        parser = new Parser();
        parser.allowTypes = true;
        parser.allowMetadata = true;
        parser.allowJSON = true;
        
        try
        {
            interp = new Interp();
            script = parser.parseString(scriptStr); //load da shit
            interp.execute(script);
        }
        catch(e)
        {
            lime.app.Application.current.window.alert(e.message, 'Error on custom mod .hx!');
            return;
        }
        init();
    }
    private function init()
    {
        if (interp == null)
            return;

        #if LEATHER
        interp.variables.set('mod', Modifier); //the game crashes without this???????? what??????????? -- fue glow
        #end

        interp.variables.set('Math', Math);
        interp.variables.set('PlayfieldRenderer', PlayfieldRenderer);
        interp.variables.set('ModchartUtil', ModchartUtil);
        interp.variables.set('Modifier', Modifier);
        interp.variables.set('ModifierSubValue', Modifier.ModifierSubValue);
        interp.variables.set('BeatXModifier', Modifier.BeatXModifier);
        interp.variables.set('NoteMovement', NoteMovement);
        interp.variables.set('NotePositionData', NotePositionData);
        interp.variables.set('ModchartFile', ModchartFile);
        interp.variables.set('FlxG', flixel.FlxG);
		interp.variables.set('FlxSprite', flixel.FlxSprite);
        interp.variables.set('FlxMath', FlxMath);
		interp.variables.set('FlxCamera', flixel.FlxCamera);
		interp.variables.set('FlxTimer', flixel.util.FlxTimer);
		interp.variables.set('FlxTween', flixel.tweens.FlxTween);
		interp.variables.set('FlxEase', flixel.tweens.FlxEase);
		interp.variables.set('PlayState', #if (PSYCH && PSYCHVERSION >= "0.7") states.PlayState #else PlayState #end);
		interp.variables.set('game', #if (PSYCH && PSYCHVERSION >= "0.7") states.PlayState.instance #else PlayState.instance #end);
		interp.variables.set('Paths', #if (PSYCH && PSYCHVERSION >= "0.7") backend.Paths #else Paths #end);
		interp.variables.set('Conductor', #if (PSYCH && PSYCHVERSION >= "0.7") backend.Conductor #else Conductor #end);
        interp.variables.set('StringTools', StringTools);
        interp.variables.set('Note', #if (PSYCH && PSYCHVERSION >= "0.7") objects.Note #else Note #end);

        #if PSYCH
        interp.variables.set('ClientPrefs', #if (PSYCHVERSION >= "0.7") backend.ClientPrefs #else ClientPrefs #end);
        interp.variables.set('ColorSwap', #if (PSYCHVERSION >= "0.7") shaders.ColorSwap #else ColorSwap #end);
        #end

        
    }
    public function call(event:String, args:Array<Dynamic>)
    {
        if (interp == null)
            return;
        if (interp.variables.exists(event)) //make sure it exists
        {
            try
            {
                if (args.length > 0)
                    Reflect.callMethod(null, interp.variables.get(event), args);
                else
                    interp.variables.get(event)(); //if function doesnt need an arg
            }
            catch(e)
            {
                lime.app.Application.current.window.alert(e.message, 'Error on custom mod .hx!');
            }
        }
    }
    public function initMod(mod:Modifier)
    {
        call("initMod", [mod]);
    }

    public function destroy()
    {
        interp = null;
    }
}
#end
