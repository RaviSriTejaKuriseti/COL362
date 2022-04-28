#include "tree.h"
#include <bits/stdc++.h>
using namespace std;




int main(int argc, char* argv[]){
    //assert(argc>4);

    string input_file=argv[1];
    int dim=atoi(argv[2]);
    string out_file=argv[3];
    FileManager fm;
    FileHandler fh = fm.CreateFile("kdb.txt");
    //outstream gout;
    KDB_Tree kdb_tree(dim,out_file,fh); //,gout);
    ifstream fin;
    string key_word;
    fin.open(input_file);
    if(fin.is_open()){
        while(fin){
            fin>>key_word;
            if(fin.eof()){
                break;
            }
            if(key_word=="INSERT"){
                vector<int>vec(dim,0);
                for(int i=0;i<dim;i++){
                    fin>>vec[i];
                }
                kdb_tree.insert(vec);
                // kdb_tree.fh.FlushPages();
            }
            else if(key_word=="PQUERY"){
                vector<int>vec(dim,0);
                for(int i=0;i<dim;i++){
                    fin>>vec[i];
                }
                kdb_tree.Point_Query(vec);
                //kdb_tree.fh.FlushPages();
            }
            else if(key_word=="RQUERY"){
                vector<int>vec(2*dim,0);
                for(int i=0;i<2*dim;i++){
                    fin>>vec[i];
                }
                kdb_tree.Range_Query(vec);
            }

            fm.PrintBuffer();

        }
    }
    fin.close();
    kdb_tree.close_file();

    fm.CloseFile (fh);
	fm.DestroyFile ("kdb.txt");




}