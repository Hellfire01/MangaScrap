## MangaScrap

MangaScrap is a Ruby based program that will allow you to download your mangas and save them on your computer<br />
It posses a database that allows it to know what chapters where not downloaded yet<br />
Unlike other manga downloaders, it creates a local website on your computer allowing you to browse your mangas offline<br />
<br />
	
#### basic usage :

./MangaScrap add link [link]<br />
will add a manga to follow to the database<br />
<br />
./MangaScrap<br />
will update all mangas within the database<br />
<br />
./MangaScrap download link [link]<br />
Will add the manga to the database and then download it<br />
<br />

#### configuration
MangaScrap possesses configurable parameters witch will allow you to configure the way it work to fit your needs<br />
<br />
./MangaScrap params list<br />
shows all the parameters and there values<br />
<br />
./MangaScrap params set [param] [value]<br />
allow you to change a parameter<br />
<br />

#### notes :
./MangaScrap help<br />
displays instructions<br />
<br />
The program will download all mangas in ~/Documents/mangas/ by default<br />
( should the path not exist, it will be created automatically )<br />
Currently MangaScrap only manages mangafox but it is planned to do much more in the near future<br />
<br />
