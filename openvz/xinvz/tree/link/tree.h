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


//extern ShotTree Tree_Root;

ShotTree tree_make_node(char *name);
void tree_init_tree(char *rootname);
void tree_free_node(ShotTree shot);
void tree_add_child(ShotTree tfather, ShotTree tchild);
void tree_delete_node(ShotTree tfather, ShotTree tchild);
int tree_is_empty(void);
void tree_traverse_tree(ShotTree tmp, void (*visit)(ShotTree));
ShotTree tree_search_node(ShotTree shot, char *name);
ShotTree tree_search_node_root(char *name);
void tree_traverse_line(ShotTree tmp, void(*visit)(ShotTree));
void tree_set_flag(char *topguid);
void inactive_node_command(void (*visit)(ShotTree));
#endif
