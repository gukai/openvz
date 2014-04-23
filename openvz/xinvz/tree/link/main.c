#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "xml.h"
#include"infolink.h"
#include "tree.h"
//gcc -Wall infolink.c tree.c xml.c main.c -o 1 -I /usr/include/libxml2/ -lxml2


int move_linknode_to_tree(ShotCL shot){
    int score = 0;
    ShotTree fatarget = NULL;
    ShotTree chtarget = NULL;

    if (tree_is_empty()){
        if(! strcmp(shot->faguid, "{00000000-0000-0000-0000-000000000000}")){
            tree_init_tree(shot->guid);
            delete_cl_node(shot);
            free_cl_node(shot);
            score = 1;
        }
        return score;
    }else{
        fatarget = tree_search_node_root(shot->faguid);
        if(fatarget != NULL){
            chtarget = tree_make_node(shot->guid);
            tree_add_child(fatarget, chtarget);
            delete_cl_node(shot);
            free_cl_node(shot);
            score = 1;
        }
        return score;
    }
    printf("***********************\n");

    return score;
}


void move_link_to_tree(void){
    int score = 0;
    while( ! cl_is_empty()){
        score = cl_traverse_link_status(move_linknode_to_tree);
        if (0 == score){
             printf("All node left in link has no father in tree. the left node in link is:\n");
             cl_traverse_link(print_cl_node);
             exit(1);
        }
    }
}

int main(int argc, char **argv){

    // auto put the xml info into the link. 
    putXMLInLink(argv[1]);
    //putXMLInLink("DiskDescriptor.xml");
    //cl_traverse_link(print_cl_node);

    // get the top node.
    //printf("next is top\n");
    //print_cl_node(CL_TOP);

    move_link_to_tree();

    tree_set_flag(CL_TOP->guid);
    inactive_node_command(NULL);



/*
    ShotTree gukai = NULL;
    gukai = tree_search_node_root("{c48112e8-9c6d-462c-8c38-c9d370c90650}");
    printf("search result is %s\n", gukai->name);
*/
    
 
    
/*
    //test, search one node from the simple link.
    ShotCL gukai = search_cl_node("{c48112e8-9c6d-462c-8c38-c9d370c90650}");
    if(gukai == NULL){
        printf("Could not find the point.\n");
        exit(1);
    }
    printf("****************\n");
    print_cl_node(gukai);

    
    printf("*************\n");
    move_link_to_tree(gukai);
    cl_traverse_link(print_cl_node);

   if (cl_is_empty()){
       printf("link is empty\n");
   }else{
       printf("link is not empty\n");
   }
*/

    return 0;
}
