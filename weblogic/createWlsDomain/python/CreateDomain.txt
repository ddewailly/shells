###########################################
# Creation d'un domaine weblogic Server
# Version : 1.0
###########################################
# Imports
import java.lang.String
import java.io.IOException
from javax.management import InstanceAlreadyExistsException
from javax.management import InstanceNotFoundException
from java.lang import Exception
from java.lang import Throwable
from java.lang import Integer
from java.util import Properties
from java.util import Enumeration
from java.io import File
from java.io import FileInputStream
from java.util.regex import Matcher
from java.util.regex import Pattern
	
def createDomain():  
    ### Lecture du template wls.jar
    print "Lecture du template ", fileTemplate
    readTemplate(fileTemplate)  
    #Chemin par defaut BEA_HOME+"/wlserver_10.3/common/templates/domains/wls.jar"
    ### Modification du nom de domaine
    print "Configuration du domaine."
    set ('Name',domainName)
    print "Serveur d'admin : " + adminServerName
    set('AdminServerName',adminServerName)

    ### Modification des proprietes du serveur d'Admin 
    print "Configuration du serveur d'administration."
    cd('/Servers/AdminServer')
    set ('Name',adminServerName)
    set('ListenAddress', adminServerAddress)  
    set('ListenPort', int(adminServerPort))  

    ### Creation du user Admin  
    print "Configuration de l'utilisateur " + adminUser + "." 
    cd('/Security/'+domainName+'/User')
    delete('weblogic','User')  
    create(adminUser,'User')  
    cd(adminUser)  
    set('Password',adminPassword)
    set('IsDefaultAdmin',1)  

    # Passage du production Mode à true
    cd('/')
    set('ProductionModeEnabled','true')
    ### Affichage de la synthese du domaine cree
    affichageSynthese()  

    ### Ecriture du Domaine  
    #setOption('OverwriteDomain', 'true')  
    print "Ecriture du domaine."
    writeDomain(domainRootDir+'/'+domainName)
    print "Fermeture du template."
    closeTemplate()

def lectureDomain():
    print "Lecture du domaine."
    readDomain(domainRootDir+'/'+domainName)

def ecritureDomain():
    print "Ecriture du domaine."
    updateDomain() 
    print "Fermeture du domaine."
    closeDomain()

def startAdminServer():
    startServer(adminServerName, domainName, 't3://'+adminServerAddress+':'+adminServerPort, adminUser, adminPassword, domainRootDir+'/'+domainName, jvmArgs='-XX:MaxPermSize=256m, -Xmx512m')

def adminConnection():
    connect(adminUser,adminPassword, 't3://'+adminServerAddress+':'+adminServerPort)
	
def parseMachine():
    keys = resources.get('Machines')
    if keys is None:
      print 'Aucune machine trouvée!'
      return None
    for name in keys.split(","):
        data = resources.get('Machine.'+name)
        token = data.split(",")
        listenAddress = token[0]
        listenPort = token[1]
        createMachine(name)
        createNodeManager(name, listenAddress, listenPort)
	
def createMachine(name):
    print 'Création de la Machine ' + name
    try:
      create(name,"Machine")
    except Exception:
      print "La machine "+name+" existe deja"

def createNodeManager(name, listenAddress, listenPort):
    print 'Création du NodeManager ' + name
    cd("Machines/"+name)
    try:
        create(name,"NodeManager")
    except Exception:
        print "Le node "+name+" existe deja"
    cd('NodeManager/'+name)
    cmo.setListenAddress(listenAddress)
    cmo.setListenPort(int(listenPort))
    cd("/")

def parseCluster():
    keys = resources.get('Clusters')
    if keys is None:
        print 'Aucun cluster trouvé!'
        return None
    for name in keys.split(","):
        data = resources.get('Cluster.'+name)
        token = data.split(',')
        clusterAddress = token[0]
        messagingMode = token[1]
        if messagingMode == 'MULTICAST': 
            mcastAddr = token[2]
            mcastPort = token[3]
        else : 
            multicastaddr = "none"
            multicastPort = "none"
        createCluster(name, clusterAddress,messagingMode,mcastAddr,mcastPort)

