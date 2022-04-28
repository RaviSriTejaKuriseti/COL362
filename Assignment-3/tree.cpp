#include "tree.h"
// #define INT_MIN -1000000
// #define INT_MAX 1000000



KDB_Tree::KDB_Tree(int d,string out_file,FileHandler fh){
   
    this->fh =fh;
    this->dim=d;
    this->fname=out_file;
    //this->fout=foutt;
    this->fout.open(this->fname);
	//cout << "File created " << endl;
}


//point_node:  pg_num,split_dim,node_type,node_parent,(point_loc,point)
//region_node: pg_num,split_dim,node_type,node_parent,(id,rmin,rmax)


bool KDB_Tree::is_point_node(int pg_num){
    char* data=this->fh.PageAt(pg_num).GetData();
    int typ;
    memcpy(&typ,&data[8],sizeof(int));
    return typ==1;
}


bool KDB_Tree::is_in_reg(int ind,char* arr,vector<int> &point){
    bool flag=true;
    for(int j=0;j<this->dim;j+=1){
        int pos=ind+4+8*j;
        int left;
        int right;
        memcpy(&left,&arr[pos],sizeof(int));
        memcpy(&right,&arr[pos+4],sizeof(int));
         
        flag=(flag && (left<=point[j] && point[j]<right));

    }

    return flag;
}


int KDB_Tree::get_region_id(int pg_num,vector<int> &point){
    char* data=this->fh.PageAt(pg_num).GetData();
    for(int i=16;i<this->get_EOP(pg_num);i+=(2*this->dim+1)*4){
        if(is_in_reg(i,data,point)){
            int rid;
            memcpy(&rid,&data[i],sizeof(int));
            this->fh.UnpinPage(pg_num);
            return rid;
        }

    }
    this->fh.UnpinPage(pg_num);

}


int KDB_Tree::get_EOP(int pg_num){

    char* data=this->fh.PageAt(pg_num).GetData();
    if(this->is_point_node(pg_num)){
        for(int i=16;i<PAGE_SIZE;i+=(this->dim+1)*4){
        int typ;
        memcpy(&typ,&data[i],sizeof(int));
        if(typ==0){
            this->fh.UnpinPage(pg_num);
            return i;
        }

    }
    this->fh.UnpinPage(pg_num);
    return PAGE_SIZE; //returns first free-block

    }
    else{

        for(int i=16;i<PAGE_SIZE;i+=(2*this->dim+1)*4){
            int typ;
            memcpy(&typ,&data[i],sizeof(int));
            if(typ==0){
                this->fh.UnpinPage(pg_num);
                return i;
            }

        }
        this->fh.UnpinPage(pg_num);
        return PAGE_SIZE; //returns first free-block
    }


    
    
}


bool KDB_Tree::check_if_equals(char *data,int start,vector<int> &point){
    for(int i=start;i<start+4*(this->dim);i+=4){
        int typ;
        memcpy(&typ,&data[i],sizeof(int));
        if(typ!=point[(i-start)/4]){
            return false;
        }
        
    }
    return true;

}


void KDB_Tree::get_data_node(int id){
    char* data=this->fh.PageAt(id).GetData();
    int buf;
    for(int i=0;i<this->get_EOP(id);i+=4){
          memcpy(&buf,&data[i],sizeof(int));
          cout<<i<<" "<<buf<<"\n";
    }
    cout<<"End Of Page"<<" "<<this->get_EOP(id)<<"\n";
    this->fh.UnpinPage(id);



}





void KDB_Tree::Point_Query(vector<int> &point){

    int ct=0;
    bool flag=false;
    if(this->root_id==-1){
        flag=false;
    }
   
    else{
        int id=this->root_id;
        while(!is_point_node(id)){
            id=get_region_id(id,point);
            ct+=1;
            
        }


        


        char* data=this->fh.PageAt(id).GetData();
        for(int i=16;i<this->get_EOP(id);i+=4*(this->dim+1)){
            flag=this->check_if_equals(data,i+4,point);
            if(flag==true){
                break;
            }

        }
        this->fh.UnpinPage(id);
        


    }

    if(flag==true){
        //Found point

        //outstream<<

        // cout<<"Point Exists"<<"\n";
        fout<<"NUM REGION NODES TOUCHED:"<<ct<<"\n";
        fout<<"TRUE"<<"\n";
        fout<<"\n";
        fout<<"\n";

        
    }
    else{
        // cout<<"Point Does Not Exists"<<"\n";
        fout<<"NUM REGION NODES TOUCHED:"<<0<<"\n";
        fout<<"FALSE"<<"\n";
        fout<<"\n";
        fout<<"\n";

    }

}


