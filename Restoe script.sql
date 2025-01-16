set nocount on
declare @DbNameList varchar(max),
		@dbName varchar(225),
		@backupscript varchar(max),
		@RestoreScript varchar(max),
		@BackupPath varchar(1000),
		@RestorePath varchar(1000),
		@logfilePath varchar(1000)
	

set @DbNameList = 'aadhaarshilaapi,Test,TRB,'
set @BackupPath = 'D:\Test\'
set @RestorePath = 'E:\Test\'
set @logfilePath = 'L:\Log\'

declare  @Table Table (id int, DatafilePath varchar(1000))

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

while CHARINDEX( ',',@DbNameList) > 0
begin
		set @dbName = SUBSTRING( @DbNameList,1, CHARINDEX( ',',@DbNameList)-1)
		set @DbNameList = SUBSTRING(@DbNameList,CHARINDEX( ',',@DbNameList)+1,len(@DbNameList))

		if exists (select top 1 1 from sys.databases where name = @dbName)
		begin
				
				set @backupscript= 'Backup database '+@dbName+' to disk ='''+@BackupPath+@dbName+'_full.bak'' with stats=1,copy_only,compression'
				print @backupscript
				print char(13)

				set @RestoreScript= 'Restore database '+@dbName+' from disk ='''+@RestorePath+'_full.bak'''+char(13)+'With stats=1,'+char(13)
			
				
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
			select 'MOVE '''+name+''' to '''+@logfilePath+right(filename, charindex('\',reverse(filename))-1)+'''' from sys.sysaltfiles 
			where db_name(dbid) = @dbName and status =66
			)
			print @RestoreScript
			

	end
		 
end



