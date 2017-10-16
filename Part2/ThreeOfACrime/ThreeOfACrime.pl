#!usr/bin/env perl

=pod
  This program was built and tested in Windows. Before running this program, it
  is necessary to install the Tk module. There are several ways to do this, but
  the most reliable and fast way is by using the Perl Package Manager (PPM).
  
  Installing the Tk Module with PPM [RECOMMENDED]:
    In a terminal window, run the command: ppm install Tk
  
  Installing the Tk Module with CPAN:
    1) In a terminal window, install the cpan module installer by running the
       command: cpan App::cpanminus
    2) Then, install the Tk module by running the command: cpanm Module::Tk
  
  Installing the Tk Module using the Padre IDE:
    1) Navigate to Run > Run Command.
    2) In the dialog box, enter 'cpan Tk' and click 'Ok'.
=cut

use strict; use warnings; no warnings 'once';
use List::Util qw/ shuffle reduce /;
use Tk; use Tk::PNG; use Tk::widgets qw/ Dialog ROText /;

## GLOBALS, CONSTANTS, AND SETTINGS ######################################################
#-----------------------------------------------------------------------------------------
# Game Images
#-----------------------------------------------------------------------------------------
my $IMGDIR = 'criminals';
unless(-d $IMGDIR){$0 =~ s!^.*/!!; die "$0:\nImage directory `$IMGDIR' does not exist\n";}
# Image Sets
use constant { IMG_LNUP => 'lineup', IMG_JAIL => 'jailed', IMG_SMLL => 'sm' };
use vars qw/ %IMG /;
#-----------------------------------------------------------------------------------------
# Game State Variables
#-----------------------------------------------------------------------------------------
use vars qw/ %PLAYERS $REM_PLAYERS $CURR_PLAYER /;  # Player data
use vars qw/ @PERPS @CRIMS @SELECTED $PERPS_DISP /; # Criminal/perpetrator data
use vars qw/ $CURR_PAGE @DISP_IMG @CRIM_CHKBTN /;   # Page/Widget data
use constant {
  # Player States
  ACTIVE    => 'active',        INACTIVE  => 'inactive',        DISABLED  => 'disabled',
  # Game Pages
  PG_START  => 'startpage',     PG_TURNS  => 'playerturn',      PG_CRSEL  => 'crimselect',
  PG_GMLST  => 'gamelost',      PG_GMWON  => 'gamewon',
  # Settings
  NUM_CRIMS => 7, NUM_PERPS => 3, CRIMS_DISP => 3, MAX_PERPS_DISP => 2
};
#-----------------------------------------------------------------------------------------
# Color/Font Settings
#-----------------------------------------------------------------------------------------
use constant {
  # Color Settings
  GLOBAL_BG   =>  '#e3e3e3',    ACTIVE_BG     =>  '#a0bd55',    INACTIVE_BG =>  '#afafaf',
  DIALOG_BG   =>  '#3b3839',    BUTTON_BG     =>  '#3b3839',    BUTTON_HL   =>  '#c74335',
  GLOBAL_TXT  =>  '#ffffff',    INACTIVE_TXT  =>  '#7a7a7a',
  # Font Settings
  TXT_NORM => ['verdana','10','bold'], TXT_EMPH => ['verdana','24','bold']
};
#-----------------------------------------------------------------------------------------
# Default Button Configuration
#-----------------------------------------------------------------------------------------
my @BTN_CONFIG = (
  -font => &TXT_NORM, -height => 2, -width => 45, -relief => 'raised', -cursor => 'hand2',
  -background => &BUTTON_BG, -foreground => &GLOBAL_TXT, -activebackground => &BUTTON_HL,
  -activeforeground => &GLOBAL_TXT
);
#-----------------------------------------------------------------------------------------
# Displayed Criminal Dialog
#-----------------------------------------------------------------------------------------
my @PERP_TEXT = (
  'None of these criminals are perpetrators', 'One of these criminals is a perpetrator',
  'Two of these criminals are perpetrators'
);
##########################################################################################

