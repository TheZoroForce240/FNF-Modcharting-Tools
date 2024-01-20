#if LEATHER
import states.PlayState;
import game.Song;
import game.Section.SwagSection;
import game.Note;
import ui.FlxUIDropDownMenuCustom;
import game.Conductor;
import utilities.CoolUtil;
import game.StrumNote;
import utilities.NoteVariables;
import states.LoadingState;
import states.MusicBeatState;
import substates.MusicBeatSubstate;
#elseif (PSYCH && PSYCHVERSION >= "0.7")
import flixel.addons.ui.FlxUIDropDownMenu;
import backend.Section.SwagSection;
import states.PlayState;
import backend.CoolUtil;
import backend.Conductor;
import backend.ClientPrefs;
import backend.Paths;
import states.LoadingState;
import backend.Difficulty;
#if SCEModchartingTools
import substates.MusicBeatSubstate;
#else
import backend.MusicBeatSubstate;
#end
import objects.Note;
#if SCEModchartingTools
import objects.StrumArrow;
#else
import objects.StrumNote;
#end
import backend.Song;
#else
import Section.SwagSection;
import Song;
import MusicBeatSubstate;
#end

#if (PSYCH && PSYCHVERSION >= "0.7")
#if LUA_ALLOWED
import psychlua.FunkinLua;
import psychlua.HScript as FunkinHScript;
#end
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end