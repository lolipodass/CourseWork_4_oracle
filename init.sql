
grant DBA to BOOKSSYS;
grant select on SYS to BOOKSSYS;
grant select on public to BOOKSSYS;

-- SELECT PRIVILEGE
--   FROM sys.dba_sys_privs
--  WHERE grantee = 'BOOKSSYS'
-- UNION
-- SELECT PRIVILEGE
--   FROM dba_role_privs rp JOIN role_sys_privs rsp ON (rp.granted_role = rsp.role)
--  WHERE rp.grantee = 'BOOKSSYS'
--  ORDER BY 1;



create role RL_BOOKSDBADMIN;
grant create session to RL_BOOKSDBADMIN;
grant create table to RL_BOOKSDBADMIN;
grant create procedure to RL_BOOKSDBADMIN;
grant create trigger to RL_BOOKSDBADMIN;
grant create view to RL_BOOKSDBADMIN;
grant create sequence to RL_BOOKSDBADMIN;
grant drop any table to RL_BOOKSDBADMIN;
grant drop any procedure to RL_BOOKSDBADMIN;
grant drop any trigger to RL_BOOKSDBADMIN;
grant drop any view to RL_BOOKSDBADMIN;
grant SELECT ANY DICTIONARY to RL_BOOKSDBADMIN;
grant create any index to RL_BOOKSDBADMIN;

create user BooksDBAdmin identified by '1122Aa'
default tablespace BOOKSPDB
quota unlimited on BOOKSPDB;


