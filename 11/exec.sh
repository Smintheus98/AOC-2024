nim c -d:danger --exceptions:setjmp -d:lto --passC:"-fopenmp -O3" --passL:"-fopenmp -O3" b_rec.nim  &&  time ./b_rec -i example.in