## GUI INITIALIZATION ####################################################################
#-----------------------------------------------------------------------------------------
# Main Window
#-----------------------------------------------------------------------------------------
my $mainWindow = MainWindow->new(-title => 'Three Of A Crime');
$mainWindow->configure(-background => &GLOBAL_BG, -cursor => 'left_ptr');
$mainWindow->geometry('1024x768');
#-----------------------------------------------------------------------------------------
# Menus
#-----------------------------------------------------------------------------------------
my $menu = $mainWindow->Menu;
$menu->cascade(
  -label => '~File', -tearoff => 0,
  -menuitems => [
    [command => 'New 1-Player Game', -command => [\&new_game, 1]],
    [command => 'New 2-Player Game', -command => [\&new_game, 2]],
    [command => 'New 3-Player Game', -command => [\&new_game, 3]],
    '',
    [command => '~Quit', -command => sub{ exit }]
  ]
);
$menu->cascade(
  -label => '~Help', -tearoff => 0,
  -menuitems => [
    [command => '~How to Play', -command => [\&show_instr]],
    '',
    [command => '~About', -command => [\&show_about]]
  ]
);
$mainWindow->configure(-menu => $menu);
#-----------------------------------------------------------------------------------------
# Start Frame
#-----------------------------------------------------------------------------------------
my $startFrame = $mainWindow->Frame(-background => &GLOBAL_BG);
my $btn = $startFrame->Button(@BTN_CONFIG)->grid(-padx => 10, -pady => 10);
$btn->configure(-text => 'New 1-Player Game', -command => [ \&new_game, 1 ]);
$btn = $startFrame->Button(@BTN_CONFIG)->grid(-padx => 10, -pady => 10);
$btn->configure(-text => 'New 2-Player Game', -command => [ \&new_game, 2 ]);
$btn = $startFrame->Button(@BTN_CONFIG)->grid(-padx => 10, -pady => 10);
$btn->configure(-text => 'New 3-Player Game', -command => [ \&new_game, 3 ]);
$btn = $startFrame->Button(@BTN_CONFIG)->grid(-padx => 10, -pady => 10);
$btn->configure(-text => 'Quit', -command => sub{ exit });
#-----------------------------------------------------------------------------------------
# Player Frame
#-----------------------------------------------------------------------------------------
my $playerFrame = $mainWindow->Frame(-background => &GLOBAL_BG);
#-----------------------------------------------------------------------------------------
# Dialog Frame
#-----------------------------------------------------------------------------------------
my $dialogFrame = $mainWindow->Frame(-background => &GLOBAL_BG);
my $dialogText = $dialogFrame->Label(-height => 2, -background => &DIALOG_BG,
  -foreground => &GLOBAL_TXT)->pack(-fill => 'x', -expand => 1);
