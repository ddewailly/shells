def usage():
  print "Syntaxe : controleWls.py fichier_proprietes commande"
  print "Exemple : controleWls.py odbipubDomain.properties startAdmin"
  exit()

def connectAdmin():
  print '---- connexion au serveur d admin ----'
  try:
    domainDir=domainRootDir+'/'+domainName
    #connect('weblogic','webl0gic','t3://localhost:11001')
    connect(userConfigFile=domainDir+'/'+ucf, userKeyFile=domainDir+'/'+ukf, url='t3://'+adminServerAddress+':'+adminServerPort)
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

def startAdmin():
  connectNode()
  print '---- demarrage du serveur d admin ----'
  try:
    domainDir=domainRootDir+'/'+domainName
    nmStart(adminServerName, domainDir)
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

def stopAdmin():
  connectAdmin()
  print '---- arret du serveur d admin ----'
  try:
    shutdown(adminServerName, "Server", force="true", block='0')
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

def startServer(serverName):
  connectNode()
  connectAdmin()
  print '---- demarrage du serveur '+serverName+'  ----'
  try:
    start(serverName, 'Server', block='false')
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

def stopServer(serverName):
  connectAdmin()
  print '---- arret du serveur '+serverName+' ----'
  try:
    shutdown(serverName, 'Server', force='true', block='0')
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

def startCluster(clusterName):
  connectNode()
  print '---- demarrage du cluster '+clusterName+'  ----'
  try:
    start(clusterName, 'Cluster', block='false')
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

def stopCluster(clusterName):
  connectAdmin()
  print '---- arret du cluster '+clusterName+' ----'
  try:
    shutdown(clusterName, 'Cluster', force='true', block='0')
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

def connectNode():
  print '---- connexion au node manager ----'
  try:
    domainDir=domainRootDir+'/'+domainName
    print domainRootDir
    print domainDir
    print nodeManagerHost
    print nodeManagerPort
    print domainName
    nmConnect(userConfigFile=domainDir+'/'+ucf, userKeyFile=domainDir+'/'+ukf,host=nodeManagerHost,port=nodeManagerPort,domainName=domainName,domainDir=domainDir)
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

def startNode():
  print '---- demarrage du node manager ----'
  try:
    startNodeManager(verbose='true', NodeManagerHome=nodeHome)
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

def stopNode() :
  connectNode()
  print '---- arret du node manager ----'
  try:
    stopNodeManager()
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

def serverStatus():
    connectAdmin()
    print '---- Affichage des status des serveurs ----'
    try:
        # Recupération de la liste des serveurs 
        domainConfig()
        cd('/')
        ServersList = cmo.getServers()
        # parcours de la liste pour récupérer l'état actuel
        domainRuntime()
        print "\n \n \nAffichage de l etat des serveurs "
        for server in ServersList : 
            cd('/')
            try : 
                cd('/ServerRuntimes/' + server.getName())
                state = cmo.getState()
                # Affichage de l'état
                print "Le serveur " + server.getName() + " est en état " + state
            except Exception, e : 
                print "Le serveur " + server.getName() + " est inactif ou dans un etat inconnu"
                pass
    except Exception, e:
        print "==> Erreur : "
        print e
        exit()
    
def chargementProperties(propFile):
  print('Lecture du fichier de proprietes : \"' + fileProperties + '\"' )
  try:
    loadProperties(propFile)
  except Exception, e:
    print "==> Erreur : "
    print e
    exit()

### Main
import sys
import string
import os
import ConfigParser

### Lecture des arguments

if len(sys.argv) < 2:
  usage()

fileProperties = sys.argv[1]
chargementProperties(fileProperties)

if sys.argv[1] == 'status' :
    serverStatus()
    exit()
    
elif sys.argv[2] == 'startNode' :
    startNode()

    
elif sys.argv[2] == 'stopNode' :
    stopNode()

elif sys.argv[2] == 'startAdmin' :
    startAdmin()

elif sys.argv[2] == 'stopAdmin' :
    stopAdmin()

elif sys.argv[2] == 'startServer' :
    serverName = sys.argv[3]
    startServer(serverName)

elif sys.argv[2] == 'stopServer' :
    serverName = sys.argv[3]
    stopServer(serverName)

elif sys.argv[2] == 'startCluster' :
    clusterName = sys.argv[3]
    startCluster(clusterName)

elif sys.argv[2] == 'stopCluster' :
    clusterName = sys.argv[3]
    stopCluster(clusterName)
  
else :
    usage()
