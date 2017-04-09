## MangaScrap

MangaScrap is a Ruby based program that will allow you to download your mangas and save them on your computer<br />
It posses a database that allows it to know what chapters where not downloaded yet<br />
Unlike other manga downloaders, it creates a local website on your computer allowing you to browse your mangas offline<br />

### basic usage :

How to add and download a manga<br />

- `./MangaScrap add link [link]`<br />
Will add a manga to follow to the database
- `./MangaScrap`<br />
Will update all mangas within the database
- `./MangaScrap download link [link]`<br />
Will add the manga to the database and then download it

### configuration

MangaScrap has configurable parameters witch will allow you to configure the way it work to fit your needs<br />
- `./MangaScrap params list`<br />
Shows all the parameters and there values
- `./MangaScrap params set [param] [value]`<br />
Allow you to change a parameter<br />

### notes :

- `./MangaScrap help`<br />
Displays instructions<br />
- The program will download all mangas in ~/Documents/mangas/ by default ( should the path not exist, it will be created automatically )<br />
- Currently MangaScrap only manages mangafox but it is planned to do much more in the near future<br />
- The dev branch of MangaScrap is on [gitlab](https://gitlab.com/Hellfire01/MangaScrapp)

### API :

If you wish to add instructions / a gui / ... to MangaScrap, please check [here](sources/api/README.md).
<br />