#-----------------------------------------------------------------------------------------
# Display Frame
#-----------------------------------------------------------------------------------------
my $displayFrame = $mainWindow->Frame(-background => &GLOBAL_BG);
foreach my $c (1..&NUM_CRIMS){
  $IMG{$c}{&IMG_LNUP} = $displayFrame->Photo(-file => "$IMGDIR/$c-".IMG_LNUP.".png");
  $IMG{$c}{&IMG_JAIL} = $displayFrame->Photo(-file => "$IMGDIR/$c-".IMG_JAIL.".png");
}
foreach my $c (1..&CRIMS_DISP){
  $DISP_IMG[$c-1] = $displayFrame->Label(-image => $IMG{$c}{&IMG_LNUP}, -borderwidth => 0);
  $DISP_IMG[$c-1]->grid(
    -row => 0, -column => $c-1, -sticky => 'nesw', -padx => 8, -pady => 11
  );
}
#-----------------------------------------------------------------------------------------
# Player Turn Interactions Frame
#-----------------------------------------------------------------------------------------
my $turnFrame = $mainWindow->Frame(-background => &GLOBAL_BG);
$btn = $turnFrame->Button(@BTN_CONFIG)->pack(-side => 'left', -expand => 1);
$btn->configure(-text => 'Identify Perpetrators', -command => [\&set_page, PG_CRSEL]);
$btn = $turnFrame->Button(@BTN_CONFIG)->pack(-side => 'left', -expand => 1);
$btn->configure(-text => 'Pass', -command => [\&pass]);
#-----------------------------------------------------------------------------------------
# Criminal Selection Frame
#-----------------------------------------------------------------------------------------
my $selectFrame = $mainWindow->Frame(-background => &GLOBAL_BG);
foreach my $c (1..NUM_CRIMS){
  $IMG{$c}{&IMG_SMLL} = $selectFrame->Photo(-file => "$IMGDIR/$c-".IMG_SMLL.".png");
  $CRIM_CHKBTN[$c-1] = $selectFrame->Checkbutton(
    -image => $IMG{$c}{&IMG_SMLL}, -borderwidth => 4, -background => &GLOBAL_BG,
    -selectcolor => &BUTTON_HL, -indicatoron => 0, -overrelief => 'flat',
    -cursor => 'hand2', -variable => \$SELECTED[$c-1], -command => [\&validate_select]
  );
  $CRIM_CHKBTN[$c-1]->grid(-row => $c > 4, -column => ($c-1)%4, -padx => 10, -pady => 0);
}
my $submitBtn = $selectFrame->Button(@BTN_CONFIG);
$submitBtn->configure(
  -height => 1, -width => 1, -text => 'Done', -state => 'disabled',
  -command => [\&submit_select]
);
$submitBtn->grid(-row => 1, -column => 3, -sticky => 'nesw', -padx => 10, -pady => 10);
#-----------------------------------------------------------------------------------------
# Cancel Criminal Selection Frame
#-----------------------------------------------------------------------------------------
my $cancelFrame = $mainWindow->Frame(-background => &GLOBAL_BG);
$btn = $cancelFrame->Button(@BTN_CONFIG)->pack(-side => 'left', -expand => 1);
$btn->configure(-text => 'Cancel', -command => [\&set_page, PG_TURNS]);
#-----------------------------------------------------------------------------------------
# Page Members
#-----------------------------------------------------------------------------------------
my %PAGE_MEMBERS = (
  &PG_START =>  [$startFrame],
  &PG_TURNS =>  [$playerFrame, $dialogFrame, $displayFrame, $turnFrame],
  &PG_CRSEL =>  [$playerFrame, $dialogFrame, $selectFrame, $cancelFrame],
  &PG_GMLST =>  [$dialogFrame, $startFrame],
  &PG_GMWON =>  [$dialogFrame, $displayFrame, $startFrame]
);
$CURR_PAGE = undef;
#-----------------------------------------------------------------------------------------
# Set starting page and start main window
#-----------------------------------------------------------------------------------------
set_page(&PG_START);
MainLoop;
##########################################################################################

