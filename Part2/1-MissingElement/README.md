# Find the Missing Element

Given an array of non-negative integers, a second array is formed by shuffling the elements of the first array and deleting a random element. This program determines which element is missing in the second array.

## Getting Started

This implementation is built in Perl 5. To run the game, an equivalent version of Perl must be installed.

### Running the Script

To run the script using the default array, run the following command in a terminal window.

```
perl missing.pl
```

This will produce output similar to the following.

```
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
7 0 16 8 4 2 3 12 6 11 1 13 9 15 10 5
Missing: 14
```

To run the script using a user-defined array, run the command `perl missing.pl` followed by the list of array elements with each element separated by a space. An example, along with its output, is shown below.

```
perl missing.pl 4 1 0 2 9 6 8 7 5 3

4 1 0 2 9 6 8 7 5 3
3 6 0 9 2 1 5 8 4
Missing: 7
```

## Authors

* [Brandon Beckwith](https://github.com/bbeckwi2)
* Bryson Roland
* [Haely Pratt](https://github.com/haelypratt)