#include<stdio.h>
#include"xml.h"
#include"infolink.h"
//gcc -Wall xml.c main_xml.c -o 1 -I /usr/include/libxml2/ -lxml2

int main(int argc, char **argv){
    putXMLInLink(argv[1]);
    cl_traverse_link(print_cl_node);
    printf("next is top\n");
    print_cl_node(TOP);
    return 0;
}