## SUBROUTINES ###########################################################################
#-----------------------------------------------------------------------------------------
# Start a new game
#-----------------------------------------------------------------------------------------
sub new_game{
  $REM_PLAYERS = shift;
  init_players();
  init_perpetrators();
  init_criminals();
  set_page(&PG_TURNS);
}
#-----------------------------------------------------------------------------------------
# Transition to new game page
#-----------------------------------------------------------------------------------------
sub set_page{
  my $new_page = shift;
  unless(not defined $CURR_PAGE){
    foreach my $pgmem (@{$PAGE_MEMBERS{$CURR_PAGE}}){ $pgmem->packForget; }
  }
  # Some pages require special setups
  if($new_page eq &PG_TURNS){
    set_dialog($PERP_TEXT[$PERPS_DISP], &TXT_NORM);
  }elsif($new_page eq &PG_CRSEL){
    foreach my $chkbtn (@CRIM_CHKBTN){
      $chkbtn->configure(-state => 'normal'); $chkbtn->deselect;
    }
    $submitBtn->configure(-state => 'disabled');
    set_dialog('Select the three perpetrators', &TXT_NORM);
  }elsif($new_page eq &PG_GMLST){
    set_dialog('GAME OVER', &TXT_EMPH);
  }elsif($new_page eq &PG_GMWON){
    set_dialog("Player $CURR_PLAYER Wins!", &TXT_EMPH);
    set_display(\@PERPS, &IMG_JAIL);
  }
  foreach my $pgmem (@{$PAGE_MEMBERS{$new_page}}){
    $pgmem->pack(-padx => 10, -pady => 10, -fill => 'x', -expand => 1);
  }
  $CURR_PAGE = $new_page;
}
#-----------------------------------------------------------------------------------------
# Set the displayed images
#-----------------------------------------------------------------------------------------
sub set_display{
  my $addr = shift; my $set = shift; my @ids = @{$addr};
  for(my $i = 0; $i < @ids && $i < @DISP_IMG; $i++){
    $DISP_IMG[$i]->configure(-image => $IMG{$ids[$i]}{$set});
  }
}
#-----------------------------------------------------------------------------------------
# Set the dialog text
#-----------------------------------------------------------------------------------------
sub set_dialog{
  my $str = shift; my $font = shift;
  $dialogText->configure(-text => $str, -font => $font);
}
#-----------------------------------------------------------------------------------------
# Set the player state
#-----------------------------------------------------------------------------------------
sub set_player_state{
  my $player = shift; my $state = shift;
  $PLAYERS{$player}{'state'} = $state;
  if($state eq &ACTIVE){
    $PLAYERS{$player}{'label'}->configure(
      -background => &ACTIVE_BG, -foreground => &GLOBAL_TXT
    );
  }elsif($state eq &INACTIVE){
    $PLAYERS{$player}{'label'}->configure(
      -background => &INACTIVE_BG, -foreground => &INACTIVE_TXT
    );
  }elsif($state eq &DISABLED){
    $PLAYERS{$player}{'label'}->configure(
      -background => &GLOBAL_BG, -foreground => &GLOBAL_BG
    );
  }
}
#-----------------------------------------------------------------------------------------
# Initialize new players
#-----------------------------------------------------------------------------------------
sub init_players{
  %PLAYERS = ();
  if($playerFrame->children){
    foreach my $child ($playerFrame->children){ $child->destroy; }
  }
  foreach my $player (1..$REM_PLAYERS){
    $PLAYERS{$player}{'label'} = $playerFrame->Label(
      -text => "Player $player", -font => &TXT_NORM, -height => 3, -width => 32,
    )->pack(-side => 'left', -expand => 1);
    set_player_state($player, &INACTIVE);
  }
  $CURR_PLAYER = 1;
  set_player_state($CURR_PLAYER, &ACTIVE);
}
#-----------------------------------------------------------------------------------------
# Initialize new perpetrators
#-----------------------------------------------------------------------------------------
sub init_perpetrators{ @PERPS = (shuffle 1..&NUM_CRIMS)[0..&NUM_PERPS-1]; }
#-----------------------------------------------------------------------------------------
# Initialize a new subset of criminals
#-----------------------------------------------------------------------------------------
sub init_criminals{
  do{
    @CRIMS = (shuffle 1..&NUM_CRIMS)[0..&CRIMS_DISP-1];
    $PERPS_DISP = intersection(\@CRIMS,\@PERPS);
  }while($PERPS_DISP > &MAX_PERPS_DISP);
  set_display(\@CRIMS, &IMG_LNUP);
  set_dialog($PERP_TEXT[$PERPS_DISP], &TXT_NORM);
}
#-----------------------------------------------------------------------------------------
# Find the intersection of two lists
#-----------------------------------------------------------------------------------------
sub intersection{
  my $a = shift; my $b = shift; my @isect = ();
  foreach my $e (@{$a}){ push(@isect, $e) if $e ~~ @{$b}; }
  return @isect;
}
#-----------------------------------------------------------------------------------------
# Pause player turn
#-----------------------------------------------------------------------------------------
sub pause_turn{
  my $sec = shift;
  foreach my $btn ($turnFrame->children){ $btn->configure(-state => 'disabled'); }
  $mainWindow->update; sleep($sec);
  foreach my $btn ($turnFrame->children){ $btn->configure(-state => 'normal'); }
}
#-----------------------------------------------------------------------------------------
# Validate criminal selection
#-----------------------------------------------------------------------------------------
sub validate_select{
  if((reduce {$a + $b} @SELECTED) eq &NUM_PERPS){
    for(my $i = 0; $i < @SELECTED; $i++){
      if(!$SELECTED[$i]){ $CRIM_CHKBTN[$i]->configure(-state => 'disabled'); }
    }
    $submitBtn->configure(-state => 'normal');
  }else{
    foreach my $chkbtn (@CRIM_CHKBTN){ $chkbtn->configure(-state => 'normal'); }
    $submitBtn->configure(-state => 'disabled');
  }
}
#-----------------------------------------------------------------------------------------
# Submit criminal selection
#-----------------------------------------------------------------------------------------
sub submit_select{
  my @selectedCriminals;
  for(my $i = 0; $i < @SELECTED; $i++){
    if($SELECTED[$i]){ push @selectedCriminals, $i+1; }
  }
  set_page(&PG_TURNS);
  if(intersection(\@selectedCriminals,\@PERPS) == &NUM_PERPS){
    set_page(&PG_GMWON);
  }else{
    my $str = "Player $CURR_PLAYER chose incorrectly! Player $CURR_PLAYER lost!";
    set_dialog($str, &TXT_NORM);
    set_player_state($CURR_PLAYER, &DISABLED);
    $REM_PLAYERS--;
    pause_turn(2);
    pass();
  }
}
#-----------------------------------------------------------------------------------------
# Pass turn to next player
#-----------------------------------------------------------------------------------------
sub pass{
  if($REM_PLAYERS == 0){
    set_page(&PG_GMLST);
  }else{
    unless($PLAYERS{$CURR_PLAYER}{'state'} eq &DISABLED){
      set_player_state($CURR_PLAYER, &INACTIVE);
    }
    do{
      $CURR_PLAYER++;
      if($CURR_PLAYER > keys %PLAYERS){
        $CURR_PLAYER = 1;
        init_criminals();
      }
    }while($PLAYERS{$CURR_PLAYER}{'state'} eq &DISABLED);
    set_player_state($CURR_PLAYER, &ACTIVE);
  }
}
##########################################################################################

