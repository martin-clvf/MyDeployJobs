# Chemin vers le fichier contenant les chemins de destination
$cheminFichierBatDestinations = "C:\Users\Chrarles\Documents\proj\deployJobs\param\batDestinations.txt"
# Chemin vers le fichier contenant les chemins de destination
$cheminFichierEtlDestinations = "C:\Users\Chrarles\Documents\proj\deployJobs\param\etlDestinations.txt"
# Chemin vers 7-Zip (assurez-vous que 7z.exe est dans ce chemin)
$chemin7Zip = "C:\Users\Chrarles\Documents\proj\deployJobs\7-Zip\7z.exe"

# Vérifie si le fichier destinations existe
if ((Test-Path $cheminFichierBatDestinations) -and (Test-Path $cheminFichierEtlDestinations)) {
    # Récupère la liste des dossiers dans le répertoire source
    $folders = Get-ChildItem -Directory
    # Lire les chemins de destination depuis le fichier
    $batDestinations = Get-Content $cheminFichierBatDestinations
    $etlDestinations = Get-Content $cheminFichierEtlDestinations

    $i = 0
    $j = 0

    foreach ($Destination in $batDestinations) {
        # Vérification si le chemin existe
        if (!(Test-Path $destination)) {
            # Si le chemin n'existe pas, création du dossier
            New-Item -Path $destination -ItemType Directory -Force
            Write-Host "Le chemin $destination a été créé."
        } else {
            Write-Host "Le chemin $destination existe déjà."
        }
    }

    foreach ($Destination in $etlDestinations) {
        # Vérification si le chemin existe
        if (!(Test-Path $destination)) {
            # Si le chemin n'existe pas, création du dossier
            New-Item -Path $destination -ItemType Directory -Force
            Write-Host "Le chemin $destination a été créé."
        } else {
            Write-Host "Le chemin $destination existe déjà."
        }
    }

    # Parcourt chaque dossier
    foreach ($folder in $folders) {
        $batFolder = $folder.FullName + "\scripts\BAT\"
        $etlFolder = $folder.FullName + "\scripts\ETL\"
        # Récupère les fichiers du dossier actuel
        $batFiles = Get-ChildItem $batFolder -File
        $etlFiles = Get-ChildItem $etlFolder -File

        # Parcourt chaque fichier du dossier actuel et le copie vers le répertoire de destination
        foreach ($file in $batFiles) {
            $destinationFile = Join-Path -Path $batDestinations[$i] -ChildPath $file.Name
            Copy-Item -Path $file.FullName -Destination $destinationFile -Force
            Write-Host "Le fichier $($file.Name) a été copié vers $destinationFile"
            $i++
        }

        # Parcourt chaque fichier du dossier actuel et le copie vers le répertoire de destination
        foreach ($file in $etlFiles) {
            $destinationFile = Join-Path -Path $etlDestinations[$j] -ChildPath $file.Name
            Copy-Item -Path $file.FullName -Destination $destinationFile -Force
            Write-Host "Le fichier $($file.Name) a été copié vers $destinationFile"
            # Décompresser l'archive dans le dossier de destination avec 7-Zip
            $arguments = "x `"$destinationFile`" -o`"$destinationPath`" -y"
            Start-Process -FilePath $chemin7Zip -ArgumentList $arguments -Wait

            # Vérifier si la décompression s'est terminée avec succès
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Décompression terminée avec succès."

                # Supprimer l'archive après décompression
                Remove-Item -Path $destinationFile -Force
                Write-Host "L'archive a été supprimée."
            } else {
                Write-Host "Erreur lors de la décompression de l'archive."
            }
            $j++
        }
    }

    Write-Host "Déploiement terminé"
} else {
    Write-Host "Le répertoire source spécifié ou le fichier destination n'existe pas."
}
