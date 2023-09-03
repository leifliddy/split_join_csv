#!/bin/bash
#set -x

usage() {
cat << EOF
Usage: split_csv [OPTION]... [CSV_FILE]...
Split CSV_FILE into smaller files while maintaining header

  -d        show debug output
  -h        display this help and exit
  -l        specify number of lines to split file by (default value is 500)
  -p        specify file prefix to use with split (default prefix is bar)
EOF

exit 0
}

while getopts dhl:p: arg
do
    case "${arg}" in
        d) debug=true;;
        h) help=true;;
        l) line_split=${OPTARG};;
        p) split_file_prefix=${OPTARG};;
    esac
done

shift $((OPTIND-1))

[[ -z "$1" ]] || [[  $help = true ]] && usage
csv_file=$1
first_file=true

# specify default values (used if variables are not set)
: ${line_split:=500}
: ${split_file_prefix:='bar'}
hashfile=${split_file_prefix}.md5
md5sum $csv_file > $hashfile

[[ $debug = true ]] && echo "line_split: $line_split"
[[ $debug = true ]] && echo "split_file_prefix: $split_file_prefix"
[[ $debug = true ]] && echo "md5sum $csv_file > $hashfile"

split_csv_with_headers() {
    [[ $debug = true ]] && echo -e "\nrunning:\nsplit -d -l $line_split $csv_file --additional-suffix='.csv' $split_file_prefix"
    split -d -l $line_split "$csv_file" --additional-suffix='.csv' "$split_file_prefix"
    csv_header_line=$(head -1 "$csv_file")
    [[ $debug = true ]] && echo "csv_header_line is $csv_header_line"
    split_filenames=$(ls | grep -E "^$split_file_prefix[0-9]+\.csv$")

    for tmp_filename in $split_filenames; do
      [[ $first_file = true ]] && first_file=false && continue
      sed -i "1s/^/$csv_header_line\n/" $tmp_filename
    done
}

split_csv_with_headers
