sync:
	fd --hidden --max-depth 4 -t f --exclude=.git | entr rsync --exclude-from=install/standard-exclude.txt -av . ~