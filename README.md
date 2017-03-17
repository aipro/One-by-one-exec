# One-by-one-exec

A small script for sequential execution of quantum chemical calculations on VASP

The script is placed in the ~/.bash_functions directory,  and the following lines are appended to the ~/.bashrc file:

<pre>
if [ -d ~/.bash_functions ]; then
  for file in ~/.bash_functions/*.sh; do
    . "$file"
  done
fi
</pre>
