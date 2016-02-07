if command -v "sudo"; then
  export install="sudo make install"
else
  export install="make install"
fi
make clean 
make 
make setnew 
make clean 
make
make setnew
${install}
make library
${install}
