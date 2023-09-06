**split_join_csv**
```
Usage: split_csv [OPTION]... [CSV_FILE]...
Split CSV_FILE into smaller files while maintaining csv header in each split file

  -d        show debug output
  -h        display this help and exit
  -l        specify number of lines to split file by (default value is 500)
  -p        specify file prefix to use with split (default prefix is bar)
```

**join_csv.sh**
```
Join files matching PREFIX*.csv into a single csv file

  -d        show debug output
  -h        display this help and exit
  -p        specify file prefix to use (default prefix is bar)
```
  
**split file by 1000 lines**
```
[leif.liddy@black ~]$ ./split_csv_with_headers.sh -l 1000 file.csv
```

**join file**
```
[leif.liddy@black ~]$ ./join_csv.sh file.csv 
success: source and dest hashes match

wrote to bar_20230906_27.csv
```
