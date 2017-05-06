select USERNAME || ',' || 
TO_CHAR(CREATED, 'YYYY-MM-DD') || ',' || 
DEFAULT_TABLESPACE
from dba_users;