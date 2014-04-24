#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "xml.h"
#include"infolink.h"
#include "tree.h"
//gcc -Wall infolink.c tree.c xml.c main.c -o 1 -I /usr/include/libxml2/ -lxml2

enum command_enum{
    BUILD,
    DELETE,
};

void usage(void){
    printf("./tree <build> <xmlfile>\n");
    printf("    build: use this command when you want to build full backup\n");
    printf("    xmlfile: the configure file of the VM private hdd.root.\n");
    printf("    return: the list of uuid which snapshot must be delete before.\n");
    printf("./tree <delete> <xmlfile> <uuid> [active].\n");
    printf("    delete: use this command when you want to delete one snapshot point.\n");
    printf("    xmlfile: the configure file of the VM private hdd.root\n");
    printf("    uuid: the uuid which snapshot you want to delete.\n");
    printf("    active: if the snapshot you want to delete in the active tree, call with the argv[4] \"active\". \n");
}


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

void build_com(void){
    tree_set_flag(CL_TOP->guid);
    inactive_node_command_root(NULL); 
}

void delete_com(char *uuid, int flag){
    ShotTree target = tree_search_node_root(uuid);    
    if (target == NULL){
        printf("ERROR: Could not find the uuid : %s in the back up.\n", uuid);
        exit(1);
    }

    if(flag)
        tree_set_flag(CL_TOP->guid);
 
    inactive_node_command(target, NULL);
    if(flag){
        //printf("\n");
        active_node_command(target, NULL);
    }
}


int main(int argc, char **argv){
    // the uuid must have {}.
    char *comarg = NULL, *uuid = NULL, *xmlfile;
    int active = 0;
    enum command_enum com;


    if(argc < 3){
        printf("ERROR:Argument is too less.\n");
        usage();
        exit(1);
    }

    comarg = argv[1];
    if(! strcmp(comarg, "build")){
        com = BUILD;
    }else if(! strcmp(comarg, "delete")){
        if(argc<4){
            printf("ERROR: you must specify the uuid which you want to delete.");
            usage();
            exit(1);
        }
        uuid = argv[3];
        com = DELETE;
        if(argc == 5 ){
            if( strcmp(argv[4], "active")){
                printf("ERROR: if the argc equal 5, the argv[4] is must be active now.");
                usage();
                exit(1);
            }
            active = 1;
        }
    }else{
        printf("ERROR: The command is error, please verfiy your parameter.\n");
        usage();
        exit(1);
    }

    xmlfile = argv[2];

    // auto put the xml info into the link. 
    putXMLInLink(xmlfile);
    //cl_traverse_link(print_cl_node);

    move_link_to_tree();

    switch (com){
    case BUILD:
        build_com();
        break;
    case DELETE:
        delete_com(uuid, active);
        break;
    default:
        usage();
        exit(1);
    }
    
    





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
