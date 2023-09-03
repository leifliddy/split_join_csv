#!/bin/bash
#set -x

usage() {
cat << EOF
Usage: join_csv [OPTION]... [PREFIX]...
Join files matching PREFIX*.csv into a single csv file

  -d        show debug output
  -h        display this help and exit
  -p        specify file prefix to use (default prefix is bar)
EOF

exit 0
}

while getopts dhp: arg
do
    case "${arg}" in
        d) debug=true;;
        h) help=true;;
        p) join_file_prefix=${OPTARG};;
    esac
done

shift $((OPTIND-1))

[[  $help = true ]] && usage

# specify default values (used if variables are not set)
: ${join_file_prefix:='bar'}
unset header
date=$(date +%Y%m%d_%S)
output_file=${join_file_prefix}_$date.csv
source_hashfile=${join_file_prefix}.md5
dest_hashfile=${join_file_prefix}_$date.md5

[[ $debug = true ]] && echo "output_file is $output_file"
[[ $debug = true ]] && echo "join_file_prefix: $join_file_prefix"

join_filenames=$(ls | grep -E "^$join_file_prefix[0-9]+\.csv$" | sort -n)

[[ -z "$join_filenames" ]] && echo -e "\nthere are no files matching ${join_file_prefix}*.csv...exiting" && exit 1

for csv_file in $join_filenames; do
    [[ $debug = true ]] && [[ -z $header ]] && echo "extracting header line from $csv_file and writing to $output_file"
    [[ -z $header ]] && header=$(head -1 $csv_file) && echo $header > $output_file
    [[ $debug = true ]] && echo "tail -n +2 $csv_file >> $output_file"
    tail -n +2 $csv_file >> $output_file
done

[[ $debug = true ]] && echo "md5sum $output_file > $dest_hashfile"
md5sum $output_file > $dest_hashfile

# compare hash files

[[ ! -f $source_hashfile ]] && echo "$source_hashfile doesn't exist...exiting" && exit

# compare hashes'
source_hash=$(cat $source_hashfile | awk '{print $1}')
dest_hash=$(cat $dest_hashfile | awk '{print $1}')

[[ $debug = true ]] && echo -e "\nsource hash: $source_hash\ndest hash:   $dest_hash"

if [[ $source_hash == $dest_hash ]]; then
    match=true
    echo "success:     source and dest hashes match"
else
    echo "error:       source and dest hashes don't match....exiting"
    echo -e "\nwrote to $output_file"
    exit 1
fi

[[ $debug = true ]] && echo "removing $join_file_prefix split files"
for split_file in $join_filenames; do
    [[ $debug = true ]] && echo "rm -f $split_file"
    rm -f $split_file
done

echo -e "\nwrote to $output_file"