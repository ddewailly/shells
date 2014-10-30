
# Software revision
VERSION = "1.0.3"

# Imports
import sys, getopt
from java.io import File
import java.lang.String as jls

# Python 2.4 will include booleans, but until then this is required
true = 1
false = 0

##########################################
##############   Fonction   ##############
##########################################

def usage():
  print """
  Usage:
      %s [options]
  Options:
      -h, --help             Affiche ce message
      -d, --dico <fichier>   Dictionnaire
      -s, --src <repertoire> Répertoire des templates (défaut = .)
      -r, --rec              Récursivité des répertoires
  Exemple:
      filter.py -d dico.properties -s /work/templates
  """ % sys.argv[0]
  sys.exit(-1)

def processFile(inputFile, outputFile):
  input = open(inputFile, 'r')
  output = open(outputFile, 'w')

  try:
    for line in input.readlines():
      # convert line (if necessary)
      if line.find('#') != 0 or line.find('=') > -1:
        response = jls(filter.replace(line))
      else:
        response = jls(line)
      # remove LineFeed
      newline = response.indexOf("\n");
      if newline > -1:
        response = response.substring(0, newline);
      # write the response
      print >> output, response
  finally:
    input.close()
    output.close()

def processDir(sourceDir):
  #print 'DEBUG: Traitement du répertoire "' + sourceDir + '" ...'
  for f in File(sourceDir).listFiles():
    #print 'DEBUG: ' + str(f)
    if recursive and f.isDirectory():
      processDir(str(f))
    if str(f).endswith('.modele'):
      print 'INFO: Traitement du fichier ' + str(f) + ' (' + str(f.length()) + ' bytes)'
      destFilename = jls(str(f))
      destFilename = destFilename.substring(0, destFilename.length()-7)
      processFile(str(f), destFilename)


##########################################
###############   Script   ###############
##########################################

### verification des arguments ###
shortargs = 'hd:s:r'
longargs = ['help', 'dico', 'src', 'rec']

### constantes globales
dictionnaryFile = ""
sourceDir = "."
recursive= false

try:
  opts, args = getopt.getopt(sys.argv[1:], shortargs, longargs)
except getopt.GetoptError, msg:
  print '  Erreur: ' + str(msg)
  usage()

for opt, val in opts:
  if opt in ('-h', '--help'):
    usage()
  elif opt in ('-s', '--src'):
    sourceDir = val
  elif opt in ('-d', '--dico'):
    dictionnaryFile = val
  elif opt in ('-r', '--rec'):
    recursive = true
if len(dictionnaryFile) == 0:
  print '  Erreur: pas de dictionnaire spécifié!'
  usage()

print 'Démarrage du script de filtering %s ...' % VERSION

# entry point
execfile("wlstFilter.py")
filter = wlstFilter(dictionnaryFile)
filter.processAntProperties()
print 'Contenu: ' + str(filter.getPropertyCount()) + ' jeton(s)'

# main loop 
print 'INFO: Lecture du répertoire "' + sourceDir + '" ...'
processDir(sourceDir)

print 'Terminé.'
