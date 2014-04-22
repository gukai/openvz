#include<stdio.h>
#include"xml.h"
#include"infolink.h"
//gcc -Wall infolink.c tree.c xml.c main.c -o 1 -I /usr/include/libxml2/ -lxml2

void move_link_to_tree(ShotCL shot){
    
    //delete from link.
    delete_cl_node(shot);
}

int main(int argc, char **argv){
    putXMLInLink(argv[1]);
    cl_traverse_link(print_cl_node);

    
    printf("next is top\n");
    print_cl_node(CL_TOP);

    printf("*************\n");
    move_link_to_tree(CL_ROOT);
    cl_traverse_link(print_cl_node);
    return 0;
}
