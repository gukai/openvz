#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include"infolink.h"

static ShotCL CLHead = NULL;

extern ShotCL make_cl_node(char *guid, char *faguid){
    ShotCL shot = malloc(sizeof(struct SnapShotCL));
    strcpy(shot->guid, guid);
    strcpy(shot->faguid, faguid);
    shot->next = NULL;

    return shot;
}

void free_cl_node(ShotCL shot){
    free(shot);
}

void print_cl_node(ShotCL shot){
   printf("guid: %s\n", shot->guid);
   printf("faguid %s\n", shot->faguid);
}

void insert_cl_node(ShotCL shot){
    shot->next = CLHead;
    CLHead = shot;
}

void delete_cl_node(ShotCL shot){
    ShotCL tmp = NULL;
    if (CLHead == shot){
        CLHead = CLHead->next;
        return ;
    }

    for(tmp = CLHead; tmp; tmp = tmp->next)
        if(tmp->next == shot){
            tmp->next = shot->next;
            return ;
        } 
}

ShotCL search_cl_node(char *guid){
    ShotCL tmp = CLHead;
    for(;tmp; tmp = tmp->next){
        //printf("%s : %s", tmp->guid, guid);
        if(! strcmp(tmp->guid, guid)) return tmp;
    }
    return NULL;
}



int cl_is_empty(void){
    if(CLHead  == NULL) return 1;
    return 0;
}

void cl_destroy_link(void){
    ShotCL tmp = CLHead;
    for(; NULL != (CLHead = tmp); tmp = CLHead->next)
        free(tmp);

}

void cl_traverse_link(void (*visit)(ShotCL)){
    ShotCL tmp = CLHead;

    for(; tmp; tmp = tmp->next){
        visit(tmp);
    }
}

/*
int main(void){
    ShotCL shot1 = make_cl_node("111", "hehe");
    ShotCL shot2 = make_cl_node("222", "gogo");
    ShotCL shot3 = make_cl_node("333", "world");

    insert_cl_node(shot1);
    insert_cl_node(shot2);
    insert_cl_node(shot3);

    if(cl_is_empty()){
        printf("it is empty\n");
        return 0;
    }
    
//    print_cl_node(CLHead);
//    print_cl_node(CLHead->next);
  
    ShotCL shot = search_cl_node("222");
    if(shot == NULL){
        printf("no that node");
    }else{
        print_cl_node(shot);
    }

    cl_traverse_link(print_cl_node);

    cl_destroy_link();    

    return 0;

}
*/
