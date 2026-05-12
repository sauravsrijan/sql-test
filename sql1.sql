CREATE TABLE CONFIG_PROFILE (
    cfp_scale_factor FLOAT NOT NULL,
    cfp_loader_start TIMESTAMP NOT NULL,
    cfp_loader_stop TIMESTAMP NOT NULL,
    cfp_user_item_histogram VARCHAR(12000) NOT NULL
);

CREATE TABLE REGION (
    r_id BIGINT NOT NULL,
    r_name VARCHAR(32),
    PRIMARY KEY (r_id)
);
CREATE TABLE USERACCT (
    u_id BIGINT NOT NULL,
    u_rating BIGINT NOT NULL,
    u_balance FLOAT NOT NULL,
    u_comments INTEGER DEFAULT 0,
    u_r_id BIGINT NOT NULL REFERENCES REGION (r_id),
    u_created TIMESTAMP,
    u_updated TIMESTAMP,
    u_sattr0 VARCHAR(64),
    u_sattr1 VARCHAR(64),
    u_sattr2 VARCHAR(64),
    u_sattr3 VARCHAR(64),
    u_sattr4 VARCHAR(64),
    u_sattr5 VARCHAR(64),
    u_sattr6 VARCHAR(64),
    u_sattr7 VARCHAR(64),
    u_iattr0 BIGINT DEFAULT NULL,
    u_iattr1 BIGINT DEFAULT NULL,
    u_iattr2 BIGINT DEFAULT NULL,
    u_iattr3 BIGINT DEFAULT NULL,
    u_iattr4 BIGINT DEFAULT NULL,
    u_iattr5 BIGINT DEFAULT NULL,
    u_iattr6 BIGINT DEFAULT NULL,
    u_iattr7 BIGINT DEFAULT NULL,
    PRIMARY KEY (u_id)
);
CREATE INDEX IDX_USERACCT_REGION ON USERACCT (u_id, u_r_id);

CREATE TABLE USERACCT_ATTRIBUTES (
    ua_id BIGINT NOT NULL,
    ua_u_id BIGINT NOT NULL REFERENCES USERACCT (u_id),
    ua_name VARCHAR(32) NOT NULL,
    ua_value VARCHAR(32) NOT NULL,
    u_created TIMESTAMP,
    PRIMARY KEY (ua_id, ua_u_id)
);

CREATE TABLE CATEGORY (
    c_id BIGINT NOT NULL,
    c_name VARCHAR(50),
    c_parent_id BIGINT REFERENCES CATEGORY (c_id),
    PRIMARY KEY (c_id)
);
CREATE INDEX IDX_CATEGORY_PARENT ON CATEGORY (c_parent_id);

CREATE TABLE GLOBAL_ATTRIBUTE_GROUP (
    gag_id BIGINT NOT NULL,
    gag_c_id BIGINT NOT NULL REFERENCES CATEGORY (c_id),
    gag_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (gag_id)
);

CREATE TABLE GLOBAL_ATTRIBUTE_VALUE (
    gav_id BIGINT NOT NULL,
    gav_gag_id BIGINT NOT NULL REFERENCES GLOBAL_ATTRIBUTE_GROUP (gag_id),
    gav_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (gav_id, gav_gag_id)
);
CREATE TABLE ITEM (
    i_id BIGINT NOT NULL,
    i_u_id BIGINT NOT NULL REFERENCES USERACCT (u_id),
    i_c_id BIGINT NOT NULL REFERENCES CATEGORY (c_id),
    i_name VARCHAR(100),
    i_description VARCHAR(1024),
    i_user_attributes VARCHAR(255) DEFAULT NULL,
    i_initial_price FLOAT NOT NULL,
    i_current_price FLOAT NOT NULL,
    i_num_bids BIGINT,
    i_num_images BIGINT,
    i_num_global_attrs BIGINT,
    i_num_comments BIGINT,
    i_start_date TIMESTAMP,
    i_end_date TIMESTAMP,
    i_status INT DEFAULT 0,
    i_created TIMESTAMP,
    i_updated TIMESTAMP,
    i_iattr0 BIGINT DEFAULT NULL,
    i_iattr1 BIGINT DEFAULT NULL,
    i_iattr2 BIGINT DEFAULT NULL,
    i_iattr3 BIGINT DEFAULT NULL,
    i_iattr4 BIGINT DEFAULT NULL,
    i_iattr5 BIGINT DEFAULT NULL,
    i_iattr6 BIGINT DEFAULT NULL,
    i_iattr7 BIGINT DEFAULT NULL,
    PRIMARY KEY (i_id, i_u_id)
);
CREATE INDEX IDX_ITEM_SELLER ON ITEM (i_u_id);
CREATE TABLE ITEM_ATTRIBUTE (
    ia_id BIGINT NOT NULL,
    ia_i_id BIGINT NOT NULL,
    ia_u_id BIGINT NOT NULL,
    ia_gav_id BIGINT NOT NULL,
    ia_gag_id BIGINT NOT NULL,
    ia_sattr0 VARCHAR(64) DEFAULT NULL,
    FOREIGN KEY (ia_i_id, ia_u_id) REFERENCES ITEM (i_id, i_u_id) ON DELETE CASCADE,
    FOREIGN KEY (ia_gav_id, ia_gag_id) REFERENCES GLOBAL_ATTRIBUTE_VALUE (gav_id, gav_gag_id),
    PRIMARY KEY (ia_id, ia_i_id, ia_u_id)
);