void KDB_Tree::insert(vector<int> &point){
    


     if(this->root_id==-1){


        PageHandler tp=this->fh.NewPage();
        PageHandler pg=this->fh.NewPage();
       
        char* data=pg.GetData();
        int pid=pg.GetPageNum();

         memcpy (&data[0], &pid, sizeof(int));
         int num=0;   //initial_split_dim
         memcpy (&data[4], &num, sizeof(int));
         num=1;   //type=0 for region node and 1 for point node
         memcpy (&data[8], &num, sizeof(int));
         num=-1;
         memcpy (&data[12], &num, sizeof(int));  //-1 is parent for root
         memcpy (&data[16], &num, sizeof(int)); //loc=-1
         for(int i=0;i<this->dim;i++){
             memcpy(&data[20+4*i],&point[i],sizeof(int));
        }
        this->root_id=pg.GetPageNum();
        set<int>vec;
        vec.insert(this->root_id);
        this->point_pages[-1]=vec;
        this->fh.MarkDirty(pid);
        this->fh.UnpinPage(pid);
        int z=tp.GetPageNum();
        this->fh.UnpinPage(z);

       

     }
     else{
          int id=this->root_id;

          if(this->is_point_node(id)){
              id=this->root_id;
          }
          else{
                int temp=-1;
                while(!this->is_point_node(id)){
                    temp=id;
                    id=get_region_id(id,point);
                }

          }

          char* data=this->fh.PageAt(id).GetData();
          int end=this->get_EOP(id);
          bool flag=false;
          for(int i=16;i<this->get_EOP(id);i+=4*(this->dim+1)){
            flag=this->check_if_equals(data,i+4,point);
            if(flag==true){
                this->fh.UnpinPage(id);
                //cout<<"Already point exists"<<"\n";
                fout<<"DUPLICATE POINT"<<"\n";
                fout<<"\n";
                fout<<"\n";
                return; //point already exists so return.
            }

        }
          int temp=-1;

          if(end+4*(this->dim+1)<=PAGE_SIZE){  //Place sufficient          
              memcpy(&data[end],&temp,sizeof(int));
              for(int j=0;j<this->dim;j++){
                  memcpy(&data[end+4+4*j],&point[j],sizeof(int));
              }
              this->fh.MarkDirty(id);
              this->fh.UnpinPage(id);
          }
          else{
              this->fh.UnpinPage(id);           
              this->reorganize_ptnode(id,point);
          }



        
      


     }

    
     //cout<<"Inserted"<<"\n";
     fout<<"INSERTION DONE:"<<"\n";
    int id=this->root_id;
    while(!is_point_node(id)){
        id=get_region_id(id,point);       
    }
    char* data=this->fh.PageAt(id).GetData();
    int end=this->get_EOP(id);    
    for(int i=16;i<this->get_EOP(id);i+=4*(this->dim+1)){
        int hr;
        for(int j=i+4;j<i+4*(this->dim);j+=4){            
            memcpy(&hr,&data[j],sizeof(int));
            fout<<hr<<" ";
        }
        memcpy(&hr,&data[i+4*(this->dim)],sizeof(int));
        fout<<hr<<"\n";   

   }
   this->fh.UnpinPage(id);

    // fout<<"\n";
    fout<<"\n";
     

     

 }


