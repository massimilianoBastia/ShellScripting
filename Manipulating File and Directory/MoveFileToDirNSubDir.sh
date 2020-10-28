#!/bin/bash 
$destinationfolder
$inputdate
$exitstatus
$findresult
$sourcefolderexamplefolder
$namenewfile
$foldertocheck
get_manual(){
FILENAME="copydirectorymanual.html"
cat > $FILENAME <<'EOF'
<html>
<head>
<title> Copy Directory Manual </title>
</head>
<body>
<strong> Copiare directory senza path di destinazione </strong>
<div>
 <strong> ./massimilianoBastia.sh -cd /home/nomeutente/cartelladacopiare 
  Copierà la directory nella stessa path dov'è collocata la cartella di origine </strong>
 <p> Aggiungedo il comando -ed dopo la directory la le sotto cartelle  saranno definite con la data del mese estesa 02=Febbraio </p>
 <p> Senza il comando -ed la data di default sarà in formato short per anno e mese </p>
   <p> Se esiste una cartella con lo stesso nome verrà aggiunto un _ID sequenziale di default<p>
</div> 
<strong> Copiare directory con path di destinazione </strong>
<div>
 <strong> ./massimilianoBastia.sh - cd /home/nomeutente/cartelladacopiare 
  /home/nomeutente/cartelladidestinazione 
  Copierà la directory nella directory specificata </strong>
 <p> Aggiungedo il comando -ed dopo la directory la le sotto cartelle  saranno definite con la data del mese estesa 02=Febbraio </p>
 <p> Senza il comando -ed la data di default sarà in formato short per anno e mese </p>
 <p> lo script non tiene conto dell'ordine di inserimento di -ed e della 
     path di destinazione<p>
     <p> Se esiste una cartella con lo stesso nome verrà aggiunto un _ID sequenziale di default<p>
</div>
<strong> Creazione cartella esempio per test </strong>
<div>
 <strong> ./massimilianoBastia.sh - cef /home/nomeutente/directory nomedeifile
 Creerà una cartella contenente dei file con nome indicato </strong>
 <p> la cartella si chiamerà con il nome definito più il default "cartella con"</p>
 <p> I file saranno creati sequenzialmente, due per anno e numerati da 1 a 20 </p>
 <p> Prima di inserire controllare che non esista già una cartella con lo stesso nome<p>
</div> 
</body>
</html>
EOF

firefox $FILENAME
}

create_example_directory(){
mkdir $sourcefolderexamplefolder/"cartellacon"$namenewfile
for i in {1..10}
do
   datelocalcreation="$i years ago"
   touch  $sourcefolderexamplefolder/"cartellacon"$namenewfile/$namenewfile$i -d   "$datelocalcreation"
   touch  $sourcefolderexamplefolder/"cartellacon"$namenewfile/$namenewfile$i"mar" -d   "$datelocalcreation -4 month"
done 
}
check_cli_arguments(){
for x in "${cli_arguments[@]}"; 
do
	if [[ $x == "-ed" ]]; then
	 inputdate="$x" 
	elif [[ $x == *\/* ]]; then
	 destinationfolder="$x"
	else
	 findresult=($(find / -type  d -name "$x"))
	fi
done
}

check_folder_sequence(){
  for x in $(ls ${foldertocheck%/*} | grep ${foldertocheck##*/}"_")
   do
    internalflag=${x##*_}
    if [[ $internalflag -eq $flagvalue ]]; then
       flagvalue=$((flagvalue+1))
   elif [[ $internalflag -gt $flagvalue ]]; then
       flagvalue=$((internalflag+1))
     fi  
  done 
}
create_subdirectory_nfile(){
for x in $(ls $sourcefolder)   
   do
    dateYearFile=$(date +%Y -r $sourcefolder/$x)
    dateMonthFile=$(date +"$dateformat" -r $sourcefolder/$x)
    newDirYearBased=$foldertocreate/$dateYearFile
    newDirMonthBased=$newDirYearBased/$dateMonthFile
    if [ ! -d "$newDirMonthBased" ];then
        mkdir -p $newDirMonthBased
        cp $sourcefolder/$x $newDirMonthBased
    elif [ -d "$newDirMonthBased" ] && [ ! -f "$newDirMonthBased $x" ];then
        cp $sourcefolder/$x $newDirMonthBased
    fi
   done
}

copy_folder(){
#########CONTROLLO DELL'ESISTENZA DI UNA PATH DI DESTINAZIONE#####
if [ -z $destinationfolder ];then 
######creazione di una cartella se esistente con lo stesso nome####
   foldertocheck=$sourcefolder
   flagvalue=1
   check_folder_sequence
#################################################################
   foldertocreate=$sourcefolder"_$flagvalue"
   mkdir $foldertocreate
   ####CREAZIONE DI CHILD FOLDER CON DATA ESTESA
   if [[ ! -z $inputdate ]]; then  
    dateformat='%B'
    create_subdirectory_nfile
#######################################################################
   else
######CREAZIONE DI CHILD FOLDER IN SHORT DATE############
   dateformat='%m'
   create_subdirectory_nfile
  fi
#######CREAZIONE DI CARTELLA CON PATH DI DESTINAZIONE SPECIFICATO########
else 
  ######CONTROLLO SE LA CARTELLA GIA' ESISTE CON LO STESSO NOME#####
 if  [[ -d $destinationfolder/${sourcefolder##*/} ]]; then
   foldertocheck=$destinationfolder/${sourcefolder##*/} 
   flagvalue=1 
   check_folder_sequence
   flagvalue=_$flagvalue
 fi
   foldertocreate=$destinationfolder/${sourcefolder##*/}$flagvalue 
   mkdir $foldertocreate
  if [[ ! -z $inputdate ]]; then   
      dateformat='%B'
      create_subdirectory_nfile
  else 
      dateformat='%m'
      create_subdirectory_nfile
   fi
 
fi
}
##MAIN
case $1 in
           -cd  | --copydirectory) 
          
		shift
		if [[ -d $1 ]]; then
		 sourcefolder=$1
		 shift
           	 cli_arguments=($@)
           	 check_cli_arguments
           	 for x in "${findresult[@]}";
           	 do
           	  echo "volevi inserire"$x "?" 
           	  read value
           	  if [[ $value == *Y* ]] || [[ $value == *y* ]]; then
           	    destinationfolder=$x
           	  break 
           	  fi
           	 done
                copy_folder
               else
               echo insert valid path
               fi
               ;;
                             
           -man | --man  ) get_manual
                             ;;
           -cef | --createexamplefolder ) 
            shift
            sourcefolderexamplefolder=$1
            shift
            namenewfile=$1
            create_example_directory
                             
esac
     
                
