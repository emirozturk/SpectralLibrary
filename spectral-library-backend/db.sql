create table categories
(
    id         int auto_increment
        primary key,
    name_en    varchar(255) not null,
    name_tr    varchar(255) null,
    created_at datetime     null,
    deleted_at datetime     null,
    constraint name_en
        unique (name_en),
    constraint name_tr
        unique (name_tr)
);

create index ix_categories_id
    on categories (id);

create table subcategories
(
    id          int auto_increment
        primary key,
    category_id int          not null,
    name_en     varchar(255) not null,
    name_tr     varchar(255) null,
    created_at  datetime     null,
    deleted_at  datetime     null,
    constraint subcategories_ibfk_1
        foreign key (category_id) references categories (id)
);

create index category_id
    on subcategories (category_id);

create index ix_subcategories_id
    on subcategories (id);

create table users
(
    id           int auto_increment
        primary key,
    email        varchar(255) not null,
    password     varchar(255) not null,
    type         varchar(50)  not null,
    is_confirmed tinyint(1)   not null,
    company      varchar(100) null,
    created_at   datetime     null,
    deleted_at   datetime     null,
    has_auth_for_public int null,
    constraint email
        unique (email)
);

create table folders
(
    id         int auto_increment
        primary key,
    name       varchar(255) not null,
    owner_id   int          not null,
    created_at datetime     null,
    deleted_at datetime     null,
    constraint folders_ibfk_1
        foreign key (owner_id) references users (id)
);

create index ix_folders_id
    on folders (id);

create index owner_id
    on folders (owner_id);

create table spectfiles
(
    id             int auto_increment
        primary key,
    name           varchar(255)  null,
    folder_id      int           not null,
    subcategory_id int           not null,
    description    varchar(1024) null,
    is_public      tinyint(1)    not null,
    created_at     datetime      null,
    deleted_at     datetime      null,
    constraint spectfiles_ibfk_1
        foreign key (folder_id) references folders (id),
    constraint spectfiles_ibfk_2
        foreign key (subcategory_id) references subcategories (id)
);

create table data
(
    id      int auto_increment
        primary key,
    file_id int   not null,
    x       float not null,
    y       float not null,
    constraint data_ibfk_1
        foreign key (file_id) references spectfiles (id)
);

create index file_id
    on data (file_id);

create index ix_data_id
    on data (id);

create table sharedfiles
(
    id         int auto_increment
        primary key,
    user_id    int      not null,
    file_id    int      not null,
    created_at datetime null,
    deleted_at datetime null,
    constraint sharedfiles_ibfk_1
        foreign key (user_id) references users (id),
    constraint sharedfiles_ibfk_2
        foreign key (file_id) references spectfiles (id)
);

create index file_id
    on sharedfiles (file_id);

create index ix_sharedfiles_id
    on sharedfiles (id);

create index user_id
    on sharedfiles (user_id);

create index folder_id
    on spectfiles (folder_id);

create index ix_spectfiles_id
    on spectfiles (id);

create index subcategory_id
    on spectfiles (subcategory_id);

create index ix_users_id
    on users (id);
