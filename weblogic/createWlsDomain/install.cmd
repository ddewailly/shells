REM Traitement du dictionnaire.
echo "Remplacement des parametres"
REM d:\Weblo10.3.5\wlserver_10.3\common\bin\wlst.cmd filter.py -d d:/scripts/coherence.dico -s d:/scripts
d:\Weblo10.3.5\wlserver_10.3\common\bin\wlst.cmd filter.py -d d:/scripts/sample.dico -s d:/scripts
REM Creation du domaine
echo "Creation du domaine"
REM d:\Weblo10.3.5\wlserver_10.3\common\bin\wlst.cmd CreateDomain.py d:/scripts/coherence.properties
d:\Weblo10.3.5\wlserver_10.3\common\bin\wlst.cmd CreateDomain.py d:/scripts/sample.properties