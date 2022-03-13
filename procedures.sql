-- Adding new category
create or replace procedure add_category(
    category_id_inp int,
    category_name_inp VARCHAR(50)
)
language plpgsql
as $$
begin
    insert into category(category_id,category_name)
    values (category_id_inp,category_name_inp);
commit;
end;$$;

call add_category(7,'shoes');

-- Adding new product
create or replace procedure add_product(
    product_name_inp VARCHAR(50),
    cost_price_inp DECIMAL(6,2),
    sell_price_inp DECIMAL(6,2),
    category_id_inp INT
)
language plpgsql
as $$
declare 
    max_product_id int;
begin

    select max(productid) into max_product_id
    from product;

    insert into product(productid,product_name,sell_price,category_id)
    values (max_product_id+1,product_name_inp,sell_price_inp,category_id_inp);

    insert into costprice(productid,cost_price)
    values (max_product_id+1,cost_price_inp);

    insert into currentstock(productid,quantity)
    values (max_product_id+1,0);

commit;
end;$$;

call add_product('nike shoe',1,5,7);

-- purchase_from_supplier
create or replace procedure purchase_from_supplier(
    supplierid_inp INT,
    productid_inp int,
    quantity_inp int
)
language plpgsql    
as $$
declare 
    cost int;
begin

    select cost_price into cost
    from costprice
    where productid=productid_inp;

    insert into purchaseinfo(supplierid,productid,quantity,totalcost)
    values (supplierid_inp,productid_inp,quantity_inp,quantity_inp*cost);

    update currentstock set quantity=quantity+quantity_inp where productid = productid_inp;

    commit;
end;$$;

call purchase_from_supplier(1,2,5);

-- customer_purchase
create or replace procedure customer_purchase(
    productid_inp int,
    customer_id_inp int,
    quantity_inp int
)
language plpgsql    
as $$
declare 
    sell_price_local int;
begin

    update currentstock set quantity=quantity-quantity_inp where productid = productid_inp;
    
    select sell_price into sell_price_local
    from product
    where productid=productid_inp;
    
    insert into salesinfo(productid,customer_id,quantity,totalcost)
    values (productid_inp,customer_id_inp,quantity_inp,sell_price_local*quantity_inp);
commit;
end;$$;

call customer_purchase(2,1,2);
