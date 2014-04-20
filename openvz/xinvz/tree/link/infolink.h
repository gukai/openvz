#ifndef __INFO_LINK_H__
#define __INFO_LINK_H__

#define GUID_LEN 40

typedef struct SnapShotCL *ShotCL;
struct SnapShotCL{
    char guid[GUID_LEN];
    char faguid[GUID_LEN];
    ShotCL next;
};

ShotCL TOP;

extern ShotCL make_cl_node(char *guid, char *faguid);
void free_cl_node(ShotCL shot);
void print_cl_node(ShotCL shot);
void insert_cl_node(ShotCL shot);
void delete_cl_node(ShotCL shot);
ShotCL search_cl_node(char *guid);
int cl_is_empty(void);
void cl_destroy_link(void);
void cl_traverse_link(void (*visit)(ShotCL));


#endif
