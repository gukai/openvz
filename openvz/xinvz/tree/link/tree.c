#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include"tree.h"

static void set_flag(ShotTree tmp);
static int tree_which_child(ShotTree shot);
static void tree_print_inactive(ShotTree shot);
static void tree_print_active(ShotTree shot);

static ShotTree Tree_Root = NULL;

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

void tree_init_tree(char *rootname){
    Tree_Root = tree_make_node(rootname);
}


void tree_free_node(ShotTree shot){
    free(shot->name);
    free(shot);
}

//add child.
void tree_add_child(ShotTree tfather, ShotTree tchild){
    tfather->child[tfather->childnum] = tchild;
    tfather->childnum++;
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
        if(whchild != tfather->childnum - 1){
            tfather[whchild] = tfather[tfather->childnum -1];
        } 
        tfather->childnum--;
    }


}

int tree_is_empty(void){
    if(Tree_Root == NULL)
        return 1;
    return 0;
}

//tmp must be Tree_Root.
void tree_traverse_tree(ShotTree tmp, void (*visit)(ShotTree)){
    int i = 0;
    for(i = 0; i < tmp->childnum; i++){
        tree_traverse_tree(tmp->child[i], visit);
    }
    visit(tmp);

    //if(tmp->father == NULL) return;

}

//tmp must be Tree_Root.
void pre_tree_traverse_tree(ShotTree tmp, void (*visit)(ShotTree)){
    int i = 0;
    visit(tmp);
    for(i = 0; i < tmp->childnum; i++){
        pre_tree_traverse_tree(tmp->child[i], visit);
    }

    //if(tmp->father == NULL) return;

}

//tmp must be Tree_Root
ShotTree tree_search_node(ShotTree tmp, char *name){
    int i = 0;
    ShotTree ret = NULL;
    if (tmp == NULL){
          printf("it is should not happened!, tree root may be null.\n");
    }

    for(i = 0; i < tmp->childnum; i++){
        ret = tree_search_node(tmp->child[i], name);
        if (ret){
            return ret;
        }
    }

    if(! strcmp(tmp->name, name)) return tmp;
    
    return NULL;    

}

ShotTree tree_search_node_root(char *name){
    return tree_search_node(Tree_Root, name);
}


//tmp must be Top ShotTree
void tree_traverse_line(ShotTree tmp, void(*visit)(ShotTree)){
    if(tmp == NULL)
	return ;
    tree_traverse_line(tmp->father, visit);
    visit(tmp);
}

/***********************************************
 specific
***********************************************/
void tree_set_flag(char *topguid){
    ShotTree treetop = tree_search_node(Tree_Root, topguid);
    tree_traverse_line(treetop, set_flag);
}

/**now visit is just tree_print_inactive.**/
void inactive_node_command_root(void (*visit)(ShotTree)){
    tree_traverse_tree(Tree_Root, tree_print_inactive);
}

void inactive_node_command(ShotTree myroot, void (*visit)(ShotTree)){
    tree_traverse_tree(myroot, tree_print_inactive);
}

void active_node_command(ShotTree myroot, void (*visit)(ShotTree)){
    pre_tree_traverse_tree(myroot, tree_print_active);
}



/***********************************************
 litile tools
************************************************/
// which child in father's child list.
static int tree_which_child(ShotTree shot){
    int i = 0;
    for(i = 0 ; i < shot->father->childnum; i++){
       if(shot->father->child[i] == shot){
           return i;
       } 
    }

    return -1;
}

static void set_flag(ShotTree tmp){
    tmp->flag = FlagActive;
}

static void tree_print_inactive(ShotTree shot){
     if(shot->flag == FlagInActive){
          printf("%s ", shot->name);
     }
}

static void tree_print_active(ShotTree shot){
     if(shot->flag == FlagActive){
          printf("%s ", shot->name);
          //printf("%s\n", shot->name);
     }
}


/*
int main(void){
    Tree_Root = tree_make_node("root");     
    ShotTree leaf1 = tree_make_node("leaf-1-1"); 
    ShotTree leaf2 = tree_make_node("leaf-1-2"); 
    ShotTree leaf3 = tree_make_node("leaf-1-3"); 
    ShotTree leaf21 = tree_make_node("leaf-2-1"); 
   
    tree_add_child(Tree_Root, leaf1); 
    tree_add_child(Tree_Root, leaf2); 
    tree_add_child(Tree_Root, leaf3); 
    tree_add_child(leaf2, leaf21); 

    int i = 0;
    for(i=0; i<Tree_Root->childnum; i++){
    	printf("child %d is %s\n", i, Tree_Root->child[i]->name);
    }     

    ShotTree gukai = NULL;
    gukai = tree_search_node(Tree_Root, "leaf-1-3");
    printf("search result is %s\n", gukai->name);

    inactive_node_command(NULL);
    tree_set_flag("leaf-2-1");
    inactive_node_command(NULL);
 
    return 0;
}
*/
