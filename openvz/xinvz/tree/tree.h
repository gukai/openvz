#ifndef __TREE_H__
#define __TREE_H__

typedef struct SnapShotTree *ShotTree;
struct SnapShotTree{
    char *name;    //uuid
    int flag;
    int childnum;
    ShotTree father;
    ShotTree child[512];
};

/*
enum NodeFlag{
    FlagActive,
    FlagInActive,
};
*/

ShotTree Tree_Root = NULL;

ShotTree tree_make_node(char *name);
void tree_free_node(ShotTree shot);
void tree_add_child(ShotTree tfather, ShotTree tchild);
void tree_delete_node(ShotTree tfather, ShotTree tchild);
void tree_traverse_tree(ShotTree tmp, void (*visit)(ShotTree));
ShotTree tree_search_node(ShotTree tmp, char *name);
void tree_traverse_line(ShotTree tmp, void(*visit)(ShotTree));
void tree_set_flag(ShotTree tmp, char *name);
int tree_which_child(ShotTree shot);

#endif
