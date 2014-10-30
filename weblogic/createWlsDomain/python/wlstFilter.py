
# Imports
import java.lang.String
import java.io.IOException
from java.util import Enumeration
from java.util import Properties
from java.util.regex import Matcher
from java.util.regex import Pattern
from java.io import File
from java.io import FileInputStream

# Python 2.4 will include booleans, but until then this is required
true = 1
false = 0

##########################################
##############  Functions   ##############
##########################################

class wlstFilter:

  # Software revision
  VERSION = "1.0.4"

  def __init__(self, propertyFileName):
    print 'Librairie Filtering WLST %s chargée' % self.VERSION
    self.resources = self.loadProperties(propertyFileName)
    self.error = false
    #self.stringBuilderBugfix()

  def getPropertyCount(self):
    return self.resources.size()

  # workaround StringBuilder java 5 bug
  def stringBuilderBugfix(self):
    if java.lang.System.getProperty("java.version") >= "1.5":
      import org.python.core
      print 'INFO: patch Java5 pour StringBuilder...'
      for n,f in java.lang.AbstractStringBuilder.__dict__.items():
        x = org.python.core.PyReflectedFunction(n)
        for a in f.argslist:
          if a is None: continue
          m = java.lang.StringBuffer.getMethod(n,a.args)
          x.addMethod(m)
          java.lang.StringBuffer.__dict__[n] = x

  # dictionnary loading function
  def loadProperties(self, filename):
    f = File("%s" % filename)
    props = Properties()

    if f.exists():
      print 'Chargement de la configuration depuis ' + filename
      fis = FileInputStream( f )
      props.load( fis )
    else:
      print 'ERROR: Impossible de charger le fichier de configuration ' + filename
    return props

  ### add all "OSENV." properties like ANT does ###
  def addOSEnvProperties(self):
    try:
      if java.lang.System.getProperty("os.name") == 'Linux':
        command = 'sh -c set'
      else:
        command = 'cmd /c set'
      runtime = java.lang.Runtime.getRuntime()
      process = runtime.exec(command)
      input = process.getInputStream()
      reader = java.io.BufferedReader(java.io.InputStreamReader(input))
      try:
        line = reader.readLine()
        while (line is not None):
          param = java.lang.String(line)
          #print 'DEBUG: ' + str(param)
          pos = param.indexOf('=')
          if pos > 2:
            entry = param.substring(0, pos)
            value = param.substring(pos+1, param.length())
            self.resources.setProperty('OSENV.' + entry, value)
          line = reader.readLine()
      finally:
        reader.close()
    except java.lang.Throwable, th:
      tgt = th.toString()
      print 'WARNING: Problème lors de la lecture des variables d\'environnement cause: ' + tgt

  ### main search and replace in template ###
  def replace(self, inputStr):
    self.error = false
    # "$...$"
    patternStr = "@[^@]+@"
    # Compile regular expression
    pattern = Pattern.compile(patternStr)
    input = java.lang.String(inputStr)
    # Replace all occurrences of pattern in input
    matcher = pattern.matcher(input)
    sb = java.lang.StringBuffer()
    last = 0
    while matcher.find():
      fragment = java.lang.String(matcher.group())
      token = fragment.substring(1, fragment.length()-1)
      replacementStr = self.resources.get(token)
      if replacementStr is None:
        print 'WARNING: la macro ' + str(fragment) + ' n\'a pas de valeur!!!'
        self.error = true
      else:
        sb.append(input.substring(last, matcher.start()))
        sb.append(replacementStr)
        last = matcher.end()
    sb.append(input.substring(last, input.length()))
    return sb.toString()

  ### dictionnary ANT macro recursive replacement ###
  def resolveProperties(self, inputStr):
    # "${...}"
    patternStr = "\\$\\{[^\\{]+\\}"
    # Compile regular expression
    pattern = Pattern.compile(patternStr)
    input = java.lang.String(inputStr)

    # Replace all occurrences of pattern in input
    matcher = pattern.matcher(input)
    sb = java.lang.StringBuffer()
    last = 0
    while matcher.find():
      fragment = java.lang.String(matcher.group())
      token = fragment.substring(2, fragment.length()-1)
      replacementStr = self.resources.get(token)
      if replacementStr is None:
        print 'WARNING: la macro ' + str(fragment) + ' n\'a pas de valeur!!!'
        self.error = true
      else:
        sb.append(input.substring(last, matcher.start()))
        sb.append(replacementStr)
        last = matcher.end()
    sb.append(input.substring(last, input.length()))
    result = sb.toString()

    if pattern.matcher(java.lang.String(result)).find():
      result = self.resolveProperties(result)

    return result

  ### dictionnary ANT global replacement ###
  def processAntProperties(self):
    self.error = false

    # include OSENV properties
    self.addOSEnvProperties()

    # "${...}"
    patternStr = "\\$\\{[^\\{]+\\}"
    # Compile regular expression
    pattern = Pattern.compile(patternStr)

    # Get all property keys
    keys = self.resources.keys()
    while keys.hasMoreElements():
      key = keys.nextElement()
      inputStr = self.resources.get(key)
      input = java.lang.String(inputStr)
      sb = java.lang.StringBuffer()
      matcher = pattern.matcher(input)
      last = 0
      while matcher.find():
        fragment = java.lang.String(matcher.group())
        token = fragment.substring(2, fragment.length()-1)
        replacementStr = self.resources.get(token)
        if replacementStr is None:
          print 'WARNING: ' + key + '=' + str(fragment) + ' n\'a pas de valeur!!!'
          self.error = true
        else:
          sb.append(input.substring(last, matcher.start()))
          sb.append(self.resolveProperties(replacementStr))
          last = matcher.end()
      sb.append(input.substring(last, input.length()))
      # key value replacement
      self.resources.setProperty(key, sb.toString())

    return self.error

  def __del__(self):
    cd("/")
