#!/usr/bin/env bash
echo "ALTER TABLE manga_trace ADD date VARCHAR(32);
ALTER TABLE manga_trace ADD nb_pages INTEGER;
ALTER TABLE manga_todo ADD date VARCHAR(32);
ALTER TABLE manga_list ADD date VARCHAR(32);
ALTER TABLE manga_list ADD no_auto_updates BOOL;
ALTER TABLE manga_list ADD ignore_todo BOOL;
.exit
" | sqlite3 ~/.MangaScrap/db/manga.db
