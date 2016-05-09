MangaScrapp is a ruby programm that allows you to download your favorite mangas
on your computer automaticaly !
The programm has a batabase that allows it to keep track of the downloaded mangas
to update them when ever a new chapter is published

versions :

0.1.0 : alpha with database and manga download and update on mangafox
0.1.1 : small debug to avoid manga duplicates in database
0.1.2 : better code factorisation and better redirection detection
0.1.3 : MangaScrapp now deletes the .txt files generated after an error
0.1.4 : MangaScrapp can now take a file with manga names as an argument
0.1.5 : better management of exceptions due to connection lost

gems required :
- nokogiri
- sqlite3

notes :
./MangaScrapp -h
    L=> displays instructions
The programm will download all mangas in Documents/mangas/
( it will create the mangas folder automaticaly )
