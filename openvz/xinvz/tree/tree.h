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


enum NodeFlag{
    FlagActive,
    FlagInActive,
};


extern ShotTree Tree_Root;

ShotTree tree_make_node(char *name);
void tree_free_node(ShotTree shot);
void tree_add_child(ShotTree tfather, ShotTree tchild);
void tree_delete_node(ShotTree tfather, ShotTree tchild);
void tree_traverse_tree(ShotTree tmp, void (*visit)(ShotTree));
ShotTree tree_search_node(ShotTree shot, char *name);
void tree_traverse_line(ShotTree tmp, void(*visit)(ShotTree));
void tree_set_flag(char *topguid);
int tree_which_child(ShotTree shot);
void inactive_node_command(void (*visit)(ShotTree));
void tree_print_inactive(ShotTree shot);
#endif
