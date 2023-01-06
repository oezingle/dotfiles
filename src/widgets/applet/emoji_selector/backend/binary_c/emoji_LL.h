
#pragma once

#include "emoji.h"
#include <stdlib.h>

struct emoji_LL_node {
    emoji value;
    struct emoji_LL_node* next;
};

typedef struct emoji_LL {
    struct emoji_LL_node* head;
    struct emoji_LL_node* tail;
} emoji_LL;

struct emoji_LL_node* node_create(emoji);

void node_destroy(struct emoji_LL_node*);

emoji_LL* LL_create();

void LL_destroy(emoji_LL*);

void LL_append(emoji_LL*, emoji);