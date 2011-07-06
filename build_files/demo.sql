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
earliest '-24h',
latest 'now'
);
