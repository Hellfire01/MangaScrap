### Changelog :

0.12.4 : stability fix : corrected an error with the instruction parsing<br />
0.12.3 : stability fix : fixed an issue with the instrction parser + an issue where MangaScrap would download 0 pages for a chapter<br />
0.12.2 : stability fix : fixed an issue when setting a param with a number<br />
0.12.1 : stability increase + added the instruction "managed" to display the compatible websites<br />
0.12.0 : huge optimisation : download is close to twice as fast + new management of the parameters + more understandable errors<br />

###### Warning : the params database is not compatible<br />Please look at the file migration/0.11.x_to_0.12.x.txt<br />

0.11.5 : lots of refactoring + bug fixes + optimisation ( the updates are now faster ) + updated the API + updated the help instruction + added management of 2 new sites : mangareader and pandamanga<br />
0.11.4 : added an API and instructions on how to use it, it will be used for the GUI<br />
0.11.3 : small bug fixes + implemented scripts to allow faster migrations / updates<br />
0.11.2 : implemented the 'data' instruction<br />
0.11.1 : implemented the 'details' and 'fast-update' instructions + debugged the delete-diff + the directory system should be compatible with Windows<br />
0.11.0 : the argument management completely changed and is now much easier to use ( added instructions and a new way to use MangaScrap ) + the html was heavily optimised + added a management of bad gem loads + changed the way mangas are identified to allow the scrap of multiple sites<br />

###### Warning : the database changes and is not compatible with the previous versions<br />Please look at the file migration/0.10.x_to_0.11.x.txt<br />

0.10.2 : added a few clickable elements on each chapter and a reading progression<br />
0.10.1 : added arrow control on chapter pages, it is now possible to go to the next / previous page with left and right arrows<br />
0.10.0 : big performance improvement, added JS to the HTML, many additions to the database to display more information and text coloration<br />

###### Warning : the database changes and is not compatible with the previous versions<br />Please look at the file migration/0.9.x_to_0.10.x.txt<br />

0.9.6 : drastically impoved the terminal display, it is now far easier to read<br />
0.9.5 : added instructions to install the dependencies on debian<br />
0.9.4 : fixed an error preventing the program to be launched correctly the very first time<br />
0.9.3 : fixed a few bugs on the html generation<br />
0.9.2 : reimplemented the delete diff, fixed a db error when trying to remove certain chapters from the traces and optimised the usage of the params<br />
0.9.1 : improved the html : it is now fully portable and can be copied ( with the pictures ) to any destination and remain readable / usable<br />
0.9.0 : implemented 3 new options ( params ) for the html management + added the hti option ( shell )<br />

###### Warning : the database changes and is not compatible with the previous versions<br />Please look at the file migration/0.8.x_to_0.9.x.txt<br />

0.8.4 : fixed the -redl option<br />
0.8.3 : refactoring + optimisations + added the -df an -uf options<br />
0.8.2 : corrections de code + optimisations<br />
0.8.1 : code factoring + optimisations<br />
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
