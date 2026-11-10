/// English UI strings for the Linux port.
///
/// Values are taken verbatim from the upstream Android app
/// (`app/src/main/res/values/strings.xml`, MIT, Copyright (c) 2020 minar)
/// so that the port speaks exactly like the original. Only the subset the
/// Linux UI needs is kept; the file is structured so a locale table can be
/// dropped in later without touching widgets.
library;

class S {
  const S._();

  // Global
  static const appName = 'Randomix';
  static const extendedName = 'Randomix - Decision Maker';
  static const introDescription =
      'An open source app to choose randomly between numbers, answers, options '
      'and so on. Let the randomness talk!';
  static const resultPlaceholder = '- - -';
  static const genericResult = 'The result is:';
  static const back = 'Back';

  // Navigation
  static const roulette = 'Roulette';
  static const coin = 'Coin';
  static const dice = 'Dice';
  static const magicBall = 'Magic Ball';
  static const settings = 'Settings';
  static const about = 'About';

  // Roulette
  static const rouletteMode = 'Roulette mode';
  static const rouletteDescription =
      'Do you have to choose something? Are you tired of polls and bossy '
      'friends? A roulette will decide for you! Long press the roulette to add '
      'generic options or clear them.';
  static const spinRoulette = 'Spin the roulette!';
  static const insertRouletteHint = 'Enter an option…';
  static const insertRouletteDescription =
      'Please list below the possible choices to add in the roulette.';
  static const noEntryRoulette =
      'Please, enter 2 or more options to spin the roulette!';
  static const tooMuchEntries = "You can't enter more than 30 options!";
  static const genericOption = 'Option';
  static const recentTitle = 'Recent options';
  static const recentDescription =
      'Tap a chip to add a predefined set. Long press on a recent option set to '
      'pin it, tap to restore it or swipe to delete it.';
  static const noRecentOptions =
      'No recent option, spin the roulette to save the current options!';
  static const lettersShortcut = 'A-Z Letters';
  static const numbersShortcut = '1–100';
  static const cardsShortcut = '🃏';
  static const range = 'Range';
  static const options = 'Options';
  static const wrongRange =
      'The range is wrong or empty, please enter both the values correctly!';
  static const deleteAll = 'Delete all the options';
  static const deleteAllConfirmation =
      'Are you sure you want to delete all the entered options?';
  static const max = 'Max';
  static const min = 'Min';
  static const removeOption = 'Remove option';
  static const presets = 'Presets';
  static const addOption = 'Add option';
  static const duplicateOption = 'This option is already in the list.';
  static const savedSetsLabel = 'Restore';
  static const noRecentRoom =
      'All recent sets are pinned, this one was not saved.';
  static const longPressHint = 'Long press to fill or clear';

  // Coin
  static const coinMode = 'Coin mode';
  static const coinDescription =
      'Flipping a coin is easy, but can help you decide between doing something '
      'or not. Just heads or tails. Let the coin talk!';
  static const flipCoin = 'Flip the coin!';
  static const resultHead = 'Heads!';
  static const resultTail = 'Tails!';
  static const streakThree = '🔥 Three in a row!';
  static const streakFive = '🔥 Five in a row!';
  static const streakTen = '🔥 Ten in a row!';
  static const streakTwenty = '🔥 Twenty in a row!';

  // Dice
  static const diceMode = 'Dice mode';
  static const diceDescription =
      'Dice can be useful, in a table game for example! The app will throw one '
      'to ten dice for you. Select the number and type below. Good luck!';
  static const throwDice = 'Throw the dice!';
  static const threeVThree = '3 vs 3';
  static const diceNumber = 'Dice number';
  static const diceType = 'Dice type';

  // Magic ball
  static const magicBallMode = 'Magic Ball';
  static const magicBallDescription =
      'The magic ball will tell you the answers! Just ask something, and it '
      'will help you with a generic and affordable answer. You can activate its '
      'rudeness from settings!';
  static const shakeBall = 'Shake it!';
  static const customAnswers = 'Custom answers';
  static const useCustomAnswers = 'Use custom answers';
  static const insertAnswerHint = 'Insert an answer…';
  static const noAnswersMagicBall =
      'No custom answers. Add one from the above text field. You can delete '
      'them by tapping on them.';
  static const customAnswersHelp =
      'Separate answers with a semicolon (;). At least 2 answers are needed.';
  static const save = 'Save';
  static const cancel = 'Cancel';