def createCluster(name, clusterAddress,messagingMode,mcastAddr,mcastPort):	
    print 'Création de Cluster ' + name
    cd("/")
    try:
        theBean = cmo.lookupCluster(name)
        if theBean == None:
            cmo.createCluster(name)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    cd("/Clusters/" + name)
    set("ClusterAddress", clusterAddress)
    set("WeblogicPluginEnabled", "true")
    if messagingMode == 'MULTICAST':
        set("ClusterMessagingMode", "multicast")
        set("MulticastAddress", mcastAddr)
        set("MulticastPort", mcastPort)
    else :
        set("ClusterMessagingMode", "unicast")
    print 'Cluster ' + name + ' cree avec succes'

def parseCoherenceCluster():
    keys = resources.get('CoherenceClusters')
    if keys is None:
        print 'Aucun cluster coherence trouvé !'
        return None
    for name in keys.split(","):
        data = resources.get('CoherenceCluster.'+name)
        token = data.split(",")
        listenAddress = token[0]
        listenPort = token[1]
        mCastAddr = token[2]
        mCastPort = token[3]
        target = token[4]
        createCoherenceCluster(name,listenAddress,listenPort,mCastAddr,mCastPort, target)
	
def createCoherenceCluster(clusterName,listenAddr,listenPort,mCastAddr,mCastPort, target):
    cd("/")
    try:
        print 'Creation du cluster coherence '+clusterName
        theBean = cmo.lookupCoherenceClusterSystemResource(clusterName)
        if theBean == None:
            cmo.createCoherenceClusterSystemResource(clusterName)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    cd("/CoherenceClusterSystemResources/" + clusterName)
    print "Mise à jour des paramètres : port, hostname,..."
    cd('Resource/'+ clusterName+'/CoherenceClusterParams/'+ clusterName)
    cmo.setUnicastListenAddress(listenAddr)
    cmo.setUnicastListenPort(int(listenPort))
    cmo.setMulticastListenAddress(mCastAddr)
    cmo.setMulticastListenPort(int(mCastPort))
    cd("/CoherenceClusterSystemResources/" + clusterName)
    bean = getMBean("/Clusters/" + target)
    cmo.addTarget(bean)
    print clusterName+' coherence cree avec succes'

def parseServer():
    keys = resources.get('Servers')
    if keys is None:
        print 'Aucun serveur trouvé !'
        return None
    for name in keys.split(","):
        data = resources.get('Server.'+name)
        token = data.split(",")
        listenAddress = token[0]
        listenPort = token[1]
        arguments = token[2]
        classPath = token[3]
        cluster = token[4]
        machine = token[5]
        createServer(name,listenAddress,listenPort,cluster, machine)
	
def createServer(serverName,serverAddr,serverPort,cluster, machine):
    cd("/")
    try:
        print 'Creation du serveur manage '+serverName
        theBean = cmo.lookupServer(serverName)
        if theBean == None:
            cmo.createServer(serverName)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    cd("/Servers/" + serverName)
    print "Mise à jour des paramètres : port, hostname,..."
    cmo.setListenAddress(serverAddr)
    cmo.setListenPort(int(serverPort))	
    if cluster != "" :
        bean = getMBean("/Clusters/" + cluster)
        cmo.setCluster(bean)
    if machine != "" : 
        machbean = getMBean("/Machines/" + machine)
        cmo.setMachine(machbean)	
    print serverName+' cree avec succes'

def parseCoherenceServer():
    keys = resources.get('CoherenceServers')
    if keys is None:
        print 'Aucun serveur coherence trouvé !'
        return None
    for name in keys.split(","):
        data = resources.get('CoherenceServer.'+name)
        token = data.split(",")
        listenAddress = token[0]
        listenPort = token[1]
        cluster = token[2]
        machine = token[3]
        createCoherenceServer(name,listenAddress,listenPort,cluster,machine)
	
def createCoherenceServer(serverName,serverAddr,serverPort,cluster,machine):
    cd("/")
    try:
        print 'Creation du serveur coherence '+serverName
        theBean = cmo.lookupCoherenceServer(serverName)
        if theBean == None:
            cmo.createCoherenceServer(serverName)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    cd("/CoherenceServers/" + serverName)
    print "Mise à jour des paramètres : port, hostname,..."
    cmo.setUnicastListenAddress(serverAddr)
    cmo.setUnicastListenPort(int(serverPort))	
    if machine != "" :
        machbean = getMBean("/Machines/" + machine)
        cmo.setMachine(machbean)
    if cluster != "" :
        bean = getMBean("/CoherenceClusterSystemResources/" + cluster)
        cmo.setCoherenceClusterSystemResource(bean)	
    print serverName+' coherence cree avec succes'

