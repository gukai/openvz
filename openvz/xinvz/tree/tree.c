#include<stdio.h>
#include<stdlib.h>
#include<string.h>

typedef struct ShotNode *NodeLink;
struct ShotNode{
    char *name;    //uuid
    int flag;
    //int level;
    int childnum;
    NodeLink father;
    NodeLink *child;
};

enum NodeFlag{
    FlagActive,
    FlagInActive,
};

NodeLink ShotRoot = NULL;

NodeLink make_node(char *name){
    NodeLink shot = (NodeLink)malloc(sizeof(struct ShotNode));
    
    shot->name = (char *)malloc(strlen(name) + 1);
    strcpy(shot->name, name);
    
    shot->flag = FlagInActive;
    shot->childnum = 0;
    shot->father = NULL;
    shot->child = NULL;
 
    return shot;
}

void free_node(NodeLink shot){
    free(shot);
}

void build_tree(void){
    ShotRoot = make_node("{00000000-0000-0000-0000-000000000000}");
    ShotRoot->flag = FlagActive;
}



int main(void){
    build_tree();
    NodeLink shot = make_node("1234567");
    printf("%s\n", shot->name);

    free_node(shot);
    return 0;
}
