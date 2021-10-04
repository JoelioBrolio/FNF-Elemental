package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	static inline final DIALOGUEMUSIC_CALAMITY = 'dialogueMusic/calamity';

	var box:FlxSprite;

	var curCharacter:String = '';
	var cutscene:FlxSprite;
	var curCutscene:String = '';
	var dialogueSoundclip:String = '#FF000000';
	var dialogueVoiceline:String = '#FF000000';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>, isOutro:Bool = false)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'reunion':
				FlxG.sound.playMusic(Paths.music('dialogueMusic/unexpectedMeeting'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'myst':
				if (!isOutro) {
					FlxG.sound.playMusic(Paths.music('dialogueMusic/negativeAura'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.5);
				} else {
					FlxG.sound.playMusic(Paths.music('dialogueMusic/distantCalamity'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.4);
				}
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear instance 1', [4], "", 24);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH instance 1', [4], "", 24);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn instance 1', [11], "", 24);

			case 'reunion' | 'myst':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('elementalBox', 'shared');
				box.animation.addByPrefix('normalOpen', 'open', 24, false);
				box.animation.addByIndices('normal', 'normal', [4], "", 24);
				box.width = 0;
				box.height = 0;
				box.x = 200;
				box.y = 475;
				box.alpha = 0.7;
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'thorns':
				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
			case 'reunion' | 'myst':
				cutscene = new FlxSprite(0, 0).loadGraphic(Paths.image('cutscene/$curCutscene'));
				add(cutscene);
		}
		
		if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
		{
			portraitLeft = new FlxSprite(-20, 40);
			portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
			portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;
		}
		else if(PlayState.SONG.song.toLowerCase()=='reunion' || PlayState.SONG.song.toLowerCase()=='myst')
		{
			portraitLeft = new FlxSprite(75, 600);
			portraitLeft.frames = Paths.getSparrowAtlas('portraits/enzoPortrait', 'shared');
			portraitLeft.animation.addByPrefix('enter', 'enzoPortrait neutral', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.1));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;
		}

		if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
		{
			portraitRight = new FlxSprite(0, 40);
			portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
			portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;
		}
		else if(PlayState.SONG.song.toLowerCase()=='reunion' || PlayState.SONG.song.toLowerCase()=='myst')
		{
			portraitRight = new FlxSprite(75, 600);
			portraitRight.frames = Paths.getSparrowAtlas('portraits/bfPortrait', 'shared');
			portraitRight.animation.addByPrefix('enter', 'bfPortrait neutral', 24, false);
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.1));
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;
		}

		box.animation.play('normalOpen');
		if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
		{
			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		}
		else if(PlayState.SONG.song.toLowerCase()=='reunion' || PlayState.SONG.song.toLowerCase()=='myst')
		{
			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.1));
		}
		box.updateHitbox();
		add(box);

		if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
		{
			box.screenCenter(X);
		}

		if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
		{
			handSelect = new FlxSprite(1042, 590).loadGraphic(Paths.getPath('hand_textbox.png', IMAGE));
			handSelect.setGraphicSize(Std.int(handSelect.width * PlayState.daPixelZoom * 0.9));
			handSelect.updateHitbox();
			handSelect.visible = false;
			add(handSelect);
		}

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 28);
		if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
		{
			dropText.font = 'Pixel Arial 11 Bold';
			dropText.color = 0xFFD89494;
		}
		else if(PlayState.SONG.song.toLowerCase()=='reunion' || PlayState.SONG.song.toLowerCase()=='myst')
		{
			dropText.font = 'VCR OSD Mono';
			dropText.color = 0xFF4a4a4a;
		}
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 28);
		if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
		{
			swagDialogue.font = 'Pixel Arial 11 Bold';
			swagDialogue.color = 0xFFD89494;
		}
		else if(PlayState.SONG.song.toLowerCase()=='reunion' || PlayState.SONG.song.toLowerCase()=='myst')
		{
			swagDialogue.font = 'VCR OSD Mono';
			swagDialogue.color = 0xFF141414;
		}
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.visible = false;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if(FlxG.keys.justPressed.ANY)
		{
			if (dialogueEnded)
			{
				remove(dialogue);
				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;
						if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
						{
							FlxG.sound.play(Paths.sound('clickText'), 0.8);	
						}
						else if(PlayState.SONG.song.toLowerCase()=='reunion' || PlayState.SONG.song.toLowerCase()=='myst')
						{
							FlxG.sound.play(Paths.sound('proceedText'), 0.8);
						}

						if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns' || PlayState.SONG.song.toLowerCase() == 'reunion' || PlayState.SONG.song.toLowerCase() == 'myst')
							FlxG.sound.music.fadeOut(1.5, 0);

						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							box.alpha -= 1 / 5 * 0.7;
							bgFade.alpha -= 1 / 5 * 0.7;
							portraitLeft.visible = false;
							portraitRight.visible = false;
							swagDialogue.alpha -= 1 / 5;
							if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
							{
								handSelect.alpha -= 1 / 5;
							}
							dropText.alpha = swagDialogue.alpha;
							cutscene.alpha = swagDialogue.alpha;
						}, 5);

						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							finishThing();
							kill();
						});
					}
				}
				else
				{
					dialogueList.remove(dialogueList[0]);
					startDialogue();
					if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
					{
						FlxG.sound.play(Paths.sound('clickText'), 0.8);	
					}
					else if(PlayState.SONG.song.toLowerCase()=='reunion' || PlayState.SONG.song.toLowerCase()=='myst')
					{
						FlxG.sound.play(Paths.sound('proceedText'), 0.8);
						FlxG.sound.play(Paths.sound('dialogueVoicelines/$dialogueVoiceline'), 1);
						FlxG.sound.play(Paths.sound('dialogueSounds/$dialogueSoundclip'), 0.8);
					}
				}
			}
			else if (dialogueStarted)
			{
				if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
					{
						FlxG.sound.play(Paths.sound('clickText'), 0.8);	
					}
				else if(PlayState.SONG.song.toLowerCase()=='reunion' || PlayState.SONG.song.toLowerCase()=='myst')
					{
						FlxG.sound.play(Paths.sound('proceedText'), 0.8);	
					}	
				swagDialogue.skip();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;
	var splitData:Array<String>;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);
		swagDialogue.completeCallback = function() {
			if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
			{
				handSelect.visible = true;
			}
			dialogueEnded = true;
		};

		if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
		{
			handSelect.visible = false;
		}
		dialogueEnded = false;
		switch (curCharacter)
		{
			case 'dad':
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'reunion' || PlayState.SONG.song.toLowerCase()=='myst') portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'bf':
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
		}
		switch (PlayState.SONG.song.toLowerCase()) {
			case 'reunion' | 'myst':
				remove(cutscene);
				cutscene = new FlxSprite(0, 0).loadGraphic(Paths.image('cutscene/$curCutscene'));
				add(cutscene);
		}
		if(nextDialogueThing != null) {
			nextDialogueThing();
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();

		splitData = dialogueList[0].split("!");
		curCutscene = splitData[1];
		dialogueList[0] = dialogueList[0].substr(splitData[1].length + 2).trim();

		splitData = dialogueList[0].split("~");
		dialogueVoiceline = splitData[1];
		dialogueList[0] = dialogueList[0].substr(splitData[1].length + 2).trim();

		splitData = dialogueList[0].split(";");
		dialogueSoundclip = splitData[1];
		dialogueList[0] = dialogueList[0].substr(splitData[1].length + 2).trim();
	}
}
