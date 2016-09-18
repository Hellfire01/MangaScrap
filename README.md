## MangaScrap

MangaScrap is a ruby programm that allows you to download your favorite mangas on your computer automaticaly !<br />
The programm has a batabase that allows it to keep track of the downloaded mangas to update them when ever a new chapter is published<br />
MangaScrap is only compatiple with mangafox at the moment but it is planned to be compatible with others sutch as mangareader and light novels<br />

##### notes :
./MangaScrap -h => displays instructions<br />
The programm will download all mangas in Documents/mangas/ by default<br />
( it will create the mangas folder automaticaly )<br />

### Changelog :

0.8.0 : added prototype html ( it needs tweaking ) : it is now possible to read the mangas with the web browser + added the -h --html option<br />
<br />

0.7.6 : activated the "delete diff" option<br />
0.7.5 : bug fixes<br />
0.7.4 : better descriptions in the description.txt files<br />
0.7.3 : code cleaning + small optimisation<br />
0.7.2 : code cleaning + better exception management<br />
0.7.1 : code cleaning + optimisations<br />
0.7.0 : added the ce ( catch exception ) option + added the option -da --data to download data + placed covers in manga directory + multiple tweaks and optimisations<br />

###### Warning : the database changes and is not compatible with the previous versions<br />Please look at the file migration/0.6.x_to_0.7.x.txt<br />

0.6.7 : changed exception handling<br />
0.6.6 : deleted unused file<br />
0.6.5 : code cleaning ( improved the quality of the code )<br />
0.6.4 : increased performances of roughly 50% by limiting the number of interactions with the targeted server<br />
0.6.3 : exception handling test<br />
0.6.2 : changed display to show chapter download progression<br />
0.6.1 : the manga list files can now have empty lines and comments<br />
0.6.0 : added the -redl option + re-enabled the -dl opion + bug fixes<br />
<br />

0.5.5 : fixed a bad link generation if a chapter in the todo database whas a float and not an int<br />
0.5.4 : bug fixes + optimisation : it is now possible to set the bs and the fs sleep at 0.2 ( instead of 0.25 and 0.5 )<br />
0.5.3 : finished debugging the link generator and the data extractor<br />
0.5.2 : bug fixes<br />
0.5.1 : bug fixes + updated the help option<br />
0.5.0 : Changed the code architecture to fix a few bugs and make the code easier to update and maintain + added a few parameters options and getting ready for multiple sites<br />

###### Warning : the manga database what moved ( new path is DB/manga.db ), move the file if you wish to keep all your tracesWarning : the parameters where reset ( new db file and more options )

0.4.4 : optimisation and code cleaning<br />
0.4.3 : stability and optimisation<br />
0.4.2 : bug fixes + general stability increase<br />
0.4.1 : bug fixes + prevented insertion of the same page multiple times in the database<br />
0.4.0 : Changed the database ( much less tables ), fixed a bug where the wrong link whas used for chapter update<br />

###### Warning : the database changes and is not compatible with the previous versions<br />

0.3.5 : more bug fix<br />
0.3.4 : more bug fix<br />
0.3.3 : bug fix<br />
0.3.2 : corrected a bug that sometimes occured when trying to download the cover<br />
0.3.1 : small bug correction + added a description file to each manga<br />
0.3.0 : Changed the database, MangaScrap now fully manages Volumes, added GemFile<br />

###### Warning : the database changes and is not compatible with the previous versions<br />

0.2.3 : corrected error on database due to the 0.2.0 update<br />
0.2.2 : changed info display for update<br />
0.2.1 : small bug correction<br />
0.2.0 : Changed database ( added data to manga, but not yet used ) + permanent parameters management<br />

###### Warning : the database changes and is not compatible with the previous versions<br />

0.1.5 : better management of exceptions due to connection loss<br />
0.1.4 : MangaScrap can now take a file with manga names as an argument<br />
0.1.3 : MangaScrap now deletes the .txt files generated after an error<br />
0.1.2 : better code factorisation and better redirection detection<br />
0.1.1 : small debug to avoid manga duplicates in database<br />
0.1.0 : alpha with database, manga download and and manga update on mangafox<br />
