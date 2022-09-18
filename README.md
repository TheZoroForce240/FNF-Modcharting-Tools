# FNF Modcharting Tools
Just a thing I made to make modcharting easier, should be easy to add to most engines.

## Features
### Modifier system for easing in and out effects
![](https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/readme/modifiers.gif)
### Custom Sustain Renderer (using FlxStrip for stretchy sustains)
![](https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/readme/sustains.gif)
### Multiple playfields that can have their own positions and modifiers
![](https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/readme/playfields.gif)
### Custom Modifier Support via Hscript
![](https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/readme/custommods.gif)


## Credits 
- [Original FNF Team](https://github.com/ninjamuffin99/Funkin) - they made the game
- [NotITG](https://www.noti.tg/) - Inspiration (made me love modcharts lol)
- [OpenITG](https://github.com/openitg/openitg) - Math used for some modifiers

## Installation 
### With Source:
1. Start by downloading the source folder from this repo and dragging it into your current fnf source folder you want to add it to.
2. Now you only need to make a few small additions to get everything working,
- In PlayState.hx:
```haxe
import modcharting.ModchartLuaFuncs;
import modcharting.NoteMovement;
import modcharting.PlayfieldRenderer;

class PlayState extends MusicBeatState
{
  //init variable for renderer
  public var playfieldRenderer:PlayfieldRenderer;
  
```
```haxe

override public function create()
{

  //add after generateSong() has been called
  playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
  playfieldRenderer.cameras = [camHUD];
  add(playfieldRenderer);
  add(grpNoteSplashes); //place splashes in front (add this if engine has splashes)
      
      
```

```haxe

// (at the bottom of create())

ModchartLuaFuncs.luaFunctionStuff(); //add this if you want lua functions in scripts
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
  public var mesh:modcharting.SustainMesh = null; 
  public var z:Float = 0;

```




