select 
	ss.session_id SPID ,
	original_login_name,
	sp.status,
	blocking_session_id [Blk by],
	command,db_name(sp.database_id) [Database],
	[objectid],
	percent_complete [% Done],
	case when datediff(mi,start_time,GETDATE())>60 then convert(varchar(4),(datediff(mi,start_time,GETDATE())/60))++' hr ' 	else '' end +case when datediff(ss,start_time,GETDATE())>60 then convert(varchar(4),(datediff(mi,start_time,GETDATE())%60))++' min ' 	else '' end +convert(varchar(4),(datediff(ss,start_time,GETDATE())%60))++' sec' [Duration]
	,estimated_completion_time/60000 [ETA (Min)]
	,[text] [input stream/text]
	, (SUBSTRING([text],statement_start_offset / 2+1 
	, ( (CASE WHEN statement_end_offset <0  THEN (LEN(CONVERT(nvarchar(max)
	,[text])) * 2) ELSE statement_end_offset END)  - statement_start_offset) / 2+1))  AS [Executeing_sql_statement]
	,wait_resource
	,wait_time/1000 [wait_time (sec)]
	,last_wait_type
	,login_time
	,last_request_start_time
	,last_request_end_time
	,host_name
	,case when program_name like 'SQLAgent%Job%' then (select top 1 '(SQLAgent Job - '+name +' - '+right(program_name,len(program_name)-charindex(':',program_name)) from msdb.dbo.sysjobs SJ where UPPER(master.dbo.fn_varbintohexstr(SJ.job_id))=UPPER(substring([program_name],30,34))) else program_name  end  [program_name]
	,sp.open_transaction_count
	,case sp.transaction_isolation_level when 0 then 'Unspecified' when 1 then 'ReadUncomitted' when 2 then 'ReadCommitted' when 3 then 'Repeatable' when 4 then 'Serializable' when 5 then 'Snapshot' end [transaction_isolation_level]
	,sp.cpu_time
	,sp.reads
	,sp.writes
	,sp.logical_reads
	,sp.lock_timeout
	,sp.row_count 
from sys.dm_exec_requests as sp 
outer APPLY sys.dm_exec_sql_text(sp.sql_handle) as esql 
right outer  join sys.dm_exec_sessions ss on ss.session_id=sp.session_id  where ss.status<>'sleeping'