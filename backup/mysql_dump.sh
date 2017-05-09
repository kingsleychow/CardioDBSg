#Dump cardiodbs_devel_test schema (No FK)
mysqldump -h 127.0.0.1 -P 3320 -p -uroot --no-data cardiodbs_devel_test -R > mysqldump_20140707_CardioDBSg_devel_InnoDB_NoFK.sql

#Load cardiodbs_devel_test schema into cardiodbs_devel (TO DEVELOP FK)
mysql -uroot -p -P 3320 -h 127.0.0.1 -Dcardiodbs_devel < mysqldump_20140707_CardioDBSg_devel_InnoDB_NoFK.sql

#Dump cardiodbs_devel schema (With FK)
mysqldump -h 127.0.0.1 -P 3320 -p -uroot --no-data cardiodbs_devel -R > mysqldump_20140707_CardioDBSg_devel_InnoDB_FK.sql

#Load cardiodbs_devel schema into cardiodbs_devel_test_fk (TO TRY UPLOAD SCRIPT WITH FK)
mysql -uroot -p -P 3320 -h 127.0.0.1 -Dcardiodbs_devel_test_fk < mysqldump_20140707_CardioDBSg_devel_InnoDB_FK.sql
