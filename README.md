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
- [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine) (working 0.6.3, includes lua functions)
- [Leather Engine](https://github.com/Leather128/LeatherEngine) (working 0.4.2)
- [Kade Engine](https://github.com/KadeDev/Kade-Engine) (not tested)
- [Yoshi Engine](https://github.com/YoshiCrafter29/YoshiCrafterEngine) (not tested)
- [Forever Engine Legacy](https://github.com/Yoshubs/Forever-Engine-Legacy) (not tested)
- [FPS Plus](https://github.com/ThatRozebudDude/FPS-Plus-Public) (not tested)


## Credits 
- [Original FNF Team](https://github.com/ninjamuffin99/Funkin) - they made the game
- [NotITG](https://www.noti.tg/) - Inspiration (made me love modcharts lol)
- [OpenITG](https://github.com/openitg/openitg) - Math used for some modifiers

## Installation 
You need the most recent version of HaxeFlixel for it to work. (5.2.1 as of writing)
### With Source:
1. Start by downloading the source folder from this repo and dragging it into your current fnf source folder you want to add it to.
2. Now you only need to make a few small additions to get everything working,
- In PlayState.hx:
```haxe
import modcharting.ModchartFuncs;
import modcharting.NoteMovement;
import modcharting.PlayfieldRenderer;

class PlayState extends modcharting.ModchartMusicBeatState
{
  
```
```haxe

override public function create()
{

  //Add this before camfollow stuff and after strumLineNotes and notes have been made
  playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
  playfieldRenderer.cameras = [camHUD];
  add(playfieldRenderer);
  add(grpNoteSplashes); /*place splashes in front (add this if the engine has splashes).
  If you have added this: remove(or something) the add(grpNoteSplashes); which is by default below the add(strumLineNotes);*/
      
      
```

```haxe

// (at the bottom of create())

ModchartFuncs.loadLuaFunctions(); //add this if you want lua functions in scripts
//being used in psych engine as an example

callOnLuas('onCreatePost', []);
super.create();

```
```haxe

public function startCountdown():Void
{
  generateStaticArrows(0);
  generateStaticArrows(1);
  //add after generating strums
  NoteMovement.getDefaultStrumPos(this);

```

- In Note.hx:
```haxe

class Note extends FlxSprite
{
  //add these 2 variables for the renderer
  public var mesh:flixel.FlxStrip = null; 
  public var z:Float = 0;

```
- In Project.xml:
```xml

<define name="PSYCH" />

```
You need to define which engine you're using to fix compiling issues, or it would default to base game settings (downscroll won't work etc).
Available ones: PSYCH, KADE, LEATHER, FOREVER_LEGACY, YOSHI, FPSPLUS


3. Now if your game compiles successfully then you should be all good to go.