CREATE TABLE ITEM_IMAGE (
    ii_id BIGINT NOT NULL,
    ii_i_id BIGINT NOT NULL,
    ii_u_id BIGINT NOT NULL,
    ii_sattr0 VARCHAR(128) NOT NULL,
    FOREIGN KEY (ii_i_id, ii_u_id) REFERENCES ITEM (i_id, i_u_id) ON DELETE CASCADE,
    PRIMARY KEY (ii_id, ii_i_id, ii_u_id)
);
CREATE TABLE ITEM_COMMENT (
    ic_id BIGINT NOT NULL,
    ic_i_id BIGINT NOT NULL,
    ic_u_id BIGINT NOT NULL,
    ic_buyer_id BIGINT NOT NULL REFERENCES USERACCT (u_id),
    ic_question VARCHAR(128) NOT NULL,
    ic_response VARCHAR(128) DEFAULT NULL,
    ic_created TIMESTAMP,
    ic_updated TIMESTAMP,
    FOREIGN KEY (ic_i_id, ic_u_id) REFERENCES ITEM (i_id, i_u_id) ON DELETE CASCADE,
    PRIMARY KEY (ic_id, ic_i_id, ic_u_id)
);
CREATE TABLE ITEM_BID (
    ib_id BIGINT NOT NULL,
    ib_i_id BIGINT NOT NULL,
    ib_u_id BIGINT NOT NULL,
    ib_buyer_id BIGINT NOT NULL REFERENCES USERACCT (u_id),
    ib_bid FLOAT NOT NULL,
    ib_max_bid FLOAT NOT NULL,
    ib_created TIMESTAMP,
    ib_updated TIMESTAMP,
    FOREIGN KEY (ib_i_id, ib_u_id) REFERENCES ITEM (i_id, i_u_id) ON DELETE CASCADE,
    PRIMARY KEY (ib_id, ib_i_id, ib_u_id)
);

CREATE TABLE ITEM_MAX_BID (
    imb_i_id BIGINT NOT NULL,
    imb_u_id BIGINT NOT NULL,
    imb_ib_id BIGINT NOT NULL,
    imb_ib_i_id BIGINT NOT NULL,
    imb_ib_u_id BIGINT NOT NULL,
    imb_created TIMESTAMP,
    imb_updated TIMESTAMP,
    FOREIGN KEY (imb_i_id, imb_u_id) REFERENCES ITEM (i_id, i_u_id) ON DELETE CASCADE,
    FOREIGN KEY (imb_ib_id, imb_ib_i_id, imb_ib_u_id) REFERENCES ITEM_BID (ib_id, ib_i_id, ib_u_id) ON DELETE CASCADE,
    PRIMARY KEY (imb_i_id, imb_u_id)
);
CREATE TABLE ITEM_PURCHASE (
    ip_id BIGINT NOT NULL,
    ip_ib_id BIGINT NOT NULL,
    ip_ib_i_id BIGINT NOT NULL,
    ip_ib_u_id BIGINT NOT NULL,
    ip_date TIMESTAMP,
    FOREIGN KEY (ip_ib_id, ip_ib_i_id, ip_ib_u_id) REFERENCES ITEM_BID (ib_id, ib_i_id, ib_u_id) ON DELETE CASCADE,
    PRIMARY KEY (ip_id, ip_ib_id, ip_ib_i_id, ip_ib_u_id)
);

CREATE TABLE USERACCT_FEEDBACK (
    uf_u_id BIGINT NOT NULL REFERENCES USERACCT (u_id),
    uf_i_id BIGINT NOT NULL,
    uf_i_u_id BIGINT NOT NULL,
    uf_from_id BIGINT NOT NULL REFERENCES USERACCT (u_id),
    uf_rating TINYINT NOT NULL,
    uf_date TIMESTAMP,
    uf_sattr0 VARCHAR(80) NOT NULL,
    FOREIGN KEY (uf_i_id, uf_i_u_id) REFERENCES ITEM (i_id, i_u_id) ON DELETE CASCADE,
    PRIMARY KEY (uf_u_id, uf_i_id, uf_i_u_id, uf_from_id),
    CHECK (uf_u_id <> uf_from_id)
);

CREATE TABLE USERACCT_ITEM (
    ui_u_id BIGINT NOT NULL REFERENCES USERACCT (u_id),
    ui_i_id BIGINT NOT NULL,
    ui_i_u_id BIGINT NOT NULL,
    ui_ip_id BIGINT,
    ui_ip_ib_id BIGINT,
    ui_ip_ib_i_id BIGINT,
    ui_ip_ib_u_id BIGINT,
    ui_created TIMESTAMP,
    FOREIGN KEY (ui_i_id, ui_i_u_id) REFERENCES ITEM (i_id, i_u_id) ON DELETE CASCADE,
    FOREIGN KEY (ui_ip_id, ui_ip_ib_id, ui_ip_ib_i_id, ui_ip_ib_u_id) REFERENCES ITEM_PURCHASE (ip_id, ip_ib_id, ip_ib_i_id, ip_ib_u_id) ON DELETE CASCADE,
    PRIMARY KEY (ui_u_id, ui_i_id, ui_i_u_id)
);

CREATE TABLE USERACCT_WATCH (
    uw_u_id BIGINT NOT NULL REFERENCES USERACCT (u_id),
    uw_i_id BIGINT NOT NULL,
    uw_i_u_id BIGINT NOT NULL,
    uw_created TIMESTAMP,
    FOREIGN KEY (uw_i_id, uw_i_u_id) REFERENCES ITEM (i_id, i_u_id) ON DELETE CASCADE,
    PRIMARY KEY (uw_u_id, uw_i_id, uw_i_u_id)
);
