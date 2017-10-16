# Three Of A Crime

Three-Of-A-Crime is a logic game for up to three players. The goal of the game is to identify the three perpetrators of a crime from a set of seven criminals. During each round of the game, the computer will display three criminals and tell the players how many of these criminals are perpetrators, but not which. Up to two of the displayed criminals may be perpetrators. Each player may choose to guess which criminals are the perpetrators or pass to the next player. Once all players have taken a turn, a new set of three criminals is displayed. If a player chooses to identify the perpetrators and picks incorrectly, the player is out of the game. The game continues until a player chooses correctly, or until all players have guessed incorrectly.

## Getting Started

This implementation is built in Perl (v5.12.3 built for MSWin32-x86-multi-thread). To run the game, an equivalent version of Perl must be installed.

### Dependencies

Before running the game, it is necessary to install the Tk module. The **recommended** way to do this is via the Perl Package Manager (PPM). In a terminal window, run the command:

```
ppm install Tk
```

Other ways to install the module are found below. These methods are much slower and much less reliable than via PPM.

**CPAN**

```
cpan App::cpanminus
cpanm Module::Tk
```

**Padre IDE**

Navigate to Run > Run Command. Enter the following command in the dialog box and click 'Ok':

```
cpan Tk
```

### Running the Script

Once the Tk module is installed, the game can be run from the terminal with

```
perl ThreeOfACrime.pl
```

## Credits

### Image Credit
Game images were created using modified vectors created by [visionheldup](https://www.vecteezy.com/members/visionheldup), which can be downloaded from [Vecteezy](https://www.vecteezy.com/vector-art/119207-mugshot-vector-people-two).

### Authors
* Brandon Beckwith
* Bryson Roland
* Haely Pratt [primary]