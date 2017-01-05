#!/bin/bash

mackup backup

apm star --installed

# these files need to be manually copied to the new machine
pg_dumpall > ~/Desktop/postgres_backup
mysqldump -u root -p --all-databases > ~/Desktop/mysql_backup.sql
