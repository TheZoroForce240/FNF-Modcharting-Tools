# FNF Modcharting Tools
Just a thing I made to make modcharting easier, should be easy to add to most engines.
Still very WIP and not everything is supported yet!

## Features
### Modifier system for easing in and out effects
![](https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/readme/modifiers.gif)
### Custom Sustain Renderer (using FlxStrip for stretchy sustains)
### Multiple playfields that can have their own positions and modifiers
![](https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/readme/sustains.gif)
### Custom Modifier Support via Hscript
![](https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/readme/custommods.gif)
### Support for multiple engines
- Base Game (not tested)
- [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine) (working 0.6.3 and 0.7.x, includes lua functions)
- [Leather Engine](https://github.com/Leather128/LeatherEngine) (working 0.5.0)
- [Kade Engine](https://github.com/KadeDev/Kade-Engine) (not tested)
- [Yoshi Engine](https://github.com/YoshiCrafter29/YoshiCrafterEngine) (not tested)
- [Forever Engine Legacy](https://github.com/Yoshubs/Forever-Engine-Legacy) (not tested)
- [FPS Plus](https://github.com/ThatRozebudDude/FPS-Plus-Public) (not tested)


## Credits 
- [Original FNF Team](https://github.com/ninjamuffin99/Funkin) - They made the game
- [NotITG](https://www.noti.tg/) - Inspiration (made me love modcharts lol)
- [OpenITG](https://github.com/openitg/openitg) - Math used for some modifiers
- [TheZoroForce240](https://github.com/TheZoroForce240/FNF-Modcharting-Tools) - Creator of modcharting tools base
- [Vortex2Oblivion](https://github.com/Vortex2Oblivion) - Helper from modcharting tools
- [Manu614](https://github.com/Manu614) - Helper from modcharting tools
- [UncertainProd](https://github.com/UncertainProd) - Helper from modcharting tools
- [Joalor64GH](https://github.com/Joalor64GH) - Helper from modcharting tools
- [Edwhak_KB](https://github.com/EdwhakKB) - Added some modifiers and fixed stuff + skewNotes
- [Glowsoony](https://github.com/glowsoony) - Help with some 0.7.X stuff! + skewNotes too
- [Slushi_Github](https://github.com/Slushi-Github) - Help with reorganisation with haxelib edition
- [2JENO](https://github.com/2JENO) - Help with the Import.hx, GPU thing (fixes some things so thanks!)

## Installation 
1. You need the most recent version of HaxeFlixel for it to work. (5.5.0 as of writing)
2. If your running any (engine or psych) that uses SScript (For Custom Modifiers) then I really recommened using versions 6.1.80 and up. NO LOWER VERSIONS! (If you use older versions, sorry but SScript in older version apperantly has many memory leaks when it comes to any scripts (even without modchartingTools). -glowsoony
### With Source:
1. Install the haxelib by typing `haxelib git fnf-modcharting-tools https://github.com/EdwhakKB/FNF-Modcharting-Tools` in the console
2. Now you only need to make a few small additions to get everything working,
- In MusicBeatState.hx:
```haxe
class MusicBeatState extends modcharting.ModchartMusicBeatState
{
  
```
- In PlayState.hx:
```haxe
import modcharting.ModchartFuncs;
import modcharting.NoteMovement;
import modcharting.PlayfieldRenderer;
  
```
```haxe
override public function create()
{
	//Add this before function create() (For Psych 0.7.1+)
	var backupGpu:Bool;
	//Add this before generateSong(); (For Psych 0.7.1+)
	backupGpu = ClientPrefs.data.cacheOnGPU;
	ClientPrefs.data.cacheOnGPU = false;
	//Add this before camfollow stuff and after strumLineNotes and notes have been made
	playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
	playfieldRenderer.cameras = [camHUD];
	add(playfieldRenderer);
	add(grpNoteSplashes); /*place splashes in front (add this if the engine has splashes).
	If you have added this: remove(or something) the add(grpNoteSplashes); which is by default below the add(strumLineNotes);*/
	//if you use PSYCH 0.6.3 use this code
	ModchartFuncs.loadLuaFunctions(); //add this if you want lua functions in scripts
	//being used in psych engine as an example
callOnLuas('onCreatePost', []);
      
  //Find this line and then add it
public function startCountdown():Void
{
  generateStaticArrows(0);
  generateStaticArrows(1);
  
  //add after generating strums
  NoteMovement.getDefaultStrumPos(this);
//Find this line and then add it (For Psych 0.7.1+)
override function destroy() {
	ClientPrefs.data.cacheOnGPU = backupGpu;
```

- In StrumNote.hx:
```haxe
//Import FlxSkewedSprite at the top
import flixel.addons.effects.FlxSkewedSprite;
//change "FlxSprite" to "FlxSkewedSprite"
class StrumNote extends FlxSkewedSprite
```

- In Note.hx:
```haxe
//Import FlxSkewedSprite at the top
import flixel.addons.effects.FlxSkewedSprite;
//change "FlxSprite" to "FlxSkewedSprite"
class Note extends FlxSkewedSprite
{
  //add these 2 variables for the renderer
  public var mesh:modcharting.SustainStrip = null;
  public var z:Float = 0;
```

- In ModchartUtilities.hx (Leather Exclusive):

```haxe
// at the start of the HX
import modcharting.ModchartFuncs; //to fix any crash lmao
// (at the bottom of create())
#if desktop DiscordClient.addLuaCallbacks(this); #end
ModchartFuncs.loadLuaFunctions(this); //add this if you want lua functions in scripts
//being used in leather engine as an example
callOnLuas('onCreate', []);
```

- In FunkinLua.hx (Found in psychlua folder) (0.7.X exclusive!):
```haxe
//at the start of the HX
    import modcharting.ModchartFuncs; //to fix any crash lmao
class FunkinLua
{
    //add this variable bellow "public var closed:Bool = false;"
  	public static var instance:FunkinLua = null;
    #if desktop DiscordClient.addLuaCallbacks(this); #end
    ModchartFuncs.loadLuaFunctions(this); //add this if you want lua functions in scripts
    being used in psych engine as an example
```
- In HScript (Found in psychlua folder) (0.7.X exclusive!)
``` haxe
//under the function (PRESET!)
//copy and paste this code if you use under SScript 6.1.80
override function preset()
{
	set('Math', Math);
	set('ModchartEditorState', modcharting.ModchartEditorState);
	set('ModchartEvent', modcharting.ModchartEvent);
	set('ModchartEventManager', modcharting.ModchartEventManager);
	set('ModchartFile', modcharting.ModchartFile);
	set('ModchartFuncs', modcharting.ModchartFuncs);
	set('ModchartMusicBeatState', modcharting.ModchartMusicBeatState);
	set('ModchartUtil', modcharting.ModchartUtil);
	for (i in ['mod', 'Modifier'])
		set(i, modcharting.Modifier); //the game crashes without this???????? what??????????? -- fue glow
	set('ModifierSubValue', modcharting.Modifier.ModifierSubValue);
	set('ModTable', modcharting.ModTable);
	set('NoteMovement', modcharting.NoteMovement);
	set('NotePositionData', modcharting.NotePositionData);
	set('Playfield', modcharting.Playfield);
	set('PlayfieldRenderer', modcharting.PlayfieldRenderer);
	set('SimpleQuaternion', modcharting.SimpleQuaternion);
	set('SustainStrip', modcharting.SustainStrip);
	
	modcharting.ModchartFuncs.loadHScriptFunctions(this);
//--(else if you use SScript above or equal to version 6.1.80)--
override function preset()
{
	set('Math', Math);
	setClass(modcharting.ModchartEditorState);
	setClass(modcharting.ModchartEvent);
	setClass(modcharting.ModchartEventManager);
	setClass(modcharting.ModchartFile);
	setClass(modcharting.ModchartFuncs);
	setClass(modcharting.ModchartMusicBeatState);
	setClass(modcharting.ModchartUtil);
	setClass(modcharting.Modifier); //the game crashes without this???????? what??????????? -- fue glow
	setClass(modcharting.Modifier.ModifierSubValue);
	setClass(modcharting.ModTable);
	setClass(modcharting.NoteMovement);
	setClass(modcharting.NotePositionData);
	setClass(modcharting.Playfield);
	setClass(modcharting.PlayfieldRenderer);
	setClass(modcharting.SimpleQuaternion);
	setClass(modcharting.SustainStrip);
	modcharting.ModchartFuncs.loadHScriptFunctions(this);
//Function initMod -- Init's the mods functions for Hscript (found in psychlua)
//Place this function anywhere in the HScript class!
public function initMod(mod:modcharting.Modifier)
{
	call("initMod", [mod]);
}
```
- In Import.hx, you should copy what mine adds and paste it there

- In Project.xml:
```xml
<!--Set this to the engine you're using!-->
<define name="PSYCH" />

<haxelib name="fnf-modcharting-tools" />

```
You need to define which engine you're using to fix compiling issues, or it would default to base game settings (downscroll won't work etc).
Available ones: PSYCH, KADE(notTested), LEATHER, FOREVER_LEGACY(notTested), YOSHI(notTested), FPSPLUS(notTested)

Note: If you use psych engine you should add this (have in mind "ver" is the version you want to use, do not add the text, use the brain)
(just in case minimal ver is 0.6.0 to 0.7.3)
and no if psych 0.7.4 or more releases i won't port this due some changes Psych has (they break MT to it max so srry :D)

```xml

<define name="PSYCHVERSION" value="ver"/>

```

to get 0.7.X and up add a higher version than 0.7 (example 0.7.3),
leave it as another value to use 0.6.3 edition


3. Now if your game compiles successfully then you should be all good to go.
