#include <bits/stdc++.h>
#include "file_manager.h"
#include "errors.h"
using namespace std;

class KDB_Tree{

    public:
        int root_id=-1;    //NULL
        FileHandler fh;
        string fname;
        int dim;
        ofstream fout;

        map<int,set<int>>point_pages;
        KDB_Tree(int d,string fname,FileHandler fh); //,ofstream gout);
        bool is_point_node(int pg_num);
        bool is_in_reg(int ind,char* arr,vector<int> &point);
        bool check_if_equals(char *data,int start,vector<int> &point);
        int get_region_id(int pg_num,vector<int> &point);
        int get_EOP(int pg_num);
        void Point_Query(vector<int> &point);
        void insert(vector<int> &point);
        pair<int,int> Node_Split_ptnode(int nid,int split_ele,int split_dim,vector<int> &pt);
        pair<int,int> Node_Split_rgnode(int nid,int split_ele,int split_dim,vector<int> &pt);

        void reorganize_ptnode(int nid,vector<int> &pt);
        void reorganize_rgnode(int nid,vector<int>&rgn);    
        void Range_Query(vector<int> &range_array);

        void get_data_node(int id);
        void close_file();

};