sampleobjects = buffer_manager.o file_manager.o tree.o main.o

main : $(sampleobjects)
	     g++ -std=c++11 -o kdbtree $(sampleobjects)

main.o : main.cpp
	g++ -std=c++11 -c main.cpp

buffer_manager.o : buffer_manager.cpp
	g++ -std=c++11 -c buffer_manager.cpp

file_manager.o : file_manager.cpp
	g++ -std=c++11 -c file_manager.cpp


tree.o : tree.cpp
	g++ -std=c++11 -c tree.cpp

clean :
	rm -f *.o
	rm -f kdbtree
	rm -f kdb.txt
