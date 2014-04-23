#include<stdio.h>
#include<stdlib.h>
#include"xml.h"
#include"infolink.h"
//gcc -Wall infolink.c tree.c xml.c main.c -o 1 -I /usr/include/libxml2/ -lxml2

void move_link_to_tree(ShotCL shot){    
    //delete from link.
    delete_cl_node(shot);
    free_cl_node(shot);
}

int main(int argc, char **argv){
   if (cl_is_empty()){
       printf("link is empty\n");
   }else{
       printf("link is not empty\n");
   }

    // auto put the xml info into the link. 
    putXMLInLink("./DiskDescriptor.xml");
    cl_traverse_link(print_cl_node);

    // get the top node.
    printf("next is top\n");
    print_cl_node(CL_TOP);

    
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

    return 0;
}
