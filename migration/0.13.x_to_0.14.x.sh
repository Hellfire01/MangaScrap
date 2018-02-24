#!/usr/bin/env bash

echo "ALTER TABLE Download ADD loop_on_todo_times INT;
.exit
" | sqlite3 ~/.MangaScrap/db/params.db

ruby ./../MangaScrap.rb param set ltt 5

ruby ../tools/mangafox_to_fanfox.rb

echo ""
echo "done"
echo ""