pair<int,int> KDB_Tree::Node_Split_ptnode(int nid,int split_ele,int split_dim,vector<int> &pt){
    PageHandler lnode=this->fh.NewPage();
    PageHandler rnode=this->fh.NewPage();

    

    int lid;
    int rid;

    lid=lnode.GetPageNum();
    rid=rnode.GetPageNum();



    char* data=this->fh.PageAt(nid).GetData();
    int par; 
    int sd;
    int num=1;   //type=0 for region node and 1 for point node

    memcpy (&par, &data[12], sizeof(int));  //Getting parent for node to be splitted.
    memcpy (&sd, &data[4], sizeof(int));  //Getting split_dim of node.

    sd=(sd+1)%(this->dim);

    char* datal=this->fh.PageAt(lid).GetData();
    char* datar=this->fh.PageAt(rid).GetData();

    // par=nid;

    int loc=-1;

    auto it=this->point_pages.find(par);
    if(it==this->point_pages.end()){
        set<int>vec;
        vec.insert(lid);
        vec.insert(rid);
        this->point_pages[par]=vec;

    }
    else{
        it->second.insert(lid);
        it->second.insert(rid);
        it->second.erase(nid);
    }

    
   
    


    memcpy (&datal[0], &lid, sizeof(int)); //setting up page_id     
    memcpy (&datal[4], &sd, sizeof(int)); //setting up split_dim  
    memcpy (&datal[8], &num, sizeof(int)); //setting type to be 1
    memcpy (&datal[12], &par, sizeof(int));  //setting up parent
    //memcpy (&datal[16], &loc, sizeof(int));  //setting up loc=-1



    memcpy (&datar[0], &rid, sizeof(int)); //setting up page_id     
    memcpy (&datar[4], &sd, sizeof(int)); //setting up split_dim
    memcpy (&datar[8], &num, sizeof(int)); //setting type to be 1
    memcpy (&datar[12], &par, sizeof(int));  //setting up parent
    //memcpy (&datar[16], &loc, sizeof(int));  //setting up loc=-1


   


   
    int temp_var;

    //this->get_data_node(nid);
    


    for(int i=16;i<this->get_EOP(nid);i+=4*(this->dim+1)){       
        int chkr;
        memcpy(&chkr,&data[i+4+split_dim*4],sizeof(int));


        if(chkr<split_ele){
            
            int l1=this->get_EOP(lid);
            int j;
            for(j=l1;j<=l1+4*this->dim;j+=4){
                memcpy(&datal[j],&data[i+j-l1],sizeof(int));
            }


        }
        else if(chkr>=split_ele){
           
            int l1=this->get_EOP(rid);
            int j;
            for(j=l1;j<=l1+4*this->dim;j+=4){
                memcpy(&datar[j],&data[i+(j-l1)],sizeof(int));
            }

        }

    }

   


    int tpr=-1;
    if(pt[split_dim]<split_ele){
        int l1=this->get_EOP(lid);
        memcpy(&datal[l1],&tpr,sizeof(int));
        for(int j=l1+4;j<=l1+4*this->dim;j+=4){
            memcpy(&datal[j],&pt[(j-l1)/4-1],sizeof(int));
        }

    }


    else if(pt[split_dim]>=split_ele){
        int l1=this->get_EOP(rid);
        memcpy(&datar[l1],&tpr,sizeof(int));
        for(int j=l1+4;j<=l1+4*this->dim;j+=4){
            memcpy(&datar[j],&pt[(j-l1)/4-1],sizeof(int));
        }
        
    }

    if(par!=-1){
        this->fh.DisposePage(nid);
    }


    //cout<<lid<<" "<<rid<<"\n";

    this->fh.MarkDirty(lid);
    this->fh.UnpinPage(lid);
    this->fh.MarkDirty(rid);
    this->fh.UnpinPage(rid);
    this->fh.UnpinPage(nid);

   
    
    pair<int,int>P;
    P.first=lid;
    P.second=rid;
    return P;
     
}


