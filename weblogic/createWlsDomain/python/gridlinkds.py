cd('/')
cmo.createJDBCSystemResource('myGDDS')

cd('/JDBCSystemResources/myGDDS/JDBCResource/myGDDS')
cmo.setName('myGDDS')

cd('/JDBCSystemResources/myGDDS/JDBCResource/myGDDS/JDBCDataSourceParams/myGDDS')
set('JNDINames',jarray.array([String('jdbc/mygdds')], String))

cd('/JDBCSystemResources/myGDDS/JDBCResource/myGDDS/JDBCDriverParams/myGDDS')
cmo.setUrl('jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=SDP)(HOST=dmt01db01-ib.exa-internal.intra.corp)(PORT=1522))(ADDRESS=(PROTOCOL=SDP)(HOST=dmt01db02-ib.exa-internal.intra.corp)(PORT=1522)))(CONNECT_DATA=(SERVICE_NAME=DRU1UATEXA_IB)))\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n')
cmo.setDriverName('oracle.jdbc.OracleDriver')
setEncrypted('Password', 'Password_1407505129888', '/wls/admin/domains/DOM_UAT_WEBAPPS/Script1407504535030Config', '/wls/admin/domains/DOM_UAT_WEBAPPS/Script1407504535030Secret')

cd('/JDBCSystemResources/myGDDS/JDBCResource/myGDDS/JDBCConnectionPoolParams/myGDDS')
cmo.setTestTableName('SQL SELECT instance_name from v$instance\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n')

cd('/JDBCSystemResources/myGDDS/JDBCResource/myGDDS/JDBCDriverParams/myGDDS/Properties/myGDDS')
cmo.createProperty('user')

cd('/JDBCSystemResources/myGDDS/JDBCResource/myGDDS/JDBCDriverParams/myGDDS/Properties/myGDDS/Properties/user')
cmo.setValue('dbsnmp')

cd('/JDBCSystemResources/myGDDS/JDBCResource/myGDDS/JDBCDataSourceParams/myGDDS')
cmo.setGlobalTransactionsProtocol('OnePhaseCommit')

cd('/JDBCSystemResources/myGDDS/JDBCResource/myGDDS/JDBCOracleParams/myGDDS')
cmo.setFanEnabled(true)
cmo.setOnsWalletFile('')
cmo.unSet('OnsWalletPasswordEncrypted')
cmo.setOnsNodeList('dmt01db01-ib.exa-internal.intra.corp:6200,dmt01db02-ib.exa-internal.intra.corp:6200\r\n\r\n')
cmo.setFanEnabled(true)
cmo.setOnsWalletFile('')
cmo.unSet('OnsWalletPasswordEncrypted')
cmo.setOnsNodeList('dmt01db01-ib.exa-internal.intra.corp:6200,dmt01db02-ib.exa-internal.intra.corp:6200\r\n\r\n')

cd('/SystemResources/myGDDS')
set('Targets',jarray.array([ObjectName('com.bea:Name=AdminServer,Type=Server'), ObjectName('com.bea:Name=CLU_UAT_DRUWEBAPPS,Type=Cluster')], ObjectName))

activate()

startEdit()
