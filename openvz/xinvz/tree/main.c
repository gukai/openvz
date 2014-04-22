#include<stdio.h>
#include"tree.h"
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