def parseDataSource():
    keys = resources.get('DataSources')
    print keys
    if keys is None:
        print 'Aucune datasource trouvée !'
        return None
    for name in keys.split(","):
        data = resources.get('DataSource.'+name)
        token = data.split(",")
        reserveTimeoutSeconds = token[0]
        initialCapacity = token[1]
        maxCapacity = token[2]
        capacityIncrement = token[3]
        testTblName = token[4]
        TestCnxOnReserve = token[5]
        CnxCreationRFS = token[6]
        jndiNames = token[7] 
        targets = token[8]
        driver = token[9]
        url = token[10]
        user = token[11]
        passwd = token[12]
        createDataSource(name,reserveTimeoutSeconds,initialCapacity,maxCapacity,capacityIncrement,testTblName,TestCnxOnReserve,CnxCreationRFS,jndiNames,targets,driver,url,user,passwd)
	
def createDataSource(dsName,reserveTimeoutSeconds,initialCapacity,maxCapacity,capacityIncrement,testTblName,TestCnxOnReserve,CnxCreationRFS,jndiNames,targets,driver,url,user,passwd):
    ### Création des datasources
    cd('/')
    try:
        theBean = cmo.lookupJDBCSystemResource(dsName)
        if theBean == None:
            print 'Creation de '+dsName
            cmo.createJDBCSystemResource(dsName)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        print 'La datasource '+dsName+' existe deja'
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    # Ajout du nom de la DS
    cd("/JDBCSystemResources/"+dsName+"/JDBCResource/" + dsName)
    set("Name", dsName)
    # declaration du nom JNDI du pool
    print "Ajout des noms JNDI '" + jndiNames + "' pour la DS '" + dsName + "'."
    cd("/JDBCSystemResources/"+dsName+"/JDBCResource/"+dsName+"/JDBCDataSourceParams/"+dsName)
    for jndiName in jndiNames.split(';'):
            cmo.addJNDIName(jndiName)

    # definition des parametres de connexion
    create_Property("/JDBCSystemResources/"+dsName+"/JDBCResource/"+dsName+"/JDBCDriverParams/"+dsName+"/Properties/"+dsName, "user")
    cd("/JDBCSystemResources/"+dsName+"/JDBCResource/"+dsName+"/JDBCDriverParams/"+dsName)
    set("Url", url)
    set("DriverName", driver)
    cd("/JDBCSystemResources/"+dsName+"/JDBCResource/"+dsName+"/JDBCDriverParams/"+dsName+"/Properties/"+dsName+"/Properties/user")
    set("Name", "user")
    set("Value", user)
    cd("/JDBCSystemResources/"+dsName+"/JDBCResource/"+dsName+"/JDBCDriverParams/"+dsName)
    set("Password", passwd)

    # definition des proprietes dites standard du datasource
    cd("/JDBCSystemResources/"+dsName+"/JDBCResource/"+dsName+"/JDBCConnectionPoolParams/"+dsName)
    set("InitialCapacity", int(initialCapacity))
    set("CapacityIncrement",int(capacityIncrement))
    set("MaxCapacity", int(maxCapacity))
    set("ConnectionReserveTimeoutSeconds",int(reserveTimeoutSeconds))
    set("TestTableName", testTblName)
    set("TestConnectionsOnReserve", TestCnxOnReserve)
    set("ConnectionCreationRetryFrequencySeconds",int(CnxCreationRFS))

    # Target du pool sur le cluster correspondant
    result = (getMBean("/JDBCSystemResources/" + dsName))
    for targetName in targets.split(";"):
        aTarget = java.lang.String(targetName)
        if targetName.find('Cluster') > 1:
            print 'Target de la DS ' + dsName + ' sur le cluster ' + targetName + '.'
            result.addTarget((getMBean("/Clusters/" + targetName)))
        else:
            print 'Target de la DS ' + dsName + ' sur ' + targetName + '.'
            result.addTarget((getMBean("/Servers/" + targetName)))
    print "la Datasource "+dsName+" a ete cree avec sucess"

