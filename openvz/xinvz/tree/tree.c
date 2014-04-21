#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include"tree.h"

/*
typedef struct SnapShotTree *ShotTree;
struct SnapShotTree{
    char *name;    //uuid
    int flag;
    int childnum;
    ShotTree father;
    ShotTree child[512];
};

enum NodeFlag{
    FlagActive,
    FlagInActive,
};

ShotTree Tree_Root = NULL;
*/


static void set_flag(ShotTree tmp){
    tmp->flag = FlagActive;
}

ShotTree tree_make_node(char *name){
    ShotTree shot = (ShotTree)malloc(sizeof(struct SnapShotTree));
    
    shot->name = (char *)malloc(strlen(name) + 1);
    strcpy(shot->name, name);
    
    shot->flag = FlagInActive;
    shot->childnum = 0;
    shot->father = NULL;
    //shot->child = NULL;
 
    return shot;
}


void tree_free_node(ShotTree shot){
    free(shot->name);
    free(shot);
}

//add child.
void tree_add_child(ShotTree tfather, ShotTree tchild){
    tfather->child[tfather->childnum] = tchild;
    tchild->father = tfather;
}

//delete the child.
void tree_delete_node(ShotTree tfather, ShotTree tchild){
    int whchild = -1;

    if(tchild->childnum > 1){
        printf("%s shot have more than one child, delete failed", tchild->name);
        exit(1);
    }
   
    whchild = tree_which_child(tchild);
    if(whchild < 0){
        printf("%s shot could not find father.\n", tchild->name);
        exit(1);
    }

    if (tchild->childnum == 1){
        tchild->child[0]->father = tfather;
        tfather->child[whchild] = tchild->child[0];
    }else{
        if(whchild != tfather->childnum - 1)
            tfather[whchild] = tfather[tfather->childnum -1]; 
    }

}

//tmp must be Tree_Root.
void tree_traverse_tree(ShotTree tmp, void (*visit)(ShotTree)){
    int i = 0;
    for(i = 0; i < tmp->childnum; i++){
        tree_traverse_tree(tmp->child[i], visit);
    }
    visit(tmp);

    if(tmp->father == NULL) return;

}

//tmp must be Tree_Root
ShotTree tree_search_node(ShotTree tmp, char *name){
    int i = 0;
    ShotTree ret = NULL;

    for(i = 0; i < tmp->childnum; i++){
        ret = tree_search_node(tmp->child[i], name);
        if (ret){
            return ret;
        }
    }

    if(! strcmp(tmp->name, name)) return tmp;
    
    return NULL;    

}


//tmp must be Top ShotTree
void tree_traverse_line(ShotTree tmp, void(*visit)(ShotTree)){
    if(tmp->father == NULL)
	return ;
    tree_traverse_line(tmp->father, visit);
}


void tree_set_flag(ShotTree tmp, char *name){
    ShotTree treetop = tree_search_node(Tree_Root, name);
    tree_traverse_line(treetop, set_flag);
}


// which child in father's child list.
int tree_which_child(ShotTree shot){
    int i = 0;
    for(i = 0 ; i < shot->father->childnum; i++){
       if(shot->father->child[i] == shot){
           return i;
       } 
    }

    return -1;
}



int main(void){
    Tree_Root = tree_make_node("root");     
    
    return 0;
}
