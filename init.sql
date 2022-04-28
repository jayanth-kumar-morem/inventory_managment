\c postgres;
drop database inventory;

create database inventory;
\c inventory;
create extension pgcrypto;

create table address(
    address_id bigserial PRIMARY key,
    address text not null,
    address2 text,
    district text not null,
    city text not null,
    phone text not null,
    last_update text default TIMEOFDAY()
);
create table supplier (
	supplierid BIGSERIAL PRIMARY KEY UNIQUE,
	full_name VARCHAR(100) NOT NULL,
	address_id bigserial NOT NULL,
	email VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT FK_AddressId FOREIGN KEY (address_id) REFERENCES address(address_id),
    CHECK (email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);
create table category (
	category_id BIGSERIAL PRIMARY KEY UNIQUE,
	category_name VARCHAR(50) NOT NULL UNIQUE,
    category_icon BYTEA
);
create table subCategory(
    id bigserial PRIMARY KEY,
    category_id int not null,
    sub_category_name text not null,
    CONSTRAINT FK_CategoryDd FOREIGN KEY (category_id) REFERENCES category(category_id)
);
create table product (
	productid BIGSERIAL PRIMARY KEY ,
	product_name VARCHAR(50) NOT NULL,
    brand_name VARCHAR(50),
	
    category_id INT NOT NULL,
    subcategory_id INT,
    
    preview_img_id int,

    rating numeric(2,1),
    description text,
    returnable int default 1,
    cashOnDelivery int default 1,
    CHECK (returnable=0 or returnable=1),
    CHECK (cashOnDelivery=0 or cashOnDelivery=1),
    CHECK (rating<=5.0 and rating>=0),
    CONSTRAINT FK_CategoryId FOREIGN KEY (category_id) REFERENCES category(category_id)
    -- CONSTRAINT FK_ImageGalleryId FOREIGN KEY (preview_img_id) REFERENCES image_gallery(id)
);
create table image_gallery(
    id bigserial PRIMARY key,
    image BYTEA ,
    file_extension text
);
create table product_gallery_mapper(
    variation_id bigserial,
    gallery_id bigserial,
    product_id bigserial
);

create table productVariations(
    id bigserial,
    productid bigserial not null,
    variationName text not null,
    PRIMARY KEY (id,productid),
    CONSTRAINT FK_Productid FOREIGN KEY (productid) REFERENCES product(productid)
);
create table productCombinations(
    id BIGSERIAL,
    combination_string text not null,
    productid bigserial not null,
    
    mrp DECIMAL(6,2) NOT NULL,
    discount int not null default 0,
    sell_price DECIMAL(6,2),
	
	cost_price DECIMAL(6,2) NOT NULL,

    availableStock int not null,
    PRIMARY key (id,productid),
    CONSTRAINT FK_Productid FOREIGN KEY (productid) REFERENCES product(productid)
);

create table offers(
    offer_id BIGSERIAL PRIMARY key,
    offer_decription text NOT NULL,
    offer_discount int NOT NULL,
    type text not null,
    min_purchase int,
    CHECK (offer_discount>=0 or offer_discount<100),
    CONSTRAINT FK_Productid FOREIGN KEY (productid) REFERENCES product(productid)
);

create table purchaseinfo(
    purchaseid BIGSERIAL PRIMARY KEY UNIQUE,
    supplierid INT NOT NULL,
    productid INT NOT NULL,
    date varchar(45) not null default CURRENT_TIMESTAMP,
    quantity int not null,
    totalcost int not null,
    product_combination_id BIGSERIAL not null,
    CONSTRAINT FK_ProductId FOREIGN KEY (productid) REFERENCES product(productid),
    CONSTRAINT FK_SupplierId FOREIGN KEY (supplierid) REFERENCES supplier(supplierid),
    CHECK(quantity>0),
    CHECK(totalcost>0)
);

create table customer (
	id BIGSERIAL PRIMARY KEY UNIQUE ,
	name text NOT NULL,
	email text NOT NULL UNIQUE,
    password text NOT NULL,
    CHECK (email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);
create table cartItems(
    customer_id BIGSERIAL,
    productid BIGSERIAL,
    product_combination_id bigserial,
    quantity int,
    check(quantity>=1),
    CONSTRAINT FK_customerId FOREIGN KEY (customer_id) REFERENCES customer(id),
    UNIQUE(productid,customer_id,product_combination_id)
);
create table reviews(
    productid BIGSERIAL,
    customer_id BIGSERIAL,
    rating int NOT NULL,
    review text,
    CHECK (rating<=5 and rating>=0),
    CONSTRAINT FK_Productid FOREIGN KEY (productid) REFERENCES product(productid),
    CONSTRAINT FK_CustomerId FOREIGN KEY (customer_id) REFERENCES customer(id)
);
create table customer_addresses(
    customer_id BIGSERIAL not null,
    address_id bigserial not null,
    CONSTRAINT FK_CustomerId FOREIGN KEY (customer_id) REFERENCES customer(id),
    CONSTRAINT FK_AddressId FOREIGN KEY (address_id) REFERENCES address(address_id)
);
create table salesinfo(
    saleid BIGSERIAL PRIMARY KEY UNIQUE,
    date varchar(45) NOT NULL default CURRENT_TIMESTAMP,
    productid INT NOT NULL,
    product_combination_id bigserial not null,
    customer_id BIGSERIAL UNIQUE,
    quantity int not null,
    totalcost int not null,
    final_cost_after_discount int not null,
    payment_method varchar(45) not null default 'credit card',
    stateOfPackage text not null,
    trackingId text not null, 
    CONSTRAINT FK_ProductId FOREIGN KEY (productid) REFERENCES product(productid),
    CONSTRAINT FK_CustomerCode FOREIGN KEY (customer_id) REFERENCES customer(id),
    CHECK(quantity>0),
    CHECK(totalcost>0),
    CHECK(final_cost_after_discount>0)
);

create table managers(
    manager_id bigserial PRIMARY KEY,
    manager_name text not null,
    phone text not null,
    email text,
    working_hrs int,
    pay_scale int,
    CHECK (email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);