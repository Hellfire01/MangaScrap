### versions :

0.1.0 : alpha with database, manga download and and manga update on mangafox<br />
0.1.1 : small debug to avoid manga duplicates in database<br />
0.1.2 : better code factorisation and better redirection detection<br />
0.1.3 : MangaScrap now deletes the .txt files generated after an error<br />
0.1.4 : MangaScrap can now take a file with manga names as an argument<br />
0.1.5 : better management of exceptions due to connection loss<br />

###### Warning : the database changes and is not compatible with the previous versions<br />

0.2.0 : Changed database ( added data to manga, but not yet used ) + permanent parameters management<br />
0.2.1 : small bug correction<br />
0.2.2 : changed info display for update<br />
0.2.3 : corrected error on database due to the 0.2.0 update<br />

###### Warning : the database changes and is not compatible with the previous versions<br />

0.3.0 : Changed the database, MangaScrap now fully manages Volumes, added GemFile<br />
0.3.1 : small bug correction + added a description file to each manga<br />
0.3.2 : corrected a bug that sometimes occured when trying to download the cover<br />
0.3.3 : bug fix<br />
0.3.4 : more bug fix<br />
0.3.5 : more bug fix<br />

###### Warning : the database changes and is not compatible with the previous versions<br />

0.4.0 : Changed the database ( much less tables ), fixed a bug where the wrong link whas used for chapter update<br />
0.4.1 : bug fixes + prevented insertion of the same page multiple times in the database<br />
0.4.2 : bug fixes + general stability increase<br />
0.4.3 : stability and optimisation<br />
0.4.4 : optimisation and code cleaning<br />

###### Warning : the manga database what moved ( new path is DB/manga.db ), move the file if you wish to keep all your traces
###### Warning : the parameters where reset ( new db file and more options )

0.5.0 : Changed the code architecture to fix a few bugs and make the code easier to update and maintain + added a few parameters options and getting ready for multiple sites<br />
0.5.1 : bug fixes + updated the help option<br />
0.5.2 : bug fixes<br />
0.5.3 : finished debugging the link generator and the data extractor<br />
0.5.4 : bug fixes + optimisation : it is now possible to set the bs and the fs sleep at 0.2 ( instead of 0.25 and 0.5 )<br />
0.5.5 : fixed a bad link generation if a chapter in the todo database whas a float and not an int<br />



0.6.0 : added the -redl option + re-enabled the -dl opion + bub fixes<br />
0.6.1 : the manga list files can now have empty lines and comments<br />
0.6.2 : changed display to show chapter download progression<br />
0.6.3 : exception handling test<br />
0.6.4 : increased performances of roughly 50% by limiting the number of interactions with the targeted server<br />
