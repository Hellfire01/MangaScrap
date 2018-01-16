#!/usr/bin/env bash

echo "ALTER TABLE Download ADD loop_on_todo VARCHAR(5);
.exit
" | sqlite3 ~/.MangaScrap/db/params.db

ruby ./../MangaScrap.rb param set lt true
ruby ../tools/mangafox_me_to_la.rb
echo ""
echo "done"
echo ""
