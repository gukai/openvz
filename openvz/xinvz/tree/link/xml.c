#include<stdio.h>
#include<libxml2/libxml/parser.h>
#include<libxml2/libxml/tree.h>
#include"infolink.h"
#define GUID_LEN 40
//gcc -Wall 1.c -o 1 -I /usr/include/libxml2/ -lxml2
//need the libxml2-devel rpm.


static void parseit(xmlDocPtr doc, xmlNodePtr snap);
static void insertlink(char *guid, char *faguid);


int putXMLInLink(char *xmlpath){
    xmlDocPtr doc = NULL;
    xmlNodePtr root_node = NULL, node = NULL;
    
    doc = xmlParseFile(xmlpath);
    if (doc == NULL ) {
        fprintf(stderr,"Document not parsed successfully. /n");
        return 1;
    }
   
    root_node = xmlDocGetRootElement(doc);
    if (root_node == NULL) {
        fprintf(stderr,"empty document/n");
        xmlFreeDoc(doc);
        return 1;
    }

    if (xmlStrcmp(root_node->name, (const xmlChar *)"Snapshots")){
        //fprintf(stderr,"document of the wrong type, root node != story");
        printf("document root is %s\n", root_node->name);
        //xmlFreeDoc(doc);
        //return 1;
    }
 
    node = root_node->xmlChildrenNode;
    while(node != NULL){
        if (! xmlStrcmp(node->name, (const xmlChar *)"Snapshots")){
             printf("find the Sanpshot point %s.\n", node->name);
             parseit(doc, node);
             break;
        }

        //printf("second level in xml is %s\n", node->name);
        node = node->next;
    }
    
    xmlFreeDoc(doc);
    return 0;   
}

static void parseit(xmlDocPtr doc, xmlNodePtr snap){
    xmlChar *top = NULL;
    xmlNodePtr titleshot;
    xmlChar *xml_guid = NULL;     
    xmlChar *xml_faguid = NULL;     

    snap = snap->xmlChildrenNode;
    if (snap == NULL){
        printf("no child!");
    }

    while(snap != NULL){
        if (! xmlStrcmp(snap->name, (const xmlChar *)"TopGUID")) {
             top = xmlNodeListGetString(doc, snap->xmlChildrenNode, 1);
             printf("top: %s\n", top);
             //xmlFree(top);
        }

        if (! xmlStrcmp(snap->name, (const xmlChar *)"Shot")) {
             titleshot = snap->xmlChildrenNode;
             xml_guid = NULL;
             xml_faguid = NULL;
             while(titleshot != NULL){
                 //printf("%s\n", titleshot->name);
                
                 if (! xmlStrcmp(titleshot->name, (const xmlChar *)"GUID")){
                     xml_guid = xmlNodeListGetString(doc, titleshot->xmlChildrenNode, 1);
             	     //printf("GUID: %s\n", xml_guid);
                 }

                 if (! xmlStrcmp(titleshot->name, (const xmlChar *)"ParentGUID")){
                     xml_faguid = xmlNodeListGetString(doc, titleshot->xmlChildrenNode, 1);
             	     //printf("ParentGUID: %s\n", xml_faguid);
                 }



                   titleshot = titleshot->next;
             }

             if( xml_guid != NULL && xml_faguid != NULL){
                 //buildthe tree.
                 //typedef unsigned char xmlChar; in libxml source code.
                 insertlink((char *)xml_guid, (char *)xml_faguid);
             }

             /*
             printf("GUID: %s\n", xml_guid);
             printf("ParentGUID: %s\n", xml_faguid);
             printf("*************************\n");
             */
        }

	
        snap = snap->next;
    }

    //test
    //cl_traverse_link(print_cl_node);

    xmlFree(top); 
    xmlFree(xml_guid); 
    xmlFree(xml_faguid); 

}

static void insertlink(char *guid, char *faguid){
    ShotCL shot = make_cl_node(guid, faguid);
    insert_cl_node(shot);
}

/*
int main(int argc, char **argv){
    putXMLInLink(argv[1]);
    return 0;  
}
*/