pair<int,int> KDB_Tree::Node_Split_rgnode(int nid,int split_ele,int split_dim,vector<int> &rgn){
    PageHandler lnode=this->fh.NewPage();
    PageHandler rnode=this->fh.NewPage();


    int lid;
    int rid;

    lid=lnode.GetPageNum();
    rid=rnode.GetPageNum();



    char* data=this->fh.PageAt(nid).GetData();
    int par; 
    int sd;
    int num=0;   //type=0 for region node and 1 for point node

    memcpy (&par, &data[12], sizeof(int));  //Getting parent for node to be splitted.
    memcpy (&sd, &data[4], sizeof(int));  //Getting split_dim of node.

    sd=(sd+1)%(this->dim);

    char* datal=lnode.GetData();
    char* datar=rnode.GetData(); 

    //par=nid;


    memcpy (&datal[0], &lid, sizeof(int)); //setting up page_id     
    memcpy (&datal[4], &sd, sizeof(int)); //setting up split_dim  
    memcpy (&datal[8], &num, sizeof(int)); //setting type to be 0
    memcpy (&datal[12], &par, sizeof(int));  //setting up parent



    memcpy (&datar[0], &rid, sizeof(int)); //setting up page_id     
    memcpy (&datar[4], &sd, sizeof(int)); //setting up split_dim
    memcpy (&datar[8], &num, sizeof(int)); //setting type to be 0
    memcpy (&datar[12], &par, sizeof(int));  //setting up parent


    int temp_var;
    for(int i=16;i<this->get_EOP(nid);i+=4*(2*this->dim+1)){       
        int lb;
        int rb;

        memcpy(&lb,&data[i+4+split_dim*8],sizeof(int));
        memcpy(&rb,&data[i+8+split_dim*8],sizeof(int));

        if(rb<=split_ele){   //[lb,rb)

         //move interval to lchild

            int b1=this->get_EOP(lid);
            for(int j=b1;j<b1+4*(2*this->dim+1);j+=4){
                memcpy(&datal[j],&data[i+j-b1],sizeof(int));
            }
           

        }
        else if(split_ele<lb){

            //move interval to rchild


            int b1=this->get_EOP(rid);

            for(int j=b1;j<b1+4*(2*this->dim+1);j+=4){
              memcpy(&datar[j],&data[i+j-b1],sizeof(int));

            }

        }
        else{
            int b1=this->get_EOP(lid);

            for(int j=b1;j<b1+4*(2*this->dim+1);j+=4){
                memcpy(&datal[j],&data[i+j-b1],sizeof(int));
            }
            memcpy(&datal[b1+8*split_dim+8],&split_ele,sizeof(int));

            b1=this->get_EOP(rid);
            for(int j=b1;j<b1+4*(2*this->dim+1);j+=4){
              memcpy(&datar[j],&data[i+j-b1],sizeof(int));

           }

           memcpy(&datar[b1+8*split_dim+4],&split_ele,sizeof(int));

        }

    }
    this->fh.UnpinPage(nid);

   

    int lb=rgn[2*split_ele+1];
    int rb=rgn[2*split_ele+2];
    if(rb<=split_ele){   //[lb,rb)

         //move interval to lchild

            int b1=this->get_EOP(lid);
            for(int j=b1;j<b1+4*(2*this->dim+1);j+=4){
                memcpy(&datal[j],&rgn[(j-b1)/4],sizeof(int));
            }
           

        }
        else if(split_ele<lb){

            //move interval to rchild


            int b1=this->get_EOP(rid);

            for(int j=b1;j<b1+4*(2*this->dim+1);j+=4){
              memcpy(&datar[j],&rgn[(j-b1)/4],sizeof(int));

            }

        }
        else{
            int b1=this->get_EOP(lid);

            for(int j=b1;j<b1+4*(2*this->dim+1);j+=4){
                memcpy(&datal[j],&rgn[(j-b1)/4],sizeof(int));
            }
            memcpy(&datal[b1+8*split_dim+8],&split_ele,sizeof(int));

            b1=this->get_EOP(rid);
            for(int j=b1;j<b1+4*(2*this->dim+1);j+=4){
              memcpy(&datar[j],&rgn[(j-b1)/4],sizeof(int));

           }

           memcpy(&datar[b1+8*split_dim+4],&split_ele,sizeof(int));

        }

    


  
    this->fh.MarkDirty(lid);
    this->fh.UnpinPage(lid);
    this->fh.MarkDirty(rid);
    this->fh.UnpinPage(rid);
  

    pair<int,int>P;
    P.first=lid;
    P.second=rid;
    return P;
     
}




 void KDB_Tree::reorganize_ptnode(int nid,vector<int> &pt){
    char* data=this->fh.PageAt(nid).GetData();
    int split_dim;
    int split_ele;
    int temp;
    vector<int>vec;
    


    memcpy(&split_dim,&data[4],sizeof(int));
    vec.push_back(pt[split_dim]);


    for(int j=16+4*split_dim+4;j<this->get_EOP(nid);j+=4*this->dim+4){
        memcpy(&temp,&data[j],sizeof(int));
        vec.push_back(temp);
    }
    sort(vec.begin(),vec.end());
    int l=vec.size();
    if(l%2==1){
        split_ele=vec[l/2];
    }
    else{
        split_ele=(vec[(l-1)/2]+vec[(l+1)/2]+1)/2;
    }

    pair<int,int>P=this->Node_Split_ptnode(nid,split_ele,split_dim,pt);
    int par;
    memcpy(&par,&data[12],sizeof(int));


    int lchild=P.first;
    int rchild=P.second;

    this->fh.UnpinPage(nid);
    

    //replace this_node with left
    if(par==-1 && this->is_point_node(this->root_id)){


        
        PageHandler pg=this->fh.NewPage();
        char* data=pg.GetData();
        int pid=pg.GetPageNum();

        this->fh.DisposePage(nid);
        this->root_id=pid;
        
        int num=0;
        int int_min=INT_MIN;
        int int_max=INT_MAX;

        
        num=-1;

        memcpy(&data[0],&pid,sizeof(int));        
        memcpy(&data[12],&num,sizeof(int)); //changing type to 0
        
        //Now need to copy id and point of both regions into root
        memcpy(&data[16],&lchild,sizeof(int));

        for(int j=20;j<20+4*(2*this->dim);j+=8){
            memcpy(&data[j],&int_min,sizeof(int));
            memcpy(&data[j+4],&int_max,sizeof(int));
        }
       
        memcpy(&data[20+8*split_dim+4],&split_ele,sizeof(int));


        int end=this->get_EOP(pid);
        

        memcpy(&data[end],&rchild,sizeof(int));
        for(int j=end+4;j<end+4*(2*this->dim);j+=8){
            memcpy(&data[j],&int_min,sizeof(int));
            memcpy(&data[j+4],&int_max,sizeof(int));
        }
        memcpy(&data[end+4+8*split_dim],&split_ele,sizeof(int));

        this->fh.MarkDirty(pid);
        this->fh.UnpinPage(pid);



        char* datal=this->fh.PageAt(lchild).GetData();
        char* datar=this->fh.PageAt(rchild).GetData();
        memcpy(&datal[12],&pid,sizeof(int));  //update to new parent
        memcpy(&datar[12],&pid,sizeof(int));  //update to new parent


        auto it1=this->point_pages.find(-1);
        auto it2=this->point_pages.end();

        if(it1!=it2){
            this->point_pages.erase(-1);
        }

        set<int>vec;
        vec.insert(lchild);
        vec.insert(rchild);
        this->point_pages[pid]=vec;

        // auto it3=this->point_pages.find(pid);
        // auto it4=this->point_pages.find(pid);

        this->fh.MarkDirty(lchild);
        this->fh.UnpinPage(lchild);
        this->fh.MarkDirty(rchild);
        this->fh.UnpinPage(rchild);
        
        //this->fh.UnpinPage(nid);


       

       
              



    }

      

   else{


     //this->fh.DisposePage(nid);
   

    int end=this->get_EOP(par);
    char* datap=this->fh.PageAt(par).GetData();
    int right_bound;
    int pos=16;

    for(int i=16;i<end;i+=8*this->dim+4){
        int val;
        memcpy(&val,&datap[i],sizeof(int));
        if(val==nid){
            memcpy(&datap[i],&lchild,sizeof(int));
            pos=i;
        }
          
    }
    memcpy(&right_bound,&datap[pos+8*split_dim+8],sizeof(int));
    memcpy(&datap[pos+8*split_dim+8],&split_ele,sizeof(int));



     // If place for one add right otherwise call reorganize.

        if(end+4*(2*this->dim+1)<=PAGE_SIZE){

            memcpy(&datap[end],&rchild,sizeof(int));
            for(int j=end+4;j<end+4*(2*this->dim+1);j++){
                memcpy(&datap[j],&datap[j-end+pos],sizeof(int));
            }
            memcpy(&datap[end+8*split_dim+4],&split_ele,sizeof(int));
            memcpy(&datap[end+8*split_dim+8],&right_bound,sizeof(int));
          
            this->fh.MarkDirty(par);
            this->fh.UnpinPage(par);      
        
        }
        else{

            vector<int>vec;
            vec.push_back(P.second);
            for(int j=end+4;j<end+4*(2*this->dim+1);j+=4){
                int pqr;
                memcpy(&pqr,&datap[j-end+pos],sizeof(int));
                vec.push_back(pqr);
            }
            vec[2*split_dim+1]=split_ele;
            vec[2*split_dim+2]=right_bound;

            this->fh.MarkDirty(par);
            this->fh.UnpinPage(par);  

            

            return reorganize_rgnode(par,vec);
            

        }



   }

   

    



 }



 


 void KDB_Tree::reorganize_rgnode(int nid,vector<int>&rgn){


    char* data=this->fh.PageAt(nid).GetData();
    int split_dim;
    int split_ele;
    int temp;
    vector<int>vec;
    
    memcpy(&split_dim,&data[4],sizeof(int));

    vec.push_back(rgn[2*split_dim+1]);
    vec.push_back(rgn[2*split_dim+2]);


    for(int j=16+8*split_dim+4;j<this->get_EOP(nid);j+=8*this->dim+4){
        memcpy(&temp,&data[j],sizeof(int));
        vec.push_back(temp);
        memcpy(&temp,&data[j+4],sizeof(int));
        vec.push_back(temp);
    }


    sort(vec.begin(),vec.end());


    int l=vec.size();
    if(l%2==1){
        split_ele=vec[l/2];
    }
    else{
        split_ele=(vec[(l-1)/2]+vec[(l+1)/2]+1)/2;
    }

    
    int par;
    memcpy(&par,&data[12],sizeof(int));
    //this->fh.MarkDirty(nid);
    this->fh.UnpinPage(nid); 
    pair<int,int>P=this->Node_Split_rgnode(nid,split_ele,split_dim,rgn);


    auto it1=this->point_pages.find(nid);
    auto it2=this->point_pages.end();

   

     if(it1!=it2){
         auto V=it1->second;
           set<int>vec1;
           set<int>vec2;        
            
            for(auto v:V){
                char *data_child=this->fh.PageAt(v).GetData();
                int tempp;
                memcpy(&tempp,&data_child[16+4+split_dim*4],sizeof(int));
                if(tempp<split_ele){
                    memcpy(&data_child[12],&P.first,sizeof(int));
                    vec1.insert(v);
                    

                }
                else{
                    memcpy(&data_child[12],&P.second,sizeof(int));
                    vec2.insert(v);

                }
                this->fh.MarkDirty(v);
                this->fh.UnpinPage(v);  
            }
            this->point_pages[P.first]=vec1;
            this->point_pages[P.second]=vec2;
            this->point_pages.erase(nid);
        }

        //cout<<"Code reached 898"<<"\n";

      

    

   

    if(par!=-1){

    
        int end=this->get_EOP(par);

        //replace this_node with left
    

        char* datap=this->fh.PageAt(par).GetData();
        int right_bound;
        int pos=-1;

        for(int i=16;i<end;i+=8*this->dim+4){
            int val;
            memcpy(&val,&datap[i],sizeof(int));
            if(val==nid){
                memcpy(&datap[i],&P.first,sizeof(int));
                pos=i;
            }

            memcpy(&right_bound,&datap[i+8*split_dim+8],sizeof(int));
            memcpy(&datap[i+8*split_dim+8],&split_ele,sizeof(int));
            
        }

       

        



        // If place for one add right otherwise call reorganize.

        if(end+4*(2*this->dim+1)<=PAGE_SIZE){


            memcpy(&datap[end],&P.second,sizeof(int));
            for(int j=end+4;j<end+4*(2*this->dim+1);j++){
                memcpy(&datap[j],&datap[j-end+pos],sizeof(int));
            }
            memcpy(&datap[end+8*split_dim+4],&split_ele,sizeof(int));
            memcpy(&datap[end+8*split_dim+8],&right_bound,sizeof(int));
            this->fh.MarkDirty(par);
            this->fh.UnpinPage(par);  

        
        }
        else{


            vector<int>vec(2*this->dim+1,0);
            vec[0]=P.second;
            for(int j=end+4;j<end+4*(2*this->dim+1);j++){
                int pqr;
                memcpy(&pqr,&datap[j-end+pos],sizeof(int));
                vec.push_back(pqr);
            }
            vec[2*split_dim+1]=split_ele;
            vec[2*split_dim+2]=right_bound;

            this->fh.MarkDirty(par);
            this->fh.UnpinPage(par);  

            return reorganize_rgnode(par,vec);

        }


    }

    else{


        PageHandler pg=this->fh.NewPage();
        int pid=pg.GetPageNum();

        this->fh.DisposePage(nid);
        this->root_id=pid;
        
        int num=0;
        int int_min=INT_MIN;
        int int_max=INT_MAX;

        int lchild=P.first;
        int rchild=P.second;

        //cout<<"Code reached 993"<<"\n";
        this->fh.UnpinPage(pid);
        this->fh.UnpinPage(lchild);
        this->fh.UnpinPage(rchild);



        char* datal=this->fh.PageAt(lchild).GetData();
        //cout<<"Code reached 1026"<<"\n";
        memcpy(&datal[12],&pid,sizeof(int));  //update to new parent
        this->fh.MarkDirty(lchild);
        this->fh.UnpinPage(lchild);

        //cout<<"Code reached 1030"<<"\n";


        char* datar=this->fh.PageAt(rchild).GetData();      
        memcpy(&datar[12],&pid,sizeof(int));  //update to new parent        
        this->fh.MarkDirty(rchild);
        this->fh.UnpinPage(rchild);


        char* data=pg.GetData();
        
        num=-1;

        memcpy(&data[0],&pid,sizeof(int));        
        memcpy(&data[12],&num,sizeof(int)); //changing type to 0
        
        //Now need to copy id and point of both regions into root
        memcpy(&data[16],&lchild,sizeof(int));

        for(int j=20;j<20+4*(2*this->dim);j+=8){
            memcpy(&data[j],&int_min,sizeof(int));
            memcpy(&data[j+4],&int_max,sizeof(int));
        }
       
        memcpy(&data[20+8*split_dim+4],&split_ele,sizeof(int));


        int end=this->get_EOP(pid);
        

        memcpy(&data[end],&rchild,sizeof(int));
        for(int j=end+4;j<end+4*(2*this->dim);j+=8){
            memcpy(&data[j],&int_min,sizeof(int));
            memcpy(&data[j+4],&int_max,sizeof(int));
        }
        memcpy(&data[end+4+8*split_dim],&split_ele,sizeof(int));
        this->fh.MarkDirty(pid);
        this->fh.UnpinPage(pid);


        






    }

    if(par!=-1){
        this->fh.DisposePage(nid);
    }


 }


 void KDB_Tree::close_file(){
     this->fout.close();

 }



 void KDB_Tree::Range_Query(vector<int> &range){
     set<pair<int,vector<int>>>result;
     if(this->root_id==-1){
         return;
     }
    queue<pair<int,int>>to_explore;
    to_explore.push(make_pair(0,this->root_id));
    
    //to_explore.push(this->root_id);
    while(!to_explore.empty()){

        pair<int,int>ptr=to_explore.front();
        int top_node=ptr.second;
        int ctr=ptr.first;
        to_explore.pop();
        if(this->is_point_node(top_node)){
            char* data=this->fh.PageAt(top_node).GetData();
            for(int i=16;i<this->get_EOP(top_node);i+=4*(this->dim+1)){
                vector<int>pt;
                int hr;
                for(int j=i+4;j<=i+4*(this->dim);j+=4){            
                    memcpy(&hr,&data[j],sizeof(int));
                    pt.push_back(hr);
                }
                result.insert(make_pair(ctr,pt));  

            }
            this->fh.UnpinPage(top_node);


        }
        else{
            char* data=this->fh.PageAt(top_node).GetData();
            
            for(int i=16;i<this->get_EOP(top_node);i+=4*(2*this->dim+1)){
                bool flag=false;
                bool flag1;
                int id;
                memcpy(&id,&data[i],sizeof(int));
                for(int j=i+4;j<i+4*(2*this->dim+1);j+=8){
                    int lbound;
                    int rbound;
                    memcpy(&lbound,&data[j],sizeof(int));
                    memcpy(&rbound,&data[j+4],sizeof(int));
                    flag1=(rbound>range[(j-i-4)/4] || lbound+1<range[1+(j-i-4)/4]);                    
                    flag=flag || flag1;                   

                }
                if(flag){                   
                    to_explore.push(make_pair(ctr+1,id));
                }            

                  

            }
            this->fh.UnpinPage(top_node);


        }
           
    }

    // this->get_data_node(1);
    // // this->get_data_node(0);
    // this->get_data_node(5);
    // this->get_data_node(2);
    // this->get_data_node(4);
    // this->get_data_node(6);


    if(result.size()>0){
            for(auto x:result){
            fout<<"POINT: ";
            for(auto y:x.second){
                fout<<y<<" ";
            }
            fout<<"NUM REGION NODES TOUCHED:"<<x.first<<"\n";
        }

    }
    else{
         fout<<"NO POINT FOUND"<<"\n"; //x.first<<"\n";

    }
    

   

    fout<<"\n";
    fout<<"\n";

    

     

}


 



