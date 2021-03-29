#!/bin/bash

. utiles.sh

CONF=config.txt
assure_script "$CONF" "cp -f .config.txt config.txt"

echo On utilise le terminal $TERMINAL avec $TERMINAL $OPTION_TITRE titre $OPTION_EXEC commande
sed -i "s/TERMINAL=.*$/TERMINAL=$TERMINAL/g" $CONF

ORIGINE=$(dirname $(readlink -f $0))
DEPOT=${ORIGINE%/installation*}
echo $DEPOT
sed -i "s:DEPOT=.*$:DEPOT=$DEPOT:g" $CONF

if [ "$1" = "venv"  ] ; then
 
    echo "Installation avec virtualenv de l'apt de linux"
    grep venv activer &> /dev/null && echo "trouvé activer avec venv" || ( rm -f activer; echo "pas de activer avec venv" )
    sed -i "s/INSTALLATION=.*$/INSTALLATION=venv/g" $CONF
else
    if [ "$1" = "conda_env" ] ; then
	echo "Installation avec conda (comme à l'Insa)"
	
    else 
	echo "Installation avec conda (comme à l'Insa) par DEFAUT" 
    fi
    grep conda activer &> /dev/null && echo "trouvé activer avec conda" ||	( rm -f activer; echo "pas de activer avec conda" )
    
    sed -i "s/INSTALLATION=.*$/INSTALLATION=conda/g" $CONF
fi


. $CONF
echo "+ Installation à partir des fichiers de $DEPOT avec ${INSTALLATION}"

echo "+ Test de $INIT_ENV : ça peut êêetre long..." 

dans_terminal_si_marche_pas "script $INIT_ENV" "$INIT_ENV" ./install_${INSTALLATION}_env.sh || exit 1
dans_terminal_si_marche_pas "script $INIT" "$INIT" ./install_${INSTALLATION}_env.sh || exit 1



gerer_alias_bashrc ()
{
    echo -e "+  Mise à jour du .bashrc pour les alias goConda et goSignal"
    echo -n "    -effacement des traces existantes du bashrc "
    sed -i "s:alias goConda=.*$::g" ~/.bashrc && echo -ne $KISS || echo -e $MERDE
    sed -i "s:alias goSignal=.*$::g" ~/.bashrc && echo -ne $KISS || echo -e $MERDE
    sed -i 's:echo "===.*$::g' ~/.bashrc && echo -e $KISS || echo -e $MERDE

    echo -n "    -creation des alias "
#    echo 'alias goConda="echo \"Initialisation de conda peut prendre quelques secondes...\" && source $INIT && echo \"..je vous l''avais dit !\""'>>~/.bashrc && echo -ne $OK || echo -e $DEAD   
    echo "alias goSignal=$DEPOT/installation/goSignal.sh">>~/.bashrc && echo -e $KISS || echo -e $MERDE
    
}

gerer_alias_bashrc

echo "+ Ajout de quelques raccourcis  sur le bureau "
echo -n "  creation des icones cliquables "

sed -i "s:DEPOT=.*$:DEPOT=$DEPOT:g" goSignal.sh

./.fait_un_lanceur.sh goSignal.sh .no_brain.jpg &>/dev/null && echo -ne $KISS || echo -ne $MERDE
./.fait_un_lanceur.sh goSignalGeek.sh .geeke.png &>/dev/null && echo -e $KISS || echo -e $MERDE


copier_vers_bureau () {
    if [ -e "$1" ]; then
	cp -f "$DEPOT/installation/goSignal.sh.desktop" "$1/goSignal.desktop" && echo -ne $KISS || echo -e $MERDE
	cp -f "$DEPOT/installation/goSignalGeek.sh.desktop" "$1/goSignalGeeke.desktop"&& echo -ne $KISS || echo -e $DEAD
	ln -sf $DEPOT $1 && echo -ne $KISS || echo -e $DEAD
    else
	return 1
    fi
}

echo  -en "  copy des lanceurs sur le Bureau "
copier_vers_bureau "$HOME/Desktop" && echo " copié dans Desktop" 
copier_vers_bureau "$HOME/Bureau"  && echo " copié dans Bureau"

echo -en "\n Ajout dans la liste des applications "
mv "$DEPOT/installation/goSignal.sh.desktop" "$HOME/.local/share/applications/goSignal.desktop"&& echo -ne $KISS || echo -e $MERDE
mv "$DEPOT/installation/goSignalGeek.sh.desktop" "$HOME/.local/share/applications/goSignalGeeke.desktop"&& echo -e $KISS || echo -e $MERDE

rm -f *.log
source ~/.bashrc
echo -e $BIERE
/bin/bash
exit
