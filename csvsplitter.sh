#/bin/bash

SCRIPT=`basename ${BASH_SOURCE[0]}`

# default values
LINES_NUM=100
DIRECTORY_OUT="."

#Help function
function printHelp {
  echo \\n"Help documentation for ${SCRIPT}."\\n
  echo "Basic usage: $SCRIPT -f string -l number -d string"\\n
  echo "-f  REQUIRED - Sets the value for input filename."
  echo "-l  OPTIONAL - Sets the value for number of lines for splitting of input file. Default value is 100."
  echo "-d  OPTIONAL - Sets the value for output directory - use relative path! Default value is working (actual) directory."
  echo "-h  Displays this help message. No further functions are performed."\\n
  echo "Example: \\n $SCRIPT -f moje_oblibene.csv -l 100000 -d adresar_pro_dalsi_pokus"\\n
  echo "Note: Order of options doesn't matter."\\n
  exit 1
}

while getopts :f:l:d:h flag
do
    case "${flag}" in
        f) FILENAME=${OPTARG};;
        l) LINES_NUM=${OPTARG};;
        d) DIRECTORY_OUT=${OPTARG};;
    	h) HELP;;
    	\?) #unrecognized option - show help
      		echo \\n"Option -$OPTARG not allowed!"
      		printHelp;;
    esac
done


# check if input filename is not empty
if [[ "$FILENAME" == "" ]]; then
    echo "Input filename was not entered!"
    printHelp
fi

# check if output directory exists
if [[ "$DIRECTORY_OUT" == "." ]]; then
    echo "Output directory is actual working directory."
else
	# if output directory is not actual directory, 
	# check if directory exists
	if [[ -d $DIRECTORY_OUT ]]; then
		echo "Output direcotry exists"
	else
	 	mkdir $DIRECTORY_OUT
	 	[ -d $DIRECTORY_OUT ] || echo "Output directory cannot be created!"; printHelp
	fi
fi

echo "File $FILENAME will be splitted by $LINES_NUM lines"

# extract original filename & create pattern for chunk naming 
OUT_FILE_NAME=${FILENAME%%.*}
OUT_FILE_PATTERN=${OUT_FILE_NAME}_chunk_
	
# extract header to var
HEADER=$(head -1 $FILENAME)

# split files into chunks
tail -n +2 $FILENAME | split -l $LINES_NUM 	- $OUT_FILE_PATTERN

# add headers to all chunks and rename them to *.csv
for i in $OUT_FILE_PATTERN*; do
	CSV_FILENAME=$DIRECTORY_OUT/$i.csv
	echo "Storing data to $CSV_FILENAME"
    awk -vheader="$HEADER" 'NR==1{print header}1' "$i" > $CSV_FILENAME && rm "$i"
done