## ABOUT AND GAME INSTRUCTIONS ###########################################################
sub show_about{
  my $about = $mainWindow->Toplevel(-title => 'About');
  my $text = $about->Scrolled('ROText',
    -scrollbars => 'e', -wrap => 'word', -width => 80, -height => 20,
    -font => ['verdana','10','normal'], -setgrid => 1
  )->pack(-fill => 'both', -expand => 1);
  my $about_str = <<'EOAbout';

This game was developed for ITCS 4102/5102 - Programming Languages.

Authors:
  Brandon Beckwith, Bryson Roland, Haely Pratt

Credits:
  Game images are modified from vectors created by
  <URL:https://www.vecteezy.com/members/visionheldup>, which can be downloaded from 
  <URL:https://www.vecteezy.com/vector-art/119207-mugshot-vector-people-two>.

Version:
  10.15.2017
EOAbout
  
  $text->insert('end', $about_str);
}

sub show_instr{
  my $instr = $mainWindow->Toplevel(-title => 'How to Play');
  my $text = $instr->Scrolled('ROText',
    -scrollbars => 'e', -wrap => 'word', -width => 80, -height => 20,
    -font => ['verdana','10','normal'], -setgrid => 1
  )->pack(-fill => 'both', -expand => 1);
  
  $text->tagConfigure('title', -font => ['verdana','12','bold']);
  
  my $instr_str = <<'EOInstr';


Three-Of-A-Crime is a logic game for up to three players. The goal of the game is to identify the three perpetrators of a crime from a set of seven criminals. During each round, the computer will display three randomly selected criminals and tell the players how many of these criminals are perpetrators, but not which. Up to two of the displayed criminals may be perpetrators. Players will use logic to deduce which criminals are the perpetrators.


Each player may choose to guess which criminals are the perpetrators or pass to the next player. Once all players have taken a turn (either by guessing incorrectly or passing), a new set of criminals will be displayed. If a player chooses to identify the perpetrators and guesses incorrectly, that player is out of the game.


The game continues until a player chooses correctly, or until all players have chosen incorrectly.
EOInstr
  # Make the paragraphs into one long line
  $instr_str =~ s/\n(?!\n)/ /g;
  $text->insert('end', "Instructions\n", 'title');
  $text->insert('end', $instr_str);
}
##########################################################################################