#include<stdio.h>
#include"tree.h"
// gcc -Wall link/tree.c main.c -I link -o tree

int main(void){
    if (tree_is_empty()){
        printf("it is empty\n");
    }else{
        printf("it is not empty\n");
    }
    tree_init_tree("root");
    ShotTree leaf1 = tree_make_node("leaf-1-1");
    ShotTree leaf2 = tree_make_node("leaf-1-2");
    ShotTree leaf3 = tree_make_node("leaf-1-3");
    ShotTree leaf21 = tree_make_node("leaf-2-1");
  
    ShotTree roota = tree_search_node_root("root");
    tree_add_child(roota, leaf1);
    tree_add_child(roota, leaf2);
    tree_add_child(roota, leaf3);
    tree_add_child(leaf2, leaf21);

    int i = 0;
    for(i=0; i < roota->childnum; i++){
        printf("child %d is %s\n", i, roota->child[i]->name);
    }

    ShotTree gukai = NULL;
    gukai = tree_search_node_root("leaf-1-3");
    printf("search result is %s\n", gukai->name);

    //inactive_node_command(NULL);
    tree_set_flag("leaf-2-1");
    //inactive_node_command(NULL);
 
    if (tree_is_empty()){
        printf("it is empty\n");
    }else{
        printf("it is not empty\n");
    }

    return 0;
}
