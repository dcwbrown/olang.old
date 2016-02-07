if $(command -v sudo 2>nul); then
  export install="sudo make install"
else
  export install="make install"
fi
echo Install command is: ${install}
make clean 
make 
make setnew 
make clean 
make
make setnew
${install}
make library
${install}