def create_Property(path, beanName):
    cd(path)
    try:
        print "creation propriété '" + beanName + "'..."
        theBean = cmo.lookupProperty(beanName)
        if theBean == None:
            cmo.createProperty(beanName)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    except TypeError:
        prop = cmo.createProperty()
        prop.setName(beanName)
	  
def chargementConf(filename):
    f = File("%s" % filename)
    props = Properties()

    if f.exists() == 1:
        print 'Chargement de la configuration depuis ' + filename
        fis = FileInputStream( f )
        props.load( fis )
    else:
        print 'Impossible de charger le fichier de configuration ' + filename
    return props

def parseJMSServer():
    keys = resources.get('JMSServers')
    if keys is None:
        print 'Aucun server trouvé!'
        return None
    for name in keys.split(","):
        data = resources.get('JMSServer.'+name)
        token = data.split(",")
        StoreEnabled = token[0]
        Target = token[1]
        createJMSServer(name,StoreEnabled,Target)
		
def createJMSServer(name, storeenabled,target):
    print 'Création du serveur JMS ' + name
    cd("/")
    try:
        print "creation mbean de type JMSServer ... "
        theBean = cmo.lookupJMSServer(name)
        if theBean == None:
            cmo.createJMSServer(name)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    cd("/JMSServers/" + name)
    set("StoreEnabled", storeenabled)
    set('AllowsPersistentDowngrade','true')
    aTarget = java.lang.String(target)
    if aTarget.length() != 0:
        # Le serveur JMS doit être targetté
        print "Target du serveur JMS '" + name + "' sur '" + target + "'."
        refBean0 = getMBean("/Servers/" + target)
        theValue = jarray.array([refBean0], Class.forName("weblogic.management.configuration.TargetMBean"))
        cd("/JMSServers/" + name)
        cmo.setTargets(theValue)

def parseJMSModule():
    keys = resources.get('JMSModules')
    if keys is None:
      print 'Aucun module trouvé!'
      return None
    for name in keys.split(","):
      data = resources.get('JMSModule.'+name)
      token = data.split(",")
      Target = token[0]
      Subs = token[1]
      createJMSModule(name,Target,Subs)

def createJMSModule(name,target,subs):
    print 'Création du module JMS ' + name
    cd("/")
    try:
        theBean = cmo.lookupJMSSystemResource(name)
        if theBean == None:
            cmo.createJMSSystemResource(name)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    cd("/JMSSystemResources/" + name)
    refBean0 = getMBean("/Clusters/" + target)
    theValue = jarray.array([refBean0], Class.forName("weblogic.management.configuration.TargetMBean"))
    cmo.setTargets(theValue)
    for sub in subs.split(";"):
        token = sub.split(":")
        Subname = token[0]
        JMSServer = token[1]
        createSubDeployment("/JMSSystemResources/"+name, Subname)
        cd("/JMSSystemResources/"+name+"/SubDeployments/"+Subname)
        print 'SubDeployment ' + Subname + ', targetté sur le serveur JMS ' + JMSServer + '.'
        refBean0 = getMBean("/JMSServers/"+JMSServer)
        #theValue = jarray.array([refBean0], Class.forName("weblogic.management.configuration.TargetMBean"))
        #cmo.addTarget(theValue)
        cmo.addTarget(refBean0)
	
def createSubDeployment(path, beanName):
    cd(path)
    try:
        theBean = cmo.lookupSubDeployment(beanName)
        if theBean == None:
            cmo.createSubDeployment(beanName)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass

def parseCnxFactory():
    keys = resources.get('CnxFactories')
    if keys is None:
      print 'Aucune connection factory trouvée !'
      return None
    for name in keys.split(","):
      data = resources.get('CnxFactory.'+name)
      token = data.split(",")
      jndiName = token[0]
      module = token[1]
      createCnxFactory(name,jndiName,module)

def createCnxFactory(name,jndiName,module):
    print 'Création de la connection Factory ' + name
    try:
      cd('/JMSSystemResources/'+ module + '/JMSResource/'+ module)
      cmo.createConnectionFactory(name)
    except Exception:
      print 'Erreur lors de la création de la connection Factory : ' + name
    cd('/JMSSystemResources/'+ module + '/JMSResource/'+ module+ '/ConnectionFactories/'+ name)
    cmo.setJNDIName(jndiName)
    cmo.setDefaultTargetingEnabled(true)
       
