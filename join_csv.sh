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
output_file=${join_file_prefix}_combined.csv
source_hashfile=${join_file_prefix}.csv.sha1
dest_hashfile=${join_file_prefix}_combined.sha1

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

[[ $debug = true ]] && echo -e "\nopenssl dgst -sha1 $output_file > $dest_hashfile"
openssl dgst -sha1 $output_file > $dest_hashfile

# compare hash files

[[ ! -f $source_hashfile ]] && echo "$source_hashfile doesn't exist...exiting" && exit

# compare hashes'
source_hash=$(awk '{print $NF}' $source_hashfile)
dest_hash=$(awk '{print $NF}' $dest_hashfile)

[[ $debug = true ]] && echo -e "\nsource hash: $source_hash\ndest hash:   $dest_hash"

if [[ $source_hash == $dest_hash ]]; then
    echo "success: source and dest hashes match"
else
    echo "error: source and dest hashes don't match....exiting"
    echo -e "\nwrote to $output_file"
    exit 1
fi

[[ $debug = true ]] && echo -e "\nremoving $join_file_prefix split files"
for split_file in $join_filenames; do
    #[[ $debug = true ]] && echo "rm -f $split_file"
    rm -f $split_file
done

[[ $debug = true ]] && echo "removing hash files: $source_hashfile $dest_hashfile"
rm -f $source_hashfile $dest_hashfile

echo -e "\nwrote to $output_file"
