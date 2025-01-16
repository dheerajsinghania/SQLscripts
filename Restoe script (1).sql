set nocount on
declare @DbNameListForbackup varchar(max),
		@DbNameListForRestore varchar(max),
		@dbName varchar(225),
		@backupscript varchar(max),
		@RestoreScript varchar(max),
		@BackupPath varchar(1000),
		@RestorePath varchar(1000),
		@logfilePath varchar(1000)

declare  @DBNeedToExclude Table ( DataName varchar(1000))
declare  @Table Table (id int, DatafilePath varchar(1000))


insert into	@DBNeedToExclude
select 'abc'
union all
select 'pqr'


set @BackupPath = 'D:\Test\'
set @RestorePath = 'E:\Test\'
set @logfilePath = 'L:\Log\'

insert into @Table
(id,DatafilePath)
select 1,'D:\Folder1\'
union all
select 2,'D:\Folder2\'
union all
select 3,'D:\Folder3\'
union all
select 4,'D:\Folder4\'
union all
select 5,'D:\Folder5\'
union all
select 6,'D:\Folder6\'
union all
select 7,'D:\Folder7\'
union all
select 8,'D:\Folder8\'

set @DbNameListForbackup = ''
select @DbNameListForbackup = coalesce(@DbNameListForbackup,'',',')+name+',' from sys.databases a 
left join @DBNeedToExclude b on a.name = b.DataName 
where a.database_id > 4
set @DbNameListForRestore = @DbNameListForbackup
while CHARINDEX( ',',@DbNameListForbackup) > 0
begin
		set @dbName = SUBSTRING( @DbNameListForbackup,1, CHARINDEX( ',',@DbNameListForbackup)-1)
		set @DbNameListForbackup = SUBSTRING(@DbNameListForbackup,CHARINDEX( ',',@DbNameListForbackup)+1,len(@DbNameListForbackup))
		set @backupscript= 'Backup database '+@dbName+' to disk ='''+@BackupPath+@dbName+'_full.bak'' with stats=1,copy_only,compression'
		print @backupscript
end

print'/*

========================================================================================================================

*/
'
while CHARINDEX( ',',@DbNameListForRestore) > 0
begin
		set @dbName = SUBSTRING( @DbNameListForRestore,1, CHARINDEX( ',',@DbNameListForRestore)-1)
		set @DbNameListForRestore = SUBSTRING(@DbNameListForRestore,CHARINDEX( ',',@DbNameListForRestore)+1,len(@DbNameListForRestore))
		
		set @RestoreScript= 'Restore database '+@dbName+' from disk ='''+@RestorePath+@dbName+'_full.bak'''+char(13)+'With stats=1,'+char(13)
		select @RestoreScript = coalesce(@RestoreScript+' ','')+RestoreScript
		from 
			(
			select 	 'MOVE '''+b.name+''' to '''+a.DatafilePath+right(filename, charindex('\',reverse(filename))-1)+''','+char(13) as RestoreScript from @Table a
			join
			(
			select row_number()over( order by fileid) as RNO,* from sys.sysaltfiles 
			where db_name(dbid) = @dbName and status =2
			)b on a.id = b.RNO
			) Z
			select @RestoreScript = @RestoreScript+
			(
		select 'MOVE '''+name+''' to '''+@logfilePath+right(filename, charindex('\',reverse(filename))-1)+''''+char(13) from sys.sysaltfiles 
		where db_name(dbid) = @dbName and status =66
		)
		print @RestoreScript
end



