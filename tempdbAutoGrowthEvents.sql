DECLARE @path nvarchar(260) = (
    SELECT REVERSE(SUBSTRING(REVERSE(path), CHARINDEX('\', REVERSE(path)), 260)) +'log.trc'
    FROM    sys.traces
    WHERE   is_default = 1)

SELECT name,DatabaseName,*
FROM  sys.fn_trace_gettable(@path, DEFAULT) gt
JOIN sys.trace_events te ON gt.EventClass = te.trace_event_id
WHERE   te.name in ('Data File Auto Grow','Log File Auto Grow','Data File Auto Shrink','Log File Auto Shrink')
or (EventClass = 116 and TextData like '%shrink%')
order by starttime desc