def parseJMSDestination():
    keys = resources.get('JMSDestinations')
    if keys is None:
      print 'Aucune destination JMS trouvée !'
    return None
    for name in keys.split(","):
        data = resources.get('JMSDestination.'+name)
        token = data.split(",")
        jndiName = token[0]
        type = token[1]
        module = token[2]
        #subs = token[3]
        if type == 'Queue'  : 
            tDeliver = token[3]
            lDeliver = token[4]
        else : 
            tDeliver = 'none'
            lDeliver = 'none'
        createJMSDestination(name,jndiName,type,module,tDeliver,lDeliver)

def createJMSDestination(name,jndiName,type,module):
    print 'Création de la destination JMS ' + name + 'de type' + type
    try:
      cd('/JMSSystemResources/' + module + '/JMSResource/'+ module)
      if type == 'Queue'  : 
        cmo.createUniformDistributedQueue(name)
        cd('/JMSSystemResources/' + module + '/JMSResource/'+ module + '/UniformDistributedQueues/' + name)
        cmo.setJNDIName(jndiName)
        cmo.setDefaultTargetingEnabled(true)
        #cmo.setSubDeploymentName(subs)
        if tDeliver != '' : 
            cd('/JMSSystemResources/' + module + '/JMSResource/'+ module + '/UniformDistributedQueues/' + name+ '/DeliveryParamsOverrides/' + name)
            cmo.set('TimeToDeliver',tDeliver)
        if lDeliver != '' : 
            cd('/JMSSystemResources/' + module + '/JMSResource/'+ module + '/UniformDistributedQueues/' + name+ '/DeliveryFailureParams/' + name)
            cmo.set('RedeliveryLimit', lDeliver)
      elif type == 'Topic'  : 
        cmo.createUniformDistributedTopic(name)
        cd('/JMSSystemResources/' + module + '/JMSResource/'+ module + '/UniformDistributedTopics/' + name)
        cmo.setJNDIName(jndiName)
        cmo.setDefaultTargetingEnabled(true)
      else : 
        print 'Type de destination JMS inconnu' 
    except Exception:
      print "Erreur lors de la création de la destination JMS" + name
      
def parseFileStore():
    keys = resources.get('FileStores')
    if keys is None:
        return None
    for name in keys.split(","):
        print 'Le File Store ' + name + ' doit être crée...'
        data = resources.get('FileStore.'+name)
        token = data.split(",")
        Directory = token[0]
        Target = token[1]
        createFileStore(name,Directory,Target)

def createFileStore(name, Directory, targets):
    cd("/")
    try:
        theBean = cmo.lookupFileStore(name)
        if theBean == None:
            cmo.createFileStore(name)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    cd("/FileStores/"+ name)
    set("Directory", Directory)
    result = (getMBean("/FileStores/" + name))
    for target in targets.split(';'):
        print "Target " + target + " sur " + name + "."
        result.addTarget((getMBean("/Servers/" + target)))
		
def parseJDBCStore():
    keys = resources.get('JDBCStores')
    if keys is None:
        return None
    for name in keys.split(","):
        print 'Le JDBC Store ' + name + ' doit être crée...'
        data = resources.get('JDBCStore.'+name)
        token = data.split(",")
        DS = token[0]
        Target = token[1]
        createJDBCStore(name,DS,Target)

def createJDBCStore(name, Datasource, targets):
    cd("/")
    try:
        theBean = cmo.lookupJDBCStore(name)
        if theBean == None:
            cmo.createJDBCStore(name)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    cd("/JDBCStores/" + name)
    print "Passage des attributs pour le JDBCStore " + name
    result = (getMBean("/JDBCStores/" + name))
    for target in targets.split(';'):
        print "Target " + target + " sur " + name + "."
        result.addTarget((getMBean("/Servers/" + target)))
    bean = getMBean("/JDBCSystemResources/" + Datasource)
    cmo.setDataSource(bean)
		
def parseApp():
    keys = resources.get('Applications')
    print keys
    if keys is None:
        print 'Aucune application trouvée !'
        return None
    for name in keys.split(","):
        data = resources.get('Application.'+name)
        token = data.split(",")
        appPath = token[0]
        stagingMode = token[1]
        appTarget = token[2]
        deployApp(name,appPath,stagingMode,appTarget)
		
