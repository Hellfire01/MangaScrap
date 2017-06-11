#!/usr/bin/env bash
# 1 - Delete your params DB ( please note all important information such as mangapath before doing so if you have changed any parameter )
rm ~/.MangaScrap/db/params.db

# 2 - Update your manga.db
echo "ALTER TABLE manga_list ADD html_name TEXT;
ALTER TABLE manga_list ADD alternative_names NTEXT;
ALTER TABLE manga_list ADD rank int;
ALTER TABLE manga_list ADD rating int;
ALTER TABLE manga_list ADD rating_max int;
.exit;
" | sqlite3 ~/.MangaScrap/db/manga.db

# 3 - install new dependency
sudo gem install colorize

# 4 - Update your database and the site
./MangaScrap -l > tmp_manga_list.txt
./MangaScrap -da -f tmp_manga_list.txt
rm tmp_manga_list.txt
