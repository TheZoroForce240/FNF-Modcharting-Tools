package modcharting;
import haxe.Exception;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end
import hscript.*;
using StringTools;

typedef ModchartJson = 
{
    var modifiers:Array<Array<Dynamic>>;
    var events:Array<Array<Dynamic>>;
    var playfields:Int;
}


class ModchartFile
{

    public static final MOD_NAME = 0;
    public static final MOD_CLASS = 1;
    public static final MOD_TYPE = 2;
    public static final MOD_PF = 3;
    public static final MOD_LANE = 4;

    public static final EVENT_TYPE = 0;
    public static final EVENT_DATA = 1;

    public static final EVENT_TIME = 0;
    public static final EVENT_SETDATA = 1;
    public static final EVENT_EASETIME = 1;
    public static final EVENT_EASE = 2;
    public static final EVENT_EASEDATA = 3;


    public var data:ModchartJson = null;
    private var renderer:PlayfieldRenderer;
    public var scriptListen:Bool = false;
    public var customModifiers:Map<String, Modifier> = new Map<String, Modifier>();
    public function new(renderer:PlayfieldRenderer)
    {

        data = loadFromJson(PlayState.SONG.song.toLowerCase());
        this.renderer = renderer;
        renderer.modchart = this;
        loadPlayfields();
        loadModifiers();
        loadEvents();
    }

    public function loadFromJson(folder:String):ModchartJson //load da shit
    {
        var rawJson = null;
        var folderShit:String = "";
        #if sys
        #if PSYCH
		var moddyFile:String = Paths.modsJson(Paths.formatToSongPath(folder) + '/modchart');
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
            folderShit = moddyFile.replace("modchart.json", "customMods/");
		}
		#end
        #end
        if (rawJson == null)
        {
            var filePath = Paths.json(folder + '/modchart');
            folderShit = filePath.replace("modchart.json", "customMods/");
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
            json = cast Json.parse(rawJson);
            //trace('loaded json');
            trace(folderShit);
            #if sys
            if (FileSystem.isDirectory(folderShit))
            {
                //trace("folder le exists");
                for (file in FileSystem.readDirectory(folderShit))
                {
                    if(file.endsWith('.hx')) //custom mods!!!!
                    {
                        var scriptStr = File.getContent(folderShit + file);
                        var mod = new Modifier("");
                        var script = new CustomModifierScript(scriptStr, mod);
                        customModifiers.set(file.replace(".hx", ""), mod);
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
        renderer.modifiers.clear();
        renderer.loadDefaultModifiers();
        for (i in data.modifiers)
        {
            ModchartFuncs.startMod(i[MOD_NAME], i[MOD_CLASS], i[MOD_TYPE], Std.parseInt(i[MOD_PF]), renderer.instance);
        }
    }
    public function loadPlayfields()
    {
        if (data == null || renderer == null)
            return;

        renderer.playfields = [];
        for (i in 0...data.playfields)
            renderer.addNewplayfield(0,0,0);
    }
    public function loadEvents()
    {
        if (data == null || renderer == null)
            return;
        renderer.events = [];
        for (i in data.events)
        {
            switch(i[EVENT_TYPE])
            {
                case "ease": 
                    ModchartFuncs.ease(Std.parseFloat(i[EVENT_DATA][EVENT_TIME]), Std.parseFloat(i[EVENT_DATA][EVENT_EASETIME]), i[EVENT_DATA][EVENT_EASE], i[EVENT_DATA][EVENT_EASEDATA], renderer.instance);
                case "set": 
                    ModchartFuncs.set(Std.parseFloat(i[EVENT_DATA][EVENT_TIME]), i[EVENT_DATA][EVENT_SETDATA], renderer.instance);
                case "hscript": 
                    //maybe just run some code???
            }
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

class CustomModifierScript
{
    public var interp:Interp = null;
    var script:Expr;
    var parser:Parser;
    public function new(scriptStr:String, mod:Modifier)
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
        init(mod);
    }
    private function init(mod:Modifier)
    {
        if (interp == null)
            return;


        interp.variables.set('Math', Math);
        interp.variables.set('PlayfieldRenderer', PlayfieldRenderer);
        interp.variables.set('ModchartUtil', ModchartUtil);
        interp.variables.set('Modifier', Modifier);
        interp.variables.set('NoteMovement', NoteMovement);
        interp.variables.set('NotePositionData', PlayfieldRenderer.NotePositionData);
        interp.variables.set('ModchartFile', ModchartFile);
        interp.variables.set('FlxG', flixel.FlxG);
		interp.variables.set('FlxSprite', flixel.FlxSprite);
		interp.variables.set('FlxCamera', flixel.FlxCamera);
		interp.variables.set('FlxTimer', flixel.util.FlxTimer);
		interp.variables.set('FlxTween', flixel.tweens.FlxTween);
		interp.variables.set('FlxEase', flixel.tweens.FlxEase);
		interp.variables.set('PlayState', PlayState);
		interp.variables.set('game', PlayState.instance);
		interp.variables.set('Paths', Paths);
		interp.variables.set('Conductor', Conductor);
        interp.variables.set('StringTools', StringTools);

        call("initMod", [mod]);

        interp = null; //kill script after running
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
}