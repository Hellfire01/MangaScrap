# MangaScrap's API

All of MangaScrap passes through the methods that are in the api directory<br />
Here you can use MangaScrap directly to ( example ) build your own GUI or your own instruction<br />
Please note that these methods are called from the argument parser witch is at  ./sources/instructions/Instructions_exec.rb
( you will have to add the call to your instruction there and follow the directions there )<br />

There are 4 files containing the API :
- _mangas.rb_<br />
Allows you to manipulate the mangas database ( add / update / download / ... )<br />
**methods**: add, update, download, data, clear, delete
- _oher.rb_<br />
contains any part of the API that could not be sorted as they are too small to justify having a file of their own<br />
**methods**: html
- _ouput.rb_<br />
Reading from the database<br />
**methods**: details, output, help and version
- _params_<br />
Configuring MangaScrap using it's parameters<br />
**methods**: get_params_list, set_param, reset_params

**Important** :<br />
To manipulate mangas, MangaScrap uses the Manga_Data class witch you can find here : ./sources/DB/Manga_data.rb.<br />
The class works by giving to it's constructor the name and site or the link and the calling the **resolve** method witch
will return true or false depending on if it could find / use the given information.