def deployApp(appName,appPath,stagingMode,appTarget):
    try:
      print "Démarrage du deploiement de " + appName + ", depuis l'emplacement " + appPath + ", targetté sur " + appTarget + " en cours..."
      lstTargets=""
      bTrouve=0
      for target in appTarget.split(';'):
        print "Target " + target + " sur " + name + "."
        if bTrouve == 1 :
          lstTargets= lstTargets + ","
          lstTargets= lstTargets+ target
          lstTargets= lstTargets+ target
        bTrouve=1
      deploy(appName,appPath,lstTargets,stagingMode,securityModel="DDOnly",block="true",timeout=0)
    except:
        print "Déploiement impossible de " + appName + "."

def parseLib():
    keys = resources.get('Libraries')
    print keys
    if keys is None:
        print 'Aucune librairie trouvée !'
        return None
    for name in keys.split(","):
        data = resources.get('Library.'+name)
        token = data.split(",")
        appPath = token[0]
        stagingMode = token[1]
        appTarget = token[2]
        deployLib(name,appPath,stagingMode,appTarget)
		
def deployLib(appName,appPath,stagingMode,appTarget):
    try:
      print "Démarrage du deploiement de " + appName + ", depuis l'emplacement " + appPath + ", targetté sur " + appTarget + " en cours..."
      lstTargets=""
      bTrouve=0
      for target in appTarget.split(';'):
        print "Target " + target + " sur " + name + "."
        if bTrouve == 1 :
          lstTargets= lstTargets + ","
          lstTargets= lstTargets+ target
          lstTargets= lstTargets+ target
        bTrouve=1
      deploy(appName,appPath,lstTargets,stagingMode,securityModel="DDOnly",block="true",timeout=0, libraryModule="true")
    except:
        print "Déploiement impossible de " + appName + "."
	
def parseWorkManager():
    keys = resources.get('WorkManagers')
    print keys
    if keys is None:
        return None
    for name in keys.split(","):
        data = resources.get('WorkManager.'+name)
        token = data.split(",")
        target = token[0]
        createWorkManager(name,target)
	
def createWorkManager(wmName, targets):
    cd('/SelfTuning/'+domainName)
    try:
        theBean = cmo.lookupWorkManager(wmName)
        if theBean == None:
            cmo.createWorkManager(wmName)
    except java.lang.UnsupportedOperationException, usoe:
        pass
    except weblogic.descriptor.BeanAlreadyExistsException,bae:
        pass
    except java.lang.reflect.UndeclaredThrowableException,udt:
        pass
    result = (getMBean('/SelfTuning/'+domainName+'/WorkManagers/'+wmName))
    for targetName in targets.split(";"):
        aTarget = java.lang.String(targetName)
        if targetName.find('Cluster') > 1:
            print 'Target du WorkManager ' + wmName + ' sur le cluster ' + targetName + '.'
            result.addTarget((getMBean("/Clusters/" + targetName)))
        else:
            print 'Target du WorkManager' + wmName + ' sur ' + targetName + '.'
            result.addTarget((getMBean("/Servers/" + target)))
    print "le work Manager "+wmName+" a ete cree avec sucess"

def modifyJTA():
    print 'Modification du timeout JTA'
    cd('/JTA/' + domainName)
    set('TimeoutSeconds', 900) 

def modifyServer():
    print 'Modification de la configuration SSL pour NodeManager'
    cd('/')
    serverList=cmo.getServers
    for server in serverList :
        serverName = server.getName()
        # Modify SSL Configuration
        cd('/Servers/' + serverName + '/SSL/'+ serverName)
        cmo.setHostnameVerificationIgnored(true)
        cmo.setHostnameVerifier(None)
        cmo.setTwoWaySSLEnabled(false)
        cmo.setClientCertificateEnforced(false)  
        # Modify Weblogic Log File 
        cd('/Servers/' + serverName + '/Log/'+ serverName)
        cmo.setFileName('/WLS/LOG/' + serverName + '/' + serverName + '.log')
        # Modify HTTP Log File
        cd('/Servers/' + serverName + '/WebServer/'+ serverName + '/WebServerLog/' + serverName)
        cmo.setFileName('/WLS/LOG/' + serverName + '/access.log')
        cmo.setLoggingEnabled(false)
 
