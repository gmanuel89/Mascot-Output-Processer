# MASCOT OUTPUT PROCESSER

***

## Programming language
R: The Comprehensive R Archive Network

https://www.r-project.org/

***

## Platform(s) tested
Ubuntu Linux 16.04 x64 - R 3.4.1

Fedora Linux 26 x64 - R 3.4.1

Microsoft Windows 7 x64 - R 3.4.1

Microsoft Windows 10 x64 - R 3.4.1

***

## Scope of the software
The software imports the output csv file yielded by Mascot. It automatically discards all the information that Mascot adds and keeps only the matrix for the analysis.

The software at first discards the peptides which do not overpass the identity and homology threshold value (after establishing the identity or the homology according to the value). Afterwards, it splits the modified peptides from the unmodified ones and then performs duplicate removal according to protein name, peptide sequence, type of modification and modification position, keeping only the peptides with the highest score. For the modified peptides, it generates also a list of modified sequences, discarding the redundant information and keeping only the unique sequences (it discards the sequences which are listed more than one time due to different modification positions).

Finally the software identifies the true modified peptides, by matching the modified peptides in the modified proteome with the modified peptides in the unmodified proteome, in such a way that only the peptides that underwent modification due to the application of the protocol are kept.


***

## Type of data and its organisation

#### Type of data
The software reads a CSV file exported from Mascot.


#### Organisation of the data
It is not necessary to manually remove the additional information from the Mascot CSV file, because the software automatically discards it by keeping only the information needed (in the form of a matrix).


#### Output data
The software generates a folder named "MASCOT" followed by an incremental number, in which all the output files are placed.

The results are organised as follows:
* A copy of the original file
* A file named "Non-modified peptides" with the peptides that do not carry any modification.
* A file named "Modified peptides" with the peptides that carry at least one modification.
* A file named "Modified peptides (unique sequences)" with the peptides that carry at least one modification, after discarding the duplicates (according to the peptide sequence) by keeping only the peptide sequence with the highest score.

***
