@ECHO OFF

@REM WARNING: This file is created by the Configuration Wizard.
@REM Any changes to this script may be lost when adding extensions to this configuration.

@REM *************************************************************************
@REM This script is used to setup the needed environment to be able to start Weblogic Server in this domain.
@REM 
@REM This script initializes the following variables before calling commEnv to set other variables:
@REM 
@REM WL_HOME         - The BEA home directory of your WebLogic installation.
@REM JAVA_VM         - The desired Java VM to use. You can set this environment variable before calling
@REM                   this script to switch between Sun or BEA or just have the default be set. 
@REM JAVA_HOME       - Location of the version of Java used to start WebLogic
@REM                   Server. Depends directly on which JAVA_VM value is set by default or by the environment.
@REM USER_MEM_ARGS   - The variable to override the standard memory arguments
@REM                   passed to java.
@REM PRODUCTION_MODE - The variable that determines whether Weblogic Server is started in production mode.
@REM DOMAIN_PRODUCTION_MODE 
@REM                 - The variable that determines whether the workshop related settings like the debugger,
@REM                   testconsole or iterativedev should be enabled. ONLY settable using the 
@REM                   command-line parameter named production
@REM                   NOTE: Specifying the production command-line param will force 
@REM                          the server to start in production mode.
@REM 
@REM Other variables used in this script include:
@REM SERVER_NAME     - Name of the weblogic server.
@REM JAVA_OPTIONS    - Java command-line options for running the server. (These
@REM                   will be tagged on to the end of the JAVA_VM and
@REM                   MEM_ARGS)
@REM 
@REM For additional information, refer to "Managing Server Startup and Shutdown for Oracle WebLogic Server"
@REM (http://download.oracle.com/docs/cd/E17904_01/web.1111/e13708/overview.htm).
@REM *************************************************************************

set WL_HOME=D:\Weblo10.3.5\wlserver_10.3
for %%i in ("%WL_HOME%") do set WL_HOME=%%~fsi

set JAVA_VENDOR=Oracle
REM set JAVA_VENDOR=Sun
set BEA_JAVA_HOME=C:\Program Files\Java\jrockit-jdk1.6.0_31-R28.2.3-4.1.0
REM set BEA_JAVA_HOME=C:\Program Files\Java\jrmc-3.1.2-1.6.0
set SUN_JAVA_HOME=C:\Program Files\Java\jdk1.6.0_30
REM set SUN_JAVA_HOME=C:\Program Files\Java\jdk1.7.0_05
set OPUS_PROFILING=false
set YKIT_PROFILING=false


if "%JAVA_VENDOR%"=="Oracle" (
	set JAVA_HOME=%BEA_JAVA_HOME%
) else (
	if "%JAVA_VENDOR%"=="Sun" (
		set JAVA_HOME=%SUN_JAVA_HOME%
		set JAVA_VM=-server
	) else (
		set JAVA_VENDOR=Oracle
		set JAVA_HOME=%BEA_JAVA_HOME%
		set JAVA_VM=-jrockit
	)
)


@REM We need to reset the value of JAVA_HOME to get it shortened AND 
@REM we can not shorten it above because immediate variable expansion will blank it

set JAVA_HOME=%JAVA_HOME%
for %%i in ("%JAVA_HOME%") do set JAVA_HOME=%%~fsi

set SAMPLES_HOME=%WL_HOME%\samples

set DOMAIN_HOME=D:\scripts\domains\domainSample
for %%i in ("%DOMAIN_HOME%") do set DOMAIN_HOME=%%~fsi

set LONG_DOMAIN_HOME=D:\scripts\domains\domainSample

if "%DEBUG_PORT%"=="" (
	set DEBUG_PORT=8453
)

if "%SERVER_NAME%"=="" (
	set SERVER_NAME=adminCoherence
)

set DERBY_FLAG=false

set enableHotswapFlag=

set PRODUCTION_MODE=true

set doExitFlag=false
set verboseLoggingFlag=false
for %%p in (%*) do call :SET_PARAM %%p
GOTO :CMD_LINE_DONE
	:SET_PARAM
	for %%q in (%1) do set noQuotesParam=%%~q
	if /i "%noQuotesParam%" == "nodebug" (
		set debugFlag=false
		GOTO :EOF
	)
	if /i "%noQuotesParam%" == "production" (
		set DOMAIN_PRODUCTION_MODE=true
		GOTO :EOF
	)
	if /i "%noQuotesParam%" == "notestconsole" (
		set testConsoleFlag=false
		GOTO :EOF
	)
	if /i "%noQuotesParam%" == "noiterativedev" (
		set iterativeDevFlag=false
		GOTO :EOF
	)
	if /i "%noQuotesParam%" == "noLogErrorsToConsole" (
		set logErrorsToConsoleFlag=false
		GOTO :EOF
	)
	if /i "%noQuotesParam%" == "noderby" (
		set DERBY_FLAG=false
		GOTO :EOF
	)
	if /i "%noQuotesParam%" == "doExit" (
		set doExitFlag=true
		GOTO :EOF
	)
	if /i "%noQuotesParam%" == "noExit" (
		set doExitFlag=false
		GOTO :EOF
	)
	if /i "%noQuotesParam%" == "verbose" (
		set verboseLoggingFlag=true
		GOTO :EOF
	)
	if /i "%noQuotesParam%" == "enableHotswap" (
		set enableHotswapFlag=-javaagent:%WL_HOME%\server\lib\diagnostics-agent.jar
		GOTO :EOF
	) else (
		set PROXY_SETTINGS=%PROXY_SETTINGS% %1
	)
	GOTO :EOF
:CMD_LINE_DONE


set MEM_DEV_ARGS=

if "%DOMAIN_PRODUCTION_MODE%"=="true" (
	set PRODUCTION_MODE=%DOMAIN_PRODUCTION_MODE%
)

if "%PRODUCTION_MODE%"=="true" (
	set debugFlag=false
	set testConsoleFlag=false
	set iterativeDevFlag=false
	set logErrorsToConsoleFlag=false
)

call "%WL_HOME%\common\bin\commEnv.cmd"

set WLS_HOME=%WL_HOME%\server

if "%JAVA_VENDOR%"=="Sun" (
	set WLS_MEM_ARGS_64BIT=-Xms256m -Xmx512m
	set WLS_MEM_ARGS_32BIT=-Xms256m -Xmx512m
) else (
	set WLS_MEM_ARGS_64BIT=-Xms512m -Xmx512m
	set WLS_MEM_ARGS_32BIT=-Xms512m -Xmx512m
)

set MEM_ARGS_64BIT=%WLS_MEM_ARGS_64BIT%

set MEM_ARGS_32BIT=%WLS_MEM_ARGS_32BIT%

if "%JAVA_USE_64BIT%"=="true" (
	set MEM_ARGS=%MEM_ARGS_64BIT%
) else (
	set MEM_ARGS=%MEM_ARGS_32BIT%
)

set MEM_PERM_SIZE_64BIT=-XX:PermSize=128m

set MEM_PERM_SIZE_32BIT=-XX:PermSize=48m

if "%JAVA_USE_64BIT%"=="true" (
	set MEM_PERM_SIZE=%MEM_PERM_SIZE_64BIT%
) else (
	set MEM_PERM_SIZE=%MEM_PERM_SIZE_32BIT%
)

set MEM_MAX_PERM_SIZE_64BIT=-XX:MaxPermSize=256m

set MEM_MAX_PERM_SIZE_32BIT=-XX:MaxPermSize=128m

if "%JAVA_USE_64BIT%"=="true" (
	set MEM_MAX_PERM_SIZE=%MEM_MAX_PERM_SIZE_64BIT%
) else (
	set MEM_MAX_PERM_SIZE=%MEM_MAX_PERM_SIZE_32BIT%
)

if "%JAVA_VENDOR%"=="Sun" (
	if "%PRODUCTION_MODE%"=="" (
		set MEM_DEV_ARGS=-XX:CompileThreshold=8000 %MEM_PERM_SIZE% 
	)
)

@REM Had to have a separate test here BECAUSE of immediate variable expansion on windows

if "%JAVA_VENDOR%"=="Sun" (
	set MEM_ARGS=%MEM_ARGS% %MEM_DEV_ARGS% %MEM_MAX_PERM_SIZE%
)

set JAVA_PROPERTIES=-Dplatform.home=%WL_HOME% -Dwls.home=%WLS_HOME% -Dweblogic.home=%WLS_HOME% 

set JAVA_PROPERTIES=%JAVA_PROPERTIES% %EXTRA_JAVA_PROPERTIES%

set ARDIR=%WL_HOME%\server\lib

pushd %LONG_DOMAIN_HOME%

@REM Clustering support (edit for your cluster!)

if "%ADMIN_URL%"=="" (
	@REM The then part of this block is telling us we are either starting an admin server OR we are non-clustered
	set CLUSTER_PROPERTIES=-Dweblogic.management.discover=true
) else (
	set CLUSTER_PROPERTIES=-Dweblogic.management.discover=false -Dweblogic.management.server=%ADMIN_URL%
)

if NOT "%LOG4J_CONFIG_FILE%"=="" (
	set JAVA_PROPERTIES=%JAVA_PROPERTIES% -Dlog4j.configuration=file:%LOG4J_CONFIG_FILE%
)

set JAVA_PROPERTIES=%JAVA_PROPERTIES% %CLUSTER_PROPERTIES%

set JAVA_DEBUG=

if "%debugFlag%"=="true" (
	set JAVA_DEBUG=-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,address=%DEBUG_PORT%,server=y,suspend=n -Djava.compiler=NONE
	set JAVA_OPTIONS=%JAVA_OPTIONS% %enableHotswapFlag% -ea -da:com.bea... -da:javelin... -da:weblogic... -ea:com.bea.wli... -ea:com.bea.broker... -ea:com.bea.sbconsole...
) else (
	set JAVA_OPTIONS=%JAVA_OPTIONS% %enableHotswapFlag% -da
)

if NOT exist %JAVA_HOME%\lib (
	echo The JRE was not found in directory %JAVA_HOME%. ^(JAVA_HOME^)
	echo Please edit your environment and set the JAVA_HOME
	echo variable to point to the root directory of your Java installation.
	popd
	pause
	GOTO :EOF
)

if NOT "%ARDIR%"=="" (
	if NOT "%POST_CLASSPATH%"=="" (
		set POST_CLASSPATH=%POST_CLASSPATH%;%ARDIR%\xqrl.jar
	) else (
		set POST_CLASSPATH=%ARDIR%\xqrl.jar
	)
)

@REM PROFILING SUPPORT

set JAVA_PROFILE=

set SERVER_CLASS=weblogic.Server

set JAVA_PROPERTIES=%JAVA_PROPERTIES% %WLP_JAVA_PROPERTIES%

set JAVA_OPTIONS=%JAVA_OPTIONS% %JAVA_PROPERTIES% -Dwlw.iterativeDev=%iterativeDevFlag% -Dwlw.testConsole=%testConsoleFlag% -Dwlw.logErrorsToConsole=%logErrorsToConsoleFlag%

if "%PRODUCTION_MODE%"=="true" (
	set JAVA_OPTIONS= -Dweblogic.ProductionModeEnabled=true %JAVA_OPTIONS%
)

@REM -- Setup properties so that we can save stdout and stderr to files

if NOT "%WLS_STDOUT_LOG%"=="" (
	echo Logging WLS stdout to %WLS_STDOUT_LOG%
	set JAVA_OPTIONS=%JAVA_OPTIONS% -Dweblogic.Stdout=%WLS_STDOUT_LOG%
)

if NOT "%WLS_STDERR_LOG%"=="" (
	echo Logging WLS stderr to %WLS_STDERR_LOG%
	set JAVA_OPTIONS=%JAVA_OPTIONS% -Dweblogic.Stderr=%WLS_STDERR_LOG%
)


@REM ADD EXTENSIONS TO CLASSPATHS

if NOT "%EXT_PRE_CLASSPATH%"=="" (
	if NOT "%PRE_CLASSPATH%"=="" (
		set PRE_CLASSPATH=%EXT_PRE_CLASSPATH%;%PRE_CLASSPATH%
	) else (
		set PRE_CLASSPATH=%EXT_PRE_CLASSPATH%
	)
)

if NOT "%EXT_POST_CLASSPATH%"=="" (
	if NOT "%POST_CLASSPATH%"=="" (
		set POST_CLASSPATH=%POST_CLASSPATH%;%EXT_POST_CLASSPATH%
	) else (
		set POST_CLASSPATH=%EXT_POST_CLASSPATH%
	)
)

if NOT "%WEBLOGIC_EXTENSION_DIRS%"=="" (
	set JAVA_OPTIONS=%JAVA_OPTIONS% -Dweblogic.ext.dirs=%WEBLOGIC_EXTENSION_DIRS%
)

if "%JAVA_VENDOR%"=="Sun" (
	REM set JAVA_OPTIONS=%JAVA_OPTIONS% -Xloggc:gc.log -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCApplicationConcurrentTime -XX:+PrintGC -XX:+PrintGCTimeStamps -XX:+PrintGCDetails -XX:+PrintHeapAtGC 
	REM set JAVA_OPTIONS=%JAVA_OPTIONS% -verbose:gc -XX:-UseConcMarkSweepGC -XX:-PrintGCTimeStamps -XX:-PrintGCDetails -Xloggc:gc.log -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCApplicationConcurrentTime  -XX:+PrintHeapAtGC 
	set JAVA_OPTIONS=%JAVA_OPTIONS% -XX:-PrintGCDetails -XX:-PrintGCTimeStamps -Xloggc:gc.log
	REM ACTIVATE ConcurrentMarkSweep
	REM set JAVA_VM=%JAVA_VM% -XX:-UseConcMarkSweepGC 
)
if "%JAVA_VENDOR%"=="Oracle" (
	set JAVA_OPTIONS=%JAVA_OPTIONS% -Xverbose:opt,memory,memdbg,gcpause -Xverboselog:gc.log
	REM ACTIVATE Concurrent MarkSweep
	set MEM_ARGS=%MEM_ARGS% -Xns256m -XgcPrio:pausetime -XXkeepAreaRatio:20
)
REM OPUS agent
if "%OPUS_PROFILING%"=="true" (
	set OPUS=C:\Tools\Opus-1.0.13
	set JAVA_OPTIONS=%JAVA_OPTIONS% -javaagent:%OPUS%\opus-aj-javaagent.jar
)

REM YourKit agent
if "%YKIT_PROFILING%"=="true" (
	set YKIT="C:\Tools\YourKit Java Profiler\bin\win64"
	set JAVA_OPTIONS=%JAVA_OPTIONS% -agentpath:%YKIT%\yjpagent.dll=delay=10000,sessionname=Weblogic
)

@REM SET THE CLASSPATH

if NOT "%WLP_POST_CLASSPATH%"=="" (
	if NOT "%CLASSPATH%"=="" (
		set CLASSPATH=%WLP_POST_CLASSPATH%;%CLASSPATH%
	) else (
		set CLASSPATH=%WLP_POST_CLASSPATH%
	)
)

if NOT "%POST_CLASSPATH%"=="" (
	if NOT "%CLASSPATH%"=="" (
		set CLASSPATH=%POST_CLASSPATH%;%CLASSPATH%
	) else (
		set CLASSPATH=%POST_CLASSPATH%
	)
)

if NOT "%WEBLOGIC_CLASSPATH%"=="" (
	if NOT "%CLASSPATH%"=="" (
		set CLASSPATH=%WEBLOGIC_CLASSPATH%;%CLASSPATH%
	) else (
		set CLASSPATH=%WEBLOGIC_CLASSPATH%
	)
)

if NOT "%PRE_CLASSPATH%"=="" (
	set CLASSPATH=%PRE_CLASSPATH%;%CLASSPATH%
)

if NOT "%JAVA_VENDOR%"=="BEA" (
	set JAVA_VM=%JAVA_VM% %JAVA_DEBUG% %JAVA_PROFILE%
) else (
	set JAVA_VM=%JAVA_VM% %JAVA_DEBUG% %JAVA_PROFILE%
)

