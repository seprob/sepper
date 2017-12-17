#!/bin/bash

# Sprawdz czy uzytkownik jest rootem.

if [ $(id -u) -ne "0" ] # Jezeli nie jest zalogowany jako root.
then
   # Sprawdz czy nalezy do grupy "docker".

   if ! groups | grep &>/dev/null '\bdocker\b'; then
      echo "[!] Nie jestes rootem ani nie nalezysz do grupy docker!"

      exit 1 # Wyjscie z kodem bledu.
   fi
fi

# Usun nienazwane obrazy.

docker rmi $(docker images | grep "<none>" | awk '{print $3}') &> /dev/null

# Dla kazdego uruchomionego kontenera.

for container in `docker ps --format '{{.Image}}'` # Pobierz nazwy obrazow.
do
   echo "[*] URUCHOMIONY KONTENER: \"$container\""

   # Dla kazdego obrazu.

   for image in `docker images --format '{{.Repository}}:{{.Tag}}'`
   do
      echo "[*] Obraz: \"$image\""

      if [ "$image" == "$container" ]
      then
         echo "[*] Aktualny obraz PASUJE do uruchomionego kontenera! Zostawiam."
      else
         # Sprawdz czy obraz dotyczy tego samego kontenera.

         repository_container=`echo $container | sed 's/:.*//'`
         repository_image=`echo $image | sed 's/:.*//'`

         if [ "$repository_container" == "$repository_image" ]
         then
            echo "[*] Usuwam obraz \"$image\"."

            docker rmi "$image"
         fi
      fi
   done

   echo "" # Nowa linia.
done