def parseUser():
    keys = resources.get('Users')
    print keys
    if keys is None:
        return None
    for name in keys.split(","):
        data = resources.get('User.'+name)
        token = data.split(",")
        password = token[0]
        libelle = token[1]
        groups = token[2]
        createUser(name,password, libelle)
        setUserToGroup(groups,name)
		
def createUser(userName,userPass,libelle) :
    cd('/SecurityConfiguration/' + domainName + '/Realms/myrealm/AuthenticationProviders/DefaultAuthenticator')
    Exist = cmo.userExists(userName)
    if Exist != 1 :
        cmo.createUser(userName,userPass,libelle)

def parseGroup():
    keys = resources.get('Groups')
    print keys
    if keys is None:
        return None
    for name in keys.split(","):
        data = resources.get('Group.'+name)
        token = data.split(",")
        libelle = token[0]
        createGroup(name, libelle)
		
def createGroup(GroupName,libelle) :
  cd('/SecurityConfiguration/' + domainName + '/Realms/myrealm/AuthenticationProviders/DefaultAuthenticator')
  Exist = cmo.groupExists(GroupName)
  if Exist != 1 :
    cmo.createGroup(GroupName,libelle)
	
def setUserToGroup(groupName, userName) :
  cd('/SecurityConfiguration/' + domainName + '/Realms/myrealm/AuthenticationProviders/DefaultAuthenticator')
  print "Add user %s to group %s" %(userName,groupName)
  cmo.addMemberToGroup(groupName,userName)

def parseRole():
  keys = resources.get('Roles')
  print keys
  if keys is None:
    return None
  for name in keys.split(","):
    data = resources.get('Role.'+name)
    token = data.split(",")
    condition = token[0]
    createRole(name, condition)
		
def createRole(roleName, roleCond) :
  cd('/SecurityConfiguration/' + domainName + '/Realms/myrealm/RoleMappers/XACMLRoleMapper')
  cmo.createRole("",roleName, roleCond)
	
def affichageSynthese():   
  print "-----------------------------------------------------------------"  
  print " Synthese du domaine cree "
  print "-----------------------------------------------------------------"  
  print "Nom du Domaine =			%s " % domainName  
  print "Path de configuration du Domaine =	%s " % domainRootDir
  print "User admin =				%s " % adminUser  
  print "Password du user admin =		%s " % adminPassword  
  print "Nom du serveur d'administration =	%s " % adminServerName
  print "Host du serveur d'administration =	%s " % adminServerAddress  
  print "Port du serveur d'administration =	%s " % adminServerPort  
  print "-----------------------------------------------------------------"  

### Main  
import sys  
import string
import os
import ConfigParser
global config
config = ConfigParser.ConfigParser()

### Lecture des arguments 
fileProperties = sys.argv[1]  

### Lecture du fichier de proprietes propre a l'application  
print('Lecture du fichier de proprietes : \"' + fileProperties + '\"' )  
try:  
	loadProperties(fileProperties)
	config.read(fileProperties)

except Exception, e:
	print "==> Erreur : " 
	print e  
	exit() 

if len(sys.argv[0]) == 2:
	fileTemplate = sys.argv[2] 
else:
	fileTemplate = template
	
if BEA_HOME=='':
	print "La variable d'environnement BEA_HOME doit etre renseignee pour que ce script fonctionne."
	exit()
	
### Creation du domaine
createDomain()  
### Demarrage du serveur d'admin, les autres actions s'effectue online
startAdminServer()
# Chargement du fichier de conf avant l'appel des methodes
resources = chargementConf(fileProperties)
# Connection au serveur d'admin
adminConnection()
# Passage en mode Edition
edit()
startEdit()
# Parsing et creation des ressources
parseMachine()
parseCluster()
parseServer()
parseDataSource()
parseFileStore()
parseJDBCStore()
parseJMSServer()
parseJMSModule()
parseWorkManager()
parseCoherenceCluster()
parseCoherenceServer()
parseCnxFactory()
parseJMSDestination()
parseApp()
parseLib()
modifyJTA()
modifyServer()
save()
activate()
domainConfig()
parseGroup()
parseUser()
parseRole()