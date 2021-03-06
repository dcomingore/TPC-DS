-- start query 40 in stream 0 using template query40.tpl
select
   w_state
  ,i_item_id
  ,sum(case when (cast(d_date as timestamp) < cast ('2000-03-28' as timestamp))
                then cs_sales_price - coalesce(cr_refunded_cash,0) else 0 end) as sales_before
  ,sum(case when (cast(d_date as timestamp) >= cast ('2000-03-28' as timestamp))
                then cs_sales_price - coalesce(cr_refunded_cash,0) else 0 end) as sales_after
 from
   catalog_sales left outer join catalog_returns on
       (cs_order_number = cr_order_number
        and cs_item_sk = cr_item_sk)
  ,warehouse
  ,item
  ,date_dim
 where
     i_current_price between 0.99 and 1.49
 and i_item_sk          = cs_item_sk
 and cs_warehouse_sk    = w_warehouse_sk
 and cs_sold_date_sk    = d_date_sk
 --removed Cloudera cheat
 --and cs_sold_date_sk between 2451602 and 2451662
 and d_date between (cast ('2000-03-28' as timestamp) - '30 days'::interval)
                and (cast ('2000-03-28' as timestamp) + '30 days'::interval)
 group by
    w_state,i_item_id
 order by w_state,i_item_id
 limit 100;

