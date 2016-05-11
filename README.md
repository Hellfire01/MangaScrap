## MangaScrapp

MangaScrapp is a ruby programm that allows you to download your favorite mangas on your computer automaticaly !<br />
The programm has a batabase that allows it to keep track of the downloaded mangas to update them when ever a new chapter is published<br />
MangaScrapp is only compatiple with mangafox at the moment but it is planned to be copatible with others sutch as mangareader<br />

#### versions :

0.1.0 : alpha with database, manga download and and manga update on mangafox<br />
0.1.1 : small debug to avoid manga duplicates in database<br />
0.1.2 : better code factorisation and better redirection detection<br />
0.1.3 : MangaScrapp now deletes the .txt files generated after an error<br />
0.1.4 : MangaScrapp can now take a file with manga names as an argument<br />
0.1.5 : better management of exceptions due to connection loss<br />

0.2.0 : Changed database ( added data to manga, but not yet used ) + permanent parameters management<br />
0.2.1 : small bug correction
0.2.2 : changed info display for update

##### gems required :
- nokogiri
- sqlite3

##### notes :
./MangaScrapp -h => displays instructions<br />
The programm will download all mangas in Documents/mangas/<br />
( it will create the mangas folder automaticaly )<br />
