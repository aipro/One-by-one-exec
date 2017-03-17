function __orca {
  if [ "$1x" == 'x' ]; then
	echo "Usage: orca <directory or input_file[.inp]> [new]"
	return 1
  else
	NL=$'\n'
	directory=$(dirname "$1")
	#
	# '~' has to be substituted by ${HOME}
	[[ ${directory} == '~' ]] && directory="${HOME}${directory:1}"
    if [[ -d $1 ]]; then
	# "$1 is a directory" 
		#  count of files
		files=$(find $1 -type f -name "*.inp" -print| wc -l)
		if [ "$files" == '1' ]; then
			eval "$FUNCNAME $(find $1 -type f -name '*.inp') $2"
			return 0
		else
			files=0
			info=""
			script="source ~/.bash_functions/_orca.sh;"
			for file in $(find $1 -type f -name "*.inp"); do
 				script+="$FUNCNAME $file $2;wait;"
				info+="${NL}   orca $file $2"
				((files++))
			done
		fi
		echo "$files Files found:$info"
		eval "($script)&"
		#2>/dev/null 1>/dev/null &
		return 0
	else
		# filename with extension, extension
		filename=$(basename "$1")
		extension="${filename##*.}"
		if [ $extension == $filename ]; then
			# Input file name is entered without extension
			extension='inp'
		fi
		if [ $extension == 'inp' ]; then
			# filename without extension
			filename="${filename%.*}"
			# Is exist the data file?
			if [[ -f "$directory/$filename.$extension" ]]; then
				# Change directory if it isn't current
				if [[ ${directory} != '.' ]]; then 
					cd $directory 2>/dev/null 1>/dev/null
				fi
				#Remove old calculation files
				if [ "$2" == 'new' ]; then
					find . -maxdepth 1 -type f -name "$filename.*" -and -not -name "$filename.inp" -exec rm -f {} \; 
				fi
				#Execute
	ORCA=/usr/local/orca_3_0_3_linux_x86-64
	MPI_RUN=$HOME/local/openmpi-1.6.5_gcc/bin
	MPI_LIB=$HOME/local/openmpi-1.6.5_gcc/lib
	PATH=$MPI_RUN:$PATH
	LD_LIBRARY_PATH=$MPI_LIB
	export PATH LD_LIBRARY_PATH
	nohup $ORCA/orca $filename.inp >& $filename.out&
				#  Back to start directory
				if [ "$directory" != '.' ]; then
					cd - 2>/dev/null 1>/dev/null 
				fi
			else
				if [ "$directory" == '.' ]; then 
					echo "ORCA Input file $filename.inp not found" 
				else 
					echo "ORCA Input file $directory/$filename.inp not found" 
				fi
		    fi
		else
			echo "Wrong ORCA Input file extension: $filename"
		fi
    fi
  fi
}

alias orcarm='rm -f *.{gbw,prop,tmp,engrad,opt,trj,xyz}'
alias orca='__orca'
