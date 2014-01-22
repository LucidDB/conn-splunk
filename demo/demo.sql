!set force true
!set maxwidth 10000

create schema splunk_demo;
set schema 'splunk_demo';

-- NEED-TO-EDIT --
create or replace server splunk_server
foreign data wrapper splunk_wrapper
options (
splunk_server 'https://localhost:8089',
username      'admin',
password      'changeme'
);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- CREATE FOREIGN TABLE EXAMPLES, FEEL FREE TO COMMENT THESE OUT --
-------------------------------------------------------------------
-------------------------------------------------------------------

-- table that represent the last 24 hours of Splunk's _internal index
-- Any query issued against this table will modify the base_search such that Splunk' handles 
-- most of the work. Only source, sourcetype, host, splunk_server and _time are displayed. 

create or replace foreign table splunk_demo.internal(
"source" varchar(4096), "sourcetype" varchar(1024), "host" varchar(512), "splunk_server" varchar(256), "_time" double )
server splunk_server
options (
base_search   'search index=_internal',
earliest '-24h',
latest 'now'
);


-- table that represent the last 24 hours of Splunk's queues state (a subset of splunk.internal)
-- Any query issued against this table will modify the base_search such that Splunk' handles
-- most of the work. This table exposes more fields than splunk.internal.
 
create or replace foreign table splunk_demo.queue(
"_time" double,
"host" varchar(256), "splunk_server" varchar(256),
"name" varchar(512),
"max_size" bigint, "filled_count" int, "empty_count" int,
"current_size" int, "largest_size" int, "smallest_size" int)
server splunk_server
options (
base_search   'search index=_internal source=*metrics.log group="queue"',
earliest '-1000d',
latest 'now'
);


create or replace foreign table splunk_demo.access_logs(
"_time" double,
"date_hour" integer,
"date_mday" integer,
"date_minute" integer,
"date_month" varchar(256),
"date_wday" varchar(256),
"date_year" integer,
"host" varchar(256),
"method" varchar(100),
"source" varchar(256),
"action" varchar(256),
"clientip" varchar(256),
"status" int,
"file" varchar(256),
"itemid" varchar(256),
"uri_query" varchar(256),
"bytes" float,
"category_id" varchar(256)
)
server splunk_server
options (
base_search   'search source=*combined.log',
earliest '-1000d',
latest 'now'
);

create or replace foreign table splunk_demo.access_logs_pentaho(
"_time" double,
"date_hour" varchar(256),
"date_mday" varchar(256),
"date_minute" varchar(256),
"date_month" varchar(256),
"date_wday" varchar(256),
"date_year" varchar(256),
"host" varchar(256),
"method" varchar(100),
"source" varchar(256),
"category" varchar(256),
"action" varchar(256),
"clientip" varchar(256),
"status" varchar(256)
)
server splunk_server
options (
base_search   'search source=*combined.log',
earliest '-1000d',
latest 'now'
);


-- For pentaho  OLD
select "date_hour" as "Date Hour", "date_mday" as "Minute in Day", "date_minute" as "Minute in Hour", "date_month" as "Month of Year", "date_wday" as "Day of Week", "date_year" as "Fiscal Year", "host" as "Host name", "method" as "HTTP Method", "source" as "HTTP Source", "category" as "Event Category", "action" as "Customer Action", "clientip" as "IP Address", "status" as "HTTP Status", "_time" as "Unix Time" from splunk_demo.access_logs;

create or replace view splunk_demo.access_logs_metadata as select t.*, t."method" as "Http Method", t."action" as "Customer Action" from splunk_demo.access_logs t;