  // Settings
  static const customization = 'Customization';
  static const rouletteSettings = 'Roulette';
  static const spinStyleName = 'Spin animation';
  static const spinStyleDescription =
      'How the roulette reveals the result. Range mode always counts through '
      'numbers.';
  static const spinStyleWheel = 'Wheel';
  static const spinStyleWheelDescription =
      'A wheel turns until the winner is under the pointer, with the current '
      'option read out in the centre.';
  static const spinStyleCoverflow = 'Cover flow';
  static const spinStyleCoverflowDescription =
      'Cards slide past each other in perspective until the winner is in front.';
  static const spinStyleChips = 'Chips';
  static const spinStyleChipsDescription =
      'Your option chips light up in turn and stop on the winner.';
  static const appBehavior = 'App behavior';
  static const themeName = 'App theme';
  static const themeDescription =
      'Use a dark, light or automatic app theme. Currently %s';
  static const accentName = 'Accent color';
  static const accentDescription =
      'Change the default accent color. Currently %s';
  static const amoledName = 'Amoled';
  static const amoledDescriptionOn =
      'The dark theme uses pure black, ideal for OLED screens';
  static const amoledDescriptionOff =
      'The dark theme uses the standard dark surfaces';
  static const blobName = 'Random Blobs background';
  static const blobDescription =
      'A random moving background, for aesthetic purposes';
  static const soundName = 'Sounds';
  static const soundDescriptionOn = 'Play a sound when a button is pressed';
  static const soundDescriptionOff = 'No sound when a button is pressed';
  static const hideDescriptionsName = 'Hide descriptions';
  static const hideDescriptionsOn = 'Descriptions hidden';
  static const hideDescriptionsOff = 'Descriptions visible';
  static const allowEqualsName = 'Allow equal options';
  static const allowEqualsOn = 'Equal options in roulette allowed';
  static const allowEqualsOff = 'Equal options in roulette not allowed';
  static const removeLastName = 'Remove last chosen';
  static const removeLastOn =
      'Remove the last chosen option in the roulette automatically';
  static const removeLastOff =
      "Don't remove the last chosen option in the roulette automatically";
  static const rudeAnswersName = 'Rude answers';
  static const rudeAnswersOn = 'Rude answers activated, idiot';
  static const rudeAnswersOff = 'Just kind and polite answers';
  static const themeSystem = 'System default';
  static const themeDark = 'Dark';
  static const themeLight = 'Light';
  static const resetSettings = 'Reset settings';
  static const resetSettingsQuestion =
      'Restore every setting to its default value?';
  static const showIntro = 'Show introduction';
  static const spaceHint = 'Space';
  static const keyboardShortcuts = 'Keyboard shortcuts';
  static const settingsRestored = 'Settings restored to their defaults';
  static const appVersion = '4.1';
  static const introReplay = 'Introduction replayed';
  static const keyboardHint =
      'Keyboard: Space triggers the active tool, Esc closes dialogs.';
  static const copyResult = 'Copy result';
  static const copiedResult = 'Result copied to the clipboard';

  // Accent names
  static const blue = 'Blue';
  static const aqua = 'Aqua';
  static const green = 'Green';
  static const orange = 'Orange';
  static const yellow = 'Yellow';
  static const teal = 'Teal';
  static const violet = 'Violet';
  static const pink = 'Pink';
  static const lightBlue = 'Light blue';
  static const red = 'Red';
  static const lime = 'Lime';
  static const crimson = 'Crimson';
  static const systemAccent = 'System';

  // About
  static const aboutVersion = 'Version';
  static const devName = 'm.i.n.a.r.';
  static const devDescription =
      "I'm a polite guy, and I like beautiful things like animations, icons, "
      'sports cars and 3D printing. I work as a designer and computer engineer.';
  static const upstream = 'Original Android app';
  static const upstreamUrl = 'https://github.com/m-i-n-a-r/randomix';
  static const fDroidUrl = 'https://f-droid.org/packages/com.minar.randomix/';
  static const license = 'License';
  static const licenseText =
      'Randomix is released under the MIT license.\n\n'
      'Copyright (c) 2020 minar\n\n'
      'Permission is hereby granted, free of charge, to any person obtaining a '
      'copy of this software and associated documentation files (the '
      '"Software"), to deal in the Software without restriction, including '
      'without limitation the rights to use, copy, modify, merge, publish, '
      'distribute, sublicense, and/or sell copies of the Software, and to permit '
      'persons to whom the Software is furnished to do so, subject to the '
      'following conditions:\n\n'
      'The above copyright notice and this permission notice shall be included '
      'in all copies or substantial portions of the Software.\n\n'
      'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS '
      'OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF '
      'MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. '
      'IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY '
      'CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, '
      'TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE '
      'SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';
  static const linuxPortNote =
      'Linux port built with Flutter. Sparkling new animations, same '
      'randomness. Vibration and shake detection are not available on desktop.';
  static const openInBrowser = 'Open link';
  static const linkCopied = 'Link copied to the clipboard';
  static const close = 'Close';
  static const introSkip = 'Skip';
  static const introNext = 'Next';
  static const introStart = 'Start';
  static const introTitle1 = 'Let randomness decide';
  static const introText1 =
      'Roulette, coin, dice and a magic ball: four ways to stop overthinking '
      'and let the app choose for you.';
  static const introTitle2 = 'Make it yours';
  static const introText2 =
      'Twelve accents, light, dark and Amoled themes, animated backgrounds and '
      'custom answers for the magic ball.';
  static const introTitle3 = 'Built for the desktop';
  static const introText3 =
      'A native Flutter window: resize it, keep it on the side of the screen, '
      'press Space to throw. Your choices are remembered.';
}
