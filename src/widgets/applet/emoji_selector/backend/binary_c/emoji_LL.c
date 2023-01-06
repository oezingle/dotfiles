
#include "emoji_LL.h"

struct emoji_LL_node *node_create(emoji value)
{
    struct emoji_LL_node *node = malloc(sizeof(struct emoji_LL_node));

    node->value = value;
    node->next = NULL;

    return node;
}

void node_destroy(struct emoji_LL_node *node)
{
    free(node);
}

emoji_LL *LL_create()
{
    emoji_LL *list = malloc(sizeof(emoji_LL));

    list->head = NULL;
    list->tail = NULL;

    return list;
}

void LL_destroy(emoji_LL *list)
{
    struct emoji_LL_node *node = list->head;

    while (node)
    {
        struct emoji_LL_node *next = node->next;

        node_destroy(node);

        node = next;
    }

    free(list);
}

void LL_append(emoji_LL *list, emoji emoji)
{
    struct emoji_LL_node *node = node_create(emoji);

    if (list->head == NULL)
    {
        list->head = node;
        list->tail = node;
    }
    else
    {
        list->tail->next = node;
        list->tail = node;
    }
}