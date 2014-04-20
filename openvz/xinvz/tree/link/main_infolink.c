#include<stdio.h>
#include"infolink.h"

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
